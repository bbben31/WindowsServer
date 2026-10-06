# Lab: Manage servers remotely using Microsoft Management Console

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Create-a-custom-Microsoft-Management-Console.md; Instructions/Labs/Explore-Windows-Admin-Center.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); CL2 (VMware display: CL2; accepted display aliases: WIN-CL2; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** MMC tools reach the intended server and client; remote service/event/storage results match their local consoles.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision only existing prerequisite machines, disks, cluster roles and certificates before starting; create machines marked Created during exercise in their designated tasks. Follow alternatives and conditional-retirement requirements instead of starting every named VM; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.








## Required VMs

* CL1
* CL2
* VN1-SRV1
* VN1-SRV10
* VN1-SRV4

## Setup

On **CL1**, logon as **ad\Administrator**.
On **CL2**, logon as **.\Administrator**.

Complete [Create a custom Microsoft Management Console](../Practices/Create-a-custom-Microsoft-Management-Console.md) on CL1 before continuing.

Complete [Explore Windows Admin Center](../Labs/Explore-Windows-Admin-Center.md), including adding the required server connections, before continuing.

## Introduction

You want to manage servers remotely using Microsoft Management Console snap-ins. You try to connect to a server with the Computer Management snap-in, but you discover the server cannot be managed. Configure the Windows Defender Firewall to allow remote management of a server using the Computer Management snap-in.

## Exercises

1. [Evaluate remote administration using Microsoft Management Console](#exercise-1-evaluate-remote-administration-using-microsoft-management-console)
1. [Configure Windows Defender Firewall rules for remote administration](#exercise-2-configure-windows-defender-firewall-rules-for-remote-administration)
1. [Verify the ability of remote administration using Computer Management](#exercise-3-verify-the-ability-of-remote-administration-using-computer-management)

## Exercise 1: Evaluate remote administration using Microsoft Management Console

[Use the custom console Basic Administration to open Event Viewer and Disk Management](#task-use-the-custom-console-basic-administration-to-open-event-viewer-and-disk-management) on VN1-SRV10

> Are you able to view the events and disks?

### Task: Use the custom console Basic Administration to open Event Viewer and Disk Management

Perform this task on CL1.

1. On the desktop, double-click **Basic Administration**.
1. In Basic Administration, in the context-menu of **Computer Management (local)**, click **Connect to another computer...**
1. In Select Computer, Another computer, type **VN1-SRV10** and click **OK**.
1. In Basic Administration, expand **Computer Management (VN1-SRV10)**.
1. Expand **System Tools**.

    > You will receive an error message telling you to enable these firewall rules:
    * COM+ Network Access (DCOM-In)
    * All rules in the Remote Event Log Management group

1. Expand **Storage** and click **Disk Management**.

    > You will receive an error message.

1. Close **Basic Administration**.

## Exercise 2: Configure Windows Defender Firewall rules for remote administration

1. [Enable firewall rules to allow for remote event log and volume management](#task-1-enable-firewall-rules-to-allow-for-remote-event-log-and-volume-management) on VN1-SRV10 and CL2
1. [Enable firewall rules to allow remote volume management](#task-2-enable-firewall-rules-to-allow-remote-volume-management) on CL1

### Task 1: Enable firewall rules to allow for remote event log and volume management

*Important*: To configure VN1-SRV10, you cannot use Desktop experience. Please use one of the other methods for VN1-SRV10.

#### Desktop experience

Perform this task on CL2.

1. Open **Windows Defender Firewall with Advanced Security**.
1. In Windows Defender Firewall with Advanced Security, click **Inbound Rules**.
1. Find rules in the group **Remote Event Log Management** in the profile **Domain**. There should be 3 rules:

    * Remote Event Log Management (NP-In)
    * Remote Event Log Management (RPC)
    * Remote Event Log Management (RPC-EPMAP)

1. Click **Remote Event Log Management (NP-In)**, hold down the CTRL key and click the other two rules to select all 3 rules.
1. In the context-menu of one of the selected rules, click **Enable Rule**.
1. Repeat from step 3 for the rules in the group **Remote Volume Management** in the profile **Domain**. These are 3 rules:

    * Remote Volume Management - Virtual Disk Service (RPC)
    * Remote Volume Management - Virtual Disk Service Loader (RPC)
    * Remote Volume Management (RPC-EPMAP)

#### Windows Admin Center

Perform this task on CL1.

1. In Microsoft Edge, navigate to <https://admincenter>.
1. In Windows Admin Center, click **VN1-SRV10.ad.lab.test**.
1. Connected to VN1-SRV10.ad.lab.test, under Tools, click **Firewall**.
1. Under Firewall, click the tab **Incoming rules**.
1. In the search box, enter **Remote Event Log**. 3 rules will be found.
1. Click the rule **Remote Event Log Management (NP-In)** and click **Settings**.
1. In Firewall Rule Remote Event Log Management (NP-In) Settings, in **General**, set **Enable Firewall Rule** to **Yes**. Under **Profiles** deactivate the checkboxes **Private** and **Public**. Click **Save**.
1. Click **Close**.
1. Repeat the steps 6 - 8 to enable each rule for the Domain profile.
1. In the search box, enter **Remote Volume Management**. 3 rules will be found.
1. Repeat the steps 6 - 8 to enable each rule for the Domain profile.

Repeat from step 2 for **CL2.ad.lab.test**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Start an interactive PowerShell remote session with VN1-SRV10.

    ````powershell
    Enter-PSSession VN1-SRV10
    ````

1. Enable all rules in the group **Remote Event Log Management** for the domain profile only.

    ````powershell
    Get-NetFirewallRule -DisplayGroup 'Remote Event Log Management' |
    Set-NetFirewallRule -Enabled True -Profile Domain
    ````

1. Enable all rules in the group **Remote Volume Management** for the domain profile only.

    ````powershell
    Get-NetFirewallRule -DisplayGroup 'Remote Volume Management' |
    Set-NetFirewallRule -Enabled True -Profile Domain
    ````

1. Exit the remote PowerShell session.

    ````powershell
    Exit-PSSession
    ````

Repeat from step 2 for **CL2**.

Note: You could perform all the commands in just one command.

````powershell
Invoke-Command -ComputerName CL2, VN1-SRV10 -ScriptBlock {
    # Remote Event Log Management
    Get-NetFirewallRule -Group '@FirewallAPI.dll,-29252' |
    Set-NetFirewallRule -Enabled True -Profile Domain
    # Remote Volume Management
    Get-NetFirewallRule -Group '@FirewallAPI.dll,-34501' |
    Set-NetFirewallRule -Enabled True -Profile Domain
}
````

### Task 2: Enable firewall rules to allow remote volume management

#### Desktop experience

Perform this task on CL1.

1. Open **Windows Defender Firewall with Advanced Security**.
1. In Windows Defender Firewall with Advanced Security, click **Inbound Rules**.
1. Click the rule **Remote Volume Management - Virtual  Disk Service (RPC)** with the profile **Domain**.
1. Hold down the CTRL key and click the rules

    * **Remote Volume Management - Virtual Disk Service Loader (RPC)** with the profile **Domain**
    * **Remote Volume Management (RPC-EPMAP)** with the profile **Domain**

1. In the pane **Actions**, under **Selected Item**, click **Enable Rule**.

Repeat the steps above for the 3 rules in the group **Remote Event Log Management**.

#### PowerShell

1. Open **Terminal** as Administrator.
1. Find all rules in the group **Remote Volume Management** in the profile **Domain** and enable them.

    ````powershell
    Get-NetFirewallRule -DisplayGroup 'Remote Volume Management' | 
    Where-Object { $PSItem.Profile -eq 'Domain' } | 
    Set-NetFirewallRule -Enabled True

    Get-NetFirewallRule -DisplayGroup 'Remote Event Log Management' | 
    Where-Object { $PSItem.Profile -eq 'Domain' } | 
    Set-NetFirewallRule -Enabled True
    ````

## Exercise 3: Verify the ability of remote administration using Computer Management

[Connect Computer Management and open Event Viewer and Disk Management](#task-connect-computer-management-and-open-event-viewer-and-disk-management) for VN1-SRV10

> Are you able to view events and the disks?

### Task: Connect Computer Management and open Event Viewer and Disk Management

Perform this task on CL1.

1. On the desktop, double-click **Basic Administration**.
1. In Basic Administration, in the context-menu of **Computer Management (local)**, click **Connect to another computer...**
1. In Select Computer, Another computer, type **VN1-SRV10** and click **OK**.
1. In Basic Administration, expand **Computer Management (VN1-SRV10)**.
1. Expand **System Tools**, **Event Viewer**, **Windows Logs**, **System**.

    > You should see events from the System log.

1. Expand **Storage** and click **Disk Management**.

    > You should see the disk configuration.
