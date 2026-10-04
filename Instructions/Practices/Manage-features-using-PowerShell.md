# Practice: Manage features using PowerShell

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV2 (VMware display: VN1-SRV2; accepted display aliases: WIN-VN1-SRV2; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing).  Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** Get-WindowsFeature reflects each requested install/remove operation on the named target.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10
* VN1-SRV2
* VN1-SRV4
* VN1-SRV5

## Setup

If you skipped the practice [Install Remote Server Administration Tools](Install-Remote-Server-Administration-Tools.md), on CL1, run ````C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1````.

## Task

On CL1, use PowerShell to install the Windows Server Backup feature on VN1-SRV1, VN1-SRV2, VN1-SRV4, VN1-SRV5, and VN1-SRV10.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Open **Terminal** as Administrator.
1. Create an array variable with the server names VN1-SRV1, VN1-SRV2, VN1-SRV4, VN1-SRV5, and VN1-SRV10.

    ````powershell
    $computername = @('VN1-SRV1', 'VN1-SRV2', 'VN1-SRV4', 'VN1-SRV5', 'VN1-SRV10')
    ````

1. Query the installed features of the first server.

    ````powershell
    Get-WindowsFeature -ComputerName $computername[0] | 
    Where-Object { $PSItem.InstallState -eq 'Installed' }
    ````

1. On the first server, find a feature for backup.

    ````powershell
    $windowsFeature = Get-WindowsFeature -ComputerName $computername[0] | 
    Where-Object { $PSItem.DisplayName -like '*backup*' }
    $windowsFeature
    ````

1. Install the feature for backup on all servers.

    ````powershell
    $computername | ForEach-Object { 
        Install-WindowsFeature `
            -Name $windowsFeature.Name `
            -ComputerName $PSItem `
            -Restart
    }
    ````

1. Verify the installation of the backup feature

    ````powershell
    $computername | Foreach-Object {
        Get-WindowsFeature -Name $windowsFeature.Name -ComputerName $PSItem `
    }
    ````
