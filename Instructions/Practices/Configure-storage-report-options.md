# Practice: Configure storage report options

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-File-Server-Resource-Manager.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** FSRM storage-report settings show a 1 MB threshold and the requested reports path.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10

## Task

Set the minimum file size for the large file report to 1MB. Set the location for reports to sub-folders of d:\\Shares\\IT\\StorageReports\\.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Run **Terminal** as Administrator.
1. Create a remote PowerShell session to **VN1-SRV10**

    ````powershell
    Enter-PSSession VN1-SRV10
    ````

1. Set the minimum file size for the large file report to **1 MB**.

    ````powershell
    Set-FsrmSetting `
        -ReportLargeFileMinimum 1MB
    ````

1. Set the location for incident reports to **d:\\Shares\\IT\\StorageReports\\Incident**.

    ````powershell
    $reportLocation = 'd:\Shares\IT\StorageReports'
    $reportLocationIncident = `
        Join-Path -Path $reportLocation -ChildPath 'Incident'
    New-Item -Type Directory -Path $reportLocationIncident
    Set-FsrmSetting `
        -ReportLocationIncident $reportLocationIncident
    ````

1. Set the location for scheduled reports to **d:\\Shares\\IT\\StorageReports\\Scheduled**.

    ````powershell
    $reportLocationScheduled = `
        Join-Path -Path $reportLocation -ChildPath 'Scheduled'
    New-Item -Type Directory -Path $reportLocationScheduled
    Set-FsrmSetting `
        -ReportLocationScheduled $reportLocationScheduled
    ````

1. Set the location for on-demand reports to **d:\\Shares\\IT\\StorageReports\\Interactive**.

    ````powershell
    $reportLocationOnDemand = `
        Join-Path -Path $reportLocation -ChildPath 'Interactive'
    New-Item -Type Directory -Path $reportLocationOnDemand
    Set-FsrmSetting `
        -ReportLocationOnDemand $reportLocationOnDemand
    ````

1. Exit the remote PowerShell session.

    ````powershell
    Exit-PSSession
    ````

Note: You could also shorten the commands above to

````powershell
$reportLocation = 'd:\Shares\IT\StorageReports'
$reportLocationIncident = `
    Join-Path -Path $reportLocation -ChildPath 'Incident'
$reportLocationScheduled = `
    Join-Path -Path $reportLocation -ChildPath 'Scheduled'
$reportLocationOnDemand = `
    Join-Path -Path $reportLocation -ChildPath 'Interactive'

$reportLocationIncident, $reportLocationScheduled, $reportLocationOnDemand |
ForEach-Object { New-Item -Type Directory -Path $PSItem }

Set-FsrmSetting `
    -ReportLargeFileMinimum 1MB `
    -ReportLocationIncident $reportLocationIncident `
    -ReportLocationScheduled $reportLocationScheduled `
    -ReportLocationOnDemand $reportLocationOnDemand 
````
