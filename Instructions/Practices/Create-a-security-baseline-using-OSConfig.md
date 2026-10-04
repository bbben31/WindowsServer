# Practice: Create a security baseline using OSConfig

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV6 (VMware display: VN1-SRV6; accepted display aliases: WIN-VN1-SRV6; existing). At least 1 of [VN1-SRV1, VN1-SRV5]: Use the active AD DNS/controller from the documented deployment lineage; do not restart a retired DC. Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: www.powershellgallery.com and its documented package CDN; Microsoft help endpoints if Update-Help is selected.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** OSConfig reports member-server compliance and drift-control state; removal of the exercise baseline is confirmed.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV5
* VN1-SRV6

## Task

On VN1-SRV6, apply the security baseline for member servers using OSConfig. Check the compliance, verify the status of drift control, disable drift control and remove the security baseline.

## Instructions

Perform these steps on CL1.

1. On CL1, sign in as **ad\Administrator**.
1. Open **Terminal**.
1. Enter into a remote PowerShell session to VN1-SRV6.

    ````powershell
    Enter-PSSession VN1-SRV6
    ````

1. Install the OSConfig PowerShell module.

    ````powershell
    Install-Module `
        -Name Microsoft.OSConfig `
        -Scope AllUsers `
        -Repository PSGallery `
        -Force
    ````

1. At the prompt NuGet provider is required to continue, enter **y**.
1. List the available security baselines.

    ````powershell
    Get-OSConfigMetadata
    ````

1. Configure the security baseline for member servers.

    ````powershell
    $scenario = 'SecurityBaseline/WS2025/MemberServer'
    Set-OSConfigDesiredConfiguration -Scenario $scenario -Default
    ````

1. Check the compliance with the baseline.

    ````powershell
    Get-OSConfigDesiredConfiguration -Scenario $scenario |
    Format-Table `
        Name, `
        @{ Name = 'Status'; Expression = { $PSItem.Compliance.Status } }, `
        @{ Name = 'Reason'; Expression = { $PSItem.Compliance.Reason } } `
        -AutoSize `
        -Wrap
    ````

1. Get the status of drift control.

    ````powershell
    Get-OSConfigDriftControl
    ````

    Drift control is enabled by default.

1. Disable drift control.

    ````powershell
    Disable-OSConfigDriftControl
    ````

1. Remove the security baseline.

    ````powershell
    Remove-OSConfigDesiredConfiguration -Scenario $scenario
    ````

1. At the prompt Confirm, enter **y**.
1. Exit the remote PowerShell session.

    ````powershell
    Exit-PSSession
    ````
