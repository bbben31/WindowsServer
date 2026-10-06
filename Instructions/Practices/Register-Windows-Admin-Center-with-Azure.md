# Practice: Register Windows Admin Center with Azure

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-Windows-Admin-Center-using-a-script.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access. WAC gateway administrator and authority to approve only the required Entra application permissions

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: login.microsoftonline.com; management.azure.com; Service-specific endpoints in the linked Microsoft product requirements.

**Risk, cost and optional status:** low; cost-gated; optional=false. Estimate current service charges before deployment; stop at the GBP 10 monthly safety limit. Confirm deletion and billing after completion. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** WAC reports the approved existing tenant registration; record application permissions without copying identifiers or tokens.

**Rollback and cleanup:** Delete only resources created for this exercise in the disposable resource group; remove exercise-specific assignments, agents/registrations and identities after checking dependencies. Verify the group is empty, no schedules remain and no recurring charges continue. Retain required prerequisite resources until dependent exercises finish. Disconnect temporary VMnet8 and restore recorded guest DNS/adapters.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV4

## Task

Register Windows Admin Center with Azure.

## Instructions

Perform this task on CL1.

1. Open **Microsoft Edge** and navigate to <https://admincenter>.
1. In Windows Admin Center, click *Settings*.
1. In Settings, ensure **Account** is selected.
1. In Account, click **Register with Azure**.
1. Under Register with Azure, click **Register**.
1. In the pane Get started with Azure in Windows Admin Center, under **Select an Azure cloud**, ensure **Azure Global** is selected.
1. Under **Copy this code**, click **Copy** and click **Enter the code**.

    In Microsoft Edge, a new tab opens.

1. Under **Enter code**, paste the copied code and click **Next**.
1. Sign in to Microsoft Azure.
1. Under **Are you trying to sign in to Windows Admin Center**, click **Continue**.
1. If you see the message You have signed in to the Windows Admin Center application on your device. You may now close this window, close the tab.
1. In **Windows Admin Center**, on the pane **Get started with Azure in Windows Admin Center**, under **Azure Active Directory (tenant) ID**, ensure the correct ID is selected.

    If you are unsure about the correct ID, perform these steps:

    1. Open a new tab.
    1. Navigate to <https://portal.azure.com> and sign in if necessary.
    1. In the search box at the top, type **Azure Active Directory** and click **Azure Active Directory**.
    1. In Azure Active Directory, on the page **Overview**, take a note of **Tenant ID**.

1. Under **Azure Active Directory application**, ensure **Create new** is selected and click **Connect**.

    Wait for the message **Now connected to Azure AD** to appear.

1. Click **Sign in**.
1. In the dialog Permissions requested, click **Accept**.
