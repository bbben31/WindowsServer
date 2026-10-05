# Lab: Storage QoS

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Installing-and-configuring-a-fail-over-cluster.md; Instructions/Labs/Configuring-and-managing-Storage-Spaces-Direct-and-hyper-converged-virtualization.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Enable VMware processor virtualization extensions on powered-off outer hosts; run Hyper-V commands only inside the declared nested lab layer. Retain VN1-CLST1 and VN1-CLST2 SOFS/CSV from the two cluster prerequisites; record owner nodes and actual CSV volume paths before moving VN1-SRV24.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV11 (VMware display: VN1-SRV11; accepted display aliases: WIN-VN1-SRV11; existing); VN1-SRV12 (VMware display: VN1-SRV12; accepted display aliases: WIN-VN1-SRV12; existing); VN1-SRV24 (Hyper-V name: VN1-SRV24; accepted display aliases: WIN-VN1-SRV24; existing-inner); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV6 (VMware display: VN1-SRV6; accepted display aliases: WIN-VN1-SRV6; existing); VN1-SRV7 (VMware display: VN1-SRV7; accepted display aliases: WIN-VN1-SRV7; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments.

**Permissions:** Local Administrator on the explicitly declared nested Hyper-V hosts and inner guests; cluster administrator for cluster changes. VMware settings permission on the outer host.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware.

**Success verification:** Get-StorageQosFlow/Policy show the intended policy on the moved inner VM and its workload remains usable.

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

### Task

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

### Task

Perform this task on VN1-SRV4.

1. Move all virtual machine data of **VN1-SRV24** to **\\\\VN1-CLST2-SOFS2\\Hyper-V Data**.

    ````powershell
    Move-VMStorage `
        -Name VN1-SRV24 `
        -DestinationStoragePath '\\VN1-CLST2-SOFS2\Hyper-V Data'
    ````

### Task

Perform this task on CL1.

1. Open **Failover Cluster Manager**.
1. In Failover Cluster Manager, expand **VN1-CLST1.ad.lab.test** and click **Roles**.
1. In the context-menu of **Roles**, click **Configure Role...**.
1. In High Availability Wizard, on page Before You Begin, click **Next >**.
1. On page Select Role, click **Virtual Machine** and click **Next >**.
1. On page Select Virtual Machine, activate the checkbox next to **VN1-SRV24** and click **Next >**.
1. On page Confirmation, click **Next >**.
1. On page Summary, click **Finish**.
