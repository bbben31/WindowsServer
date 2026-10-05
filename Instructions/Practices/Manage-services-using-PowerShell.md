# Practice: Manage Services using PowerShell

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV2 (VMware display: VN1-SRV2; accepted display aliases: WIN-VN1-SRV2; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Get-Service on the named target shows each requested service state/startup type and the restored final state.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10
* VN1-SRV2

## Task

On CL1, list the services on VN1-SRV1 with their status, name, display name, and start type. Stop the W32Time service on VN1-SRV1, VN1-SRV2, and VN1-SRV10 and disable it. Restart VN1-SRV1, VN1-SRV2, and VN1-SRV10 and verify the changes. Then set W32Time to start automatically and start it again.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Run **Terminal**.
1. List the services on VN1-SRV1, with their status, name, display name, and start type.

    ````powershell
    Get-Service -Computername VN1-SRV1 | Select-Object Status, Name, Displayname, StartType
    ````

    Notice the slow response. ````Get-Service```` uses an interface not optimized for PowerShell.

1. Press CTRL + C to interrupt the running command.
1. List the services on VN1-SRV1, with their status, name, display name, and start type. This time, use PowerShell remoting.

    ````powershell
    Invoke-Command -Computername VN1-SRV1 { 
        Get-Service | Select-Object Status, Name, Displayname, StartType 
    }
    ````

1. Verify the status and start type of the W32Time service on VN1-SRV1, VN1-SRV2, and VN1-SRV10. Format the output as table.

    ````powershell
    $name = 'W32Time'
    $computername = @('VN1-SRV1', 'VN1-SRV2', 'VN1-SRV10')
    Invoke-Command -Computername $computername { 
        Get-Service -Name $using:name | Select-Object Name, Status, StartType 
    } | 
    Format-Table
    ````

1. Stop the W32Time service on VN1-SRV1, VN1-SRV2, and VN1-SRV10.

    ````powershell
    Invoke-Command -ComputerName $computername {
        Stop-Service -Name $using:name 
    }
    ````

1. Verify the status and start type of the W32Time service on VN1-SRV1, VN1-SRV2, and VN1-SRV10. Format the output as table.

    ````powershell
    Invoke-Command -Computername $computername { 
        Get-Service -Name $using:name | Select-Object Name, Status, StartType 
    } | 
    Format-Table
    ````

    The status should be stopped on all computers.

1. Set the start type of the W32Time service to **Disabled** on VN1-SRV1, VN1-SRV2, and VN1-SRV10.

    ````powershell
    Invoke-Command -ComputerName $computername { 
        Set-Service -Name $using:name -StartupType Disabled 
    }
    ````

1. Restart VN1-SRV1, VN1-SRV2, and VN1-SRV10.

    ````powershell
    Invoke-Command -ComputerName $computername { Restart-Computer -Force }
    ````

    Wait until the logon screen appears on VN1-SRV1.

1. Verify the status and start type of the W32Time service on VN1-SRV1, VN1-SRV2, and VN1-SRV10. Format the output as table.

    ````powershell
    Invoke-Command -Computername $computername { 
        Get-Service -Name $using:name | Select-Object Name, Status, StartType 
    } | 
    Format-Table
    ````

    The status should be stopped on all computers.

1. Set the start type of the W32Time service to **Automatic** on VN1-SRV1, VN1-SRV2, and VN1-SRV10.

    ````powershell
    Invoke-Command -ComputerName $computername { 
        Set-Service -Name $using:name -StartupType Automatic 
    }
    ````

1. Start the W32Time service on VN1-SRV1, VN1-SRV2, and VN1-SRV10.

    ````powershell
    Invoke-Command -ComputerName $computername {
        Start-Service -Name $using:name 
    }
    ````

1. Verify the status and start type of the W32Time service on VN1-SRV1, VN1-SRV2, and VN1-SRV10. Format the output as table.

    ````powershell
    Invoke-Command -Computername $computername { 
        Get-Service -Name $using:name | Select-Object Name, Status, StartType 
    } | 
    Format-Table
    ````

    The status should be started and the start type should be automatic on all computers.
