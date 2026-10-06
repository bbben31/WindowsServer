# Lab: Installing and configuring a failover cluster

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Create-an-exportable-web-server-certificate-template.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Enable VMware processor virtualization extensions on powered-off outer hosts; run Hyper-V commands only inside the declared nested lab layer.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV2 (VMware display: VN1-SRV2; accepted display aliases: WIN-VN1-SRV2; existing); VN1-SRV23 (Hyper-V name: VN1-SRV23; accepted display aliases: WIN-VN1-SRV23; created in the designated task; not a preflight prerequisite); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the explicitly declared nested Hyper-V hosts and inner guests; cluster administrator for cluster changes. VMware settings permission on the outer host.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Official Microsoft Windows Admin Center download/extension endpoints.

**Risk, cost and optional status:** high; local-only; optional=true. Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware. Verify current support for optional products before execution.

**Success verification:** Cluster validation completes with documented lab exceptions; the general-use File Server, CSVs and inner test VM move to the intended surviving node. Optional WAC results are recorded only where its current cluster support gate permits them.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision only existing prerequisite machines, disks, cluster roles and certificates before starting; create machines marked Created during exercise in their designated tasks. Follow alternatives and conditional-retirement requirements instead of starting every named VM; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10
* VN1-SRV2
* VN1-SRV4
* VN1-SRV5
* Created during exercise: VN1-SRV23

## Known Issues

Exercise 4 is compatibility-gated: verify the recorded WAC version's current documented cluster-deployment support before attempting it. If unavailable, skip only that optional extension and its WAC-specific checks in Exercises 5 and 6; complete the file-server and Hyper-V failover tests. Do not treat a dated product note as verification of present support.

## Setup

Use the recorded **member-server** lineage for VN1-SRV4 and VN1-SRV5. If VN1-SRV5 is an AD domain controller from directory exercises, use a separate coordinated pre-promotion lab snapshot/clone for this cluster; do not remove live directory roles to make it a cluster node. Before Exercise 1, complete [Implementing and managing iSCSI and MPIO](Implementing-and-managing-iSCSI-and-multipath-io.md): verify target **VN1-CLST1** on VN1-SRV10 exports its **1 GB quorum, 10 GB CSV1, 80 GB CSV2 and 100 MB Shares** disks to **both nodes**. Record guest DiskGuid/volume mappings and both .128/.144 storage paths. Provision/configure **Multipath I/O on both nodes**; this lab's detailed initiator demonstration is on VN1-SRV4, not evidence that VN1-SRV5 is connected. Never initialize a shared disk twice.

1. On **VN1-SRV2**, sign in as **ad\Administrator**.
1. Open **Windows PowerShell** as Administrator.
1. Complete [Create an exportable web server certificate template](../Practices/Create-an-exportable-web-server-certificate-template.md). Through the Certificate Templates console, grant VN1-SRV4 Enroll permission on `WebServerExportable` and confirm the enterprise CA issues the template.

1. On **CL1**, sign in as **ad\Administrator**.
1. On **VN1-SRV4**, sign in as **ad\Administrator**.

## Introduction

Adatum wants you to install a failover cluster to run an important virtual machine with high availability. Moreover, Adatum also wants to install the Windows Admin Center highly available. Lastly, prepare the new cluster to be used as a file share witness for other clusters.

## Exercises

