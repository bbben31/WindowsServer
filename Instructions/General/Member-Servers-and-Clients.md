# Milestone D: member servers and clients

Milestone D starts only after [Milestone C](AD-DNS-Foundation.md) has passed its first-DC DNS checks. It creates disposable domain members without cloning an AD identity. The examples target Windows Server 2025 Evaluation and Windows 10 on VMware Workstation Pro 17; use Server 2022 only when the selected curriculum item requires it.

## Prerequisites, capacity, and checkpoints

Complete Milestones A-C, keep `C-first-DC-validated` (and `C-second-DC-validated` if used), and run the [read-only preflight checker](../../tools/Preflight-LearnerLab.ps1). On the 32 GB host, run `VN1-SRV1`, one member, and one client first. Shut down unused templates and optional VMs. Take `D-before-members` before cloning and `D-members-validated` after the required members pass the checks below.

The minimum D set is `VN1-SRV20` and `CL1`. Add `VN1-SRV21` and `CL3` only for a practice or lab that names them. File serving, DHCP, WSUS, RDS, clustering, storage, and management labs may require additional disks, servers, clients, or an expanded VM profile; use the manifest rather than assuming this topology is sufficient.

## Default names, addresses, and NIC placement

VMnet10 and VMnet20/30 do not route by themselves. A member that must reach AD DNS needs a VMnet10 management/domain NIC, or a deliberately documented router. This runbook uses a second NIC instead of enabling Windows routing.

| VM | Role | VMnet10 management/AD | Workload/client NIC | DNS |
| --- | --- | --- | --- | --- |
| `VN1-SRV20` | Primary member server | `10.10.10.30/24` | VMnet20: `10.10.20.20/24` | `10.10.10.10`, then `10.10.10.11` |
| `VN1-SRV21` | Optional second member server | `10.10.10.31/24` | VMnet20: `10.10.20.21/24` | `10.10.10.10`, then `10.10.10.11` |
| `CL1` | Primary Windows 10 client | VMnet10: `10.10.10.40/24` | VMnet30: `10.10.30.20/24` or one DHCP reservation | `10.10.10.10`, then `10.10.10.11` on the VMnet10 path |
| `CL3` | Optional second client | VMnet10: `10.10.10.41/24` | VMnet30: `10.10.30.21/24` or one DHCP reservation | AD DNS only |

Use no default gateway on the isolated VMnet10 and VMnet20 NICs. Use `<VMNET30_GATEWAY>` only if a selected client lab supplies an intentional router/NAT design. Do not configure two gateways on a dual-homed member. If VMnet8 is temporarily attached for updates, record `<VMNET8_GATEWAY>` privately and disconnect it before domain administration. Never use VMnet8 DNS as the domain DNS server.

The VMnet10 NIC provides AD/DNS and management reachability; the VMnet20 or VMnet30 NIC provides the workload/client segment. Do not enable IP forwarding or Internet Connection Sharing. For a selected lab that truly requires cross-segment routing, document and verify that routing separately before enabling it.

## Create and prepare `VN1-SRV20`

1. From the clean Server 2025 template, create a full clone named `VN1-SRV20`. Do not clone `VN1-SRV1` or any promoted server.
2. Add a NIC on **Custom: VMnet10** and a second NIC on **Custom: VMnet20**. Connect VMnet8 only for approved updates, then disconnect it.
3. In the guest, rename the adapters so their purpose is unambiguous, for example `LAB-AD` and `LAB-SRV`. Assign `10.10.10.30/24` to `LAB-AD` and `10.10.20.20/24` to `LAB-SRV`. Leave both gateways blank.
4. Configure the VMnet10 NIC to use `10.10.10.10` as preferred DNS. Add `10.10.10.11` only after the second DC/DNS has passed replication validation. Do not configure public DNS.
5. Set the computer name before joining. Use the GUI **Server Manager > Local Server > Computer name** or the interactive command:

```powershell
Rename-Computer -NewName 'VN1-SRV20'
Restart-Computer
```

6. After restart, confirm both addresses and that only the intended NIC has DNS registration. Set the time zone to the host/lab choice and verify the clock against `VN1-SRV1`.
7. Join the domain from **System Properties > Computer Name > Change**, or use the interactive command below. Enter a permitted domain credential at the prompt; never place a password in a script.

```powershell
Add-Computer -ComputerName 'VN1-SRV20' -DomainName 'ad.lab.test' -Credential (Get-Credential) -Restart
```

8. Sign in with a permitted domain account after reboot. Use a least-privilege practice account for routine administration; reserve the domain Administrator account for tasks that explicitly require it.

## Create and prepare `CL1`

1. Full-clone the clean Windows 10 template as `CL1`; do not use a personal Microsoft account or a domain-joined source template.
2. Attach VMnet30 for client traffic and a second NIC on VMnet10 for AD/DNS and management reachability. Use `10.10.30.20/24` (or the single documented VMnet30 DHCP reservation) and `10.10.10.40/24`; leave gateways blank unless a deliberate router is documented.
3. Set DNS on the VMnet10 path to `10.10.10.10`, then optionally `10.10.10.11` after the second DC is healthy. Do not accept a public DNS server from an accidental DHCP service.
4. Rename the client through **Settings > System > About > Rename this PC** or an elevated PowerShell prompt, then restart:

