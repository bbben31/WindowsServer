# Practice: Create an Automation account

## Required VMs

None

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
