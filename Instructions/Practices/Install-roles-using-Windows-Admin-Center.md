# Practice: Install Roles using Windows Admin Center

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Explore-Windows-Admin-Center.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV2 (VMware display: VN1-SRV2; accepted display aliases: WIN-VN1-SRV2; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** WAC shows the intended role installed on the selected server; its resulting service is available.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV2
* VN1-SRV4

## Setup

Complete [Explore Windows Admin Center](../Labs/Explore-Windows-Admin-Center.md), including adding the required server connections, before continuing.

## Task

On CL1, use Windows Admin Center to install the Certification Authority Web Enrollment role service on VN1-SRV2.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Using Microsoft Edge, navigate to <https://admincenter>.
1. In Windows Admin Center, click **VN1-SRV2.ad.lab.test**.
1. Connected to VN1-SRV2.ad.lab.test, under **Tools**, click **Roles & features**.
1. In Roles and features, expand **Active Directory Certificate Service**.
1. Activate the checkbox beside  **Certification Authority Web Enrollment** and click **Install**.
1. In the pane Install Role and Features, activate the checkbox **Reboot the server automatically, if required** and click **Yes**.
1. After a few minutes, a notification **Install Roles and Features** appears. If you missed the notification, a small number appears beside the icon *Notifications* (in form of a bell) at the top-right of Windows Admin Center. Click the icon *Notification* and the notification **Install Roles and Features**.
1. In the pane **Notification details**, click **Close**.
1. In Roles and features, verify the **State** of **Certification Authority Web Enrollment** is **Installed**.
1. In Roles and features, verify that the **State** of **Web Server (IIS)** is **16 of 43 installed**.
1. Expand **Web Server (IIS)** and explore the installed role services.
1. Under Web Server (IIS), expand **Application Development**, activate the checkbox beside **ASP**, and click **Uninstall**.
1. In the pane **Uninstall Roles and Features**, notice that **Certification Authority Web Enrollment** would be removed together with ASP, because there is a dependency. Click **No**.
