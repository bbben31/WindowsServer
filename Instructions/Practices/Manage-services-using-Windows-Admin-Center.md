# Practice: Manage Services using Windows Admin Center

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Explore-Windows-Admin-Center.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing).  Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** The WAC Services tool reports the intended service transitions on the selected server.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV4
* VN1-SRV5

## Setup

Complete [Explore Windows Admin Center](../Labs/Explore-Windows-Admin-Center.md), including adding the required server connections, before continuing.

## Task

On CL1, stop the W32Time service on VN1-SRV5 and disable it. Restart VN1-SRV5 and verify the changes. Then set W32Time to start automatically and start it again.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Using Microsoft Edge, navigate to <https://admincenter>.
1. In Windows Admin Center, click **VN1-SRV5.ad.lab.test**.
1. Connected to VN1-SRV5.ad.lab.test, under **Tools**, click **Services**.
1. Under Services, click **W32Time**.
1. Click **Stop**. Click **Yes**.
1. Click **Settings**.
1. In W32Time Settings, in **Set Startup Mode**, select **Disabled**.
1. Click **Save**.
1. Click **Close**.
1. Under Tools, click **Overview**.
1. In Overview, click **Restart** and click **Yes**. Wait for about 30 seconds.
1. In Windows Admin Center, click **VN1-SRV5.ad.lab.test**.
1. Connected to VN1-SRV5.ad.lab.test, under **Tools**, click **Services**.
1. Verify, that the status of **W32Time** is **Stopped** and the **Start** button is disabled. Click **Settings**
1. In W32Time Settings, in **Set Startup Mode**, select **Automatic**.
1. Click **Save**.
1. Click **Close**.
1. Click **Start**.
