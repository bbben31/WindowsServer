# Lab: Storage QoS

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Installing-and-configuring-a-fail-over-cluster.md; Instructions/Labs/Configuring-and-managing-Storage-Spaces-Direct-and-hyper-converged-virtualization.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Enable VMware processor virtualization extensions on powered-off outer hosts; run Hyper-V commands only inside the declared nested lab layer. Retain VN1-CLST1 and VN1-CLST2 SOFS/CSV from the two cluster prerequisites; record owner nodes and actual CSV volume paths before moving VN1-SRV24. Before cross-cluster moves, record/remove only VN1-SRV24's prior HA registration; retain its VM/disks. Verify authenticated host migration and compute-account SMB/NTFS access to both SOFS shares.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV11 (VMware display: VN1-SRV11; accepted display aliases: WIN-VN1-SRV11; existing); VN1-SRV12 (VMware display: VN1-SRV12; accepted display aliases: WIN-VN1-SRV12; existing); VN1-SRV24 (Hyper-V name: VN1-SRV24; accepted display aliases: WIN-VN1-SRV24; existing-inner); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV6 (VMware display: VN1-SRV6; accepted display aliases: WIN-VN1-SRV6; existing); VN1-SRV7 (VMware display: VN1-SRV7; accepted display aliases: WIN-VN1-SRV7; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments.

**Permissions:** Local Administrator on the explicitly declared nested Hyper-V hosts and inner guests; cluster administrator for cluster changes. VMware settings permission on the outer host.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware.

**Success verification:** On VN1-CLST2 create the dedicated Lab-SRV24 policy; on the compute owner apply its recorded ID to the intended VM disks and verify prior IDs are retained for cleanup. Get-StorageQosFlow/Policy show that ID and 10/100 normalized-IOPS settings while the guest remains usable. Record missing/error flows and quiet workload limits instead of claiming measured throttling.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10
* VN1-SRV11
* VN1-SRV12
* VN1-SRV24
* VN1-SRV4
* VN1-SRV5
* VN1-SRV6
* VN1-SRV7


> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision only existing prerequisite machines, disks, cluster roles and certificates before starting; create machines marked Created during exercise in their designated tasks. Follow alternatives and conditional-retirement requirements instead of starting every named VM; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Setup

1. On CL1, sign in as **ad\Administrator**.
1. On VN1-SRV4, sign in as **ad\Administrator**.
1. In SConfig, enter **15**.

Before moving VN1-SRV24 between clusters, record its current owner, VM ID, disks, paths and cluster role. Remove only its high-availability registration from **VN1-CLST2** in Failover Cluster Manager (do not delete the VM or disks), then verify the VM remains available in Hyper-V on its recorded host. Cross-host migration must already be enabled/authenticated between that host and VN1-SRV4; otherwise stop before `Move-VM`. Both SOFS shares must grant the compute-host computer accounts the required SMB and NTFS access.

## Exercise 1: Move virtual machine data

### Task 1: Move virtual machine data to the SOFS share

Perform this task on the owner node of VN1-SRV24.

1. Sign in as **ad\Administrator**.
1. In SConfig, enter **15**.
1. Move the data of VN1-SRV24 to **\\\\VN1-CLST2-SOFS\\Hyper-V Data\\**

   ````powershell
   Move-VMStorage `
      -Name VN1-SRV24 `
      -DestinationStoragePath '\\vn1-clst2-sofs\Hyper-V Data'
   ````

### Task 2: Move the virtual machine to VN1-SRV4

Perform this task on the owner node of VN1-SRV24.

