# Practice: Manage PowerShell output

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Standard lab user for local read-only queries and user-owned files; no local elevation. If the explicitly documented system-help prerequisite is selected under Windows PowerShell 5.1, use a separate authorized elevated session.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The requested formatting, text export and CSV round-trip show the selected properties and expected objects.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1

## Task

On CL1, get all information about the running process of Terminal. Start all services configured for automatic start but not currently running.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. From the context-menu of **Start** (you can press WIN + X), launch **Terminal** as Administrator.
1. Find the Terminal process

    ````powershell
    Get-Process *terminal*
    ````

1. Show detailed information about the Terminal process

    ````powershell
    Get-Process WindowsTerminal | Format-List
    ````

1. Show more information about the Terminal process

    ````powershell
    Get-Process WindowsTerminal | Format-List *
    ````

1. Get a list of installed services.

    ````powershell
    Get-Service
    ````

1. Get information about the returned class of Get-Service.

    ````powershell
    Get-Service | Get-Member
    ````

    Notice the **StartType** property.

1. List the services with **Name**, **Status**, and **StartType** properties only.

    ````powershell
    Get-Service | 
    Select-Object Name, Status, StartType
    ````

1. List all services with the StartType **Automatic**. Display Name, Status, and StartType.

    ````powershell
    Get-Service | 
    Where-Object { $PSItem.StartType -eq 'Automatic' } | 
    Select-Object Name, Status, StartType
    ````

1. List all services with the Status **Stopped**. Display Name, Status, and StartType.

    ````powershell
    Get-Service | 
    Where-Object { $PSItem.Status -eq 'Stopped' } | 
    Select-Object Name, Status, StartType
    ````

1. Now, list all services with the Status **Stopped** and the StartType **Automatic**. Display Name, Status, and StartType.

    ````powershell
    Get-Service | 
    Where-Object { 
        $PSItem.Status -eq 'Stopped' -and $PSitem.StartType -eq 'Automatic'
    } | 
    Select-Object Name, Status, StartType
    ````

1. Start all services with the Status **Stopped** and the StartType **Automatic**.

    ````powershell
    Get-Service | 
    Where-Object { 
        $PSItem.Status -eq 'Stopped' -and $PSitem.StartType -eq 'Automatic'
    } | 
    Start-Service
    ````

    Note: Some services will not start correctly, because the are terminated immediatly. Moreover, some services will stop running after a few seconds or minutes. This is normal.
