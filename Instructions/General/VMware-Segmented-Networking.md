# Milestone A: VMware Workstation Pro 17 segmented networking

This is the operational runbook for **Milestone A**. It defines the core local VMware network. Advanced procedures use the isolated [enterprise expansion profile](Environment-Profiles.md#profile-2-enterprise-expansion). These are **VMware VMnet segments**, not Azure virtual networks.

## Prerequisites and safety checkpoint

Use the supported host baseline: Windows 11, VMware Workstation Pro 17, Intel Core i7-14700KF, 32 GB RAM, and approximately 2 TB free storage. Close or suspend lab VMs before changing a VMnet. Export or record the current Virtual Network Editor settings and take the host configuration checkpoint `A-before-vmnet-changes` if you already have working networks.

This guide contains no network-mutating script. The Virtual Network Editor changes below are deliberate, confirmation-gated UI actions. Do not disable the physical Ethernet/Wi-Fi adapter. VMware host virtual adapters can be disabled or enabled in `ncpa.cpl`, but changing them affects host-to-guest connectivity and possibly host routes; record their prior state and change only the VMware adapter named for the lab segment.

## Target segments

| VMnet | Network | Host adapter | DHCP | Default gateway | Intended use |
| --- | --- | --- | --- | --- | --- |
| `VMnet10` | `10.10.10.0/24` | Enabled | Disabled | None | Management and AD/DNS |
| `VMnet20` | `10.10.20.0/24` | Enabled | Disabled | None | Server workloads |
| `VMnet30` | `10.10.30.0/24` | Enabled | Enabled, `10.10.30.100-199` | `10.10.30.1` only if using NAT | Windows 11 clients |
| `VMnet8` | VMware NAT | Existing VMware adapter | VMware-managed | VMware NAT gateway | Temporary updates and approved Internet access |

The address ranges are private examples dedicated to this lab. Do not bridge them to a home or corporate LAN. If they overlap with another local network, change the entire range and update the static addresses consistently.

## Create the VMnets in Virtual Network Editor

1. In VMware Workstation Pro 17, select **Edit > Virtual Network Editor**, then click **Change Settings** and approve the elevation prompt.
2. Select **Add Network**, choose `VMnet10`, and select **Host-only**. Set subnet IP to `10.10.10.0` and mask to `255.255.255.0`. Clear **Use local DHCP service to distribute IP addresses to VMs**. Leave **Connect a host virtual adapter to this network** enabled, then click **Apply**.
3. Add `VMnet20` as **Host-only**, subnet `10.10.20.0/24`, DHCP disabled, and a connected host adapter. Click **Apply**.
4. Add `VMnet30` as **Host-only**, subnet `10.10.30.0/24`, and choose one DHCP owner. For the initial client stage, VMware DHCP may use `10.10.30.100` through `10.10.30.199`. If a later practice installs Windows DHCP, disable VMware DHCP first and let Windows DHCP be the only DHCP server. Click **Apply**.
5. Select the existing `VMnet8` and confirm it is **NAT**. Record its displayed subnet and gateway in your private lab notes as `<VMNET8_SUBNET>` and `<VMNET8_GATEWAY>`; do not assume either value.
6. Confirm that no lab segment is set to **Bridged**. Bridging exposes lab traffic to the physical network and can create DHCP, DNS, or address conflicts.
7. Click **Apply** and **OK**. Open `ncpa.cpl` on the host and confirm the VMware adapters for VMnet10, VMnet20, and VMnet30 are present. Optional display names are `VMware VMnet10 Management`, `VMware VMnet20 Servers`, and `VMware VMnet30 Clients`.

Do not enable Internet Connection Sharing or Windows routing as a shortcut. VMware NAT is the only default outbound path in this design.

The host adapters are for host-to-guest management and testing. They are not Windows Server NICs and must not be configured as the AD DNS server or a router. If a host adapter is disabled, host access to that VMnet stops while guest-to-guest traffic may continue. Re-enable it from `ncpa.cpl` only when needed; never disable the physical host adapter.

## Addressing and routing decisions

Use this concrete default plan. Values marked as placeholders are host-specific and must be recorded before use:

| Role | Example address | NIC |
| --- | --- | --- |
| Host VMnet10 adapter | `<VMNET10_HOST_IP>/24` | Host only |
| Host VMnet20 adapter | `<VMNET20_HOST_IP>/24` | Host only |
| Host VMnet30 adapter | `<VMNET30_HOST_IP>/24` | Host only |
| `VN1-SRV1` AD DS/DNS | `10.10.10.10/24` | VMnet10 |
| `VN1-SRV5` additional DC/DNS | `10.10.10.11/24` | VMnet10 |
| `VN1-SRV4` management/WAC | `10.10.10.20/24` | VMnet10, optional VMnet20 |
| `CL1` Windows 11 management client | `10.10.30.20/24` or DHCP reservation | VMnet30 |
| Server workload pool | `10.10.20.50-199/24` | VMnet20 |
| Client static pool | `10.10.30.20-80/24` | VMnet30 |

Add the server, storage, cluster, and client VMs named by a lab only when needed. Use `10.10.20.0/24` for server workload traffic and `10.10.30.0/24` for clients. Keep the first NIC on VMnet10 for domain management unless a lab explicitly requires another design.

On isolated VMnet10 and VMnet20 NICs, leave **Default gateway** blank. On VMnet30, use no gateway for an isolated client or the documented `<VMNET30_GATEWAY>` only when a deliberate router/NAT design exists. Set the preferred DNS server to `10.10.10.10` on domain members, and add `10.10.10.11` only after the second DNS server is healthy. Do not point domain controllers or domain members directly to public DNS or the VMnet8 NAT DNS.

For Internet access, add a second NIC connected to `VMnet8` only to a VM that needs updates, downloads, Azure Arc, or another documented outbound operation. Keep the lab NIC as the primary/domain NIC and do not assign the VMnet8 DNS server to the AD NIC. Disconnect the NAT NIC after the operation. Do not enable Internet Connection Sharing, Windows NAT, or IP forwarding unless a specific routing lab requires it.

VMnet10, VMnet20, and VMnet30 do not route between one another by default. This isolation is intentional. A multi-homed Windows Server can route between them only when you deliberately enable and secure routing; avoid doing so for the foundation. If a lab requires cross-segment traffic, document the route and firewall rules before enabling it.

## Place VM NICs

For each VM, open **VM > Settings > Network Adapter**:

1. Select **Custom: Specific virtual network** and choose the required VMnet.
2. Use one NIC on VMnet10 for AD, DNS, management, and domain reachability.
3. Add a VMnet20 NIC for server, storage, cluster, or workload traffic only when the lab calls for it.
4. Add a VMnet30 NIC to `CL1`, `CL3`, and other client VMs.
5. Add VMnet8 temporarily for safe outbound access; select **Connect at power on** only when required.
6. Inside Windows, rename adapters to `LAB-AD`, `LAB-SRV`, `LAB-CLIENT`, or `NAT-OUTBOUND`. Confirm the intended interface with `Get-NetIPConfiguration` before assigning an address.

Never attach a lab VM directly to a bridged physical adapter unless the exercise explicitly requires it and the network owner has approved it.

## DNS and AD reachability

Build `VN1-SRV1` first with `10.10.10.10`, install AD DS and DNS, and create `ad.lab.test`. Configure its own DNS client to use its static address. Join `VN1-SRV4` and `CL1` only after:

```powershell
Get-NetIPConfiguration
Test-NetConnection 10.10.10.10 -Port 53
Resolve-DnsName ad.lab.test -Server 10.10.10.10
Test-Connection 10.10.10.10 -Count 2
```

After `VN1-SRV5` is promoted, validate both DNS servers and replication before using `10.10.10.11` as a secondary resolver:

```powershell
Resolve-DnsName _ldap._tcp.ad.lab.test -Type SRV -Server 10.10.10.10
Resolve-DnsName _ldap._tcp.ad.lab.test -Type SRV -Server 10.10.10.11
repadmin /replsummary
dcdiag /test:dns /v
```

If a client receives a public DNS server from DHCP, correct the DHCP option or assign the lab DNS server. A client that can browse the Internet but cannot resolve `ad.lab.test` is not ready to join the domain.

## Verification and troubleshooting

Take checkpoint `A-network-foundation` after the VMnets, host adapters, and address plan are stable, before creating templates or guests. The checkpoint is a record of the Virtual Network Editor state and host adapter state; it is not a backup of the physical host.

Run these read-only checks on the host and inside the affected VM:

```powershell
# Inside a VM: identify adapters, addresses, DNS, and routes
Get-NetAdapter
Get-NetIPConfiguration
Get-DnsClientServerAddress
Get-NetRoute -AddressFamily IPv4
Get-NetIPInterface -AddressFamily IPv4
Get-NetFirewallProfile
ipconfig /all

# Check local segment reachability and required ports
Test-Connection 10.10.10.10 -Count 2
Test-NetConnection 10.10.10.10 -Port 53
Test-NetConnection 10.10.10.10 -Port 389
Test-NetConnection 10.10.10.10 -Port 445
Resolve-DnsName VN1-SRV1.ad.lab.test
```

Use `ipconfig /all` when comparing DHCP leases, DNS suffixes, and gateways. Use `tracert 10.10.10.10` to detect an unexpected router, and `Get-NetFirewallProfile` to check whether a Windows firewall profile is blocking a test. On the host, use `Get-NetIPConfiguration` and `Get-NetAdapter` to confirm the VMware adapters are up.

Expected conditions before Milestone B:

* VMnet10, VMnet20, and VMnet30 are present as custom host-only networks with the planned subnets.
* VMware DHCP is disabled on VMnet10 and VMnet20, and exactly one DHCP owner is selected for VMnet30.
* Host VMware adapters are present and enabled; no physical adapter was disabled.
* No isolated NIC has an unintended default gateway.
* `VN1-SRV1` will use `10.10.10.10` and DNS on that address; no domain controller is dependent on VMnet8 NAT.

Common fixes:

* **No address:** check that the VM is connected to the intended Custom VMnet and that only one DHCP service is active.
* **Wrong gateway:** remove a gateway from isolated NICs; retain a gateway only on the approved NAT path.
* **Internet works but AD fails:** set the domain DNS server on the lab NIC; do not use the NAT DNS server for AD queries.
* **AD works but Internet fails:** connect VMnet8 temporarily, verify its VMware NAT gateway, and confirm that the lab NIC remains the preferred interface.
* **Cross-segment traffic fails:** this is expected until a lab explicitly provides routing and firewall rules.
* **Name resolves but ports fail:** check Windows Firewall, the service state, and whether the VM is on the correct VMnet.

## Rollback

1. Power off or suspend lab guests.
2. Reopen **Edit > Virtual Network Editor > Change Settings** and restore the recorded subnet, DHCP, NAT, and host-adapter settings from `A-before-vmnet-changes`.
3. In `ncpa.cpl`, re-enable only a VMware host adapter that was intentionally disabled. Do not disable or reset the physical Ethernet/Wi-Fi adapter.
4. If a guest has an incorrect address, disconnect its NIC before correcting the VMnet assignment. Do not use a broad host network reset.
5. Re-run the read-only checks above and preflight. If the host has lost connectivity, stop and restore the VMware settings with the host's normal physical adapter left enabled.

Cleanup after Milestone A is limited to removing unused VMnet definitions and temporary notes. Do not delete a VMnet still used by a snapshot or guest.

## VMware networks versus Azure VNets

VMnets are local virtual switches managed by VMware Workstation on the Windows 11 host. They have no Azure control-plane object, do not consume Azure quota, and do not incur Azure charges. Azure VNets are cloud resources with subnets, route tables, NSGs, private endpoints, service endpoints, and region-specific availability. Do not copy the VMnet names, routes, or addresses into Azure without checking for overlap and following the Azure lab's prerequisites.
