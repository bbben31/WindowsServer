# Lab: Implementing and managing Storage Spaces and storage tiering

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-prerequisites-for-file-serving.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=true. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** Storage pools/virtual disks report the intended resiliency/tier layout and healthy disposable volumes.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision only existing prerequisite machines, disks, cluster roles and certificates before starting; create machines marked Created during exercise in their designated tasks. Follow alternatives and conditional-retirement requirements instead of starting every named VM; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10

## Setup

On CL1 sign in as ad\administrator.

## Introduction

Adatum wants to evaluate the resiliency of a storage pool. Moreover, Adatum wants to create a tiered virtual disk in a storage pool to make optimal use of the performance of SSDs and the low cost of magnetic hard drives.

## Exercises

1. [Configuring a storage pool](#exercise-1-configuring-a-storage-pool)
1. [Testing storage pool resilience](#exercise-2-testing-storage-pool-resilience)
1. [Storage Tiering](#exercise-3-storage-tiering)

## Exercise 1: Configuring a storage pool

1. [Create a storage Pool](#task-1-create-a-storage-pool) on VN1-SRV10 using the 1 TB disks.
1. [Create a virtual disk](#task-2-create-a-virtual-disk) in the storage pool with three-way-mirroring and 1 TB capacity.

### Task 1: Create a storage pool

#### Desktop Experience

Perform these steps on CL1.

1. Open **Server Manager**.
1. In Server Manager, click on **File and Storage Services**
1. In File and Storage Services, click on **Storage Pools**.
1. In Storage Pools, under **STORAGE POOLS**, click **Tasks**, **New Storage Pool...**.
1. In new Storage Pool Wizard, on page Before you begin, click **Next >**.
1. On page Specify a storage pool name and subsystem, in **Name**, type **Pool1**. Under **Select the group of available disks (also known as a primordial pool) that you want to use**, click **VN1-SRV10**. Click **Next >**.
1. On page Select physical disks for the storage pool, activate all disks with a **Capacity** of **1,00 TB** and click **Next >**.
1. On page Confirmation, click **Create**.
1. On page results, click **Close**.

#### Powershell

Perform these steps on CL1.

1. Open **Terminal**.
1. In Terminal, create a CIM session to **VN1-SRV10**.

   ````powershell
   $cimSession = New-CimSession -ComputerName VN1-SRV10
   ````

1. On VN1-SRV10, select the physical disks available for a storage pool with a size of **1 TB**.

   ````powershell
   $physicalDisks = Get-PhysicalDisk -CanPool $true -CimSession $cimSession |
      Where-Object { $PSItem.Size -eq 1TB }
   ````

1. Create a new Storage Pool **Pool1** using the physical disks you selected.

   ````powershell
   New-StoragePool `
      -FriendlyName 'Pool1' `
      -PhysicalDisks $physicalDisks `
      -StorageSubSystemFriendlyName 'Windows Storage*' `
      -CimSession $cimSession
   ````

1. Remove the CIM session.

   ````powershell
   Remove-CimSession $cimSession
   ````

### Task 2: Create a virtual disk

#### Desktop Experience

Perform these steps on CL1.

1. Open **Server Manager**.
1. In Server Manager, click on **File and Storage Services**
1. In File and Storage Services, click on **Storage Pools**.
1. In Storage Pools, under **VIRTUAL DISKS**, click **Tasks**, **New Virtual Disk...**
1. In Select the storage pool, click **Pool1** and click **OK**.
1. In new Virtual Disk Wizard, on page Before You Begin, click **Next >**.
1. On page Virtual Disk Name, in **Name**, type **Data** and click **Next >**.
1. On page Enclosure Awareness, click **Next >**.
1. On page Storage layout, under **Layout**, click **Mirror** and click **Next >**.
1. On page Resiliency Settings, click **Three-way-mirror** and click **Next >**.
1. On page Provisioning, click **Thin** and click **Next >**.
1. On page Specify size, under **Specify size**, type **1** and click **TB**. Click **Next >**.
1. On page Confirmation, click **Create**.
1. On page Results, click **Close**.
1. In **New Volume Wizard**, on page Before You Begin, click **Next >**.
1. On page Server and Disk, under **Server**, ensure **VN1-SRV10** is selected. Under Disk, ensure the **Virtual Disk** **Data** is selected. Click **Next >**.
1. On page Size, ensure, in **Volume size**, **1024** is filled in and **GB** is selected. Click **Next >**.
1. On page Drive Letter or Folder, ensure, beside **Drive letter**, **D** is selected and click **Next >**.
1. On page File System settings, beside **File System**, click **ReFS**. In **Volume label**, type **Data**. Click **Next >**.
1. On page Confirmation, click **Create**.
1. On page Results, click **Close**.

#### PowerShell

Perform these steps on CL1.

1. Open **Terminal**.
1. In Terminal, create a CIM session to **VN1-SRV10**.

   ````powershell
   $cIMSession = New-CimSession -ComputerName VN1-SRV10
   ````

1. On VN1-SRV10, select the storage pool **Pool1** and store it in a variable.

   ````powershell
   $storagePool = Get-StoragePool -FriendlyName 'Pool1' -CimSession $cIMSession
   ````

1. In the storage pool, create a new three-way-mirror virtual disk of **1 TB** in size. Use thin provisioning. Store the new virtual disk in a variable.

   ````powershell
   $virtualDisk = $storagePool | New-VirtualDisk `
      -FriendlyName 'Data' `
      -ResiliencySettingName 'Mirror'`
       -NumberOfDataCopies 3 `
       -ProvisioningType Thin `
       -Size 1TB `
       -CimSession $cIMSession
   ````

1. Create a new volume on the new virutal disk with the ReFS file system and assign it to the drive letter D.

   ```powershell
   New-Volume `
      -FriendlyName 'Data' `
      -FileSystem ReFS `
      -DriveLetter D `
      -DiskUniqueId $virtualDisk.UniqueId `
      -CimSession $cIMSession
   ````

1. Remove the CIM session.

   ````powershell
   Remove-CimSession $cIMSession
   ````

## Exercise 2: Testing storage pool resilience

1. [Install the File Server role](#task-1-install-the-file-server-role) on VN1-SRV10
1. [Start a continuous copy process](#task-2-start-a-continuous-copy-process) from the host to the virtual disk on VN1-SRV10
1. [Simulate a disk failure](#task-3-simulate-a-disk-failure) on VN1-SRV10

   > Does the copy process continue?

1. [Validate the results from a failed disk](#task-4-validate-the-results-from-a-failed-disk)

   > What is the status of the storage pool, the virtual disk and the physical disks on VN1-SRV10?

1. [Simulate another disk failure](#task-5-simulate-another-disk-failure)

   > Does the copy process still continue?

1. [Add new virtual hard disks](#task-6-add-new-virtual-hard-disks) to VN1-SRV10 as replacement of the failed disks
1. [Repair the storage pool](#task-7-repair-the-storage-pool) on VN1-SRV10
1. [Simulate a fatal failure](#task-8-simulate-a-fatal-failure) by removing three physical disks in the storage pool of VN1-SRV10

   > What happens to the copy process?

1. [Remove the storage pool](#task-9-remove-the-storage-pool) from VN1-SRV10

### Task 1: Install the File Server role

#### Desktop experience

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Features**.
1. In Add Roles and Features Wizard, on page Before You Begin, click **Next >**.
1. On page Installation Type, ensure **Role-based or feature-based installation** is selected and click **Next >**.
1. On page Server Selection, click **VN1-SRV10.ad.lab.test** and click **Next >**.
1. On page Server Roles, expand **File and Storage Services (1 of 12 installed)**, **File and iSCSI Services**, and activate **File Server** and click **Next >**.
1. On page Features, click **Next >**.
1. On page **Confirmation**, click **Install**.
1. On page **Results**, click **Close**.
1. In **Server Manager**, in **File and Storage Services**, click **Servers**.
1. In Servers, under **SERVERS**, click **VN1-SRV10**.
1. Under **SERVICES** (you might have to scroll down), in the context-menu of **LanmanServer**, click **Restart services**.

#### PowerShell

Peform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. Install the windows feature **File Server** on **VN1-SRV10**.

    ````powershell
    $computerName = 'VN1-SRV10'
    Install-WindowsFeature `
      -ComputerName $computerName `
      -Name FS-FileServer `
      -IncludeManagementTools
    ````

1. Restart the service LanmanServer on VN1-SRV10.

   ````powershell
   Invoke-Command -ComputerName $computerName -ScriptBlock { 
      Restart-Service LanmanServer
   }
   ````

### Task 2: Start a continuous copy process

Perform this task on the host.

1. In the context-menu of *Start*, click **Windows PowerShell (Admin)** or **Terminal (Administrator)**.
1. In Windows PowerShell (Admin) or Terminal, create a drive with the name **V** using the **FileSystem** provider with the root **\\\\vn1-srv10\\d$** using the credentials of **Administrator**.

   ````powershell
   New-PSDrive `
      -Name V `
      -PSProvider FileSystem `
      -Root \\vn1-srv10\d$ `
      -Credential Administrator
   ````

1. Enter the credentials of **Administrator** on VN1-SRV10.
1. Copy **C:\\WindowsServerLab\\ISOs\\2022_x64_EN_Eval.iso** from the host to **V:\\** in an infinite loop.

   ````powershell
   while ($true) { 
      Copy-Item `
         -Path 'C:\WindowsServerLab\ISOs\2022_x64_EN_Eval.iso' -Destination 'V:\' -Force
   }
   ````

Leave the instances **Windows PowerShell (Admin)** or **Terminal** open with the copy process running while continuing with the next tasks.

### Task 3: Simulate a disk failure

Perform this task in VMware Workstation on the host.

1. Record the guest `Get-PhysicalDisk` serial/unique IDs, capacities and pool membership, and match them to the VMware SCSI device nodes and VMDK filenames. Identify only the disposable 1 TB pool disks; never detach the OS disk or an unrelated disk. Keep the recorded mapping for the replacement tasks.
1. Stop the copy loop with Ctrl+C. Shut down VN1-SRV10 cleanly and confirm VMware shows **Powered Off**; do not suspend it.
1. In **VM > Settings**, select one recorded 1 TB pool hard disk and click **Remove**. Remove only its VM attachment, retaining the VMDK file for rollback. Do not delete files on the host.
1. Start VN1-SRV10. Reconnect the share and restart the copy loop if the virtual disk is accessible. Record the degraded state in task 4.

This is an offline missing-disk simulation. A power-off interrupts the copy workload; uninterrupted live I/O is not a promised VMware result. The objective remains observing three-way-mirror resilience and repair after loss of a pool member.

### Task 4: Validate the results from a failed disk

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, click on **File and Storage Services**
1. In File and Storage Services, click on **Storage Pools**.
1. In Storage Pools, under **STORAGE POOLS**, click **TASKS**, **Refresh**.

   > A warning sign will be displayed beside the storage pool **Pool1**, the virtual disk **Data**, and one of the physical disks. When hovering with the mouse over the warning signs, you receive a more detailed error description. The status will be **Degraded**.

### Task 5: Simulate another disk failure

1. Stop the test copy loop and shut down VN1-SRV10; confirm **Powered Off** in VMware.
1. In **VM > Settings**, remove the attachment of a second recorded 1 TB pool disk, retaining its VMDK. Do not detach the OS disk.
1. Start the guest, reconnect the share and try the copy workload again. Repeat [task 4](#task-4-validate-the-results-from-a-failed-disk), recording actual pool/virtual-disk health and data availability rather than assuming uninterrupted I/O.

### Task 6: Add new virtual hard disks

Perform this task in VMware Workstation on the host.

1. Stop the workload and shut down VN1-SRV10; confirm **Powered Off**. Record its existing SCSI controller and device-node mapping.
1. In **VM > Settings > Add > Hard Disk**, select **SCSI**, then **Create a new virtual disk**. Set capacity to **1024 GB (1 TB)**, keep the disk growable (do not allocate all space now), and choose the normal VMDK storage layout for this disposable VM. Use a new uniquely named replacement VMDK in the VM's recorded folder under `C:\WindowsServerLab`; never overwrite a detached disk. Reserve sufficient host space for actual data growth.
1. Finish the wizard and verify the new disk uses an unused SCSI node. Repeat to create the second 1 TB replacement. Keep both disconnected old VMDKs for rollback.
1. Start the guest, refresh its disk inventory and confirm both new disks are eligible to pool. Do not initialize or format them as standalone volumes; continue with pool repair.

### Task 7: Repair the storage pool

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, click on **File and Storage Services**
1. In File and Storage Services, click on **Storage Pools**.
1. In Storage Pools, under **STORAGE POOLS**, click **TASKS**, **Refresh**.
1. In the context-menu of the storage pool **Pool1**, click **Add Physical Disk...**
1. In Add Physical Disk, activate one disk with **Capacity** of **1,00 TB** and click **OK**.
1. In **Server Manager**, **Storage Pools**, under **STORAGE POOLS**, ensure **Pool1** is selected. Under **PHYSICAL DISKS** in the context menu of one disk with the warning sign, click **Remove Disk**.
1. In the message box Remove Physical Disk, click **Yes**.
1. In the message box Remove Physical Disk, click **OK**.

   The **Usage** of the physical disk will change to **Retired**.

1. In **Server Manager**, **Storage Pools**, under **STORAGE POOLS**, ensure **Pool1** is selected. Under **PHYSICAL DISKS** in the context menu of the disk with the **Usage** of **Retired**, click **Remove Disk**.
1. In the message box Remove Physical Disk, click **Yes**.
1. In the message box Remove Physical Disk, click **OK**.

   Repeat from step 5 for the second disk with warning sign.

1. In **Server Manager**, **Storage Pools**, under **STORAGE POOLS**, click **TASKS**, **Refresh**.

   > The warning disappears from the pool and the virtual disk.

### Task 8: Simulate a fatal failure

1. Confirm the prior repair completed and the pool is healthy. Stop the copy workload and shut down VN1-SRV10; confirm **Powered Off** in VMware.
1. In **VM > Settings**, remove the attachments of three recorded 1 TB disks from the repaired pool, retaining all VMDKs and their SCSI mappings. Never remove the OS disk.
1. Start VN1-SRV10 and inspect storage health. Attempt the disposable copy again and record whether the virtual disk/share is unavailable after losses exceed its redundancy. Stop the loop with Ctrl+C; this is an offline failure simulation, not a hot-unplug availability benchmark.
1. Remove the host test PowerShell drive if it still exists.

   ````powershell
   Remove-PSDrive V
   ````

### Task 9: Remove the storage pool

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, click on **File and Storage Services**
1. In File and Storage Services, click on **Storage Pools**.
1. In Storage Pools, under **STORAGE POOLS**, click **TASKS**, **Refresh**.

   > Beside the storage pool and the virtual disk, a red error sign will be displayed.

1. Open **Terminal (Admin)**.
1. Open a CIM session to **VN1-SRV10**.

   ````powershell
   $cimSession = New-CimSession -ComputerName VN1-SRV10
   ````

1. Remove the virtual disk **Data**.

   ````powershell
   Remove-VirtualDisk -FriendlyName Data -CimSession $cimSession
   ````

1. At the prompt VN1-SRV10: This will remove the VirtualDisk "Data" and will erase all of the data that it contains, enter **y**.
1. Remove the storage pool **Pool1**.

   ````powershell
   Get-StoragePool -FriendlyName Pool1 -CimSession $cimSession |
   Remove-StoragePool
   ````

1. At the prompt VN1-SRV10: This will remove the StoragePool "Pool1", enter **y**.
1. Remove the CIM session

   ````powershell
   Remove-CimSession $cimSession
   ````

## Exercise 3: Storage Tiering

1. [Add new disks](#task-1-add-new-disks): 3 disks with 1 TB capacity as replacement for the failed disks on VN1-SRV10
1. [Set the media type of physical disks](#task-2-set-the-media-type-of-physical-disks): SSD for all 100 GB disks and HDD for all 1 TB disks
1. [Create a storage pool](#task-3-create-a-storage-pool) with all available disks on VN1-SRV10
1. [Create a tiered virtual disk](#task-4-create-a-tiered-virtual-disk) with 32 GB in the faster tier and 64 GB in the standard tier and assign it the drive letter D
1. [Review the storage tiers management tasks](#task-5-review-the-storage-tiers-management-tasks) on VN1-SRV10
[Epilog](#epilog)

### Task 1: Add new disks

Perform these steps in VMware Workstation on the host.

1. Shut down VN1-SRV10 and confirm **Powered Off**. In **VM > Settings > Add > Hard Disk**, select **SCSI > Create a new virtual disk**.
1. Create three new **1024 GB (1 TB)** growable VMDKs with unique filenames in the VM's recorded `C:\WindowsServerLab` folder and unused SCSI nodes. Do not overwrite the detached files or preallocate the full capacities on the learner host.
1. Retain the existing 100 GB disks used for the fast tier. Start VN1-SRV10, rescan storage and verify the new 1 TB disks are available for pooling without initializing standalone volumes.
1. The guest media-type assignments in task 2 are a lab simulation: VMware virtual disks do not prove distinct physical SSD/HDD performance. Preserve the tier configuration objective and record that limitation.

### Task 2: Set the media type of physical disks

Perform these steps on CL1.

1. Open **Terminal**.
1. In Terminal, open a CIM session to **VN1-SRV10**.

   ````powershell
   $cimSession = New-CimSession -ComputerName VN1-SRV10
   ````

1. On VN1-SRV10, set the media type of the **100 GB** physical disks to **SSD**.

   ````powershell
   Get-PhysicalDisk -CimSession $cimSession | 
   Where-Object { $PSItem.Size -eq 100GB } | 
   Set-PhysicalDisk -MediaType SSD -CimSession $cimSession
   ````

1. On VN1-SRV10, set the media type of the **1 TB** physical disks to **HDD**.

   ````powershell
   Get-PhysicalDisk -CimSession $cimSession | 
   Where-Object { $PSItem.Size -eq 1TB } | 
   Set-PhysicalDisk -MediaType HDD -CimSession $cimSession
   ````

1. Verify the media type of the physical disks.

   ````powershell
   Get-PhysicalDisk -CimSession $cimSession | Sort-Object MediaType
   ````

1. Remove the SIM session.

   ````powershell
   Remove-CimSession $cimSession
   ````

This simulates our virtual disks being SSDs and HDDs.

### Task 3: Create a storage pool

#### Desktop Experience

Perform these steps on CL1.

1. Open **Server Manager**.
1. In Server Manager, click on **File and Storage Services**
1. In File and Storage Services, click on **Storage Pools**.
1. In Storage Pools, under **STORAGE POOLS**, click **Tasks**, **New Storage Pool...**.
1. In new Storage Pool Wizard, on page Before you begin, click **Next >**.
1. On page Storage Pool name, in **Name**, type **TieredPool1**. Under **Select the group of available disks (also known as a primordial pool) that you want to use**, click **VN1-SRV10**. Click **Next >**.
1. On page Physical disks, verify the **Media Type** of the available disks (you may have to scroll right or resize the **New Storage Pool Wizard**).

   There should be 5 disks with **Media Type** of **HDD** and two of **SSD**. If you see **Uknown**, do the following:

   1. Click **Cancel**.
   1. In **Server Manager**, **Storage Pools**, under **STORAGE POOLS**, click **TASKS**, **Refresh**.
   1. Restart the creation of the storage pool at step 4.

1. Activate all available disks and click **Next >**.
1. On page Confirmation, click **Create**.
1. On page results, click **Close**.

#### Powershell

Perform these steps on CL1.

1. Open **Terminal**.
1. In Terminal, create a CIM session to **VN1-SRV10**.

   ````powershell
   $cimSession = New-CimSession -ComputerName VN1-SRV10
   ````

1. On VN1-SRV10, select the physical disks available for a storage pool.

   ````powershell
   $physicalDisks = Get-PhysicalDisk -CanPool $true -CimSession $cimSession
   ````

1. Create a new Storage Pool **TieredPool1** using the physical disks you selected.

   ````powershell
   New-StoragePool `
      -FriendlyName 'TieredPool1' `
      -PhysicalDisks $physicalDisks `
      -StorageSubSystemFriendlyName 'Windows Storage*' `
      -CimSession $cimSession
   ````

1. Remove the CIM session.

   ````powershell
   Remove-CimSession $cimSession
   ````

### Task 4: Create a tiered virtual disk

#### Desktop Experience

Perform these steps on CL1.

1. Open **Server Manager**.
1. In Server Manager, click on **File and Storage Services**
1. In File and Storage Services, click on **Storage Pools**.
1. Under **STORAGE POOLS**, click **TieredPool1**.
1. In Storage Pools, under **VIRTUAL DISKS**, click **Tasks**, **New Virtual Disk...**
1. In Select the storage pool, click **TieredPool1** and click **OK**.
1. In new Virtual Disk Wizard, on page Before You Begin, click **Next >**.
1. On page Virtual Disk Name, in **Name**, type **Tiered Disk 1**. Activate **Create storage tiers on this virtual disk**. Click **Next >**.
1. On page Enclosure Awareness, click **Next >**.
1. On page Storage layout, under **Layout**, click **Mirror** and click **Next >**.
1. On page Size, under **Faster Tier**, type **32** and click **GB**. Under **Standard Tier**, type **64** and click **GB**. Click **Next >**.
1. On page Confirmation, click **Create**.
1. On page Results, click **Close**.
1. In **New Volume Wizard**, on page Before You Begin, click **Next >**.
1. On page Server and Disk, under **Server**, ensure **VN1-SRV10** is selected. Under Disk, ensure the **Virtual Disk** **Tiered Disk 1** is selected. Click **Next >**.
1. On page Size, click **Next >**.
1. On page Drive Letter or Folder, ensure, beside **Drive letter**, **D** is selected and click **Next >**.
1. On page File System settings, in **Volume label**, type **Data**. Click **Next >**.
1. On page Confirmation, click **Create**.
1. On page Results, click **Close**.

#### PowerShell

Perform these steps on CL1.

1. Open **Terminal**.
1. In Terminal, create a CIM session to **VN1-SRV10**.

   ````powershell
   $cIMSession = New-CimSession -ComputerName VN1-SRV10
   ````

1. On VN1-SRV10, select the storage pool **Pool1** and store it in a variable.

   ````powershell
   $storagePool = `
      Get-StoragePool -FriendlyName 'TieredPool1' -CimSession $cIMSession
   ````

1. Create storage tiers for **SSD** and **HDD** media types.

   ````powershell
   $storageTiers = @('SSD', 'HDD') | ForEach-Object {
      $storagePool | New-StorageTier `
         -FriendlyName "$($PSItem)_Tier" `
         -MediaType $PSItem `
         -CimSession $cimSession
   }
   ````

1. In the storage pool, create a new mirrored virtual disk with **32 GB** in the SSD and **64 GB** in the HDD tier and the name **Tiered Disk 1**.

   ````powershell
   $virtualDisk = $storagePool | New-VirtualDisk `
      -FriendlyName 'Tiered Disk 1' `
      -ResiliencySettingName 'Mirror' `
      -StorageTiers $storageTiers `
      -StorageTierSizes 32GB, 64GB
   ````

1. Create a new volume on the new virtual disk and assign it to the drive letter D.

   ```powershell
   New-Volume `
      -FriendlyName 'Data' `
      -DriveLetter D `
      -DiskUniqueId $virtualDisk.UniqueId `
      -CimSession $cimSession
   ````

1. Remove the CIM session.

   ````powershell
   Remove-CimSession $cIMSession
   ````

### Task 5: Review the storage tiers management tasks

Perform this task on CL1.

1. Open **Terminal**.
1. In Terminal, open a remote PowerShell session to **VN1-SRV10**.

   ````powershell
   Enter-PSSession VN1-SRV10
   ````

1. Display the tasks in the path **\\Microsoft\\Windows\\Storage Tiers Management\\**.

   ````powershell
   Get-ScheduledTask -TaskPath '\Microsoft\Windows\Storage Tiers Management\'
   ````

   > You should see details about two tasks: Storage Tiers Management Initialization and Storage Tiers Optimization.

   If time permits, use PowerShell to explore the actions and triggers of the **Storage Tiers Optimization**.

1. Exit the remote PowerShell session.

   ````powershell
   Exit-PSSession
   ````

### Epilog

As our HDDs are simulated, we will not see any acceleration in this lab. Note that you could assign files permanently to the SSD tier, for example:

````powershell
$filePath = 'D:\VM1\Virtual hard Disks\VM1.vhdx'
Set-FileStorageTier `
    -FilePath $filePath `
    -DesiredStorageTierFriendlyName 'SSD_Tier'
````
