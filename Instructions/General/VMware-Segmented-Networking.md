# VMware Workstation Pro 17 segmented networking

This guide defines the local VMware network used by the self-learner edition. These are **VMware VMnet segments**, not Azure virtual networks. VMware segments connect the local Windows Server and Windows 10 VMs on the host; Azure VNets are separate cloud resources with their own subnets, routing, security rules, and billing.

## Target segments

| VMnet | Network | Host adapter | DHCP | Default gateway | Intended use |
| --- | --- | --- | --- | --- | --- |
| `VMnet10` | `10.10.10.0/24` | Enabled | Disabled | None | Management and AD/DNS |
| `VMnet20` | `10.10.20.0/24` | Enabled | Disabled | None | Server workloads |
| `VMnet30` | `10.10.30.0/24` | Enabled | Enabled, `10.10.30.100-199` | `10.10.30.1` only if using NAT | Windows 10 clients |
| `VMnet8` | VMware NAT | Existing VMware adapter | VMware-managed | VMware NAT gateway | Temporary updates and approved Internet access |

The address ranges are private examples dedicated to this lab. Do not bridge them to a home or corporate LAN. If they overlap with another local network, change the entire range and update the static addresses consistently.

## Create the VMnets

1. Close or suspend lab VMs. Do not change a VMnet while a production workload depends on it.
2. In VMware Workstation Pro 17, select **Edit > Virtual Network Editor** and click **Change Settings** to elevate.
3. Select **Add Network** and create `VMnet10`. Choose **Host-only**. Set subnet IP to `10.10.10.0` and mask to `255.255.255.0`. Clear **Use local DHCP service to distribute IP addresses to VMs**. Leave **Connect a host virtual adapter to this network** enabled. Apply the change.
4. Add `VMnet20` with the same settings, using subnet `10.10.20.0/24`, DHCP disabled, and a connected host adapter.
5. Add `VMnet30` with subnet `10.10.30.0/24`. Enable the VMware DHCP service only if this segment is not using the Windows DHCP lab. If enabled, use a range such as `10.10.30.100` through `10.10.30.199`. Do not run VMware DHCP and Windows DHCP on the same segment.
6. Leave `VMnet8` as VMware NAT for controlled outbound access. Record its current gateway from the Virtual Network Editor; do not assume it is `10.10.30.1`.
7. Do not use **Bridged** networking for the lab segments. Bridging exposes lab traffic to the physical network and can create DHCP or address conflicts.
8. Click **Apply** and **OK**. In Windows, open `ncpa.cpl` and confirm that the VMware host adapters for VMnet10, VMnet20, and VMnet30 are present. Rename them to `VMware VMnet10 Management`, `VMware VMnet20 Servers`, and `VMware VMnet30 Clients` if desired. Leave the host adapter IPv4 addresses at their VMware-assigned values; do not configure a default gateway on more than one host adapter.

The host adapters are for host-to-guest management and testing. They are not Windows Server NICs and must not be configured as the AD DNS server or a router.

## Addressing and routing decisions

Use static addresses for infrastructure and servers:

| Role | Example address | NIC |
| --- | --- | --- |
| `VN1-SRV1` AD DS/DNS | `10.10.10.10/24` | VMnet10 |
| `VN1-SRV5` additional DC/DNS | `10.10.10.11/24` | VMnet10 |
| `VN1-SRV4` management/WAC | `10.10.10.20/24` and optional VMnet20 NIC | VMnet10 first |
| `CL1` Windows 10 management client | DHCP or `10.10.30.20/24` | VMnet30 |

Add the server, storage, cluster, and client VMs named by a lab only when needed. Use `10.10.20.0/24` for server workload traffic and `10.10.30.0/24` for clients. Keep the first NIC on VMnet10 for domain management unless a lab explicitly requires another design.

On an isolated VMnet10 or VMnet20 NIC, leave **Default gateway** blank. Set the preferred DNS server to `10.10.10.10` on domain members, and add `10.10.10.11` only after the second DNS server is healthy. Do not point domain members directly to public DNS.

For Internet access, add a second NIC connected to `VMnet8` only to a VM that needs updates, downloads, Azure Arc, or another documented outbound operation. Keep the lab NIC as the primary/domain NIC. Do not enable Internet Connection Sharing, Windows NAT, or IP forwarding unless a specific routing lab requires it. Remove or disconnect the NAT NIC after the operation.

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

Run these checks on the host and inside the affected VM:

```powershell
# Inside a VM: identify adapters, addresses, DNS, and routes
Get-NetAdapter
Get-NetIPConfiguration
Get-DnsClientServerAddress
Get-NetRoute -AddressFamily IPv4

# Check local segment reachability and required ports
Test-Connection 10.10.10.10 -Count 2
Test-NetConnection 10.10.10.10 -Port 53
Test-NetConnection 10.10.10.10 -Port 389
Test-NetConnection 10.10.10.10 -Port 445
Resolve-DnsName VN1-SRV1.ad.lab.test
```

Use `ipconfig /all` when comparing DHCP leases, DNS suffixes, and gateways. Use `tracert 10.10.10.10` to detect an unexpected router, and `Get-NetFirewallProfile` to check whether a Windows firewall profile is blocking a test. On the host, use `Get-NetIPConfiguration` and `Get-NetAdapter` to confirm the VMware adapters are up.

Common fixes:

* **No address:** check that the VM is connected to the intended Custom VMnet and that only one DHCP service is active.
* **Wrong gateway:** remove a gateway from isolated NICs; retain a gateway only on the approved NAT path.
* **Internet works but AD fails:** set the domain DNS server on the lab NIC; do not use the NAT DNS server for AD queries.
* **AD works but Internet fails:** connect VMnet8 temporarily, verify its VMware NAT gateway, and confirm that the lab NIC remains the preferred interface.
* **Cross-segment traffic fails:** this is expected until a lab explicitly provides routing and firewall rules.
* **Name resolves but ports fail:** check Windows Firewall, the service state, and whether the VM is on the correct VMnet.

## VMware networks versus Azure VNets

VMnets are local virtual switches managed by VMware Workstation on the Windows 11 host. They have no Azure control-plane object, do not consume Azure quota, and do not incur Azure charges. Azure VNets are cloud resources with subnets, route tables, NSGs, private endpoints, service endpoints, and region-specific availability. Do not copy the VMnet names, routes, or addresses into Azure without checking for overlap and following the Azure lab's prerequisites.
