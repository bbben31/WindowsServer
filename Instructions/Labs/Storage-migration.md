# Lab: Storage migration

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-prerequisites-for-file-serving.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); CL2 (VMware display: CL2; accepted display aliases: WIN-CL2; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV7 (VMware display: VN1-SRV7; accepted display aliases: WIN-VN1-SRV7; existing); VN1-SRV8 (VMware display: VN1-SRV8; accepted display aliases: WIN-VN1-SRV8; existing). At least 1 of [VN1-SRV1, VN1-SRV5]: Use the active AD DNS/controller from the documented deployment lineage; do not restart a retired DC. Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Official Microsoft Windows Admin Center download/extension endpoints.

**Risk, cost and optional status:** high; local-only; optional=true. Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware. Verify current support for optional products before execution.

**Success verification:** The destination contains the intended shares/data/ACLs and the cutover client reaches the intended server identity.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision only existing prerequisite machines, disks, cluster roles and certificates before starting; create machines marked Created during exercise in their designated tasks. Follow alternatives and conditional-retirement requirements instead of starting every named VM; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Required VMs

* CL1
* CL2
* VN1-SRV10
* VN1-SRV4
* VN1-SRV7
* VN1-SRV8
* One active domain controller: VN1-SRV1 or VN1-SRV5

## Setup

1. On **VN1-SRV10**, sign in as **ad\Administrator**.
1. Open **Terminal**.
1. In Terminal, execute the following PowerShell command.

    ````powershell
    Get-NetAdapter |
    Where-Object { $PSItem.Name -ne 'VNet1' } |
    Disable-NetAdapter -Confirm:$false
    ````

1. Sign out from VN1-SRV10.
1. On **CL1**, sign in as **ad\Administrator**.
1. On **CL2**, sign in as **ad\Administrator**.

Complete [Install prerequisites for file server](../Practices/Install-prerequisites-for-file-serving.md) before continuing.

## Introduction

Adatum wants to migrate shares to a different server to reduce the number of servers.

## Exercises

1. [Migrating shares](#exercise-1-migrating-shares)
1. [Verify the migration](#exercise-2-verify-the-migration)

## Exercise 1: Migrating shares

1. [Enable firewall rules on the destination server](#task-1-enable-firewall-rules-on-the-destination-server) VN1-SRV7 necessary for the storage migration
1. [Install Storage Migration Service on the orchestration server](#task-2-install-storage-migration-service-on-the-orchestration-server) VN1-SRV8
1. [Create a migration job and inventory server](#task-3-create-a-migration-job-and-inventory-server)
1. [Transfer data](#task-4-transfer-data) to VN1-SRV7
1. [Cut over to the new server](#task-5-cut-over-to-the-new-server)

### Task 1: Enable firewall rules on the destination server

Perform this task on CL1.

1. Open **Microsoft Edge** and navigate to <https://admincenter>.
1. In Windows Admin Center, click **vn1-srv7.ad.lab.test**.
1. Connected to vn1-srv7.ad.lab.test, under **Tools**, click **Firewall**.
1. Under Firewall, click the tab **Incoming rules**.
1. On the tab Incoming rules, click the rule **File and Printer Sharing (SMB-In)** and click **Enable**.

    Repeat this step for the following rules:

    * Netlogon Service (NP-In)
    * Windows Management Instrumentation (DCOM-In)
    * Windows Management Instrumentation (WMI-In)

### Task 2: Install Storage Migration Service on the orchestration server

Perform this task on CL1.

1. Open **Microsoft Edge** and navigate to <https://admincenter>.
1. In Windows Admin Center, click **vn1-srv8.ad.lab.test**.
1. Connected to vn1-srv8.ad.lab.test, under **Tools**, click **Storage Migration Service**.
1. Under Storage Migration Service, click **Install**.

    Wait for the setup to finish. This should take about a minute.

1. In Migrate storage in three steps, activate **Don't show this again** and click **Close**.

### Task 3: Create a migration job and inventory server

Perform this task on CL1.

1. Open **Microsoft Edge** and navigate to <https://admincenter>.
1. In Windows Admin Center, click **vn1-srv8.ad.lab.test**.
1. Connected to vn1-srv8.ad.lab.test, under **Tools**, click **Storage Migration Service**.
1. In **Windows Admin Center**, under **Storage Migration Service**, click **+ New Job**.
1. In the New job pane, under **Job name**, type **MigrationJob1**. Under **Source devices**, ensure **Windows servers and clusters** is selected and click **OK**.
1. Under 1 Inventory servers, on page Check the prerequisites, click **Next**.
1. On page Enter credentials for the devices you want to migration, type the credentials of **ad\Administrator**. Ensure, **Include administrative shares** is not activated. Click to deactivate **Migrate from failover clusters**. Click **Next**.

    On page Install required tools, wait for the installation to finish. This takes about a minute.

1. Click **Next**.
1. On page Add and scan devices, click **Add a device**.
1. In pane Add source device, in **Name**, type **VN1-SRV10** and click **Add**
1. On page **Add and scan device**, click **VN1-SRV10**. Then, click **Start scan**.

    Wait for the scan to finish. This takes about a minute. After the scan has finished, you may explore the details in the bottom pane.

1. Click **Next**.

### Task 4: Transfer data

Perform this task on CL1.

If you proceeded from the previous task, you may skip to step 5.

1. Open **Microsoft Edge** and navigate to <https://admincenter>.
1. In Windows Admin Center, click **vn1-srv8.ad.lab.test**.
1. Connected to vn1-srv8.ad.lab.test, under **Tools**, click **Storage Migration Service**.
1. Under Storage Migration Service, click **MigrationJob1**.
1. Under 2 Transfer data, on page **Enter credentials for the destination devices**, type the credentials of **ad\Administrator** and click **Next**.
1. On page vn1-srv10.ad.lab.test, ensure **Use an existing server or VM** is selected. Under **Destination device**, type **VN1-SRV7** and click **Scan**.

    Wait for the scan to complete. This takes about a minute or two.

1. Under **Map each source volume to a destination volume**, in line with **Source volume** D:, in column **Destination volume**, click **C:**. Click **Next**.

    After you clicked Next, it may take a minute for the wizard to proceed. Be patient!

1. On page Adjust settings, under **Validation method (checksum) for transmitted files**, click **CRC64**. Review other settings and click **Next**.

    After you clicked Next, it may take a minute for the wizard to proceed. Be patient!

    On page Install required features, wait for the installation to finish. This takes about a minute.

1. On page Validate devices, click **Validate**.

    Wait for the validation to finish. The column **Validation** should show **Pass**. If it shows a Warning, you may still able to proceed.

1. Click **Next**.
1. On page Start the transfer, click **Start transfer**.

    After you click Start transfer, it may take up to a minute for the user interface to update. Wait for the transfer to finish. This will take less than a minute. You may explore the details in the bottom pane.

1. Click **Next**.

### Task 5: Cut over to the new server

Perform this task on CL1.

If you proceeded from the previous task, you may skip to step 5.

1. Open **Microsoft Edge** and navigate to <https://admincenter>.
1. In Windows Admin Center, click **vn1-srv8.ad.lab.test**.
1. Connected to vn1-srv8.ad.lab.test, under **Tools**, click **Storage Migration Service**.
1. Under Storage Migration Service, click **MigrationJob1**.
1. Under 3 Cut over to the new servers, on page **Enter credentials**, under **Enter credentials for the source devices** and **Enter credentials for the destination devices**, ensure **Stored credentials** is selected and click **Next**.
1. On page vn1-srv10.ad.lab.test, in column **Destination network adapters**, for the source network adapter **VNet1** select the destination network adapter with the same name. Under **VNet1**, under **IP address**, type **10.1.1.81**. Under **Subnet**, type **255.255.255.0**, under **Gateway**, type **10.1.1.1**.
1. On page Adjust settings, under **Enter AD credentials**, ensure **Stored credentials** is selected and click **Next**.
1. On page Validate devices, click **Validate**.

    Wait for the validation to finish.  The column **Validation** should show **Pass**.

1. Click **Next**.
1. On page Cut over to the new servers, click **Start cutover**.

    Wait for the cutover to finish. The cutover will take a few minutes. You may observe the source and destination computers to reboot two times.

1. Click **Finish**.

## Exercise 2: Verify the migration

1. [Verify changes on the source server](#task-1-verify-changes-on-the-source-server) VN1-SRV10 and shut down the computer

    > What is the computer name of former VN1-SRV10?

    > Which IP address does VNet1 have?

    > Which IP address do SAN1 and SAN2 have?

1. [Verify the changes on the destination server](#task-2-verify-changes-on-the-destination-server) VN1-SRV7

    > What is the computer name of former VN1-SRV7?

    > What are the IP addresses of the network adapters?

1. [Verify client access to the shares](#task-3-verify-client-access-to-the-shares)

    > What are the permissions on the shares?

    > What is the content of the shares?

### Task 1: Verify changes on the source server

Perform this task on VN1-SRV10.

1. Sign in as **ad\Administrator**.
1. Open **Server Manager**.
1. In Server Manager, click **Local Server**.

    > The computer name will be a random name starting with WIN-.
    
    > The IP address of VNet1 should be the IP address you defined in the previous exercise.
    
    > SAN1 and SAN2 should be configured as DHCP clients.

1. Shut down the computer.

### Task 2: Verify changes on the destination server

Perform this task on VN1-SRV7.

1. Sign in as **ad\Administrator**.

    SConfig will start. The computer name will be VN1-SRV10.

1. Enter **8**.

    The IP addresses of the network adapter VNet1 will be 10.1.1.80.

1. Press ENTER.
1. Enter **12**.
1. Enter **y**.

### Task 3: Verify client access to the shares

Perform this task on CL1.

1. In **File Explorer**, navigate to **\\\\VN1-SRV10**.
1. In the context menu of **Finance**, click **Properties**.
1. In Finance properties, click the tab **Security**.

    > Beyond entries for CREATOR OWNER, SYSTEM, and Administrators, Finance Read should have Read & execute, and Finance Modify should have Modify permissions.

1. Click **Cancel**
1. Double-click **Finance**.

    > The content of Finance should be the same as throughout other labs.

If time permits, repeat from step 2 for the other shares.
