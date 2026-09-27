# Milestone E: core Windows administration

Milestone E follows [Milestone D](Member-Servers-and-Clients.md). It is an ordered administration pass over the already-built `ad.lab.test` lab, not a replacement for the 89 practices and 50 labs. Use the linked source-aligned procedures for the full exercise, then use this runbook to stage, verify, snapshot, and clean up safely.

## Prerequisites and scope

Keep `C-first-DC-validated`, complete `D-members-validated`, and run the read-only preflight for `VN1-SRV1`, `VN1-SRV20`, and `CL1`. The minimum profile is `VN1-SRV1`, `VN1-SRV20`, and `CL1`; `VN1-SRV4`, `VN1-SRV5`, `VN1-SRV21`, `CL3`, extra disks, WSUS, DHCP, WAC gateway services, and file/RDS/storage nodes are optional or lab-specific. On the 32 GB host, power on only the systems required by the current step.

Keep local and domain identities distinct:

* A **local account** exists only on one computer and is useful for break-glass access to a member or template. Never assume a local account on `VN1-SRV20` exists on `CL1`.
* A **domain account** is managed by AD DS and can be authorized across joined computers. Use a disposable least-privilege practice account such as `<DOMAIN_PRACTICE_ACCOUNT>` for routine work.
* Use the built-in Administrator only when the documented task requires elevation. Enter passwords interactively and keep them in a password manager; do not create accounts, reset passwords, or grant broad groups through repository automation.

Take `E-before-administration` before the first role or policy change, then a named checkpoint before each destructive or stateful lab. The expected cleanup point is `E-core-administration-validated`.

## Recommended order

### 1. Establish management paths

From `CL1`, install the required [RSAT tools](../Practices/Install-Remote-Server-Administration-Tools.md), then add `VN1-SRV20` to [Server Manager](Adding-servers-to-Server-Manager.md). If the exercise uses Windows Admin Center, install/configure it using [Configure Windows Admin Center](../Practices/Configure-Windows-Admin-Center.md) and add the server using [Adding servers to Windows Admin Center](Adding-servers-to-Windows-Admin-Center.md). Do not register WAC with Azure unless the selected hybrid practice explicitly requires it.

Read-only checks:

```powershell
Get-WindowsCapability -Online -Name RSAT* | Where-Object State -eq Installed
Test-WSMan VN1-SRV20
Resolve-DnsName VN1-SRV20.ad.lab.test -Server 10.10.10.10
Test-NetConnection VN1-SRV20 -Port 5985
Get-Service -ComputerName VN1-SRV20 -Name WinRM
```

Expected state is resolvable hostname, successful WinRM negotiation, and only the required RSAT components installed. If WAC is used, its browser endpoint and server connection should show healthy without saving credentials in documentation.

### 2. Practice PowerShell and remoting

Complete [PowerShell remoting](../Practices/PowerShell-remoting.md) after D’s secure-channel test. Use `Enter-PSSession` for one interactive check and `Invoke-Command` for read-only inventory. Do not use IP addresses or `TrustedHosts` for normal domain operations. If a lab requires changing WinRM, snapshot first and follow the source procedure manually.

```powershell
Test-WSMan VN1-SRV20
Invoke-Command -ComputerName VN1-SRV20 -ScriptBlock {
    Get-ComputerInfo | Select-Object CsName,WindowsProductName,OsBuildNumber
    Get-Service -Name WinRM
    Get-WinEvent -LogName System -MaxEvents 10
}
```

Expected state: remoting works over the domain/private profile, WinRM is running, and the remote output identifies the intended member.

### 3. Inspect and install roles/features deliberately

Map the topic to [Explore Server Manager](../Practices/Explore-Server-Manager.md), [Install roles using Server Manager](../Practices/Install-roles-using-Server-Manager.md), [Manage features using PowerShell](../Practices/Manage-features-using-PowerShell.md), and [Installing roles and features](Installing-roles-and-features-on-Windows-Server.md). Install only the role named by the selected lab; do not install DHCP, DNS, Hyper-V, WSUS, or file services on the first member merely for convenience.

```powershell
Get-WindowsFeature -ComputerName VN1-SRV20 |
    Where-Object Installed |
    Select-Object Name,DisplayName,InstallState
Get-WindowsFeature -ComputerName VN1-SRV20 -Name FS-FileServer,Web-Server,Hyper-V,AD-Domain-Services
```

Use the GUI or the source-supported `Install-WindowsFeature` command interactively for a selected role. Record whether a restart is required, let it complete, and re-run the read-only inventory. Take `E-before-<role>` before installation and remove the role afterward only when the lab’s cleanup permits it.

### 4. Manage identities and permissions safely

Study [Manage local users](../Practices/Manage-local-users.md), [Manage local groups](../Practices/Manage-local-groups.md), and [Manage domain users, groups, and computers](../Labs/Manage-domain-users-groups-and-computers.md). Use the GUI or an explicitly reviewed manual command with placeholder names; never add account-creation automation to this repository. Prefer a disposable domain practice account and a narrowly scoped local administrator for the selected member. Do not grant Domain Admins for convenience.

