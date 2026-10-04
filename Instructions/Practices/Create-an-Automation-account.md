# Practice: Create an Automation account

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Optional-Cost-Gated-Topics.md. Use an existing authorized Azure for Students subscription, an approved disposable resource group, the declared scoped Azure role, and a named budget/cleanup plan. Confirm current regional availability before deployment.

**Machines and network profile:** No dedicated guest; use the host/browser or existing tenant context specified by this reference.. No dedicated guest segment is required for host-browser portal work; use temporary VMnet8 if using a VMware guest browser. Keep all lab segments isolated.

**Permissions:** Standard lab user for local read-only queries and user-owned files; no local elevation. If the explicitly documented system-help prerequisite is selected under Windows PowerShell 5.1, use a separate authorized elevated session. Automation Contributor at disposable resource-group scope

**Outbound access:** Approved host-browser outbound access to Azure endpoints, or temporary VMware NAT VMnet8 for a guest browser; disconnect guest NAT afterward. Endpoints: login.microsoftonline.com; management.azure.com; Service-specific endpoints in the linked Microsoft product requirements.

**Risk, cost and optional status:** low; cost-gated; optional=false. Estimate current service charges before deployment; stop at the GBP 10 monthly safety limit. Confirm deletion and billing after completion. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The Automation account exists in the approved resource group and no unintended runbook schedules or jobs are active.

**Rollback and cleanup:** Delete only resources created for this exercise in the disposable resource group; remove exercise-specific assignments, agents/registrations and identities after checking dependencies. Verify the group is empty, no schedules remain and no recurring charges continue. Retain required prerequisite resources until dependent exercises finish. Disconnect temporary VMnet8 and restore recorded guest DNS/adapters.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

None; use the existing reference context.

## Setup

Use the existing Azure for Students subscription and approved disposable resource group `<AZURE_RESOURCE_GROUP>`. Never use instructor credentials or identifiers.

## Task

Create an Automation account in your Azure subscription.

## Instructions

Perform this task on the host computer.

1. Open **Microsoft Edge** and navigate to <https://portal.azure.com>
1. Sign in to Azure using the existing tenant and least-privilege role.
1. In Microsoft Azure, click **Create a resource**.

    Note: Depending on your settings, this command is on the Home screen, in menu on the side, or in the hamburger menu.

1. In Create a resource, in **Search services and marketplace**, enter **Automation**.
1. In Marketplace, click **Automation** ([figure 1]).
1. In Automation, click **Create**.
1. In Create an Automation Account, on the tab Basics, select the existing subscription and `<AZURE_RESOURCE_GROUP>`. Use a disposable name such as `auto-<LAB_SUFFIX>` and set the region to UK South after checking availability. Confirm the £10 hard limit, quota, and cleanup plan before selecting **Review + Create**.
1. On the tab Review + Create, click **Create**.

    Wait for the deployment to complete, then remove the account and any runbooks, identities, schedules, or diagnostic data created for the practice.

[figure 1]: /images/Automation.png