1. [Configure the iSCSI initiator](#exercise-1-configure-the-iscsi-initiator)
1. [Install and configure a failover cluster](#exercise-2-install-and-configure-a-failover-cluster)
1. [Use Hyper-V on a cluster](#exercise-3-use-hyper-v-on-a-cluster)
1. [Install Windows Admin Center on the cluster](#exercise-4-install-windows-admin-center-on-a-failover-cluster)
1. [Install File Server on a failover cluster](#exercise-5-install-file-server-on-a-failover-cluster)
1. [Test failover](#exercise-6-test-failover)
1. [Use cluster-aware updating](#exercise-7-use-cluster-aware-updating)

## Exercise 1: Configure the iSCSI initiator

1. [Install the Multipath feature](#task-1-install-the-multipath-feature) on VN1-SRV4
1. [Configure Multipath I/O](#task-2-configure-multipath-io) on VN1-SRV4
1. [Connect to the iSCSI target](#task-3-connect-to-the-iscsi-target) on VN1-SRV10 from VN1-SRV4 using Multipath I/O

### Task 1: Install the Multipath feature

#### Desktop experience

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Features**.
1. In Add Roles and Features Wizard, on page Before You Begin, click **Next >**.
1. On page Installation Type, ensure **Role-based or feature-basedd installation** is selected and click **Next >**.
1. On page Server Selection, click **VN1-SRV4.ad.lab.test** and click **Next >**.
1. On page Server Roles, click **Next >**.
1. On page Features, activate **Multipath I/O** and click **Next >**.
1. On page **Confirmation**, click **Install**.
1. On page **Results**, click **Close**.

#### PowerShell

Peform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. In Terminal, install the Windows feature **Multipath I/O** on **VN1-SRV4**.

    ````powershell
    Install-WindowsFeature `
      -ComputerName VN1-SRV4 `
      -Name MultiPath-IO `
      -IncludeManagementTools
    ````

### Task 2: Configure Multipath I/O

#### Desktop experience

Perform this task on VN1-SRV4.

1. In SConfig, enter **15**.
1. Open **MPIO properties**.

   ````shell
   mpiocpl.exe
   ````

1. In MPIO Properties, on the tab **Discover Multi-Path**, activate **Add support for iSCSI devices** and click on **Add**
1. In the message box MPIO operation: Successful, click **OK**.
1. In **MPIO Properties** click **OK**.

#### PowerShell

Perform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. In Terminal, activate the Multipath I/O support for iSCSI devices on **VN1-SRV4**.

    ````powershell
    Invoke-Command -ComputerName VN1-SRV4 -ScriptBlock {
        Enable-MSDSMAutomaticClaim -BusType iSCSI
    }
    ````

### Task 3: Connect to the iSCSI target

#### Desktop experience

Perform this task on VN1-SRV4.

1. In SConfig, enter **15**.
1. Open **iSCSI Initiator properties**.

   ````powershell
   iscsicpl.exe
   ````

1. In the message box The Microsoft iSCSI service is not running. The service is required to be started for iSCSI to function correctly. To start the service now and have the service start automatically each time the computer restarts, click the Yes button, click **Yes**.
1. In iSCSI Initiator Properties, on tab Targets, in the text box **Target**, type **vn1-srv10.ad.lab.test**, and click **Quick Connect**.
1. In Quick Connect, click **Done**.
1. In **iSCSI Initiator Properties**, on tab **Targets**, click **Disconnect** and click **Connect**.
1. In Connect To Target, activate **Enable multi-path** and click on **Advanced**.
1. In Advanced Settings, in **Local adapter**, click **Microsoft iSCSI Initiator**. In **Initiator IP**, click **10.1.128.32**. In **Target portal IP**, click **10.1.128.80 / 3260**. Click **OK**.
1. In **Connect To Target**, click **OK**.
1. In **iSCSI Initiator Properties**, on tab **Targets**, click on **Connect**.
1. In Connect To Target, activate **Enable multi-path** and click on **Advanced**.
1. In Advanced Settings, in **Local adapter**, click **Microsoft iSCSI Initiator**. In **Initiator IP**, click **10.1.144.32**. In **Target portal IP**, click **10.1.144.80 / 3260**. Click **OK**.
1. In **Connect To Target**, click **OK**.
1. In **iSCSI Initiator Properties**, click **OK**.

#### PowerShell

Perform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. In Terminal, create a remote PowerShell session to **VN1-SRV4**.

    ````powershell
    Enter-PSSession VN1-SRV4
    ````

1. Set the service MSiSCSI to auto start.

    ````powershell
    $service = Get-Service -Name MSiSCSI
    $service | Set-Service -StartupType Automatic
    $service | Start-Service
    ````

1. Create a new iSCSI target portal **vn1-srv10.ad.lab.test**.

    ````powershell
    $iscsiTargetPortal = New-IscsiTargetPortal `
        -TargetPortalAddress vn1-srv10.ad.lab.test
    ````

1. Retrieve the available iSCSI targets on the portal and store them in a variable.

    ````powerShell
    $iscsiTarget = Get-IscsiTarget -IscsiTargetPortal $iscsiTargetPortal
    ````

1. Connect to the target using multi-path. Use the IP address **10.1.128.32** on the initiator side, and **10.1.128.80** on the target side.

    ````powershell
    $iscsiTarget | Connect-IscsiTarget `
      -IsMultipathEnabled $true `
      -InitiatorPortalAddress 10.1.128.32 `
      -TargetPortalAddress 10.1.128.80 `
      -IsPersistent $true
    ````

1. Connect to the target using multi-path. Use the IP address **10.1.144.32** on the initiator side, and **10.1.144.80** on the target side.

   ````powershell
   $iscsiTarget | Connect-IscsiTarget `
      -IsMultipathEnabled $true `
      -InitiatorPortalAddress 10.1.144.32 `
      -TargetPortalAddress 10.1.144.80 `
      -IsPersistent $true
    ````

1. Close the remote PowerShell session.

   ````powershell
   Exit-PSSession
   ````

## Exercise 2: Install and configure a failover cluster

1. [Install the Remote Server Administration Failover Clustering Tools](#task-1-install-the-remote-server-administration-failover-clustering-tools) on CL1
1. [Install the failover clustering feature](#task-2-install-the-failover-clustering-feature) on VN1-SRV4 and VN1-SRV5
1. [Validate the configuration](#task-3-validate-the-configuration) on VN1-SRV4 and VN1-SRV5
1. [Create a failover cluster](#task-4-create-a-failover-cluster) with VN1-SRV4 and VN1-SRV5 as nodes with the name VN1-CLST1 and the IP address 10.1.1.33
1. [Configure the quorum](#task-5-configure-the-quorum) to use the smallest disk as disk witness
1. [Configure Cluster Shared Volumes](#task-6-configure-cluster-shared-volumes) according to the table below.

    | Name | Capacity | Path |
    |------|----------|------|
    |      | 10,0 GB  |      |
    |      | 80,0 GB  |      |

1. [Configure cluster networks](#task-7-configure-cluster-networks) accoring to the table below

    | Name | Subnets       | Enabled Options                                                                                            |
    |------|---------------|------------------------------------------------------------------------------------------------------------|
    |      | 10.1.1.0/24   | **Allow cluster network communication on this network**, **Allow clients to connect through this network** |
    |      | 10.1.128.0/24 | **Do not allow cluster network communication on this network**                                             |
    |      | 10.1.144.0/24 | **Do not allow cluster network communication on this network**                                             |
    |      | 10.1.160.0/24 | **Allow cluster network communication on this network**                                                    |

### Task 1: Install the Remote Server Administration Failover Clustering Tools

#### Desktop experience

Perform these steps on CL1.

1. Open **Settings**.
1. In Settings, click **System**.
1. In System, click **Optional features**.
1. In Optional features, click the button **View features**.
1. In View features, if necessary, click **See available features**. In the text field **Find an available optional feature**, type **RSAT**. Activate the check box beside **RSAT: Failover Clustering Tools**. Click **Add (1)**.
1. If required, restart the computer.

You do not need to wait for the completion of the installation

#### PowerShell

Perform these steps on CL1.

1. In the context menu of **Start**, click **Terminal (Admin)**.
1. Add the Windows capability **RSAT: Failover Clustering Management Tools**.

    ````powershell
    Get-WindowsCapability `
        -Online `
        -Name 'Rsat.FailoverCluster.Management.Tools*' |
    Add-WindowsCapability -Online
    ````

You do not need to wait for the completion of the installation

### Task 2: Install the failover clustering feature

#### Desktop Experience

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Reatures**.
1. In the Add Rules and Features Wizard, on page **Before You Begin**, click **Next >**.
1. On page Installation Type, ensure **Role-based or feature-based installation** is selected and click **Next >**.
1. On page Server Selection, click **VN1-SRV4.ad.lab.test** and click **Next >**.
1. On page Server Roles, click **Next >**.
1. On page Features, activate **Failover Clustering**.
1. In Add features that are required for Failover Clustering, click **Add Features**.
1. In **Add Roles and Features Wizard**, on page **Features**, click **Next >**.
1. On page Confirmation, verify your selection and click **Install**.
1. On  page **Results**, wait for the installation to succeed, then click **Close**.

Repeat the steps of this task to install the role on **VN1-SRV5**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Install **Failover Clustering** on **VN1-SRV4** and **VN1-SRV5**.

    ````powershell
    Invoke-Command -ComputerName VN1-SRV4, VN1-SRV5 -ScriptBlock {
        Install-WindowsFeature `
            -Name Failover-Clustering `
            -IncludeManagementTools `
            -Restart
    }
    ````

### Task 3: Validate the configuration

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In the left pane, in the context-menu of **Failover Cluster Manager**, click **Validate Configuration...**.
1. In Validate a Configuration Wizard, on page Before You Begin, click **Next >**.
1. On page Select Servers or a Cluster, in **Enter server name**, type **vn1-srv4.ad.lab.test** and click **Add**. Repeat for **vn1-srv5.ad.lab.test**. Click **Next >**.
1. On page Testing options, ensure **Run all tests (recommended)** is selected and click **Next >**.
1. On page Confirmation, click **Next >**.
1. On page Summary, click **View Report...**

Review every warning or error in the validation report. Correct storage, network, DNS, domain, driver, or configuration failures and repeat validation. Continue only when no blocking test fails; record any accepted lab-only warning and its reason.

### Task 4: Create a failover cluster

Perform this task on VN1-SRV4.

1. In SConfig, enter **15**.
1. Create a cluster with the name **VN1-CLST1** consisting of the nodes **VN1-SRV4** and **VN1-SRV5**. The static address for administrative purposes should be **10.1.1.33**.

    ````powershell
    New-Cluster `
        -Name VN1-CLST1 `
        -Node vn1-srv4.ad.lab.test, vn1-srv5.ad.lab.test `
        -StaticAddress 10.1.1.33
    ````

### Task 5: Configure the quorum

#### Desktop experience

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, in the context-menu of **Failover Cluster Manager**, click **Connect To Cluster...**
1. In Select Cluster, in **Cluster name**, type **VN1-CLST1** and click **OK**.
1. In **Failover Cluster Manager**, in the context-menu of **VN1-CLST1.ad.lab.test**, click **More Actions**, **Configure Cluster Quorum Settings...**
1. In Configure Cluster Quorum Wizard, on page Before You Begin, click **Next >**.
1. On page Select Quorum Configuration Option, click **Advanced quorum configuration** and click **Next >**.
1. On page Select Voting Configuration, ensure **All Nodes** is selected and click **Next >**.
1. On page Select Quorum Witness, click **Configure a disk witness** and click **Next >**.
1. On page Configure Storage Witness, expand the disks, find the disk **D** with the capacity of around 1000 MB. Activate the checkbox beside this disk and ensure, the other checkboxes are deactivated. Click **Next >**.
1. On page Confirmation, click **Next >**.
1. On page Summary, click **Finish**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. In Terminal, query the disks on the cluster **VN1-CLST1**.

    ````powershell
    $cluster = 'VN1-CLST1'
    $cimSession = New-CimSession -ComputerName $cluster
    Get-ClusterResource -Cluster $cluster | 
    Where-Object { $PSItem.ResourceType -eq 'Physical Disk' } | 
    Get-ClusterParameter -Name DiskGuid | ForEach-Object { 
        $name = $PSItem.ClusterObject
        Get-Disk -CimSession $cimSession -Path "\\?\Disk$($PSItem.Value)" | 
        Select-Object `
            @{ label = 'Name'; expression = { $name } }, `
            PartitionStyle, `
            @{ 
                label = 'Total Size'
                expression = { "$($PSItem.Size / 1GB) GB" } 
            } 
    }
    Remove-CimSession -CimSession $cimSession
    ````

    Take a note of the GPT disk's name with a total size of 1 GB.

1. Set the cluster quorum to node and disk majority.

    *Important*: Replace the name **Cluster Disk 1** with the name you took note of.

    ````powershell
    # Replace the name 'Cluster Disk 1' with the name you took note of.

    Set-ClusterQuorum -Cluster $cluster -NodeAndDiskMajority 'Cluster Disk 1'
    ````

### Task 6: Configure Cluster Shared Volumes

#### Desktop experience

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, expand **VN1-CLST1.ad.lab.test**, **Storage** and click **Disks**.
1. Refer to the table above. Under Disks (4), in the context-menu of the first disk with the capacity noted in the table and **Assigned To** **Available Storage**, click **Add to Cluster Shared Volumes**.
1. Click the same disk again. In the bottom pane, take a note of the path of the volume, e.g., **C:\ClusterStorage\Volume1**. Record the paths in form of a table like the table above.

Repeat from step 3 for all disks from the table above and **Assigned To** **Available Storage**.

In result, one disk should be assigned to **Disk Witness in Quorum**, the disks with a capacity from the table above should be assigned to **Cluster Shared Volume**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. In Terminal, query the disks on the cluster **VN1-CLST1**.

    ````powershell
    $cluster = 'VN1-CLST1'
    $cimSession = New-CimSession -ComputerName $cluster
    $cluster = 'VN1-CLST1'
    $cimSession = New-CimSession -ComputerName $cluster
    Get-ClusterResource -Cluster $cluster | 
    Where-Object { $PSItem.ResourceType -eq 'Physical Disk' } | 
    Get-ClusterParameter -Name DiskGuid | ForEach-Object { 
        $name = $PSItem.ClusterObject
        Get-Disk -CimSession $cimSession -Path "\\?\Disk$($PSItem.Value)" | 
        Select-Object `
            @{ label = 'Name'; expression = { $name } }, `
            PartitionStyle, `
            @{ 
                label = 'Total Size'
                expression = { "$($PSItem.Size / 1GB) GB" } 
            } 
    }

    Remove-CimSession -CimSession $cimSession
    ````

    Take a note of the GPT disk's name with a total size corresponding to the capacity in the table above. Complete the column name in the table.

1. Add the disks from the table as cluster shared volume.

    *Important*: Replace the names **Cluster Disk 1** and **Cluster Disk 4** with the name you took note of.

    ````powershell
    # Replace the names with the names from the table.

    Add-ClusterSharedVolume -Cluster $cluster -Name 'Cluster Disk 1'
    Add-ClusterSharedVolume -Cluster $cluster -Name 'Cluster Disk 4'
    ````

1. Query the paths of the cluster shared volumes and fill the column path in the table above.

    ````powershell
    Get-ClusterSharedVolume -Cluster $cluster | 
    Select-Object Name, SharedVolumeInfo
    ````

### Task 7: Configure cluster networks

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, expand **VN1-CLST1.ad.lab.test**, and click **Networks**.
1. In the context-menu of each cluster network, click **Properties**.
1. In Properties of each network click the options according to the table above. Take a note of the names while configuring the networks. You will need them in the next step.
1. In **Failover Cluster Manager**, in the context-menu of **Networks**, click **Live Migration Settings**.
1. In Live Migration Settings, deactivate the cluster networks corresponding to 10.1.128.0/24 and 10.1.144.0/24. Click the cluster network corresponding to the subnet 10.1.160.0/24 and click **Up** until it appears at the top of the list. Click **OK**.

## Exercise 3: Use Hyper-V on a cluster

1. [Configure nested virtualization](#task-1-configure-nested-virtualization) by exposing VMware processor virtualization extensions for the outer WIN-VN1-SRV4 and WIN-VN1-SRV5 guests. Configure each with 4 GB memory. Hyper-V MAC-spoofing commands do not apply to these outer VMware guests.
1. [Install Hyper-V](#task-2-install-hyper-v) on VN1-SRV4 and VN1-SRV5 and set the default locations to the 80 GB CSV
1. [Configure a virtual switch](#task-3-configure-a-virtual-switch) VN1-SRV4 and VN1-SRV5 connected to the network adapter VNet1
1. [Create a virtual machine](#task-4-create-a-virtual-machine) on the cluster using a diffencing disk based on TinyCorePure64.vhdx with 256 MB memory.
1. [Configure the virtual machine's operating system](#task-5-configure-the-virtual-machines-operating-system) to use the IP address 10.1.1.184

### Task 1: Configure nested virtualization

On the VMware Workstation host, shut down the Hyper-V cluster hosts named by this exercise. Open each outer VM's **Settings > Processors** and enable **Virtualize Intel VT-x/EPT or AMD-V/RVI**; allocate at least 4 GB fixed memory or the larger amount required by the workload. Record each VMnet and disk mapping, then restart the guests and verify virtualization with systeminfo. Run the later Hyper-V/cluster commands inside these nested Windows guests. Do not apply Hyper-V host commands to the outer VMware VMs.

### Task 2: Install Hyper-V

#### Desktop Experience

Perform this task on CL1.

1. Open Server Manager.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Reatures**.
1. In the Add Rules and Features Wizard, on page **Before You Begin**, click **Next >**.
1. On page Installation Type, ensure **Role-based or feature-based installation** is selected and click **Next >**.
1. On page Server Selection, click **VN1-SRV4.ad.lab.test** and click **Next >**.
1. On page Server Roles, activate **Hyper-V**
1. In Add features that are required for Hyper-V, click **Add Features**.
1. In **Add Roles and Features Wizard**, on page **Server Roles**, click **Next >**.
1. On page Features, click **Next >**.
1. On page Hyper-V, click **Next >**.
1. On page Virtual Switches, click **Next >**.
1. On page Virtual Machine Migration, click **Next >**.
1. On page Default Stores, in **Default location for virtual hard disk files**, type **C:\\ClusterStorage\\Volume*x*\\Hyper-V\\Virtual Hard Disks**, where x is the volume number you recorded for the 80 GB disk in the previous exercise. In **Default location for virtualmachine configuration files**, type **C:\\ClusterStorage\\Volume*x*\\Hyper-V**, where x is the volume number you recorded for the 80 GB disk in the previous exercise. Click **Next >**.
1. On page Confirmation, activate **Restart the destination server automatically if required** and click **Install**.
1. On  page **Results**, wait for the installation to succeed, then click **Close**.

Repeat the steps of this task to install the role on **VN1-SRV5**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Install **Hyper-V** on **VN1-SRV4** and **VN1-SRV5**.

    ````powershell
    $computerName = 'VN1-SRV4', 'VN1-SRV5'
    Invoke-Command -ComputerName $computerName -ScriptBlock {
        Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
    }
    ````

1. On **VN1-SRV4** and **VN1-SRV5**, set the default stores to the cluster shared volume of 80 GB capacity, you recorded in the previous exercise.

    *Important*: In the first line, replace *4* with the volume number recorded for 80 GB disk.

    ````powershell
    $volumeNumber = 4 # Replace with the volume number recorded for 80 GB disk
    Set-VMHost `
        -ComputerName $computerName `
        -VirtualHardDiskPath `
            "C:\ClusterStorage\Volume$volumeNumber\Hyper-V\Virtual Hard Disks" `
        -VirtualMachinePath "C:\ClusterStorage\Volume$volumeNumber\Hyper-V"
    ````

### Task 3: Configure a virtual switch

Perform this task on CL1.

1. Open **Terminal**.
1. On **VN1-SRV4** and **VN1-SRV5**, create an external switch connected to the **VNet1** network adapter. Allow the management OS to use the adapter.

    ````powershell
    $computerName = 'VN1-SRV4', 'VN1-SRV5'
    New-VMSwitch `
        -ComputerName $computerName `
        -Name External `
        -NetAdapterName VNet1 `
        -AllowManagementOS $true
    ````

### Task 4: Create a virtual machine

Perform this task on CL1.

1. Open **File Explorer**.
1. In File Explorer, copy **\\\\VN1-SRV4\\C$\\WindowsServerLab\\Resources\\TinyCorePure64.vhdx** to the **Hyper-V\\Virtual Hard Disks** folder on the recorded 80 GB CSV. Keep this parent disk's name and contents unchanged.
1. In an elevated PowerShell session on **VN1-SRV4**, create the differencing child on that same CSV. Replace the placeholder with the recorded CSV directory, verify both paths, and stop if a child already exists:

    ````powershell
    $diskRoot = 'C:\ClusterStorage\<RECORDED_CSV>\Hyper-V\Virtual Hard Disks'
    if ($diskRoot.Contains('<')) { throw 'Supply the recorded 80 GB CSV path.' }
    $parentPath = Join-Path $diskRoot 'TinyCorePure64.vhdx'
    $childPath = Join-Path $diskRoot 'VN1-SRV23.vhdx'
    if (!(Test-Path -LiteralPath $parentPath) -or (Test-Path -LiteralPath $childPath)) {
        throw 'Verify the staged parent and a new child path before continuing.'
    }
    New-VHD -Path $childPath -ParentPath $parentPath -Differencing
    Get-VHD -Path $childPath | Select-Object Path, VhdType, ParentPath
    ````

    Return to CL1. Attach **VN1-SRV23.vhdx**, not its parent, in the following wizard. Both disks must remain on shared storage for migration.
1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, expand **VN1-CLST1.ad.lab.test** and click **Roles**.
1. In **Failover Cluster Manager**, in the context-menu of **Roles**, click **Virtual Machines...**, **New Virtual Machine...**.
1. In New Virtual Machine, click **VN1-SRV4** and click **OK**.
1. In New Virtual Machine Wizard, on page Before You Begin, click **Next >**.
1. On page Specify Name and Location, in **Name**, type **VN1-SRV23** and click **Next >**.
1. On page Specify Generation, click **Generation 1** and click **Next >**.
1. On page Assign Memory, in **Startup memory**, type **256** and click **Next >**.
1. On page Configure Networking, in **Connection**, click **External** and click **Next >**.
1. On page Connect Virtual Hard Disk, click **Use an existing virtual hard disk** and click **Browse...**.
1. In Open, click **VN1-SRV23.vhdx** and click **Open**.
1. In **New Virtual Machine Wizard**, on page **Connect Virtual Hard Disk**, click **Next >**.
1. On page Completing the New Virtual Machine Wizard, click **Finish**.
1. In the **High Availability Wizard**, on page **Summary**, click **Finish**.
1. In **Failover Cluster Manager**, under **Roles (1)**, in the context-menu of **VN1-SRV23**, click **Start**.

### Task 5: Configure the virtual machine's operating system

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, expand **VN1-CLST1.ad.lab.test** and click **Roles**.
1. Under Roles (1), in the context-menu of **VN1-SRV23**, click **Connect...**.
1. In VN1-SRV23 on VN1-SRV4 - Virtual Machine Connection, click on the desktop, **System tools**, **ControlPanel**.
1. In ControlPanel, click **Network**.
1. In Network, under **IP Address**, type  **10.1.1.184**. Under **Gateway**, type **10.1.1.1**. Under **NameServers**, type **10.1.1.8**. Ensure that under **Save Configuration**, **Yes** is selected. Click **Apply** and click **Exit**.

### Task 6: Compare live migration and quick migration

Perform this task on CL1.

1. Open **Terminal**.
1. In Terminal, test the connection to 10.1.1.184 or a long period.

    ````powershell
    Test-Connection -ComputerName 10.1.1.184 -Count 1000
    ````

    > You should get a response every few seconds.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, expand **VN1-CLST1.ad.lab.test** and click **Roles**.

    Note the current **Owner Node** of **VN1-SRV23**, probably VN1-SRV4.

1. In the context-menu of **VN1-SRV23**, click **Connect...**
1. Switch to **Failover Cluster Manager**.
1. In the context-menu of **VN1-SRV23**, click **Move**, **Live Migration**, **Select Node...**
1. In Move Virtual Machine, click the node, which is not the owner node, probably VN1-SRV5, and click **OK**.

    While the virtual machine moves, observe the running connection test and the Virtual Machine Connection.

    > The connection tests continue running without any error.

    > The Virtual Machine Connection to VN1-SRV23 will stay open and connected.

1. In the context-menu of **VN1-SRV23**, click **Move**, **Quick Migration**, **Select Node...**
1. In Move Virtual Machine, click the node, which was the original owner node, probably VN1-SRV4, and click **OK**.

    While the virtual machine moves, observe the running connection test and the Virtual Machine Connection.

    > The connection tests will throw a few errors before resuming to normal.

    > The Virtual Machine Connection to VN1-SRV23 will be dropped. However, you will be able to reconnect afert a few seconds.

## Exercise 4: Install Windows Admin center on a failover cluster

1. [Download the install script](#task-1-download-the-install-script) from <https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/deploy/high-availability#prerequisites> and copy it to VN1-SRV4
1. [Uninstall Windows Admin Center](#task-2-uninstall-windows-admin-center) from VN1-SRV4
1. [Request and export a certificate](#task-3-request-and-export-a-certificate) for Windows Admin Center on VN1-SRV4 using the WebServerExportable template
1. [Install Windows Admin Center with high availability](#task-4-install-windows-admin-center-with-high-availability) on VN1-SRV4 with the IP address 10.1.1.34 and using the 10 GB volume
1. [Verify Windows Admin Center installation](#task-5-verify-windows-admin-center-installation)

    > Which roles were added to the failover cluster?

    > Which resources are used by the failover cluster?

    > How could you change the IP address of Windows Admin Center?

    > Does Windows Admin Center work?

### Task 1: Download the install script

Perform this task on CL1.

1. Open **Microsoft Edge**.
1. In Microsoft Edge, navigate to <https://learn.microsoft.com/en-us/windows-server/manage/windows-admin-center/deploy/high-availability#prerequisites>.
1. On page Deploy Windows Admin Center with high availability, under **Prerequisites**, click the link **Windows Admin Center HA Script zip file** (in the third bullet point).
1. Extract the downloaded file to **\\\\vn1-srv4\\c$\\ClusterStorage\\Volumex**. Replace x with the number of the volume with 10 GB capacity, e.g. 1.

### Task 2: Uninstall Windows Admin Center

Perform this task on VN1-SRV4.

1. In SConfig, enter **15**.
1. Uninstall Windows Admin Center.

    ````powershell
    msiexec.exe /uninstall C:\WindowsServerLab\Resources\WindowsAdminCenter.msi /quiet
    ````

1. Remove the DNS A record admincenter.

    ````powershell
    Remove-DnsServerResourceRecord `
        -ZoneName ad.lab.test `
        -RRType A `
        -Name admincenter `
        -ComputerName VN1-SRV1
    ````

### Task 3: Request and export a certificate

Perform this task on VN1-SRV4.

1. In SConfig, enter **15**.
1. Request a certificate using the template **WebServerExportable** for **admincenter.ad.lab.test**.

    ````powershell
    $hostname = 'admincenter'
    $zoneName = 'ad.lab.test'
    $fQDN = "$hostname.$zoneName"
    $enrollmentResult = Get-Certificate `
        -Template WebServerExportable `
        -SubjectName "CN=$fQDN" `
        -DnsName $hostname, $fQDN `
        -CertStoreLocation Cert:\LocalMachine\My\
    ````

1. Read a password for the PFX file.

    ````powershell
    $password = Read-Host -Prompt 'Password for PFX file' -AsSecureString
    ````

1. At the prompt Password for PFX file, enter a secure password and take a note.
1. Export the certificate to a PFX file. Store the file on the CSV with 10 GB capacity.

    ````powershell
    # Replace x with the volume with 10 GB capacity, e.g., 1
    $filePath = 'C:\ClusterStorage\Volumex\admincenter.ad.lab.test.pfx'

    Export-PfxCertificate `
        -Password $password `
        -FilePath $filePath `
        -Cert $enrollmentResult.Certificate
    ````

On VN1-SRV4, leave everything open for the next task.

### Task 4: Install Windows Admin Center with high availability

Perform this task on VN1-SRV4.

1. Treat Windows Admin Center high availability as an optional compatibility-gated extension. The source installation helper is not part of this repository.
1. Verify that the current Windows Admin Center release supports the intended failover-cluster deployment and obtain the Microsoft-supplied procedure or signed deployment package from the official product documentation.
1. Use the 10 GB CSV, the enterprise-profile address `10.1.1.34`, and the certificate exported above only when the current procedure confirms those inputs. Otherwise, stop this extension and continue with the remaining cluster exercises; do not substitute an unverified script.

1. Add a DNS host record for the admincenter to the DNS server **VN1-SRV1**.

    ````powershell
    $staticAddress = '10.1.1.34'
    Add-DnsServerResourceRecordA `
        -Name $hostname `
        -IPv4Address $staticAddress `
        -ComputerName VN1-SRV1 `
        -ZoneName $zoneName
    ````

### Task 5: Verify Windows Admin Center installation

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, expand **VN1-CLST1.ad.lab.test** and click **Roles**.

    > The role admincenter should have been added.

1. In Roles, click **admincenter**.
1. In the bottom pane, click the tab **Resources**.
1. On tab Resources, expand **Name: admincenter**

    > Windows Admin center uses a network name and an IP address as additonal resources.

1. Double click **IP Address: 10.1.1.34**.
1. In IP Address: 10.1.1.34 Properties, review the options and click **Cancel**.
1. Open **Microsoft Edge**.
1. In Microsoft Edge, navigate to <https://admincenter>.

    > Admin Center should load.

## Exercise 5: Install File Server on a failover cluster

1. [Install the File Server](#task-1-install-the-file-server-role) role on VN1-SRV4

    Verify FS-FileServer on **each** node with `Get-WindowsFeature -ComputerName VN1-SRV4 -Name FS-FileServer`, then repeat for VN1-SRV5. Repeat installation for either node where it is absent; a prior exercise name is not proof that the role exists.

1. [Configure the File Server role on the failover cluster](#task-2-configure-the-file-server-role-on-the-failover-cluster) with the name VN1-CLST1-FS and the IP address 10.1.1.35 using the 100 MB disk

### Task 1: Install the File Server role

#### Desktop experience

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Features**.
1. In Add Roles and Features Wizard, on page Before You Begin, click **Next >**.
1. On page Installation Type, ensure **Role-based or feature-basedd installation** is selected and click **Next >**.
1. On page Server Selection, click **VN1-SRV4.ad.lab.test** and click **Next >**.
1. On page Server Roles, expand **File and Storage Services (1 of 12 installed)**, **File and iSCSI Services**, and activate **File Server** and click **Next >**.
1. On page Features, click **Next >**.
1. On page **Confirmation**, click **Install**.
1. On page **Results**, click **Close**.
1. In **Server Manager**, in **File and Storage Services**, click **Servers**.

#### PowerShell

Peform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. Install the windows feature **File Server** on **VN1-SRV4**.

    ````powershell
    Install-WindowsFeature `
      -ComputerName 'VN1-SRV4' `
      -Name FS-FileServer `
      -IncludeManagementTools
    ````

### Task 2: Configure the File Server role on the failover cluster

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, expand **VN1-CLST1.ad.lab.test** and click **Roles**.
1. In the context-menu of **Roles**, click **Configure Role...**.
1. In the High Availability Wizard, on page Before You Begin, click **Next >**.
1. On page Select Role, click **File Server** and click **Next >**.
1. On page File Server Type, ensure **File Server for general use** is selected and click **Next >**.
1. On page Client Access point, in **Name**, type **VN1-CLST1-FS**. Under **Address**, beside **10.1.1.0/24**, type **10.1.1.35**. Click **Next >**.
1. On page Select Storage expand the available disks and activate the disk with a capacity of about 100 MB. Click **Next >**.
1. On page Confirmation, click **Next >**.
1. On page Summary, click **Finish**.

### Prepare the clustered witness share for dependent clusters

After **VN1-CLST1-FS** is Online, create a dedicated **Witness** folder on its recorded 100 MB shared disk and publish an SMB share named **Witness** through the clustered file-server role, not a node-local share. The resulting path is `\\VN1-CLST1-FS\Witness`. Retain administrator access and remove broad Everyone access. When a dependent cluster's computer object exists, grant that specific CNO (for example **ad\VN2-VN3-CLST1$** for the stretched cluster) share Change and NTFS Modify on this dedicated witness folder, then verify the selected cluster can configure the share witness. Add only the actual consuming CNOs; do not expose the witness as a general data share. Record the clustered share/volume mapping and fail it over before relying on it for another cluster.

## Exercise 6: Test failover

1. [Monitor cluster services](#task-1-monitor-cluster-services) by testing the network connection to 10.1.1.184 continously, monitoring the console of VN1-SRV23 and viewing the Windows Admin Center web site

1. [Simulate a failure](#task-2-simulate-a-failure) by turning off the node running the roles

    > What happens to the Windows Admin Center?

    > What happens to the virtual machine?

### Task 1: Monitor cluster services

Perform this task on CL1.

1. Open Microsoft Edge and navigate to <https://admincenter>.

    > Windows Admin Center should load.

1. Open **Terminal**.
1. In Terminal, test the connection to 10.1.1.184 or a long period.

    ````powershell
    Test-Connection -ComputerName 10.1.1.184 -Count 1000
    ````

    > You should get a response every few seconds.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, expand **VN1-CLST1.ad.lab.test** and click **Roles**. Take a note of the **Owner Node** of each service. If the Owner Node is not the same for all services, perform these additional steps:

    1. In the context-menu of the service, click **Move**, **Select Node...** or **Move**, **Live Migration**, **Select Node...**.
    1. In the following dialog, select the other node and click **OK**.

1. In Roles, in the context-menu of **VN1-SRV23**, click **Connect...**.
1. In VN1-SRV23 on VN1-SRV4 - Virtual Machine Connection, open an application, e.g. Editor.
1. Arrange the window of **VN1-SRV23 on VN1-SRV4 - Virtual Machine Connection** so, that you can monitor it, while continuing with the next steps.

Keep all windows open for the next task.

### Task 2: Simulate a failure

Perform this task on the host.

1. Arrange the VMware CL1 console and the inner VN1-SRV23 connection so you can monitor the management view and workload.
1. Open **VMware Workstation**.
1. Identify the outer VMware VM for the recorded owner of the cluster roles. Choose **VM > Power > Power Off** for this controlled disposable-node failure simulation.

    > After a few seconds, in **Failover Cluster Manager**, **Roles** the **admincenter** should move to the other node and the Windows Admin Center should stay available.

    > VN1-SRV23 should restart on the recorded **surviving node** (not necessarily VN1-SRV5). Verify its actual owner and reconnect to the guest. Verify WAC availability only if its optional clustered deployment was successfully completed.

1. In VMware Workstation, power on the outer VM you just turned off and verify the cluster node rejoins.

## Exercise 7: Use cluster-aware updating

### Task 1: Configure cluster-aware updating

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, in the context-menu of **VN1-CLST1.ad.lab.test**, click **More Actions**, **Cluster-Aware Updating**.
1. In VN1-CLST1 - Cluster-Aware Updating, click **Preview updates for this cluster**.
1. In VN1-CLST1 - Preview Updates, click **Generate Update Preview List**.

    If there are any updates, review the list.

1. Click **Close**.
1. In **VN1-CLST1 - Cluster-Aware Updating**, click **Analyze cluster readiness**.
1. Review the results and click **Close**.
1. In **VN1-CLST1 - Cluster-Aware Updating**, click **Create or modify Updating Run Profile**.
1. In Updating Run Profile Editor, review the options and click **Close**.

### Task 2: Run cluster-aware updating

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, in the context-menu of **VN1-CLST1.ad.lab.test**, click **More Actions**, **Cluster-Aware Updating**.
1. In VN1-CLST1 - Cluster-Aware Updating, click **Apply updates to this cluster**.
1. In VN1-CLST1 - Cluster-Aware Updating Wizard, on page Getting Started, click **Next >**.
1. On page Advanced Options, click **Next >**.
1. On page Additional Update Options, click **Next >**.
1. On page Confirmation, click **Update**.
1. On page Completion, click **Close**.
1. In **VN1-CLST1 - Cluster-Aware Updating**, observe the update progress.

While the updates progress, you may want to observe the nodes in **Failover Cluster Manager**. Moreover, you may open the console on VN1-SRV4 and VN1-SRV5 to observe the reboots. You may continue to the next task, while the updates are applied. The update process wil take more than 40 minutes in total.

### Task 3: Configure cluster self-updating options

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, in the context-menu of **VN1-CLST1.ad.lab.test**, click **More Actions**, **Cluster-Aware Updating**.
1. In VN1-CLST1 - Cluster-Aware Updating, click **Configure cluster self-updating options**.
1. In VN1-CLST1 - Configure Self-Updating Options Wizard, on page Getting Startetd, click **Next >**.
1. On page Add CAU Clustered Role with Self-Updating Enabled, activate **Add the CAU clustered role, with self-updating mode enabled**, to this cluster and click **Next >**.
1. On page Specify self-updating schedule, click **Next >**.
1. On page Advanced Options, click **Next >**.
1. On page Additional Update Options, activate **Give me recommended updates the same way that I receive important updates** and click **Next >**.
1. On page Confirmation, click **Apply**.
1. On page Completion, click **Close**.
