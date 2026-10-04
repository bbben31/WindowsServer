# Practice: Authorize DHCP server and activate scope

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Add-a-DHCP-scope.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV6 (VMware display: VN1-SRV6; accepted display aliases: WIN-VN1-SRV6; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** DHCP Administrators/delegated scope rights on the named servers; authorized AD DHCP-authorization rights for authorization steps. Local Administrator for guest networking/role setup.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Get-DhcpServerInDC lists VN1-SRV6 and Get-DhcpServerv4Scope reports VNet1 Active.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV6

## Task

Authorize VN1-SRV6 as DHCP server and activate the scope VNet1.

## Instructions

### Desktop experience

Perform this task on CL1.

1. Open **DHCP**.
1. In DHCP, in the context-menu of **DHCP**, click **Add Server...**
1. In Add Server, under **This server**, type **VN1-SRV6** and click **OK**.
1. In **DHCP**, expand **vn1-srv6.ad.lab.test**, **IPv4**., **Scope [10.10.30.0] VNet1**.
1. In the context-menu of **vn1-srv6.ad.lab.test**, click **Authorize**.
1. In the context-menu of **DHCP**, click **Manage authorized servers...**

    In Manage Authorized Servers, verify that vn1-srv6.ad.lab.test is listed.

1. Click **Close**.
1. In **DHCP**, in the context-menu of **Scope [10.10.30.0] VNet1**, click **Activate**.

### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Add **vn1-srv6.ad.lab.test** to the list of autorized DHCP server services in Active Directory.

    ````powershell
    Add-DhcpServerInDC -DnsName vn1-srv6.ad.lab.test
    ````

1. Verify the autorization of vn1-srv6.ad.lab.test.

    ````powershell
    Get-DhcpServerInDC
    ````

    This should list vn1-srv6.ad.lab.test.

1. Activate the scope **10.10.30.0** on **VN1-SRV6**.

    ````powershell
    $computerName = 'VN1-SRV6'
    $scopeId = '10.10.30.0'
    Set-DhcpServerv4Scope `
        -ComputerName $computerName -ScopeId $scopeId -State Active
    ````

1. Verify the state of the scope.

    ````powershell
    Get-DhcpServerv4Scope -ComputerName $computerName -ScopeId $scopeId
    ````

    The scope schould be listed with a State of Active.
