# Practice: Configure basic Hyper-V settings

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-the-Hyper-V-role.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Enable VMware processor virtualization extensions on powered-off outer hosts; run Hyper-V commands only inside the declared nested lab layer.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV1 (VMware display: PM-SRV1; accepted display aliases: WIN-PM-SRV1; existing); PM-SRV2 (VMware display: PM-SRV2; accepted display aliases: WIN-PM-SRV2; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing).  Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the explicitly declared nested Hyper-V hosts and inner guests; cluster administrator for cluster changes. VMware settings permission on the outer host.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** Get-VMHost and Get-VMSwitch show the requested paths, live-migration setting and external switch on both inner hosts.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


> **Optional nested-Hyper-V exercise:** This source topic is not part of the default VMware host path. Perform it only inside a dedicated nested Hyper-V guest as described in [Advanced Infrastructure](../General/Advanced-Infrastructure.md).

## Required VMs

* CL1
* PM-SRV1
* PM-SRV2
* VN1-SRV1

## Task

On PM-SRV1 and PM-SRV2, set the default path for virtual machines to C:\\Hyper-V and, for virtual hard disks, to C:\\Hyper-V\\Virtual Hard Disks. Moreover, on both servers, enable live migrations and create an external virtual switch.

## Instructions

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Terminal**.
1. On PM-SRV1, create a directory **C:\\Hyper-V\\Virtual Hard Disks**

    ````powershell
    Invoke-Command -ComputerName PM-SRV1 -ScriptBlock {
        New-Item -Path 'C:\Hyper-V\Virtual Hard Disks' -ItemType Directory
    }
    ````

1. Open **Hyper-V Manager**.
1. In Hyper-V Manager, in the context menu of **Hyper-V Manager**, click **Connect to Server...**
1. In Select Computer, ensure **Another computer** is selected, type **PM-SRV1**, and click **OK**.
1. In **Hyper-V Manager**, click **PM-SRV1**.
1. In the context-menu of **PM-SRV1**, click **Hyper-V Settings**.
1. In Hyper-V Settings for PM-SRV1, ensure **Virtual Hard Disks** is selected. Under **Virtual Hard Disks**, cick **Browse...**
1. In Select Folder, expand **pm-srv1.ad.lab.test**, **Local Disk (C:)**, **hyper-v** and click **Virtual Hard Disks**. Click **Select Folder**.
1. In **Hyper-V Settings for PM-SRV1**, in the left pane, click **Virtual Machines**.
1. Under Virtual Machines, click **Browse...**.
1. In Select Folder, expand **pm-srv1.ad.lab.test**, **Local Disk (C:)** and click **hyper-v**. Click **Select Folder**.
1. In **Hyper-V Settings for PM-SRV1**, click **Live Migrations**.
1. Under Live Migrations, activate **Enable incoming and outgoing live migrations** and click **Use any available network for the live migration**.
1. In the left pane, expand **Live Migrations** and click **Advanced Features**.
1. Under Advanced Features, ensure **Use Credential Security Support Provider (CredSSP)** is selected. Under **Performance options**, ensure **Compression** is selected.
1. Click **OK**.
1. In **Hyper-V Manager**, in the context-menu of **PM-SRV1**, click **Virtual Switch Manager...**
1. In Virtual Switch Manager for PM-SRV1, in the left pane, ensure **New virtual network switch** is selected. In the right pane, under **Create virtual switch**, ensure **External** is selected and click **Create Virtual Switch**.
1. Under **Name**, type **External**. Under **Connection type**, ensure **External network** and **Microsoft Hyper-V Network Adapter** is selected. Ensure, **Allow management operating system to share this network adapter** is activated. Click **OK**.
1. In the message box Apply Networking Changes, click **Yes**.

Repeat this task from step 3 for **PM-SRV2**.
