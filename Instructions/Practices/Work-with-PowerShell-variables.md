# Practice: Work with PowerShell variables

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Standard lab user for local read-only queries and user-owned files; no local elevation. If the explicitly documented system-help prerequisite is selected under Windows PowerShell 5.1, use a separate authorized elevated session.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The displayed variable values, types, scopes and arithmetic results match the procedure.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1

## Task

Store 'cl1' and 'ad.lab.test' in separate variables and create a third variable for a FQDN using the two variables. Calculate the time until December 25th of the current year. Calculate the number of bytes of 7 TB.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. From the context-menu of **Start** (you can press WIN + X), launch **Terminal** as Administrator.
1. Store 'cl1' in the variable $hostname.

    ````powershell
    $hostname = 'cl1'
    ````

1. Verify the content of the variable $hostname.

    ````powershell
    $hostname
    ````

1. Store 'ad.lab.test' in variable $zonename.

    ````powershell
    $zonename = 'ad.lab.test'
    ````

1. Verify the content of the variable $zonename.

    ````powershell
    $zonename
    ````

1. Compose $hostname and $zonename and store it in a variable $fqdn

    ````powershell
    $fqdn = "$hostname.$zonename"
    ````

1. Verify the content of the variable $fqdn.

    ````powershell
    $fqdn
    ````

    The result should be 'cl1.ad.lab.test'

1. Find a command to get the current date.

    ````powershell
    Get-Command -Noun *date*
    ````

1. Get help about Get-Date.

    ````powershell
    Get-Help Get-Date
    ````

1. Get the current date and store it in a variable $now.

    ````powershell
    $now = Get-Date
    ````

1. Verify the content of $now

    ````powershell
    $now
    ````

1. Get the members of $now.

    ````powershell
    $now | Get-Member
    ````

    Notice the Year property.

1. Get the current year.

    ````powershell
    $now.Year
    ````

1. Build a date using December 25th of the current year and store it in a variable $holiday.

    ````powershell
    $holiday = Get-Date -Day 25 -Month 12 -Year $now.Year
    ````

1. Verify the content of $holiday.

    ````powershell
    $holiday
    ````

1. Calculate the time difference between $holiday and $now

    ````powershell
    $holiday - $now
    ````

1. Calculate the number of bytes of 7 TB.

    ````powershell
    7TB
    ````
