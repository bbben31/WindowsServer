# Practice: PowerShell remoting

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** A remote session reaches the intended server, returns its hostname, and is removed when complete.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10
* VN1-SRV5

## Task

On CL1, check the value IPEnableRouter on VN1-SRV5 using an interactive remote session. Check the same value on VN1-SRV10 by invoking remote commands.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. From the context-menu of **Start** (you can press WIN + X), launch **Terminal** as Administrator.
1. Start an interactive remote session with **VN1-SRV5**.

    ````powershell
    Enter-PSSession VN1-SRV5
    ````

1. Query the value **IPEnableRouter** in the registry key **HKLM:\system\CurrentControlSet\services\Tcpip\Parameters**.

    ````powershell
    Get-ItemProperty `
        -Path HKLM:\system\CurrentControlSet\services\Tcpip\Parameters `
        -Name IPEnableRouter
    ````

1. Exit the remote session.

    ````powershell
    Exit-PSSession
    ````

1. Store the registry key path **HKLM:\system\CurrentControlSet\services\Tcpip\Parameters** in a variable.

    ````powershell
    $path = 'HKLM:\system\CurrentControlSet\services\Tcpip\Parameters'
    ````

1. Invoke a command with VN1-SRV10 to query the same registry value as above.

    ````powershell
    Invoke-Command -ComputerName VN1-SRV10 -ScriptBlock {
        Get-ItemProperty -Path $using:path -Name IPEnableRouter
    }
    ````
