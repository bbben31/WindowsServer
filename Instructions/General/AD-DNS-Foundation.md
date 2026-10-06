# Milestone C: AD DS and DNS foundation

This runbook builds the disposable `ad.lab.test` forest on the personal VMware lab. It uses Windows Server 2025 Evaluation, VMware Workstation Pro 17, and the segmented networks from [Milestone A](VMware-Segmented-Networking.md). `ad.lab.test` is a lab-only name; it is not a production domain design or a public DNS suffix.

## Prerequisites and topology

Complete [Milestone A](VMware-Segmented-Networking.md) and [Milestone B](Base-Images-and-Templates.md). Use this runbook's foundation checks and confirm the template is generalized, workgroup-joined, not a domain controller, and has no secrets. The [read-only preflight checker](../../tools/Preflight-LearnerLab.ps1) is for a selected manifest Practice/Lab, not this General runbook.

The minimum topology is one VM:

| VM | Role | Address | VMware NIC |
| --- | --- | --- | --- |
| `VN1-SRV1` | First forest/root domain controller, DNS, Global Catalog | `10.10.10.10/24` | VMnet10 only |

The optional two-controller topology is:

| VM | Role | Addresses | VMware NICs |
| --- | --- | --- | --- |
| `VN1-SRV1` | First domain controller, DNS, Global Catalog | `10.10.10.10/24` | VMnet10 |
| `VN1-SRV5` | Additional domain controller, DNS, Global Catalog | `10.10.10.11/24` | VMnet10; optional `10.10.20.11/24` on VMnet11 for a lab explicitly requiring a server/workload path |

The VMnet11 NIC on `VN1-SRV5` is not required for AD DS and must not become an additional default gateway or an accidentally registered DNS address. Keep AD management, DNS, and domain discovery on VMnet10. Do not add the VMnet11 NIC until a selected lab requires it.

Use a static address for every domain controller. A controller whose address changes can break DNS glue, SRV records, replication, secure channels, and client discovery. Domain controllers should be authoritative for `ad.lab.test` and should not use public DNS directly. Member servers and clients must use `10.10.10.10`, then `10.10.10.11` after the second DNS server is healthy; public resolution belongs behind DNS forwarders.

## Checkpoint and credentials

Before promotion, shut down dependent guests and take the checkpoint `C-before-first-DC`. Keep the clean template checkpoint from Milestone B. After first-DC validation, take `C-first-DC-validated`. If the second controller is built, take `C-second-DC-validated` only after replication checks pass.

Promotion requires a local administrator, a new DSRM password, and later (for `VN1-SRV5`) authorized domain credentials. Enter them interactively through the wizard or `Get-Credential`/`Read-Host -AsSecureString`. Store them only in a password manager or another approved secret store. Do not write them into scripts, command history, reports, Git, screenshots, or this repository. Never create bulk accounts or automate password handling.

## Prepare `VN1-SRV1`

1. Create a **full clone** of the clean Server 2025 template. Do not use a domain-controller snapshot or clone.
2. In VMware settings, use one NIC on **Custom: VMnet10**. Do not attach VMnet8 unless updates are still required; disconnect it before promotion.
3. Rename the guest to `VN1-SRV1`. Assign `10.10.10.10`, mask `255.255.255.0`, and no default gateway on the isolated VMnet10 NIC. Before DNS exists, use its own address only as the temporary DNS value; do not set a public resolver on the domain NIC.
4. Confirm the Windows network profile/firewall is appropriate for a private lab and that the machine is still in a workgroup.
5. Verify the address and absence of an unexpected gateway:

```powershell
Get-NetIPConfiguration
Get-NetRoute -AddressFamily IPv4
Get-NetConnectionProfile
Test-Connection 10.10.10.10 -Count 2
```

## Promote the first forest and DNS

### GUI path

1. In **Server Manager**, choose **Manage > Add Roles and Features**, install **Active Directory Domain Services**, and include the management tools.
2. Select the notification flag and choose **Promote this server to a domain controller**.
3. Choose **Add a new forest** and enter `ad.lab.test` as the root domain name. Do not use a public name or a name belonging to another network.
4. On **Domain Controller Options**, keep **DNS server** and **Global Catalog** selected. Choose the highest forest/domain functional level supported by this lab’s Server 2025 build unless a selected compatibility lab explicitly requires another level. Record the choice privately.
5. Enter a unique DSRM password interactively. Do not save it in the wizard output or a repository file.
6. Leave **Update DNS delegation** cleared. This is an isolated lab with no parent DNS zone to delegate.
7. Keep the default AD database, log, and SYSVOL paths unless a storage lab explicitly requires separate disposable volumes.
8. Review prerequisites, install, and allow the required reboot. Sign in only after the server restarts and services settle.

