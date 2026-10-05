# Practice: Install the DNS server role

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV1 (VMware display: PM-SRV1; accepted display aliases: WIN-PM-SRV1; existing); PM-SRV2 (VMware display: PM-SRV2; accepted display aliases: WIN-PM-SRV2; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN2-SRV1 (VMware display: VN2-SRV1; accepted display aliases: WIN-VN2-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Get-WindowsFeature DNS reports Installed on VN2-SRV1, PM-SRV1 and PM-SRV2; inspect each DNS service.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* PM-SRV1
* PM-SRV2
* VN1-SRV1
* VN1-SRV4
* VN2-SRV1

## Task

Install the DNS server role on VN2-SRV1, PM-SRV1, and PM-SRV2

## Instructions

### Desktop Experience

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Reatures**.
1. In the Add Rules and Features Wizard, on the page **Before You Begin**, click **Next >**.
1. On the page Installation Type, ensure **Role-based or feature-based installation** is selected and click **Next >**.
1. On the page Server Selection, click **VN2-SRV1.ad.lab.test** and click **Next >**.
1. On the page Server Roles, activate the checkbox next to **DNS Server** and click **Next >**.
1. On the page Features, click **Next >**.
1. On the page DNS Server, click **Next >**.
1. On the page Confirmation, verify your selection and click **Install**.
1. On the page **Results**, click **Close**.

Repeat the steps of this task to install the role on **PM-SRV1** and **PM-SRV2**.

### Windows Admin Center

Perform this task on CL1.

1. Using Microsoft Edge, navigate to <https://admincenter>.
1. In Windows Admin Center, on the connections page, click **vn2-srv1.ad.lab.test**.
1. Connected to **vn2-srv1.ad.lab.test**, under **Tools**, click **Roles & features**.
1. In Roles and features, activate the checkbox beside **DNS Server** and click **Install**.
1. In the pane Install Role and Features, activate the checkbox **Reboot the server automatically, if required** and click **Yes**.

After a few minutes, a notification **Install Roles and Features** appears. If you missed the notification, a small number appears beside the icon *Notifications* (in form of a bell) at the top-right of Windows Admin Center.

Repeat the steps of this task to install the role on **PM-SRV1** and **PM-SRV2**.

### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Install the DNS role on VN2-SRV1, PM-SRV1, and PM-SRV2.

    ````powershell
    Invoke-Command -ComputerName VN2-SRV1, PM-SRV1, PM-SRV2 -ScriptBlock {
        Install-WindowsFeature -Name DNS -IncludeManagementTools -Restart 
    }
    ````
