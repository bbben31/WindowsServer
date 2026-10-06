# Practice: NIC teaming

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Preserve a verified management/AD NIC separately; use only two recorded dedicated same-VMnet11 team members. Verify guest build/driver support, disable team DNS registration and defer the demonstration if unsupported.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV3 (VMware display: PM-SRV3; accepted display aliases: WIN-PM-SRV3; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=true. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. The guest NIC-team demonstration is support-gated and does not establish physical-link redundancy.

**Success verification:** Verify team/member state and that management/AD access survives without adding the management NIC to the team. Record simulation/support limits, not physical redundancy.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* PM-SRV3
* VN1-SRV1

## Task

On PM-SRV3, configure the network adapters in a team and assign it the IP address 10.10.20.26.

## Instructions

> **Topology note:** The original Hyper-V switch-level NIC-team exercise is source-specific and is not part of the default VMware path. VMware Workstation does not expose Hyper-V's **Advanced Features** or **Enable this network adapter to be part of a team in guest operating system** controls. Do not follow those UI steps or ignore a faulted virtual switch.

For a VMware learner, use the following guest-only demonstration only when two virtual NICs are connected to the same intended network and the guest supports NIC teaming. Record the existing management NIC, its MAC address, routes and DNS settings. Power off **PM-SRV3**, add two dedicated VMware virtual network adapters on VMnet11, then power on the guest. Keep the management NIC outside the team and preserve its reachable AD DNS path. Do not bridge or route the isolated network through the physical host. Perform the remaining steps from CL1.

1. Open **Server Manager**.
1. In Server Manager, click **All Servers**.
1. Under All Servers, in the context-menu of **PM-SRV3**, click **Configure NIC Teaming**.
1. In NIC Teaming, under **TEAMS**, click **TASKS**, **New Team**.
1. In NIC Teaming, under **Team name**, type **Perimeter**. Under **Member adapters**, select the two guest adapters that are actually connected to VMnet11. Click **Additional Properties**, review the settings, and click **OK**. No VMware host adapter setting is required.

    > Leave at least one adapter out of the team to not loose the remote connection to the server.

1. Close **NIC Teaming**.
1. Close **Server Manager**.
1. Open **Terminal**.
1. Open a CIM session to **PM-SRV3**.

    ````powershell
    $cimSession = New-CimSession PM-SRV3
    ````

1. Assign IP address **10.10.20.26/24** to **Perimeter**. Leave the default gateway unset on isolated VMnet11.

    ````powershell
    $interfaceAlias = 'Perimeter'
    New-NetIPAddress `
        -InterfaceAlias $interfaceAlias `
        -IPAddress 10.10.20.26 `
        -PrefixLength 24 `
        -AddressFamily IPv4 `
        -CimSession $cimSession
    ````

1. Prevent the isolated **Perimeter** team from registering a workload-only address in AD DNS. Do not assign unreachable **10.10.10.10** DNS to this isolated VMnet11 team: with no recorded route, it cannot reach VMnet10. Keep DNS resolution on the separate management NIC and preserve its recorded settings.

    ````powershell
    Set-DnsClient `
        -InterfaceAlias $interfaceAlias `
        -RegisterThisConnectionsAddress $false `
        -CimSession $cimSession
    ````

1. Remove the CIM session.

    ````powershell
    Remove-CimSession $cimSession
    ````

1. Clear the DNS client cache.

    ````powershell
    Clear-DnsClientCache
    ````

1. Open **Server Manager**.
1. In Server Manager, click **All Servers**.
1. Under All Servers, in the context-menu of **PM-SRV3**, click **Configure NIC Teaming**.
1. In NIC Teaming, select **Perimeter** and verify that only the two dedicated VMnet11 adapters are members. Do not add the remaining management NIC to the team. Verify management access still works and record `Get-NetLbfoTeam` / `Get-NetLbfoTeamMember` output from PM-SRV3.

Note: VMware virtual NICs on the same isolated VMnet do not provide physical-link redundancy. The purpose of this optional guest-only practice is to demonstrate the Windows teaming workflow; if the guest build or driver does not support it, record the limitation and leave the activity deferred rather than applying Hyper-V-only settings.
