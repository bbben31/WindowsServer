# Practice: Create Windows Server Update Services automatic approval rules

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Create-Windows-Server-Update-Services-computer-groups.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Microsoft Windows Update/WSUS and feature-on-demand endpoints.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** WSUS displays the requested approval rules and a completed synchronization; inspect approvals in the intended groups.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV5

## Task

In Update Services on VN1-SRV5, create automatic approval rules:

* Definition updates should be approved immediately.
* Critical updates should be approved after 2 days.
* For the Insider group, all updates should be approved immediately.
* For the Target group, all other updates should be approved after 7 days.
* For the Standard group, all other updates should be approved after 14 days.

Start the synchronization manually.

## Instructions

Perform this task on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Windows Server Update Services**.
1. In Update Services, expand **VN1-SRV5** and click **Options**.

    If you do not see **VN1-SRV5**, perform these steps:

    1. In Update Services, in the context-menu of **Update Services**, click **Connect to Server...**
    1. In Connect to Server, beside **Server name**, type **VN1-SRV5** and click **Connect**.

1. Under Options, click **Automatic Approvals**.
1. In Automatic Approvals, click **New Rule...**
1. In Add Rule, under **Step 1: Select properties**, activate **When an update is in a specific classification**.
1. Under **Step 2: Edit the properties (click an underlined value)**, click **any classification**.
1. In Choose Update Classifications, deactivate **All Classifications** and activate **Definition Updates**. Click **OK**.
1. In **Add Rule**, under **Step 3: Specify a name**, type **Definition Updates** and click **OK**.
1. In **Automatic Approvals**, click **New Rule...**
1. In Add Rule, under **Step 1: Select properties**, activate **When an update is in a specific classification** and **Set a deadline for the approval**.
1. Under **Step 2: Edit the properties (click an underlined value)**, click **any classification**.
1. In Choose Update Classifications, deactivate **All Classifications** and activate **Critical Updates**. Click **OK**.
1. In **Add Rule**, under **Step 2: Edit the properties (click an underlined value)**, click **all computers**.
1. In Choose Computer Groups, deactivate **Insider** and click **OK**.
1. In **Add Rule**, under **Step 2: Edit the properties (click an underlined value)**, click **7 days after the approval at 03:00**.
1. In Choose Deadline, beside **Days**, type **2** and click **OK**.
1. In **Add Rule**, under **Step 3: Specify a name**, type **Critical Updates** and click **OK**.
1. In **Automatic Approvals**, click **New Rule...**
1. Under **Step 2: Edit the properties (click an underlined value)**, click **all computers**.
1. In Choose Computer Groups, deactivate **All Computers** and activate **Insider**. Click **OK**.
1. In **Add Rule**, under **Step 3: Specify a name**, type **Insider Updates** and click **OK**.
1. In **Automatic Approvals**, click **New Rule...**
1. In Add Rule, under **Step 1: Select properties**, activate **When an update is in a specific classification** and **Set a deadline for the approval**.
1. Under **Step 2: Edit the properties (click an underlined value)**, click **any classification**.
1. In Choose Update Classifications, deactivate **Critical Updates** and **Definition Updates**. Click **OK**.
1. In **Add Rule**, under **Step 2: Edit the properties (click an underlined value)**, click **all computers**.
1. In Choose Computer Groups, deactivate **All Computers** and activate **Target**. Click **OK**.
1. In **Add Rule**, under **Step 3: Specify a name**, type **Target updates** and click **OK**.
1. In **Automatic Approvals**, click **New Rule...**
1. In Add Rule, under **Step 1: Select properties**, activate **When an update is in a specific classification** and **Set a deadline for the approval**.
1. Under **Step 2: Edit the properties (click an underlined value)**, click **any classification**.
1. In Choose Update Classifications, deactivate **Critical Updates** and **Definition Updates**. Click **OK**.
1. In **Add Rule**, under **Step 2: Edit the properties (click an underlined value)**, click **all computers**.
1. In Choose Computer Groups, deactivate **Insider** and **Target**. Click **OK**.
1. In **Add Rule**, under **Step 2: Edit the properties (click an underlined value)**, click **7 days after the approval at 03:00**.
1. In Choose Deadline, beside **Days**, type **14**. and click **OK**.
1. In **Add Rule**, under **Step 3: Specify a name**, type **Standard updates** and click **OK**.
1. In **Automatic Approvals**, click **OK**.
1. In **Update Services**, click **Synchronizations**.
1. In the context-menu of **Synchronizations**, click **Synchronize Now**.

Depending on the product selection, the first synchronization will run for 15 minutes up to 15 hours or even longer.