```powershell
Rename-Computer -NewName 'CL1'
Restart-Computer
```

5. Join `ad.lab.test` through **System Properties** or with `Add-Computer -Credential (Get-Credential) -Restart`. Use an approved, disposable domain account interactively.
6. After reboot, sign in with the least-privilege practice account and verify the client firewall remains enabled. The VMnet30 interface is for client exercises; do not turn the client into a router.

Use the same sequence for optional `VN1-SRV21`/`CL3`, substituting the table’s names and addresses. Do not reuse static addresses, hostnames, certificates, or local profiles.

## Management from `CL1`

Install only the management tools required by the selected exercise. [RSAT](../Practices/Install-Remote-Server-Administration-Tools.md) on Windows 10 provides Server Manager, MMC snap-ins, and role tools. Add `VN1-SRV20` to Server Manager using [Adding servers to Server Manager](Adding-servers-to-Server-Manager.md), by AD search or DNS name. For Windows Admin Center, follow [Adding servers to Windows Admin Center](Adding-servers-to-Windows-Admin-Center.md); use a local administrator only when the connection requires it and do not save credentials in a shared connection file.

For remoting, use the existing [PowerShell remoting practice](../Practices/PowerShell-remoting.md). A safe read-only test from `CL1` is:

```powershell
Test-WSMan VN1-SRV20
Enter-PSSession VN1-SRV20
Get-ComputerInfo | Select-Object CsName,WindowsProductName,OsBuildNumber
Exit-PSSession
Invoke-Command -ComputerName VN1-SRV20 -ScriptBlock {
    Get-Service -Name WinRM
    Get-NetConnectionProfile
}
```

Do not run `Enable-PSRemoting`, firewall changes, or trusted-host changes blindly. If remoting is not enabled, follow the source practice and the lab’s required GUI confirmation on the isolated network, then retest. Prefer Kerberos by hostname inside `ad.lab.test`; avoid IP-based remoting for domain administration.

## Verification and expected state

Run on each member and from `CL1`:

```powershell
Get-ComputerInfo | Select-Object CsName,WindowsProductName,OsBuildNumber,WindowsInstallDateFromRegistry
Get-NetAdapter
Get-NetIPConfiguration
Get-DnsClientServerAddress
Get-NetRoute -AddressFamily IPv4
Get-NetConnectionProfile
Get-NetFirewallProfile
whoami /fqdn
Resolve-DnsName ad.lab.test -Server 10.10.10.10
Resolve-DnsName VN1-SRV20.ad.lab.test -Server 10.10.10.10
Test-NetConnection 10.10.10.10 -Port 53
Test-NetConnection 10.10.10.10 -Port 389
Test-NetConnection VN1-SRV20 -Port 5985
Test-ComputerSecureChannel -Verbose
```

Expected conditions:

* The hostname and Windows version match the intended clone.
* `PartOfDomain` is true and `whoami /fqdn` identifies the disposable `ad.lab.test` account context.
* AD DNS resolves the forest and member records; no public DNS appears on the domain NIC.
* The VMnet10 path reaches DNS/LDAP/WinRM, and VMnet20/30 addresses are present without an unintended gateway.
* The Windows Firewall is enabled with a suitable private/domain profile.
* `Test-ComputerSecureChannel` returns `True` for a healthy member.

Take `D-members-validated` only after the required members pass. Then begin [Milestone E](Core-Windows-Administration.md).

## Troubleshooting

* **Domain join cannot find the domain:** inspect `Get-DnsClientServerAddress`, `Resolve-DnsName _ldap._tcp.ad.lab.test -Type SRV`, and VMnet10 reachability. Correct DNS before changing credentials.
* **Duplicate or wrong address:** power off the conflicting clone, verify VMware NIC-to-VMnet placement, and correct the disposable member before retrying. Do not alter a DC address to accommodate a member.
* **No route between VMnets:** expected without a router. Ensure the management/AD NIC is connected to VMnet10 instead of enabling routing as a shortcut.
* **Secure channel failure:** verify DNS, time, hostname uniqueness, and the member’s computer object. Use a planned repair or de-join/rejoin only after capturing diagnostics.
* **WinRM/Server Manager/WAC failure:** check `Test-WSMan`, ports 5985/5986 as applicable, firewall profile, hostname resolution, and the selected management account. Do not disable the firewall globally.
* **Unexpected Internet/DHCP:** disconnect VMnet8, inspect `ipconfig /all`, and confirm exactly one DHCP owner on VMnet30.

## Rollback, de-join, and cleanup

Before changing a member role, take a role-specific snapshot such as `D-before-file-server` or `D-before-remoting`. If a member is inconsistent, shut it down and revert only that disposable member; keep the AD foundation intact.

When retiring a member, sign in with an authorized account, remove it from `ad.lab.test` through **System Properties** or the documented domain-removal procedure, restart, and remove its stale computer object only after confirming it is no longer used. If de-join cannot complete, preserve the diagnostics and use the source cleanup guidance rather than deleting an active computer object blindly. Delete failed clones, temporary VMnet8 adapters, test shares, and local profiles after verification. Do not snapshot-revert a member after it has been used for an identity-sensitive lab without checking its domain relationship.
