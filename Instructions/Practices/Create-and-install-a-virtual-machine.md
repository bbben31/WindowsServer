# Practice: Create and install a virtual machine

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Configure-basic-Hyper-V-settings.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Enable VMware processor virtualization extensions on powered-off outer hosts; run Hyper-V commands only inside the declared nested lab layer.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV1 (VMware display: PM-SRV1; accepted display aliases: WIN-PM-SRV1; existing); PM-SRV20 (Hyper-V name: PM-SRV20; accepted display aliases: WIN-PM-SRV20; created); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing).  Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the explicitly declared nested Hyper-V hosts and inner guests; cluster administrator for cluster changes. VMware settings permission on the outer host.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** The new inner PM-SRV20 boots Server Core and Get-VM shows its intended processor, memory and integration settings.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


> **Optional nested-Hyper-V exercise:** This source procedure is retained for a dedicated nested Hyper-V guest. The default learner VM creation path is VMware Workstation Pro 17.

## Required VMs

* CL1
* PM-SRV1
* PM-SRV20 (created during this exercise)
* VN1-SRV1

## Task

On PM-SRV1, create a new virtual machine with the name PM-SRV20. The virtual machine should have 1 GB of memory, 4 virtual processor, time synchronization disabled, and should install Windows Server Core from 2025_x64_EN_Eval.iso.

> Why would you want to deactivate time synchronization?

## Instructions

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Hyper-V Manager**.
1. In Hyper-V Manager, click **PM-SRV1**.
1. In the context-menu of **PM-SRV1**, click **New**, **Virtual Machine...**
1. In New Virtual Machine Wizard, on page Before You Begin, click **Next >**.
1. On page Specify name and Location, in **Name**, type **PM-SRV20** and click **Next >**.
1. On page Specify Generation, click **Generation 2** and click **Next >**.
1. On page Assign Memory, in **Startup Memory**, type **1024** and click **Next >**.
1. On page Configure Networking, in **Connection**, click **External** and click **Next >**.
1. On page Connect virtual hard disk, ensure **Create a virtual hard disk** is selected. In **Name**, ensure **PM-SRV20.vhdx**, and, in location **C:\\hyper-v\\Virtual Hard Disks\\** is filled in. Click **Next >**.
1. On page Installation Options, click **Install an operating system from a bootable image file** and click **Browse...**
1. In Open, expand **pm-srv1.ad.lab.test**, **Local Disk (C:)**, **WindowsServerLab**, and click **Resources**.
1. Click **2025_x64_EN_Eval.iso** and click **Open**.
1. In **New Virtual Machine Wizard**, on page **Installation Options**, click **Next >**.
1. On page Summary, click **Finish**.
1. In **Hyper-V Manager**, under **Virtual machines**, in the context-menu of **PM-SRV20**, click **Settings...**.
1. In **Settings for PM-SRV20 on PM-SRV1**, click **Security**.
1. Under **Encryption Support**, activate **Enable Trusted Platform Module** and activate **Encrypt state and virtual machine migration traffic**.
1. Click **Processor**.
1. Under Processor, in **Number of virtual processors**, type **4**.
1. Click **Integration Services**.
1. Under Integration Services, deactivate **Time synchronization**.

    > On domain-joined computers, it is recommended to disable time synchronization, because they synchronize the time with a domain controller.

1. Click **OK**.
1. In **Hyper-V Manager**, under **Virtual machines**, in the context-menu of **PM-SRV20**, click **Connect...**.
1. In PM-SRV20 on PM-SRV1 - Virtual Machine Connection, in the menu, click **Action**, **Start**.
1. On the message Press any key to boot from CD or DVD, press any key within a few seconds. If fail to do so, and the VM tries to start PXE over IPv4, on the menu, click **Action**, **Reset...**.
1. In Windows Server Setup, on page Select language settings, configure **Time and currency format**  as you wish and click **Next**.
1. On page Select keyboard settings, configure the **Keyboard or input method** as you wich and click **Next**.
1. On page Select setup option, ensure **Install Windows Server** is selected, click **I agree everything will be deleted including files, apps, and settings** and click **Next**.
1. On page Select image, click **Windows Server 2025 Datacenter Evaluation** and click **Next**.
1. On page Applicable notices and license terms, click **Accept**.
1. On page Select location to install Windows Server, explore the options and click **Next**.
1. On page Ready to install, click **Install**.

Do not wait for the installation to finish.