Read-only checks:

```powershell
Get-LocalUser
Get-LocalGroup
Get-LocalGroupMember -Group Administrators
Get-ADUser -Filter * -Properties Enabled | Select-Object SamAccountName,Enabled
Get-ADGroupMember -Identity 'Domain Admins'
```

Run AD cmdlets from a host with RSAT/AD tools. Expected state is that only intentionally created disposable identities exist and privileged group membership is understood. Remove temporary users, group members, and permissions during cleanup.

### 5. Inspect services, events, and storage

Map these topics to [Managing services](Managing-services.md), [Manage services using PowerShell](../Practices/Manage-services-using-PowerShell.md), [View events using PowerShell](../Practices/View-events-using-PowerShell.md), [View events using Windows Admin Center](../Practices/View-events-using-Windows-Admin-Center.md), [Manage local storage](../Labs/Manage-local-storage.md), and [Manage shares](Managing-shares.md).

```powershell
Get-Service -ComputerName VN1-SRV20
Get-WinEvent -ComputerName VN1-SRV20 -LogName System -MaxEvents 20
Get-Disk -CimSession VN1-SRV20
Get-Volume -CimSession VN1-SRV20
Get-SmbShare -CimSession VN1-SRV20
```

Create or format only disposable disks after taking `E-before-storage-<lab>`. Confirm volume letters, filesystem, share path, and access rules before deleting test data. Never treat a snapshot as a backup for lab data that matters.

### 6. Review firewall and network state

Map to [Configuring the network profile type](Configuring-the-network-profile-type.md), [Changing TCP/IP settings on Windows Server](Changing-TCP-IP-settings-on-Windows-Server.md), and the relevant firewall/share practice. Keep Windows Firewall enabled and open only the rule or port required by a selected lab.

```powershell
Get-NetConnectionProfile -CimSession VN1-SRV20
Get-NetFirewallProfile -CimSession VN1-SRV20
Get-NetFirewallRule -CimSession VN1-SRV20 -Enabled True |
    Select-Object DisplayName,Direction,Action,Profile
Test-NetConnection VN1-SRV20 -Port 445
Test-NetConnection VN1-SRV20 -Port 5985
```

Expected state is a DomainAuthenticated profile after joining, enabled firewall profiles, and no unexplained broad allow rule. Troubleshoot DNS and profile classification before changing firewall rules.

### 7. Patch and assess

Use the evaluation media’s licensing boundaries and a controlled VMnet8 connection for updates. Follow the selected Windows Update/WSUS practice rather than creating WSUS on the core member. Record update date privately, restart when required, and check for pending restart state. Use [Running Best Practices Analyzer](Running-Best-Practices-Analyzer-and-managing-scan-results.md) after a role is installed; BPA results are guidance to review, not a reason to suppress warnings blindly.

```powershell
Get-HotFix -ComputerName VN1-SRV20
Get-WindowsFeature -ComputerName VN1-SRV20 |
    Where-Object Installed | Select-Object Name,InstallState
Invoke-Command -ComputerName VN1-SRV20 -ScriptBlock {
    Get-BpaModel
}
```

Run BPA from Server Manager or with the source’s `Invoke-BpaModel` pattern for the selected role, then review `Get-BpaResult`. Do not run update or BPA automation with embedded credentials.

## Verification gate and troubleshooting

Milestone E is verified when `CL1` can resolve and manage `VN1-SRV20`, WinRM and the required Server Manager/WAC path work, the selected role inventory matches the lab, local/domain identities are understood, firewall profiles remain enabled, and events/storage/update checks have been recorded. Re-run the [preflight checker](../../tools/Preflight-LearnerLab.ps1) with the stage’s VM names and `-ExpectedDnsServer 10.10.10.10`.

* **Remoting fails:** check `Resolve-DnsName`, `Test-WSMan`, port 5985/5986, WinRM service, time, and the domain firewall profile.
* **Server Manager/WAC cannot connect:** verify hostname resolution and credentials interactively; check that the management tool version supports the target Server version.
* **Role state is unexpected:** compare `Get-WindowsFeature` with the selected practice and inspect pending restart state before retrying.
* **BPA reports warnings:** read each result in context; do not apply a remediation that changes the lab topology without a snapshot and explicit rationale.
* **Storage/share access fails:** inspect `Get-Volume`, `Get-SmbShare`, firewall, and the effective domain account permissions before changing ACLs.

## Rollback and cleanup

Revert only the disposable member or client to its pre-topic checkpoint; do not revert the AD controllers to an old snapshot after new domain state exists. Remove temporary roles, services, shares, scheduled tasks, firewall rules, test accounts, local profiles, downloaded installers, and VMnet8 connections. De-join a retired member using the D runbook before deleting it. Keep `E-core-administration-validated` only if it represents a known-good, disposable lab state.
