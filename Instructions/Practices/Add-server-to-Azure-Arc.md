# Practice: Add server to Azure Arc

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Windows-Admin-Center.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV8 (VMware display: VN1-SRV8; accepted display aliases: WIN-VN1-SRV8; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access. Azure Connected Machine onboarding role at disposable resource-group scope

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: login.microsoftonline.com; management.azure.com; Service-specific endpoints in the linked Microsoft product requirements.

**Risk, cost and optional status:** low; cost-gated; optional=false. Estimate current service charges before deployment; stop at the GBP 10 monthly safety limit. Confirm deletion and billing after completion. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The intended server appears Connected in Azure Arc; its agent reports the same resource scope.

**Rollback and cleanup:** Delete only resources created for this exercise in the disposable resource group; remove exercise-specific assignments, agents/registrations and identities after checking dependencies. Verify the group is empty, no schedules remain and no recurring charges continue. Retain required prerequisite resources until dependent exercises finish. Disconnect temporary VMnet8 and restore recorded guest DNS/adapters.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV4
* VN1-SRV8

## Setup

Use your existing tenant, Azure for Students subscription, disposable `<AZURE_RESOURCE_GROUP>`, and UK South when the service is available there. Confirm the current Azure Connected Machine onboarding permissions and budget before continuing.

Complete the local installation and connection exercises in [Windows Admin Center](../Labs/Windows-Admin-Center.md) before using its Azure integration. Azure Arc onboarding itself can be completed directly on VN1-SRV8 as described below.

## Task

Onboard VN1-SRV8 to Azure Arc.

## Instructions

Perform this task on VN1-SRV8.

1. Sign in as **ad\Administrator**.
1. In **Server Manager**, click **Local Server**.
1. Under Local Server, under PROPERTIES, beside **Azure Arc Management**, click **Disabled**.
1. In Azure Arc Setup, on page Get started, click **Next >**.

    Wait for the Azure Connected Machine agent to install. This takes a minute or two.

1. On page Install Azure Arc, click **Configure**.
1. In Azure Arc Configuration, on page Configure Azure Arc, click **Next >**.
1. On page Sign in to Azure, under **Select an Azure cloud**, ensure **Azure Global** is selected. Click **Sign in to Azure**.
1. In Microsoft Edge, sign in zu Azure.
1. Close **Microsoft Edge**.
1. In **Azure Arc Configuration**, on page Sign in to Azure, click **Next >**.
1. On page Resource details, select **Azure Active Directory Tenant**, **Subscription**, **Resource Group**, and **Azure Region**. Under **Network Connectivity**, ensure **Public endpoint** is selected and click **Next >**.
1. On page Connecting your server, wait for the connection to be successful and click **Finish**.
