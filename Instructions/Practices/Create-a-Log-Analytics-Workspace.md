# Practice: Create a Log Analytics Workspace

## Required VMs

None

## Setup

Use the existing Azure for Students subscription and an approved disposable resource group. Use placeholders `<AZURE_SUBSCRIPTION_ID>` and `<AZURE_RESOURCE_GROUP>` in notes.

## Task

Create a Log Analytics Workspace in your Azure subscription.

## Instructions

Perform this task on the host computer.

1. Open **Microsoft Edge** and navigate to <https://portal.azure.com>
1. Sign in to Azure using the existing tenant and least-privilege role.
1. In Microsoft Azure, click **Create a resource**.

    Note: Depending on your settings, this command is on the Home screen, in the left-hand menu, or in the hamburger menu.

1. In Create a resource, in **Search services and marketplace**, enter **Log Analytics Workspace**.
1. In Marketplace, click **Log Analytics Workspace** ([figure 1]).
1. In Log Analytics Workspace, click **Create**.
1. On the tab Basics, select the existing subscription and `<AZURE_RESOURCE_GROUP>`; do not create a new subscription.
1. Under **Name**, type a disposable unique name such as `wins-<LAB_SUFFIX>` and click **OK**.
1. Set **Region** to **UK South** (or the explicit `<AZURE_REGION>` placeholder only after checking availability). Confirm the estimated cost and that the hard £10 monthly limit remains safe before selecting **Review + Create**.
1. On the tab Review + Create, click **Create**.

    Wait for the deployment to complete, then record the workspace name privately.

1. When the lab is complete, delete the disposable workspace and verify the resource group contains no unexpected resources.

[figure 1]: /images/Log-Analytics-Workspace.png
