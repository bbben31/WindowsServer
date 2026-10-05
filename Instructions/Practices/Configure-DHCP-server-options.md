# Practice: Configure DHCP server options

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-the-DHCP-server-role.md; Instructions/Practices/Authorize-DHCP-server-and-activate-scope.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV6 (VMware display: VN1-SRV6; accepted display aliases: WIN-VN1-SRV6; existing); VN1-SRV7 (VMware display: VN1-SRV7; accepted display aliases: WIN-VN1-SRV7; existing); VN2-SRV2 (VMware display: VN2-SRV2; accepted display aliases: WIN-VN2-SRV2; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments.

**Permissions:** DHCP Administrators/delegated scope rights on the named servers; authorized AD DHCP-authorization rights for authorization steps. Local Administrator for guest networking/role setup.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware.

**Success verification:** Get-DhcpServerv4OptionValue reports AD DNS 10.1.1.8 and suffix ad.lab.test on all three DHCP servers.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV6
* VN1-SRV7
* VN2-SRV2

## Task

On VN1-SRV6, VN1-SRV7, and VN2-SRV2 set the IPv4 server options DNS Server to 10.1.1.8 on the isolated enterprise VNet1 profile and DNS domain to ad.lab.test.

## Instructions

### Desktop experience

Perform this task on CL1.

1. Open **DHCP**.
1. In DHCP, in the context-menu of **DHCP**, click **Add Server...**
1. In Add Server, under **This server**, type **VN1-SRV6** and click **OK**.
1. In **DHCP**, expand  **vn1-srv6.ad.lab.test**, **IPv4** and click **Server Options**.
1. In the context-menu of **Server Options**, click **Configure Options...**
1. In Server Options, under **Available Options**, activate **006 DNS Servers**.
1. Under **IP address**, type **10.1.1.8** and click **Add**.
1. Under **Available Options**, activate **015 DNS Domain Name**.
1. Under **String value**, type **ad.lab.test**.
1. Click **OK**.

Repeat from step 2 for **VN1-SRV7** and **VN2-SRV2**.

### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. On **VN1-SRV6**, **VN1-SRV7**, and **VN2-SRV2** set the IPv4 server options DNS Server to **10.1.1.8** and DNS domain to **ad.lab.test**.

    ````powershell
    'VN1-SRV6', 'VN1-SRV7', 'VN2-SRV2' | ForEach-Object {
        Set-DhcpServerv4OptionValue `
            -ComputerName $PSItem -DnsServer 10.1.1.8 -DnsDomain ad.lab.test
    }
    ````