1. Sign in as **ad\Administrator**.
1. In SConfig, enter **15**.
1. Move the virtual machine VN1-SRV24 to the host VN1-SRV4. Move all data to **C:\ClusterStorage\Volumex\Hyper-V**, where x is the volume number you recorded for the 80 GB disk on VN1-CLST1 in the previous lab.

    ````powershell
    Move-VM `
        -Name VN1-SRV24 `
        -DestinationHost VN1-SRV4 `
        -DestinationStoragePath 'c:\clusterstorage\volumex\Hyper-V' # Replace x
    ````

### Task 3: Move virtual machine data to the second SOFS share

Perform this task on VN1-SRV4.

1. Move all virtual machine data of **VN1-SRV24** to **\\\\VN1-CLST2-SOFS2\\Hyper-V Data**.

    ````powershell
    Move-VMStorage `
        -Name VN1-SRV24 `
        -DestinationStoragePath '\\VN1-CLST2-SOFS2\Hyper-V Data'
    ````

### Task 4: Make the virtual machine highly available

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, expand **VN1-CLST1.ad.lab.test** and click **Roles**.
1. In the context-menu of **Roles**, click **Configure Role...**.
1. In High Availability Wizard, on page Before You Begin, click **Next >**.
1. On page Select Role, click **Virtual Machine** and click **Next >**.
1. On page Select Virtual Machine, activate the checkbox next to **VN1-SRV24** and click **Next >**.
1. On page Confirmation, click **Next >**.
1. On page Summary, click **Finish**.

## Exercise 2: Create, apply and observe a Storage QoS policy

Follow the [Microsoft Storage QoS guidance](https://learn.microsoft.com/en-us/windows-server/storage/storage-qos/storage-qos-overview). Use the storage cluster serving **VN1-CLST2-SOFS2**, not the compute cluster, for policy creation and flow queries.

1. On a node of **VN1-CLST2**, verify **Storage Qos Resource** is Online with `Get-ClusterResource -Name 'Storage Qos Resource'`. Record any pre-existing policy named **Lab-SRV24** and stop if it is not owned by this exercise.
1. In that node's elevated PowerShell, create a dedicated policy and record its ID:

    ````powershell
    $policy = New-StorageQosPolicy -Name 'Lab-SRV24' -PolicyType Dedicated -MinimumIops 10 -MaximumIops 100
    $policy | Format-List Name, PolicyId, MinimumIops, MaximumIops
    ````

1. On the current **VN1-CLST1** owner of **VN1-SRV24**, list `Get-VMHardDiskDrive -VMName VN1-SRV24` and record each existing QoSPolicyID. Apply the newly recorded ID to this VM only:

    ````powershell
    $policyId = [guid](Read-Host 'Paste the Lab-SRV24 policy ID from VN1-CLST2')
    Get-VMHardDiskDrive -VMName VN1-SRV24 | Set-VMHardDiskDrive -QoSPolicyID $policyId
    Get-VMHardDiskDrive -VMName VN1-SRV24 | Select-Object Path, QoSPolicyID
    ````

1. Start VN1-SRV24 and verify its guest remains usable. On a **VN1-CLST2** node, inspect the policy and live disk flows:

    ````powershell
    Get-StorageQosPolicy -Name 'Lab-SRV24' | Format-List
    Get-StorageQosFlow -InitiatorName 'VN1-SRV24' |
        Format-Table InitiatorName, PolicyId, MinimumIOPS, MaximumIOPS, StorageNodeIOPS, Status, FilePath -AutoSize
    ````

1. Compare the ID and 10/100 normalized-IOPS settings with the host configuration. Observe again after guest disk activity. A quiet TinyCore guest may produce little disk I/O; minimum IOPS is a reservation under demand, not a requirement to issue 10 IOPS. If performing a bounded file-copy test, first identify a mounted persistent guest volume, use only a disposable file in its test directory, and never write to a raw device or memory-only filesystem as proof of disk throttling. Record **UnknownPolicyId**, **InsufficientThroughput**, missing flows or unsupported migration as failures/limitations, not a successful policy test.
1. When dependent exercises finish, restore each disk's recorded prior QoSPolicyID on the compute owner. Only then remove the exercise policy on VN1-CLST2 with `Get-StorageQosPolicy -Name 'Lab-SRV24' | Remove-StorageQosPolicy`. Retain VM storage and prerequisite cluster roles until their consumers finish.
