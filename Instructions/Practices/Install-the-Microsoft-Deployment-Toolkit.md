# Practice: Install the Microsoft Deployment Toolkit

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Official Microsoft product download endpoints and installer dependencies.

**Risk, cost and optional status:** low; local-only; optional=true. Historical optional compatibility exercise; use only isolated disposable legacy media from official sources. Skip installation if official media/support prerequisites cannot be met.

**Success verification:** In the isolated legacy snapshot, Deployment Workbench opens; otherwise record official-installer unavailability and skip installation.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1

## Task

This optional practice preserves a historical enterprise deployment workflow. Microsoft has [retired MDT](https://learn.microsoft.com/en-us/troubleshoot/mem/configmgr/mdt/mdt-retirement); it is unsupported and is not part of the Windows 11 or Windows Server 2025 baseline. Continue only in an isolated, disposable Server 2022 compatibility snapshot when the official installer remains available. Otherwise, read the procedure for concepts and skip installation.

On CL1, install the legacy Microsoft Deployment Toolkit package and the ADK/Windows PE versions required by that isolated Server 2022 exercise. Do not describe the combination as supported for Windows 11.

## Instructions

Perform this task on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Microsoft Edge**.
1. In Microsoft Edge, navigate to <https://www.microsoft.com/en-us/download/details.aspx?id=54259>.
1. On page Download Microsoft Deployment Toolkit (MDT) from Official Microsoft Download Center, click **Download**.
1. In Choose the download you want, activate the checkbox beside **MicrosoftDeploymentToolkit_x64.msi** and click **Next**.
1. In Downloads, click **Open file**.
1. In Microsoft Deployment Toolkit ... Setup, on page Welcome to the Microsoft Deployment Toolkit ... Setup Wizard, click **Next**.
1. On page End-User License Agreement, activate **I accept the terms in the License Agreement** and click **Next**.
1. On page Custom Setup, ensure all features are selected to be installed and click **Next**.
1. On page Customer Experience Improvement Program, make a selection of your choice and click **Next**.
1. On page Ready to install Microsoft Teployment Toolkit ..., click **Install**.
1. On page Completed the Microsoft Deployment Toolkit ... Setup Wizard, click **Finish**.
1. Switch to **Microsoft Edge**.
1. Navigate to <https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install>.
1. On page Download and install the Windows ADK | Microsoft Learn, use **Other ADK Downloads** to select the ADK version required by the historical MDT procedure, then obtain its matching Windows PE add-on. Do not substitute the newest ADK without first verifying the retired MDT combination in the disposable snapshot.
1. Download the matching Windows PE add-on.
1. Under Downloads, under **adkwinpesetup.exe**, click **Open file**.
1. In the Windows Assessment and Deployment Kit Windows Preinstallation Environment Add-on, on page Specify Location, click **Next**.
1. On page Windows Kits Privacy, make a selection of your choice and click **Next**.
1. On page License Agreement, click **Accept**.
1. On page Select the features you want to install, ensure the checkbox beside **Windows Preinstallation Environment (Windows PE)** is activated, and click **Install**.

    You do not have to wait for the download and installation to complete. The time is dependent on your internet connection.

1. On the final Windows PE add-on page, click **Close**.