### PowerShell path

The source procedure [Configuring AD DS as a new forest](Configuring-Active-Directory-Domain-Services-as-a-new-forest.md) contains the supported `Install-ADDSForest` pattern. Use its interactive secure-string prompt and replace only the documented domain placeholders. A safe learner-specific shape is:

```powershell
$safeModeAdministratorPassword = Read-Host `
    -Prompt 'DSRM password (do not record in Git)' `
    -AsSecureString

Install-ADDSForest `
    -DomainName 'ad.lab.test' `
    -DomainNetbiosName 'AD' `
    -InstallDns `
    -CreateDnsDelegation:$false `
    -SafeModeAdministratorPassword $safeModeAdministratorPassword `
    -ForestMode 'Default' `
    -DomainMode 'Default' `
    -DatabasePath 'C:\Windows\NTDS' `
    -LogPath 'C:\Windows\NTDS' `
    -SysvolPath 'C:\Windows\SYSVOL' `
    -Force
```

This is an interactive promotion command, not a repository automation script. Do not paste a password into it. The command reboots the server; wait for the reboot before validation.

## Configure internal DNS safely

After promotion, ensure the VMnet10 NIC uses `10.10.10.10` for DNS. Do not put a public resolver or VMnet8 DNS server on the domain NIC. Add forwarders only if the lab needs controlled external name resolution:

* In **DNS Manager**, open the server's **Forwarders** properties and add an approved resolver, represented in private notes as `<DNS_FORWARDER_IP>`.
* Keep DNS forwarders on the DNS server. Clients still query `10.10.10.10`; they do not query the public resolver directly.
* The source [Configuring forwarders](Configuring-forwarders.md) provides the supported GUI and `Set-DnsServerForwarder` forms. Do not invent a forwarder address, and do not use a home router as a domain controller's primary DNS.

Forwarders are optional for the isolated forest. If no Internet name resolution is needed, leave them unset and keep VMnet8 disconnected.

## Validate the first domain controller

Run these read-only checks on `VN1-SRV1` after the reboot:

```powershell
Get-ADDomain
Get-ADForest
Get-ADDomainController -Discover
Get-DnsServerZone
Get-DnsServerForwarder
Resolve-DnsName ad.lab.test -Server 10.10.10.10
Resolve-DnsName _ldap._tcp.ad.lab.test -Type SRV -Server 10.10.10.10
nslookup ad.lab.test 10.10.10.10
dcdiag /test:dns /v
Test-NetConnection 10.10.10.10 -Port 53
Test-NetConnection 10.10.10.10 -Port 389
Get-NetIPConfiguration
Get-NetRoute -AddressFamily IPv4
```

Expected conditions:

* `Get-ADDomain` reports `ad.lab.test`, and `Get-ADForest` reports the same forest root.
* `Get-ADDomainController -Discover` returns `VN1-SRV1`.
* The AD-integrated forward and reverse zones exist as appropriate, and the LDAP SRV record resolves.
* `dcdiag /test:dns /v` reports no blocking DNS failures.
* The VMnet10 address is `10.10.10.10/24`, the domain NIC has no unsuitable gateway, and DNS points to the local AD DNS service.

Take `C-first-DC-validated` only after these conditions are met. Then join a disposable member server or client, not before.

## Optional `VN1-SRV5` and replication

The second controller is not required for the minimum lab. Add it when a replication, availability, sites, RODC, or upgrade exercise needs it.

1. Full-clone the clean Server 2025 template as `VN1-SRV5`; never clone `VN1-SRV1`.
2. Attach VMnet10 and assign `10.10.10.11/24`, with no default gateway on the isolated NIC. Set DNS temporarily to `10.10.10.10`.
3. Confirm `VN1-SRV1` resolves and the clocks are close before promotion.
4. Install AD DS and use **Promote this server to a domain controller**, choose **Add a domain controller to an existing domain**, enter `ad.lab.test`, enable DNS and Global Catalog, leave RODC disabled for this basic topology, and enter the DSRM password interactively.
5. If a selected lab requires a server/workload NIC, add VMnet11 as `10.10.20.11/24` without a gateway. Do not register that secondary NIC in DNS unless the lab explicitly documents the required multi-homing design.
6. Reboot and wait for promotion to complete. Set DNS on the VMnet10 NIC to `10.10.10.10` and `10.10.10.11` only after both services are healthy.

The source [additional domain controller procedure](Configuring-Active-Directory-Domain-Services-as-an-additional-domain-controller.md) provides the GUI and PowerShell alternatives. Use `Get-Credential` interactively; never embed domain credentials.

Validate replication:

```powershell
Get-ADDomainController -Filter * | Select-Object HostName,IPv4Address,IsGlobalCatalog,OperatingSystem
Resolve-DnsName _ldap._tcp.ad.lab.test -Type SRV -Server 10.10.10.10
Resolve-DnsName _ldap._tcp.ad.lab.test -Type SRV -Server 10.10.10.11
repadmin /replsummary
repadmin /showrepl
dcdiag /test:dns /v
```

Expected conditions are both controllers discoverable, both DNS servers resolving the same AD SRV records, and no replication failures. Take `C-second-DC-validated` only then. Run `Test-ComputerSecureChannel` only on a joined member during Milestone D, not on a DC: [Microsoft documents false-positive errors on domain controllers](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-computersecurechannel?view=powershell-5.1).

## Time synchronization

Kerberos depends on close clock agreement. Keep the lab's time zone consistent with the host, and verify before promotion:

```powershell
Get-TimeZone
Get-Date
w32tm /query /status
w32tm /query /source
```

For the isolated forest, do not invent an Internet time source. Use the documented Windows time hierarchy and configure an external source only when the selected lab explicitly requires controlled outbound access. A large skew is a prerequisite failure, not something to bypass with repeated promotion attempts.

## Troubleshooting

* **Wrong DNS:** inspect `Get-DnsClientServerAddress`, `ipconfig /all`, and `Resolve-DnsName`. Remove public/VMnet8 DNS from the domain NIC and point members to AD DNS.
* **Duplicate IP:** power off the conflicting VM, inspect the VMware VMnet assignment and static plan, then re-run `Get-NetIPAddress`. Do not “fix” a duplicate by changing the DC address after promotion without understanding DNS/AD consequences.
* **Time skew:** compare `Get-Date` and `w32tm /query /status` on both machines. Correct the time design before retrying promotion.
* **Firewall/profile:** inspect `Get-NetConnectionProfile`, `Get-NetFirewallProfile`, and required ports 53, 88, 123, 135, 389, 445, and dynamic RPC as applicable. Do not broadly disable the firewall.
* **Replication failure:** run `repadmin /replsummary`, `repadmin /showrepl`, `dcdiag`, and DNS SRV lookups. Check VMnet10 reachability and name resolution before changing AD settings.
* **VMnet reachability:** use `Get-NetIPConfiguration`, `Test-Connection`, and `Test-NetConnection`. Confirm the VM is on Custom: VMnet10 and no unintended NAT/bridged NIC is present.
* **Secure channel failure:** run `Test-ComputerSecureChannel -Verbose` on the member. Do not run repair actions from this read-only checklist without a separate, deliberate recovery plan.

## Rollback and destruction cautions

Promotion changes the machine into an identity-bearing domain controller. Do not casually revert `VN1-SRV1` to a pre-promotion snapshot while other domain members have changed state. For an isolated, disposable forest with no dependent members, the safe reset is to power off and delete/recreate the disposable DC from the clean Milestone B template, then rebuild the lab in dependency order. Do not restore a stale DC snapshot into an active domain.

If `VN1-SRV5` fails before it becomes a dependency, remove the failed disposable VM and rebuild it from the clean template. If it has replicated and served clients, use supported AD demotion/metadata-cleanup procedures from the relevant lab rather than deleting its files. Preserve `VN1-SRV1` and the validated checkpoint unless intentionally destroying the entire lab forest.

Clean up only disposable test members, temporary forwarders, VMnet8 connections, and failed clones. `ad.lab.test` remains local-only and must never be delegated or published to public DNS.
