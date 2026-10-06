# Practice: Manage the guest operating system from the host

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Create-and-install-a-virtual-machine.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Enable VMware processor virtualization extensions on powered-off outer hosts; run Hyper-V commands only inside the declared nested lab layer. Run PowerShell Direct locally in elevated Windows PowerShell on the outer PM-SRV1 console, not inside a nested interactive network-remoting session. Stage the verified Server 2025 ISO at C:\WindowsServerLab\ISOs\2025_x64_EN_Eval.iso. PM-SRV20 has completed installation, a working virtual TPM and usable guest credentials; retain a private OS-volume BitLocker recovery password before encryption.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV1 (VMware display: PM-SRV1; accepted display aliases: WIN-PM-SRV1; existing); PM-SRV20 (Hyper-V name: PM-SRV20; accepted display aliases: WIN-PM-SRV20; existing-inner); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the explicitly declared nested Hyper-V hosts and inner guests; cluster administrator for cluster changes. VMware settings permission on the outer host.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** PowerShell Direct reaches the disconnected inner PM-SRV20; its C: BitLocker protection is verified and recovery password retained privately. Copy-VMFile finishes while the guest remains disconnected; guest/source ISO SHA-256 values agree before the recorded switch is restored.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Keep the private recovery password until the encrypted disposable VM is intentionally removed.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Optional nested-Hyper-V exercise:** This source procedure is not a default VMware host procedure. Use it only inside a dedicated nested Hyper-V guest.

## Required VMs

* CL1
* PM-SRV1
* PM-SRV20
* VN1-SRV1

## Task

Disconnect the inner virtual machine PM-SRV20 from the network. From its nested Hyper-V host PM-SRV1, use PowerShell Direct to enable BitLocker on its operating-system volume and copy the staged Windows Server 2025 ISO without a network connection. Verify the copy, then reconnect the guest to its recorded lab switch.

## Instructions

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Hyper-V Manager**.
1. In Hyper-V Manager, click **PM-SRV1**.
1. In the context-menu of **PM-SRV20**, click **Settings...**.
1. In **Settings for PM-SRV20 on PM-SRV1**, click **Network Adapter**.
1. Under Network Adapter, under **Virtual switch**, click **Not connected** and click **OK**.
Continue in the VMware console of the outer guest **PM-SRV1**, signed in as its authorized local administrator. Open elevated **Windows PowerShell 5.1** locally (SConfig option **15** on Server Core). Do not nest an interactive `Enter-PSSession -VMName` inside a Windows PowerShell 5.1 network-remoting session from CL1; PowerShell Direct is executed on the Hyper-V host itself. See [PowerShell Direct requirements](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/powershell-direct).

1. Open a PowerShell Direct session to the disconnected inner virtual machine.

    ````powershell
    $vMName = 'PM-SRV20'
    Enter-PSSession -VMName $vMName
    ````

1. In Windows PowerShell credential request, enter the credentials of **ad\Administrator** or **PM-SRV20\Administrator**.

    The prompt will be displayed as

    ````shell
    [PM-SRV20]:
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

1. Add a recovery-password protector to the operating-system volume. Record the recovery password privately outside the VM before enabling encryption; do not publish it or add it to the repository.

    ````powershell
    Add-BitLockerKeyProtector -MountPoint C: -RecoveryPasswordProtector
    ````

1. Encrypt the operating-system volume using the previously configured virtual TPM, skipping the hardware test.

    ````powershell
    Enable-BitLocker -MountPoint C: -TpmProtector -SkipHardwareTest
    Get-BitLockerVolume -MountPoint C:
    ````

1. Close the connection to the virtual machine.

    ````powershell
    Exit-PSSession
    ````

Return to **CL1** and switch to **Hyper-V Manager**.

1. In Hyper-V Manager, under Virtual Machines, in the context-menu of **PM-SRV20**, click **Settings...**.
1. In **Settings for PM-SRV20 on PM-SRV1**, click **Network Adapter**.
1. Leave **Virtual switch** set to **Not connected** until the offline copy is verified.
1. Click **Integration Services**.
1. Under Integration Services, activate  **Guest services** and click **OK**.

Continue in the elevated local PowerShell console on **PM-SRV1**.

1. Confirm that the verified ISO staged by the prerequisite is present at **C:\WindowsServerLab\ISOs\2025_x64_EN_Eval.iso**. Copy it to the full destination file path on the disconnected inner guest.

    ````powershell
    Copy-VMFile `
        -Name PM-SRV20 `
        -SourcePath C:\WindowsServerLab\ISOs\2025_x64_EN_Eval.iso `
        -DestinationPath C:\WindowsServerLab\ISOs\2025_x64_EN_Eval.iso `
        -FileSource Host `
        -CreateFullPath
    ````

1. Wait for the copy to finish. Compare its SHA-256 with the host source using PowerShell Direct; the guest NIC must still be disconnected.

    ````powershell
    $sourceHash = (Get-FileHash C:\WindowsServerLab\ISOs\2025_x64_EN_Eval.iso).Hash
    $guestHash = Invoke-Command -VMName PM-SRV20 -Credential (Get-Credential PM-SRV20\Administrator) -ScriptBlock {
        (Get-FileHash C:\WindowsServerLab\ISOs\2025_x64_EN_Eval.iso).Hash
    }
    if ($sourceHash -ne $guestHash) { throw 'The guest ISO does not match its host source.' }
    ````

1. On **CL1**, in **Hyper-V Manager**, reconnect **PM-SRV20** to its recorded prerequisite switch (**External** if that was the recorded switch). Verify BitLocker reports the expected protection/encryption state and retain the private recovery password. An incomplete or cancelled copy is not a completed practice.
