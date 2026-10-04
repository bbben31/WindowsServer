# Practice: Getting started with System Insights

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-Remote-Server-Administration-Tools.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV6 (VMware display: VN1-SRV6; accepted display aliases: WIN-VN1-SRV6; existing).  Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** System Insights reports the enabled capability and its latest prediction result; record insufficient-history limitations.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV6

## Setup

If you skipped the practice [Install Remote Server Administration Tools](Install-Remote-Server-Administration-Tools.md), on CL1, run the script **C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1**.

## Task

Install System Insights von VN1-SRV6, check the status of all capabilities, invoke all capabilities and check the default schedules.

## Instructions

Perform these steps on CL1.

1. On CL1, sign in as **ad\Administrator**.
1. Open **Terminal**.
1. In Terminal, install the Windows feature **System-Insights** on VN1-SRV6.

    ````powershell
    Add-WindowsFeature `
        -Computername VN1-SRV6 `
        -Name System-Insights `
        -IncludeManagementTools
    ````

1. Enter into a remote PowerShell session to VN1-SRV6.

    ````powershell
    Enter-PSSession VN1-SRV6
    ````

1. Get capabilities and their status.

    ````powershell
    Get-InsightsCapability
    ````

    State should be enabled for all capabilities, but the status is None, because they have not run yet.

1. Invoke all capabilities.

    ````powershell
    Get-InsightsCapability | Invoke-InsightsCapability
    ````

1. On the prompt Invoking a capability, enter **y**. Repeat this step for all capabilities.
1. Get the last run of all capabilities.

    ````powershell
    Get-InsightsCapability | Format-Table Name, Description, Status, LastRun
    ````

    LastRun should be the current date now.

1. Get the results of all capabilities.

    ````powershell
    Get-InsightsCapability | Get-InsightsCapabilityResult
    ````

    You will not see any results, because System Insights has to run for 5 days at least, before it can make any forecasts.

1. Check the default schedule of all capabilities.

    ````powershell
    Get-InsightsCapability | Get-InsightsCapabilitySchedule
    ````

1. Exit the remote PowerShell session

    ````powershell
    Exit-PSSession
    ````
