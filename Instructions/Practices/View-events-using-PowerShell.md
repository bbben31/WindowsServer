# Practice: View events using PowerShell

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Get-WinEvent returns the requested log/filter results from the named target without modifying its logs.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1

## Task

On CL1, list the latest 20 events from the system log on VN1-SRV1. List all warnings, errors and audit failures from the system log on VN1-SRV1. List all details for the oldest events that DSC generated on VN1-SRV1.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Run **Terminal**.
1. List the lastest 20 events from the system log on VN1-SRV1.

    ````powershell
    $computername = 'VN1-SRV1'
    Get-EventLog -LogName System -Newest 20 -Computername VN1-SRV1 # Error occurs
    Invoke-Command -ComputerName $computername { 
        Get-EventLog -LogName System -Newest 20 
    }
    ````


1. List the error, warning and audit failure events from the system log on VN1-SRV1.

    ````powershell
    Invoke-Command -ComputerName $computername {
        Get-EventLog -LogName System -EntryType Error, Warning, FailureAudit
    }
    ````

1. List all logs on VN1-SRV1.

    ````powershell
    Get-WinEvent -ListLog * -ComputerName $computername # Error occurs
    Invoke-Command -ComputerName $computername { Get-WinEvent -ListLog * }
    ````

1. List the events from the **Microsoft-Windows-DSC/Operational** log on VN1-SRV1.

    ````powershell
    Invoke-Command -ComputerName $computername { 
        Get-WinEvent -LogName Microsoft-Windows-DSC/Operational 
    }
    ````

1. List the latest 10 events from the **Microsoft-Windows-DSC/Operational** log on VN1-SRV1.

    ````powershell
    Invoke-Command -ComputerName $computername {
        Get-WinEvent -LogName Microsoft-Windows-DSC/Operational -MaxEvents 10 
    }
    ````

1. List the oldest 10 events from the **Microsoft-Windows-DSC/Operational** log on VN1-SRV1.

    ````powershell
    Invoke-Command -ComputerName $computername {
        Get-WinEvent `
            -LogName Microsoft-Windows-DSC/Operational `
            -MaxEvents 10 `
            -Oldest
    }
    ````

1. List the oldest 10 events from the **Microsoft-Windows-DSC/Operational** log on VN1-SRV1 with more details.

    ````powershell
    Invoke-Command -ComputerName $computername {
        Get-WinEvent `
            -LogName Microsoft-Windows-DSC/Operational `
            -MaxEvents 10 `
            -Oldest
    } |
    Format-List
    ````

1. Clear the Security log on VN1-SRV1.

    ````powershell
    Invoke-Command -ComputerName $computername { 
        Clear-EventLog -LogName Security 
    }
    ````

1. List all events from the Security log on VN1-SRV1.

    ````powershell
    Invoke-Command -ComputerName $computername { 
        Get-WinEvent -LogName Security 
    }
    ````

    Notice the event with Id 1102.
