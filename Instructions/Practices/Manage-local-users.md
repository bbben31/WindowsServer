# Practice: Manage local users

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); CL2 (VMware display: CL2; accepted display aliases: WIN-CL2; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=true. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** Get-LocalUser reflects the requested test-account properties and deletion result.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* CL2
* VN1-SRV1
* VN1-SRV4
* VN1-SRV5

## Setup

Complete [Create a custom Microsoft Management Console](Create-a-custom-Microsoft-Management-Console.md) on CL1 before continuing.

Complete [Explore Windows Admin Center](../Labs/Explore-Windows-Admin-Center.md), including adding the required server connections, before continuing.

## Task

On CL1, CL2, and VN1-SRV5, create a local user with the name LocalAdmin. Use different tools on the machines.

## Instructions

### Desktop experience

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. On the desktop, double-click **Basic Administration**.
1. In Basic Administration, click **Computer Management**.
1. In Basic Administration, in the context-menu of **Computer Management**, click **Connect to another computer...**
1. In Select Computer, ensure **Another computer** is selected and type either **CL1**, **CL2** or **VN1-SRV5**. Click **OK**.
1. In **Basic Administration**, expand **Computer Management**, **System Tools**,  **Local Users and Groups**, and click **Users**.
1. In the context-menu of **Users**, click **New User...**.
1. In New User, enter this data:

    **User name:** LocalAdmin

    **Full name:** Local Administrator

    **Description:** Account for administering the computer

1. In **Password** and **Confirm password** enter a secure password.
1. Deactivate the checkbox **User must change password at next logon** and click **Create**.
1. Click **Close**.

Repeat from step 4 for CL2 and VN1-SRV5.

### PowerShell

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. Run **Terminal** as Administrator.
1. Open a remote PowerShell session to CL2 or VN1-SRV5. If you want to create a user on CL1, you can skip this step.

    ````powershell
    Enter-PSSession CL2 # or VN1-SRV5
    ````

1. Store a secure password in a variable as secure string.

    ````powershell
    $password = Read-Host -Prompt 'Enter password' -AsSecureString
    ````

    Enter a secure password.

1. Create a user with the same data as in the previous step.

    ````powershell
    New-LocalUser `
        -Name 'LocalAdmin' `
        -FullName 'Local Administrator' `
        -Description 'Account for administering the computer' `
        -Password $password
    ````

1. Verify the creation of the user.

    ````powershell
    Get-LocalUser -Name LocalAdmin
    ````

    Data about the new user should be returned.

1. Exit the remote PowerShell session. If you did not open a remote PowerShell session, skip this step.

    ````powershell
    Exit-PSSession
    ````

### Windows Admin Center

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Microsoft Edge**.
1. Using Microsoft Edge, navigate to <https://admincenter>.
1. In Windows Admin Center, click **CL1.ad.lab.test**, **CL2.ad.lab.test** or **VN1-SRV5.ad.lab.test**.
1. Connected to CL1.ad.lab.test, CL2.ad.lab.test or VN1-SRV5.ad.lab.test, under **Tools**, click **Local users & groups**.
1. In Local users and groups, on the tab **Users**, click **New user**.
1. In the pane Add new user, enter this data:

    **Name**: LocalAdmin

    **Full name**: Local Administrator

    **Description**: Account for administering the computer

1. In **Password** and **Confirm password** enter a secure password.
1. Click **Submit**.
1. In **Local users and groups**, verify the new account was created.

If time allows, try to logon with the new account on the computers.
