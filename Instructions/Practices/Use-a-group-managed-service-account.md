# Practice: Use a Group Managed Service Account

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV2 (VMware display: PM-SRV2; accepted display aliases: WIN-PM-SRV2; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; conditional); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing).  Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Delegated AD/GPO rights for the named OU, account and policy changes; lab Domain Administrator only where the procedure requires it. Local Administrator for guest setup.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** The gMSA is installed only on authorized hosts, Test-ADServiceAccount succeeds, and the test service runs under it.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* PM-SRV2
* VN1-SRV1
* VN1-SRV5

If you did not complete the lab [Deploying domain controllers](../Labs/Deploying-domain-controllers.md), in addition to the VMs above, **VN1-SRV1** is required. If VN1-SRV1 is already shut down after the lab, do not start it.

## Setup

If you skipped the practice [Install Remote Server Administration Tools](Install-Remote-Server-Administration-Tools.md), on **CL1**, in **Terminal**, execute ````C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1````.

## Task

Create a Group Managed Service Account, install it on PM-SRV2 and use it to create a service.

## Instructions

Perform these steps on CL1.

1. Sign in as **Administrator@ad.lab.test**.
1. Run **Terminal**.
1. Generate a new root key for the Microsoft Group KdsSvc within Active Directory.

    ````powershell
    Add-KdsRootKey -EffectiveTime (Get-Date).AddHours(-10)
    ````

    Note: In real-world you should omit the parameter ````-EffectiveImmediately```` and wait some hours to replicate the key throught your forest.

1. Create a new Group Managed Service Account with the name **MyService**, the DNS host name **myservice.ad.lab.test**, and allow PM-SRV2 to retrieve the managed password.

    ````powershell
    New-ADServiceAccount `
        -Name MyService `
        -DNSHostName myservice.ad.lab.test `
        -PrincipalsAllowedToRetrieveManagedPassword PM-SRV2$
    ````

Perform these steps on PM-SRV2.

1. Sign in as **Administrator@ad.lab.test**.
1. In SConfig, enter **15**.
1. Install the PowerShell module for Active Directory.

    ````powershell
    Install-WindowsFeature -Name RSAT-AD-PowerShell
    ````

1. Install the Group Managed Service Account **MyService**.

    ````powershell
    Install-ADServiceAccount -Identity MyService
    ````

1. Install a test service **NotepadService** with the binary **C:\windows\System32\notepad.exe** to verify the Group Managed Service Account.

    ````powershell
    $name = 'NotepadService'
    New-Service `
        -Name $name `
        -BinaryPathName C:\windows\System32\notepad.exe
    ````

1. Get the new service using WMI.

    ````powershell
    $service = Get-WmiObject -Class Win32_Service -Filter "Name = '$name'"
    ````

1. Change the start account for the service to **ad\MyService$**

    ````powershell
    $service.Change($null, $null, $null, $null, $null, $null, 'ad\MyService$')
    ````

1. Verify the change.

    ````powershell
    $service = Get-WmiObject -Class Win32_Service -Filter "Name = '$name'"
    $service.StartName
    ````

    > The return value should bei ad\MyService$.

1. Open **Task Manager**.

    ````powershell
    taskmgr.exe
    ````

1. In Task Manager, click **More details**.
1. Click the tab Details. Move Task Manager side by side with the console window.
1. In console windows, start the service.

    ````powershell
    Start-Service -Name $name
    ````

    Note: PowerShell will seem to hang, because Notepad is not a real service. Continue to the next step. If you receive an error message before you can finish the next steps, run the command again.

1. Switch to **Task Manager**.

    > You should see a process notepad.exe running under the user name MyService$.

1. Sign out.

    ````powershell
    logoff
    ````
