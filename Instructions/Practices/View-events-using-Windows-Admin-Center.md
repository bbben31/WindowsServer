# Practice: View events using Windows Admin Center

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Explore-Windows-Admin-Center.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** WAC displays the requested event log/filter on the selected server.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV4

## Setup

Complete [Explore Windows Admin Center](../Labs/Explore-Windows-Admin-Center.md), including adding the required server connections, before continuing.

## Task

On CL1, view the events from the System log on VN1-SRV1 using Windows Admin Center. In the preview version, create a workspace that includes all warning, error, and critical events from the System and Application logs.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Using Microsoft Edge, navigate to <https://admincenter>.
1. In Windows Admin Center, click **VN1-SRV1.ad.lab.test**.
1. Connected to VN1-SRV1.ad.lab.test, under **Tools**, click **Events**.
1. Under Events, **Windows Logs**, click **System**.
1. Click the icon *Filter*.
1. Click the checkbox **Select All** to deactivate all event levels. Activate the checkboxes **Critical**, **Error**, and **Warning** and click **Apply**.
1. Click one of the events and view its description and details.
1. At the top-right, activate **Preview Mode**.
1. Click **Blank workspace**.
1. Click **Add Events**.
1. Click **Select logs** and click **System**.
1. Click **Level**, deactivate the checkboxes **Information** and **Verbose**.
1. Click **Event ID** and make sure **Select All** is activated.
1. At the bottom click **Add Events**.
1. Repeat the steps above to include all critical, error and warning events from the log **Application**.
1. At the top, click **Save**, **Save workspace as**.
1. In **Workspace name**, type **System, Application: Warnings and more** and click **Save workspace**.
1. In the breadcrumb navigation at the top, click **Events**.
1. **System, Application: Warnings and more** to open the  workspace again.

    Note: Due to a bug in the preview version, you might not see events in the Application log. Select the log again to refresh the events.
