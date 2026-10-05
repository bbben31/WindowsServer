# Lab: Storage Replica and stretched cluster

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Enable VMware processor virtualization extensions on powered-off outer hosts; run Hyper-V commands only inside the declared nested lab layer. The cluster nodes are outer VMware VMs with nested Hyper-V enabled; control their outer failure/recovery in VMware and their inner workload in Hyper-V.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN2-SRV1 (VMware display: VN2-SRV1; accepted display aliases: WIN-VN2-SRV1; existing); VN2-SRV20 (Hyper-V name: VN2-SRV20; accepted display aliases: WIN-VN2-SRV20; created); VN3-SRV1 (VMware display: VN3-SRV1; accepted display aliases: WIN-VN3-SRV1; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments.

**Permissions:** Local Administrator on the explicitly declared nested Hyper-V hosts and inner guests; cluster administrator for cluster changes. VMware settings permission on the outer host.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware.

**Success verification:** Replication/cluster roles and the intended test workload recover on the documented surviving site; record data/log disks and recovery results.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision every VM, extra disk, cluster member, certificate, and client named by this lab; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10
* VN1-SRV4
* VN1-SRV5
* VN2-SRV1
* VN2-SRV20 (inner Hyper-V guest/role)
* VN3-SRV1

## Setup

1. On CL1, sign in as **ad\Administrator**.
1. On VN2-SRV1, sign in as **ad\Administrator**.

## Exercises

1. [Preparing for Storage Replica and stretched cluster](#exercise-1-preparing-for-storage-replica-and-stretched-cluster)
1. [Testing Storage Replica storage](#exercise-2-testing-storage-replica-storage)
1. [Create a stretched Hyper-V cluster](#exercise-3-create-a-stretched-hyper-v-cluster)
1. [Test stretched Hyper-V cluster failover](#exercise-4-test-stretched-hyper-v-cluster-failover)

## Exercise 1: Preparing for Storage Replica and stretched cluster

1. [Configure nested virtualization](#task-1-configure-nested-virtualization) on WIN-VN2-SRV1 and WIN-VN3-SRV1 and assign them 3 GB of memory
1. [Configure iSCSI target and disks](#task-2-configure-iscsi-targets-and-disks): 2 targets for VN2-SRV1 and VN3-SRV1, with 2 disks each with 20 GB and 10 GB capacity
1. [Connect to to iSCSI targets](#task-3-connect-to-iscsi-targets) on VN2-SRV1 and VN3-SRV1
1. [Create volumes](#task-4-create-volumes): name the 20 GB disks Data and assign them the drive letter D, and the 10 GB disks Log and assign them the drive letter E on VN2-SRV1 and VN3-SRV1
1. [Install Storage Replica feature](#task-5-install-storage-replica-feature) on VN2-SRV1 and VN3-SRV1

### Task 1: Configure nested virtualization

On the VMware Workstation host, shut down VN2-SRV1 and VN3-SRV1. Open each outer VM's **Settings > Processors** and enable **Virtualize Intel VT-x/EPT or AMD-V/RVI**; allocate at least 3 GB fixed memory or the larger amount required by the workload. Record each VMnet and disk mapping, then restart the guests and verify virtualization with systeminfo. Run the later Hyper-V/cluster commands inside these nested Windows guests. Do not apply Hyper-V host commands to the outer VMware VMs.

### Task 2: Configure iSCSI targets and disks

#### Desktop experience

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, in the left pange, click **File and Storage Services**.
1. In File and Storage Services, click **iSCSI**.
1. In iSCSI, in the right pane, in the drop-down **TASKS**, click **New iSCSI Virtual Disk...**.
1. In New iSCSI Virtual Disk Wizard, on page iSCSI Virtual Disk Location, under **Server**, click **VN1-SRV10**. Under **Storage location**, click **D:**. Click **Next >**.
1. On page Specify iSCSI virtual disk name, in **Name**, type **VN2-CLST1-Data** and click **Next >**.
1. On page Specify iSCSI virtual disk size, in **Size**, type **20** and ensure **GB** is selected. Ensure, **Dynamically expanding** is selected and click **Next >**.
1. On page Assign iSCSI target, click **New iSCSI target** and click **Next >**.
1. On page Specify target name, in **Name**, type **VN2-CLST1** and click **Next >**.
1. On page Specify access servers, click **Add...**.
1. In Add initiator ID, ensure **Query initiator computer for ID** is selected, type **VN2-SRV1** and click **OK**.
1. In **New iSCSI Virtual Disk Wizard**, on page **Specify access servers**, click **Add...**.
1. In Add initiator ID, ensure **Query initiator computer for ID** is selected and click **Browse...**.
1. In Select Computer, under **Enter the object name to select**, type **VN3-SRV1** and click **OK**.
1. In **Add initiator ID**, click **OK**.
1. In **New iSCSI Virtual Disk Wizard**, on page **Specify access servers**, click **Next >**.
1. On page Enable Authentication, click **Next >**.
1. On page Confirmation, click **Create**.
1. On page Results, click **Close**.
1. In **Server Manager**, in **iSCSI**, in the right pane, in the drop-down **TASKS**, click **New iSCSI Virtual Disk...**.
1. In New iSCSI Virtual Disk Wizard, on page iSCSI Virtual Disk Location, under **Server**, click **VN1-SRV10**. Under **Storage location**, click **D:**. Click **Next >**.
1. On page Specify iSCSI virtual disk name, in **Name**, type **VN2-CLST1-Log** and click **Next >**.
1. On page Specify iSCSI virtual disk size, in **Size**, type **10** and ensure **GB** is selected. Ensure, **Dynamically expanding** is selected and click **Next >**.
1. On page Assign iSCSI target, ensure **Existing iSCSI target** is selected and click **vn2-clst1**. Click **Next >**.
1. On page Confirmation, click **Create**.
1. On page Results, click **Close**.
1. In **Server Manager**, in **iSCSI**, in the right pane, in the drop-down **TASKS**, click **New iSCSI Virtual Disk...**.
1. In New iSCSI Virtual Disk Wizard, on page iSCSI Virtual Disk Location, under **Server**, click **VN1-SRV10**. Under **Storage location**, click **D:**. Click **Next >**.
1. On page Specify iSCSI virtual disk name, in **Name**, type **VN3-CLST1-Data** and click **Next >**.
1. On page Specify iSCSI virtual disk size, in **Size**, type **20** and ensure **GB** is selected. Ensure, **Dynamically expanding** is selected and click **Next >**.
1. On page Assign iSCSI target, click **New iSCSI target** and click **Next >**.
1. On page Specify target name, in **Name**, type **VN3-CLST1** and click **Next >**.
1. On page Specify access servers, click **Add...**.
1. In Add initiator ID, ensure **Query initiator computer for ID** is selected, type **VN3-SRV1** and click **OK**.
1. In **New iSCSI Virtual Disk Wizard**, on page **Specify access servers**, click **Add...**.
1. In Add initiator ID, ensure **Query initiator computer for ID** is selected and click **Browse...**.
1. In Select Computer, under **Enter the object name to select**, type **VN2-SRV1** and click **OK**.
1. In **Add initiator ID**, click **OK**.
1. In **New iSCSI Virtual Disk Wizard**, on page **Specify access servers**, click **Next >**.
1. On page Enable Authentication, click **Next >**.
1. On page Confirmation, click **Create**.
1. On page Results, click **Close**.
1. In **Server Manager**, in **iSCSI**, in the right pane, in the drop-down **TASKS**, click **New iSCSI Virtual Disk...**.
1. In New iSCSI Virtual Disk Wizard, on page iSCSI Virtual Disk Location, under **Server**, click **VN1-SRV10**. Under **Storage location**, click **D:**. Click **Next >**.
1. On page Specify iSCSI virtual disk name, in **Name**, type **VN3-CLST1-Log** and click **Next >**.
1. On page Specify iSCSI virtual disk size, in **Size**, type **10** and ensure **GB** is selected. Ensure, **Dynamically expanding** is selected and click **Next >**.
1. On page Assign iSCSI target, ensure **Existing iSCSI target** is selected and click **vn3-clst1**. Click **Next >**.
1. On page Confirmation, click **Create**.
1. On page Results, click **Close**.

#### PowerShell

Perform these steps on CL1.

1. Open **Terminal**.
1. In the new directory, create new iSCSI virtual disks.

   | File name             | Size   |
   |-----------------------|--------|
   | VN2-CLST1-Data.vhdx   | 20 GB  |
   | VN2-CLST1-Log.vhdx    | 10 GB  |
   | VN3-CLST1-Data.vhdx   | 20 GB  |
   | VN3-CLST1-Log.vhdx    | 10 GB  |

   ````powershell
   $computerName = 'VN1-SRV10'
   $driveLetter = 'D'
   $name = 'iSCSIVirtualDisks'
   $path = "$($driveLetter):\$name"
   $diskParams = @(
      @{ Path = "$path\VN2-CLST1-Data.vhdx"; SizeBytes = 20GB }
      @{ Path = "$path\VN2-CLST1-Log.vhdx"; SizeBytes = 10GB }
      @{ Path = "$path\VN3-CLST1-Data.vhdx"; SizeBytes = 20GB }
      @{ Path = "$path\VN3-CLST1-Log.vhdx"; SizeBytes = 10GB }
   )
   $iscsiVirtualDisk = $diskParams | ForEach-Object {
      New-IscsiVirtualDisk `
         -Path $PSItem.Path `
         -SizeBytes $PSItem.SizeBytes `
         -ComputerName $computerName 
   }
   ````

1. On **VN1-SRV10**, Create a new iSCSI server targets with the names **VN2-CLST1** and **VN3-CLST1** for the initiators on **VN2-SRV1** and **VN3-SRV1**.

   ````powershell
   $initiatorIdPrefix = 'IQN:iqn.1991-05.com.microsoft:'
   $DomainSuffix = '.ad.lab.test'
   New-IscsiServerTarget `
      -TargetName "VN2-CLST1" `
      -InitiatorIds ($initiatorIdPrefix + "VN2-SRV1" + $DomainSuffix) `
      -ComputerName $computerName
   New-IscsiServerTarget `
      -TargetName "VN3-CLST1" `
      -InitiatorIds ($initiatorIdPrefix + "VN3-SRV1" + $DomainSuffix) `
      -ComputerName $computerName
   ````

1. Add the iSCSI virtual disks to the iSCSI target.

   ````powershell
   $diskParams | Where-Object { $PSItem.Path -like "$path\VN2-*" } | ForEach-Object { 
      Add-IscsiVirtualDiskTargetMapping `
         -TargetName "VN2-CLST1" `
         -Path $PSItem.Path `
         -ComputerName $computerName 
   }
   $diskParams | Where-Object { $PSItem.Path -like "$path\VN3-*" } | ForEach-Object { 
      Add-IscsiVirtualDiskTargetMapping `
         -TargetName "VN3-CLST1" `
         -Path $PSItem.Path `
         -ComputerName $computerName 
   }
   ````

### Task 3: Connect to iSCSI targets

Perform this task on VN2-SRV1 and VN3-SRV1.

1. Open **iSCSI Initiator**.
1. In message box **Microsoft iSCSI**, click **Yes**.
1. In iSCSI Initiator Properties, in **Target**, type **VN1-SRV10** and click **Quick Connect...**
1. In Quick Connect, click **Done**.
1. In **iSCSI Initiator Properties**, click **OK**.

### Task 4: Create volumes


Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, click **File and Storage Services**.
1. Under File and Storage Services, click **Disks**.
1. In Disks, under **VN2-SRV1**, in the context menu of the disk with a **Capacity** of **20 GB**, click **Bring online**.
1. In Bring Disk Online, click **Yes**.
1. In **Server Manager**, under **Disks**, in the context-menu the Disk of the disk with a **Capacity** of **20 GB**, attached to **Bus Type** **iSCSI**, click **Initialize**.
1. In Initialize Disk, click **Yes**
1. In **Server Manager**, under **Disks**, in the context-menu the Disk of the disk with a **Capacity** of **20 GB**, attached to **Bus Type** **iSCSI**, click **New Volume...**.
1. In New Volume Wizard, on page Before You Begin, click **Next >**.
1. On page Server and Disk, ensure **VN2-SRV1** and a disk with **Capacity** of **20 GB** are selected and click **Next >**.
1. On page size, in **Volume size**, ensure **20,0** is filled in and **GB** is selected. Click **Next >**.
1. On page Drive Letter or Folder, ensure **Drive letter** and **D** is selected and click **Next >**.
1. On page File System Settings, in **File System**, click **ReFS**. In **Volume label**, type **Data**. Click **Next >**.
1. On page Confirmation, click **Create**.
1. On page Results, click **Close**.
1. In **Server Manager**, under **Disks**, under **VN2-SRV1**, in the context menu of the disk with a **Capacity** of **10,0 GB**, attached to **Bus Type** **iSCSI**, click **Bring online**.
1. In Bring Disk Online, click **Yes**.
1. In **Server Manager**, under **Disks**, in the context-menu the Disk of the disk with a **Capacity** of **10 GB**, attached to **Bus Type** **iSCSI**, click **Initialize**.
1. In Initialize Disk, click **Yes**
1. In **Server Manager**, under **Disks**, in the context-menu of the disk with a **Capacity** of **10,0 GB**, attached to **Bus Type** **iSCSI**, click **New Volume...**.
1. In New Volume Wizard, on page Before You Begin, click **Next >**.
1. On page Server and Disk, ensure **VN2-SRV1** and a disk with **Capacity** of **10,0 GB** are selected and click **Next >**.
1. On page size, in **Volume size**, ensure **9,98** is filled in and **GB** is selected. Click **Next >**.
1. On page Drive Letter or Folder, ensure **Drive letter** and **E** is selected and click **Next >**.
1. On page File System Settings, in **File System**, click **ReFS**. In **Volume label**, type **Log**. Click **Next >**.
1. On page Confirmation, click **Create**.
1. On page Results, click **Close**.

Repeat from step 4 for VN3-SRV1.




### Task 5: Install Storage Replica feature



#### Desktop Experience

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Features**.
1. In the Add Rules and Features Wizard, on page **Before You Begin**, click **Next >**.
1. On page Installation Type, ensure **Role-based or feature-based installation** is selected and click **Next >**.
1. On page Server Selection, click **VN2-SRV1.ad.lab.test** and click **Next >**.
1. On page Server Roles, click **Next >**.
1. On page Features, activate **Failover Clustering**.
1. In Add features that are required for Failover Clustering, click **Add Features**.
1. In **Add Roles and Features Wizard**, on page **Features**, activate **Storage Replica**.
1. In Add features that are required for Storage Replica, click **Add Features**.
1. In **Add Roles and Features Wizard**, on page **Features**, click **Next >**.
1. On page Confirmation, verify your selection and click **Install**.
1. On  page **Results**, wait for the installation to succeed, then click **Close**.

Repeat the steps of this task to install the role on **VN3-SRV1**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Install **Failover Clustering** on **VN2-SRV1** and **VN3-SRV1**.

    ````powershell
    Invoke-Command -ComputerName VN2-SRV1, VN3-SRV1 -ScriptBlock {
        Install-WindowsFeature `
            -Name Failover-Clustering, Storage-Replica `
            -IncludeManagementTools `
            -Restart
    }
    ````

## Exercise 2: Testing Storage Replica storage

1. [Run the Storage Replica test](#task-1-run-the-storage-replica-test) on VN2-SRV1 and VN3-SRV1 using the D and E volumes
1. [Evaluate the Storage Replica test](#task-2-evaluate-the-storage-replica-test)

   > According to the report, will Storage Replica work in this environment?

### Task 1: Run the Storage Replica test

Perform this task on VN2-SRV1.

1. Open **Settings**.
1. In Settings, click **Time & Languange**.
1. Under Time & Language, cick **Region**.
1. In Region, under **Regional Format**, click **English (United States)**

   Note: Due to a bug in Windows Server, the Storage Replica test cannot plot the results with regional settings other than English (United States).

1. Open **Window PowerShell (Admin)**.
1. Create a new directory **C:\Temp**.

   ````powershell
   $resultPath = 'C:\Temp'
   New-Item -Path $resultPath -ItemType Directory
   ````

1. Test the Storage Replica topology. Wait for the command to complete.

   ````powershell
   Test-SRTopology `
      -SourceComputerName VN2-SRV1 `
      -DestinationComputerName VN3-SRV1 `
      -SourceVolumeName D: `
      -SourceLogVolumeName E: `
      -DestinationVolumeName D: `
      -DestinationLogVolumeName E: `
      -DurationInMinutes 2 `
      -ResultPath $resultPath
   ````

   This will take 2 - 3 minutes.

### Task 2: Evaluate the Storage Replica test

Perform this task on CL1.

From **\\\VN2-SRV1\\C$\\Temp** open the report in a browser.

> Record which checks passed, which warnings are expected in the isolated lab, and what remediation is required before this design would be production-ready.

## Exercise 3: Create a stretched Hyper-V cluster

1. [Install the failover clustering feature](#task-1-install-the-failover-clustering-feature) on VN2-SRV1 and VN3-SRV1
1. [Add cluster nodes to group](#task-2-add-cluster-nodes-to-group) Witness Modify: VN2-SRV1 and VN3-SRV1
1. [Create a failover cluster](#task-3-create-a-failover-cluster) with VN2-SRV1 and VN3-SRV1 as nodes and the IP addresses 10.1.2.9 and 10.3.9; use \\\\vn1-clst1-fs\\Witness as witness and set the resilience default period to 10; set the preffered site to the 10.1.2.0 subnet; add all available disks to the cluster
1. [Add disk to cluster shared volume](#task-4-add-disk-to-cluster-shared-volumes): disk Data from VN2-SRV1
1. [Configure storage replica](#task-5-configure-storage-replica) to replicate the Data volume from VN2-SRV1 to VN3-SRV1 using the Log volume as log disk

### Task 1: Install the failover clustering feature

#### Desktop Experience

Perform this task on CL1.

1. Open Server Manager.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Features**.
1. In the Add Rules and Features Wizard, on page **Before You Begin**, click **Next >**.
1. On page Installation Type, ensure **Role-based or feature-based installation** is selected and click **Next >**.
1. On page Server Selection, click **VN2-SRV1.ad.lab.test** and click **Next >**.
1. On page Server Roles, click **Next >**.
1. On page Features, activate **Failover Clustering**.
1. In Add features that are required for Failover Clustering, click **Add Features**.
1. In **Add Roles and Features Wizard**, on page **Features**, click **Next >**.
1. On page Confirmation, verify your selection and click **Install**.
1. On  page **Results**, do not wait for the installation to succeed. Click **Close**.

Repeat the steps of this task to install the role on **VN3-SRV1**.

Do not wait for the installation to succeed. Continue with the next task.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Install **Failover Clustering** on **VN2-SRV1** and **VN3-SRV1**

    ````powershell
    Invoke-Command `
      -ComputerName VN2-SRV1, VN3-SRV1 `
      -ScriptBlock {
        Install-WindowsFeature `
            -Name Failover-Clustering `
            -IncludeManagementTools `
            -Restart
    }
    ````

Do not wait for the installation to succeed. Continue with the next task.

### Task 2: Add cluster nodes to group

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **ad (local)**.
1. In ad (local), double-click **Entitling groups**.
1. In Entitling groups, double-click **Witness Modify**.
1. In Witness VN1-CLST Modify, click **Members**.
1. Under Members, click **Add...**.
1. In Select Users, Contacts, Computers, Services Accounts, or Groups, click **Object Types...**.
1. In Object Types, activate **Computers** and click **OK**.
1. In **Select Users, Contacts, Computers, Services Accounts, or Groups**, under **Enter the object names to select**, type **VN2-SRV1; VN3-SRV1** and click **OK**.
1. In **Witness VN1-CLST Modify**, click **OK**.

### Task 3: Create a failover cluster



Perform this task on VN2-SRV1.

1. Open **Windows PowerShell (Admin)**
1. Create a new failover cluster with the name **VN2-VN3-CLST** and the IP address **10.1.2.9** and **10.1.3.9**. Include **VN2-SRV1** and **VN3-SRV1** as nodes.

   ````powershell
   $cluster = New-Cluster `
      -Name VN2-VN3-CLST1 `
      -Node VN2-SRV1, VN3-SRV1 `
      -StaticAddress 10.1.2.9, 10.1.3.9 `
      -NoStorage `
      -AdministrativeAccessPoint ActiveDirectoryAndDns
   ````

1. Configure the cluster quorum settings to use a file share witness using **\\\\vn1-clst1-fs\\Witness**.

   ````powershell
   Set-ClusterQuorum -FileShareWitness '\\vn1-clst1-fs\Witness'
   ````

1. Set the cluster resiliency period to **10** seconds.

   ````powershell
   $cluster.ResiliencyDefaultPeriod = 10
   ````

1. Create the sites **Primary** and **Secondary**.

   ````powershell
   New-ClusterFaultDomain -Name Primary -Type Site
   New-ClusterFaultDomain -Name Secondary -Type Site
   ````

1. Add **VN2-SRV1** to the site **Primary** and **VN3-SRV2** to the site **Secondary**.

   ````powershell
   Set-ClusterFaultDomain -Name VN2-SRV1 -Parent Primary
   Set-ClusterFaultDomain -Name VN3-SRV1 -Parent Secondary
   ````

1. Read the cluster fault domains.

   ````powershell
   Get-ClusterFaultDomain
   ````

   Note the sites and childrens.

1. Set the preferred site **Primary**.

   ````powershell
   $cluster.PreferredSite = 'Primary'
   ````

1. Add all Disks to the cluster.

   ````powershell
   Get-ClusterAvailableDisk -All | Add-ClusterDisk
   ````


### Task 4: Add disk to cluster shared volumes

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, in the context-menu of **Failover Cluster Manager**, click **Connect to Cluster...**
1. Select Cluster, type **VN2-VN3-CLST1.ad.lab.test** and click **OK**.
1. In Failover Cluster Manager, expand **VN2-VN3-CLST1.ad.lab.test**, **Storage**, and click **Disks**.
1. Under Disks (4), in the context menu of the disk with **Capacity** of **20 GB** with a **Status** of **Online**, click **Add to Cluster Shared Volumes**.

### Task 5: Configure storage replica

Perform this task on VN2-SRV1.

1. Open **Windows PowerShell (Admin)**.
1. In Windows PowerShell, read the cluster shared volume.

   ````powershell
   $clusterSharedVolume = Get-ClusterSharedVolume
   ````

1. Read the volume name from the cluster shared volume

   ````powershell
   $sourceVolumeName = $clusterSharedVolume.SharedVolumeInfo.FriendlyVolumeName
   ````

1. Enable the replication.

   ````powershell
   New-SRPartnership `
      -SourceComputerName VN2-SRV1 `
      -SourceRGName 'Replication 1' `
      -SourceVolumeName $sourceVolumeName `
      -SourceLogVolumeName E: `
      -DestinationComputerName VN3-SRV1 `
      -DestinationRGName 'Replication 2' `
      -DestinationVolumeName D: `
      -DestinationLogVolumeName E: `
      -ReplicationMode 'Synchronous' `
      -Force
   ````

1. Get the initial block copy state. Take a note of the DataVolume property of the first replica. Repeat the command until **ReplicationStatus** changes to **ContinouslyReplicating**.

   ````powershell
   (Get-SRGroup).Replicas
   ````

You can continue with the lab, but the failover will only succeed, when the **ReplicationStatus** changed to **ContinouslyReplicating**.

## Exercise 4: Test stretched Hyper-V cluster failover

1. [Install Hyper-V](#task-1-install-hyper-v) on VN2-SRV1 and VN3-SRV1
1. [Create a virtual machine](#task-2-create-a-virtual-machine) with Windows Server 2022 from a differencing disk the cluster node VN2-SRV1
1. [Simulate a failure](#task-3-simulate-a-failure) by turning off VN2-SRV1
1. [Verify failover](#task-4-verify-failover)
1. [Simulate recovery](#task-5-simulate-recovery)
1. [Verify recovery](#task-6-verify-recovery)
1. [Reverse replication](#task-7-reverse-replication) and move the virtual machine back

### Task 1: Install Hyper-V

#### Desktop Experience

Perform this task on CL1.

1. Open Server Manager.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Reatures**.
1. In the Add Rules and Features Wizard, on page **Before You Begin**, click **Next >**.
1. On page Installation Type, ensure **Role-based or feature-based installation** is selected and click **Next >**.
1. On page Server Selection, click **VN2-SRV1.ad.lab.test** and click **Next >**.
1. On page Server Roles, activate **Hyper-V**
1. In Add features that are required for Hyper-V, click **Add Features**.
1. In **Add Roles and Features Wizard**, on page **Server Roles**, click **Next >**.
1. On page Features, click **Next >**.
1. On page Hyper-V, click **Next >**.
1. On page Virtual Switches, click **Next >**.
1. On page Virtual Machine Migration, click **Next >**.
1. On page Default Stores, in **Default location for virtual hard disk files**, type **C:\\ClusterStorage\\Volume1\\Hyper-V\\Virtual Hard Disks**. In **Default location for virtualmachine configuration files**, type **C:\\ClusterStorage\\Volume1\\Hyper-V**. Click **Next >**.
1. On page Confirmation, activate **Restart the destination server automatically if required** and click **Install**.
1. On  page **Results**, wait for the installation to succeed, then click **Close**.

Repeat the steps of this task to install the role on **VN3-SRV1**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Install **Hyper-V** on **VN2-SRV1** and **VN3-SRV1**.

    ````powershell
    $computerName = 'VN2-SRV1', 'VN3-SRV1'
    Invoke-Command -ComputerName $computerName -ScriptBlock {
        Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
    }
    ````

1. On **VN2-SRV1**, set the default stores to the cluster shared volume **Volume1**.

   ````powershell
   Set-VMHost `
      -ComputerName VN2-SRV1 `
      -VirtualHardDiskPath `
         'C:\ClusterStorage\Volume1\Hyper-V\Virtual Hard Disks' `
        -VirtualMachinePath 'C:\ClusterStorage\Volume1\Hyper-V'
    ````

### Task 2: Create a virtual machine

Perform these steps on CL1.

1. In File Explorer, copy **\\\\vn2-srv1\\c$\\WindowsServerLab\\Resources\\TinyCorePure64.vhdx** to **\\\\vn2-srv1\\c$\\ClusterStorage\\Volume1\\Hyper-V\\Virtual Hard Disks**
1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, expand **VN2-VN3-CLST1.ad.lab.test** and click **Roles**.
1. In the context-menu of **Roles**, click **Virtual Machines...**, **New Hard Disk...**
1. In New Virtual Hard Disk, click **VN2-SRV1** and click **OK**.
1. In New Virtual Hard Disk Wizard, on page Before You Begin, click **Next >**.
1. On page Choose Disk Format, ensure **VHDX** is selected and click **Next >**.
1. On page Choose Disk Type, click **Differencing** and click **Next >**.
1. On page Specify Name and Location, in **Name**, type **VN2-SRV20.vhdx** and click **Next >**
1. On page Configure disk, click **Browse...**.
1. In Open, click **TinyCorePure64.vhdx** and click **Open**.
1. In **New Virtual Hard Disk Wizard**, on page **Configure disk**, click **next >**.
1. On page Summary, click **Finish**.
1. In **Failover Cluster Manager**, in the context-menu of **Roles**, click **Virtual Machines...**, **New Virtual Machine...**
1. In New Virtual Machine, click **VN2-SRV1** and click **OK**.
1. In New Virtual Machine Wizard, on page Before You Begin, click **Next >**.
1. On page Specify Name and Location, in **Name**, type **VN2-SRV20** and click **Next >**.
1. On page Specify Generation, click **Generation 1** and click **Next >**.
1. On page Assign Memory, in **Startup memory**, type **256** and click **Next >**.
1. On page Configure Networking, click **Next >**.
1. On page Connect Virtual Hard Disk, click **Use an existing virtual hard disk** and click **Browse**.
1. In Open, click **vn2-srv20.vhdx** and click **Open**.
1. In **New Virtual Machine Wizard**, on page **Connect Virtual Hard Disk**, click **Next >**.
1. On page Summary, click **Finish**.
1. In High Availability Wizard, click **Finish**.
1. In **Failover Cluster Manager**, under **Roles (1)**, in the context-menu of **VN2-SRV20**, click **Start**.
1. In the context-menu of **VN2-SRV20**, click **Connect...**.

### Task 3: Simulate a failure

On the VMware host, select the outer **VN2-SRV1** VM (recorded display alias WIN-VN2-SRV1 where used) and choose **VM > Power > Power Off**. This deliberately simulates abrupt loss of the disposable node; the inner VN2-SRV20 workload remains managed by the guest Hyper-V cluster.

### Task 4: Verify failover

Perform these steps on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, expand **VN2-VN3-CLST1.ad.lab.test** and click **Roles**.

   > VN2-SRV20 should be running on node VN3-SRV1.

1. In the context-menu of **VN2-SRV20**, click **Connect...**.

   > You should see a running operating system

1. In **Failover Cluster Manager**, expand *Storage* and click **Disks**.
1. Click the 20 GB disk, that is still online.
1. At the bottom pane, click on **Replication** and check the status.

### Task 5: Simulate recovery

On the VMware host, power on only the **VN2-SRV1** outer VM turned off in task 3. Verify it rejoins the cluster before testing replication and inner-workload recovery.

### Task 6: Verify recovery

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In **Failover Cluster Manager**, click Nodes.

   > Both nodes should show as up.

1. Click **Disks**.

   > All Disks should be online.

1. In Disks (4), click **Cluster Disk 1** and click the tab **Replication**.

   > Replication should be healthy.

It can take a few minutes before everything is fine again.

### Task 7: Reverse replication

Perform these steps on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, click on **Roles**.
1. Under Roles (1), in the context menu of **VN2-SRV20**, click **Move**, **Live Migration**, **Select Node...**
1. In Move Virtual Machine, click **VN2-SRV1** , and click **OK**.
1. In **Failover Cluster Manager**, expand **Storage** and click **Disks**.
1. In the context-menu of the 20 GB disk, assigned to **Cluster Shared Volume**, click **Move**, **Select Node...**.
1. In Move Cluster Shared Volume, click **VN2-SRV1** , and click **OK**.
