# Practice: Install File Server Resource Manager and Tools

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-prerequisites-for-file-serving.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Get-WindowsFeature reports FS-Resource-Manager installed and the remote FSRM console connects.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10

## Task

On VN1-SRV10, install File Server Resource Manager, configure it for remote management and verify the remote management connection.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Open **Terminal** as Administrator.
1. Creaate a variable for the computer, where File Server Resource Manager should be configured.

    ````powershell
    $computerName = 'VN1-SRV10'
    ````

1. Install the File Server Resource Manager on VN1-SRV10.

    ````powershell
    Add-WindowsFeature -Name FS-Resource-Manager -ComputerName $computername
    ````

1. Enable remote management of FSRM through the firewall of VN1-SRV10.

    ````powershell
    Invoke-Command -Computername $computerName -ScriptBlock {
        <#
            '@FirewallAPI.dll,-53631' is the group 
            Remote File Server Server Resource Manager Management
        #>
        Set-NetFirewallRule `
            -Group '@FirewallAPI.dll,-53631' `
            -Enabled True `
            -Profile Domain
    }
    ````

1. Open **File Server Resource Manager**.
1. In File Server Resource Manager, in the left pane, in the context menu of **File Server Resource Manager**, click **Connect to Another Computer...**
1. In Connect to Another Computer, click **Another computer**, type **VN1-SRV10**, and click **OK**.

    > You should be able to connect to FSRM on VN1-SRV10. Take a minute to explore the nodes in **File Server Resource Manager**.
