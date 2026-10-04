# Practice: Harden SMB

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-prerequisites-for-file-serving.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing).  Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** Get-SmbServerConfiguration and test access show the intended signing/encryption settings; authorized clients still connect.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10
* VN1-SRV5

## Setup

Complete [Install prerequisites for file server](./Install-prerequisites-for-file-serving.md) before continuing.

## Task

Verify that SMB 1.0 is disabled and uninstalled on VN1-SRV10.

Enable SMB encryption on server VN1-SRV5 and on the share \\\\VN1-SRV10\\IT.

## Instructions

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. Run **Terminal** as Administrator.
1. Create a remote PowerShell session with **VN1-SRV10**.

    ````powershell
    Enter-PSSession -ComputerName VN1-SRV10
    ````

1. Verify that SMB 1.0 is disabled.

    ````powershell
    Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol
    ````

    The value of EnableSMB1Protocol should be False.

1. Verify that SMB 1.0 is not installed.

    ````powershell
    Get-WindowsFeature -Name FS-SMB1*
    ````

    The features FS-SMB1, FS-SMB1-CLIENT, and FS-SMB1-SERVER should have an Install State of Available.

1. Exit the remote PowerShell session, but leave Terminal open.

    ````powershell
    Exit-PSSession
    ````

1. Create a remote PowerShell session with **VN1-SRV5**.

    ````powershell
    Enter-PSSession -ComputerName VN1-SRV5
    ````

1. Enable SMB encryption for the server

    ````powershell
    Set-SmbServerConfiguration -EncryptData $true
    ````

1. Under **Confirm**, enter **y**.
1. Exit the remote PowerShell session, but leave Terminal open.

    ````powershell
    Exit-PSSession
    ````

1. Enable encryption for the share **\\\\VN1-SRV10\\IT**.

    ````powershell
    Invoke-Command -ComputerName VN1-SRV10 -ScriptBlock {
        Set-SmbShare -Name IT -EncryptData $true -Force
    }
    ````
