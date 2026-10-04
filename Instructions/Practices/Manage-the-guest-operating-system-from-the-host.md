# Practice: Manage the guest operating system from the host

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Create-and-install-a-virtual-machine.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Enable VMware processor virtualization extensions on powered-off outer hosts; run Hyper-V commands only inside the declared nested lab layer.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV1 (VMware display: PM-SRV1; accepted display aliases: WIN-PM-SRV1; existing); PM-SRV20 (Hyper-V name: PM-SRV20; accepted display aliases: WIN-PM-SRV20; existing-inner); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the explicitly declared nested Hyper-V hosts and inner guests; cluster administrator for cluster changes. VMware settings permission on the outer host.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** PowerShell Direct and integration services work from the declared inner Hyper-V host to its guest.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


> **Optional nested-Hyper-V exercise:** This source procedure is not a default VMware host procedure. Use it only inside a dedicated nested Hyper-V guest.

## Required VMs

* CL1
* PM-SRV1
* PM-SRV20 (inner Hyper-V guest/role)
* VN1-SRV1

## Task

Disconnect the virtual machine PM-SRV20 from the network. Using a remote PowerShell session from PM-SRV1, on PM-SRV20, enable BitLocker encryption. Reconnect the virtual machine to the network. Copy C:\WindowsServerLab\Resources\2022_x64_EN_Eval.iso to PM-SRV20 without using a network connection.

## Instructions

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Hyper-V Manager**.
1. In Hyper-V Manager, click **PM-SRV1**.
1. In the context-menu of **PM-SRV20**, click **Settings...**.
1. In **Settings for PM-SRV20 on PM-SRV1**, click **Network Adapter**.
1. Under Network Adapter, under **Virtual switch**, click **Not connected** and click **OK**.
1. Open **Terminal**
1. In Terminal, open a remote PowerShell session to the Hyper-V host **PM-SRV1**.

    ````powershell
    Enter-PSSession -ComputerName PM-SRV1
    ````

1. Open a remote PowerShell session to the disconnected virtual machine.

    ````powershell
    $vMName = 'PM-SRV20'
    Enter-PSSession -VMName $vMName
    ````

1. In Windows PowerShell credential request, enter the credentials of **ad\Administrator** or **PM-SRV20\Administrator**.

    The prompt will be displayed as

    ````shell
    [PM-SRV1]: [PM-SRV20]:
    ````

1. Query the computer info to confirm that you are connected with the virtual machine.

    ````powershell
    Get-ComputerInfo
    ````

    * **CsName** is **PM-SRV20**
    * **CsTotalPhysicalMemory** is **1072590848** (1 GB)

1. Query the net adapter to confirm its disconnected status.

    ````powershell
    Get-NetAdapter
    ````

    **Status** is **Disconnected**.

1. Install the windows feature **BitLocker**

    ````powershell
    Install-WindowsFeature -Name BitLocker
    ````

1. Close the connection to the virtual machine.

    ````powershell
    Exit-PSSession
    ````

1. Shut down and start the virtual machine.

    ````powershell
    Stop-VM -Name $vMName
    Start-VM -Name $vMName
    ````

1. Remove the ISO from the DVD drive of the virtual machine

    ````powershell
    Get-VMDvdDrive -VMName $vMName | Set-VMDvdDrive -Path $null
    ````

1. Open a remote PowerShell session to the disconnected virtual machine again.

    ````powershell
    Enter-PSSession -VMName $vMName
    ````

1. In Windows PowerShell credential request, enter the credentials of **ad\Administrator** or **PM-SRV20\Administrator**.

1. Encrypt all available drives using BitLocker skipping the hardware tests.

    ````powershell
    Get-BitLockerVolume | Enable-BitLocker -TpmProtector -SkipHardwareTest
    ````

1. Close the connection to the virtual machine.

    ````powershell
    Exit-PSSession
    ````

1. Close the connection to the Hyper-V host.

    ````powershell
    Exit-PSSession
    ````

1. Switch to **Hyper-V Manager**.
1. In Hyper-V Manager, under Virtual Machines, in the context-menu of **PM-SRV20**, click **Settings...**.
1. In **Settings for PM-SRV20 on PM-SRV1**, click **Network Adapter**.
1. Under Network Adapter, under **Virtual switch**, click **External**.
1. Click **Integration Services**.
1. Under Integration Services, activate  **Guest services** and click **OK**.

1. Switch to **Terminal**.
1. In Terminal, copy **C:\\WindowsServerLab\\Resources\\2022_x64_EN_Eval.iso** from **PM-SRV1** to **C:\WindowsServerLab\Resources** on the disconnected virtual machine **PM-SRV20**

    ````powershell
    Copy-VMFile `
        -ComputerName PM-SRV1 `
        -Name PM-SRV20 `
        -SourcePath C:\WindowsServerLab\Resources\2022_x64_EN_Eval.iso `
        -DestinationPath C:\WindowsServerLab\Resources `
        -FileSource Host `
        -CreateFullPath
    ````

You do not have to wait for the copy process to finish. If the copy process is not finished before starting with the next practice or lab, perform these steps:

1. Switch to **Hyper-V Manager**.
1. Under Virtual Machines, in the context-menu of **PM-SRV20**, click **Cancel Copying a file to the guest**.
