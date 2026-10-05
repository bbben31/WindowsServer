# Lab: Group Policies Management

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-group-policy-management.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); CL2 (VMware display: CL2; accepted display aliases: WIN-CL2; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Delegated AD/GPO rights for the named OU, account and policy changes; lab Domain Administrator only where the procedure requires it. Local Administrator for guest setup.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Microsoft Windows Update/WSUS and feature-on-demand endpoints.

**Risk, cost and optional status:** high; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** gpresult on the intended clients shows the requested GPO links, filtering and precedence.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision every VM, extra disk, cluster member, certificate, and client named by this lab; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Required VMs

* CL1
* CL2
* VN1-SRV1

## Setup

1. On **CL1**, sign in as **ad\Administrator**.
1. On **CL2**, sign in as **ad\Administrator**.

If you skipped the practice [Install Remote Server Administration Tools](../Practices/Install-Remote-Server-Administration-Tools.md), on CL1, run ````C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1````.

## Introduction

Adatum wants to enable remote management for all computers in the domain without configuring each computer individually. Moreover, the Microsoft Store should be disabled for users in the organizational unit Marketing. You should use Group Policies to accomplish these requirements. Furthermore, you should create a report proofing the correct group policy settings are applied.

## Exercises

1. [Configure Windows Defender Firewall rules for remote administration](#exercise-1-configure-windows-defender-firewall-rules-for-remote-administration)
1. [Disable the Microsoft Store](#exercise-2-disable-the-microsoft-store)
1. [View Group Policy Results](#exercise-3-view-group-policy-results)

## Exercise 1: Configure Windows Defender Firewall rules for remote administration

1. [Create a group policies object](#task-1-create-a-group-policies-object)
1. [Create firewall rules for remote management](#task-2-create-firewall-rules-for-remote-management) in the group policies object
1. [Link the GPO](#task-3-link-the-gpo) to the domain root
1. [Verify GPO application](#task-4-verify-gpo-application) on CL2

    > Are the firewall rules for remote management enabled?

    > Can you disable the firewall rules configured by the GPO?

### Task 1: Create a group policies object

Perform this task on CL1.

1. Open **Group Policy Management**.
1. In Group Policy Management, expand **Forest: ad.lab.test**, **Domains**, **ad.lab.test**, and click **Group Policy Objects**.
1. In the context-menu of **Group Policy Objects**, click **New**.
1. In New GPO, under **Name**, type **Custom Computer Security Windows Defender Firewall remote administration** and click **OK**.

### Task 2: Create firewall rules for remote management

Perform this task on CL1.

1. Open **Group Policy Management**.
1. In Group Policy Management, expand **Forest: ad.lab.test**, **Domains**, **ad.lab.test**, and click **Group Policy Objects**.
1. In **Group Policy Management**, in the context-menu of **Custom Computer Security Windows Defender Firewall remote administration**, click **Edit**.
1. In Group Policy Management Editor, expand **Computer Configuration**, **Policies**, **Windows Settings**, **Security Settings**, **Windows Defender Firewall with Advanced Security**, **Windows Defender Firewall with Advanced Security - LDAP://...**, and click **Inbound Rules**.
1. In the context-menu of Inbound Rules, click **New Rule...**
1. In New Inbound Rule Wizard, on page Rule Type, click **Predefined**, and, below, click **Remote Event Log Management**, and click **Next >**.
1. On page Predefined rules, deactivate all rules with the value **Private, Public** in the column **Profile**. Click **Next >**.
1. On page Action, ensure **Allow the connection** is selected and click **Finish**.

    Repeat steps 5 - 8 for the predefined rules:

    * Remote Scheduled Tasks Management
    * Remote Service Management
    * Remote Shutdown
    * Remote Volume Management

### Task 3: Link the GPO

Perform this task on CL1.

1. Open **Group Policy Management**.
1. In Group Policy Management, expand **Forest: ad.lab.test**, **Domains**, **ad.lab.test**, and click **ad.lab.test**.
1. In the right pane, click the tab **Linked Group Policy Objects**.
1. In the context-menu of **ad.lab.test**, click **Link an Existing GPO...**
1. In Select GPO, click **Custom Computer Security Windows Defender Firewall remote administration** and click **OK**.

### Task 4: Verify GPO application

Perform this task on CL2.

1. Open **Terminal**.
1. In Terminal, refresh the group policies.

    ````shell
    gpupdate.exe
    ````

1. Open **Windows Defender Firewall with Advanced Security**.
1. In Windows Defender Firewall with Advanced Security, click **Inbound Rules**.

    > The following rules are enabled for die **Profile** **Domain**.
    >
    >   * Inbound Rule for Remote Shutdown (RPC-Ep-In)
    >   * Inbound Rule for Remote Shutdown (TCP-In)
    >   * Remote Event Log Management (NP-In)
    >   * Remote Event Log Management (RPC)
    >   * Remote Event Log Management (RPC-EPMAP)
    >   * Remote Scheduled Tasks Management (RPC)
    >   * Remote Scheduled Tasks Management (RPC-EPMAP)
    >   * Remote Service Management (NP-In)
    >   * Remote Service Management (RPC)
    >   * Remote Service Management (RPC-EPMAP)
    >   * Remote Volume Management - Virtual Disk Service (RPC)
    >   * Remote Volume Management - Virtual Disk Service Loader  (RPC)
    >   * Remote Volume Management (RPC-EPMAP)

1. Double-click on one of the rules listed in the previous step.

    > At the top of the tab **General**, the message **This rule has been applied by the system administrator and cannot be modified** should appear. Furthermore, the checkbox **Enabled** is activated and disabled.

1. Click **Cancel**.
1. Sign out.

## Exercise 2: Disable the Microsoft Store

1. [Create and link a group policies object](#task-1-create-and-link-a-group-policies-object) to the organizational unit Marketing
1. [Disable the store](#task-2-disable-the-store) in the GPO linked to Marketing
1. [Verify GPO application](#task-3-verify-gpo-application)

    > Can Bill open the store and why?

    > Can Pia open the store and why?

### Task 1: Create and link a group policies object

Perform this task on CL1.

1. Open **Group Policy Management**.
1. In Group Policy Management, expand **Forest: ad.lab.test**, **Domains**, **ad.lab.test**, and click **Marketing**.
1. In the context-menu of **Marketing**, click **Create a GPO in this domain, and Link it here...**.
1. In New GPO, under **Name**, type **Custom User Store Disable** and click **OK**.

### Task 2: Disable the store

Perform this task on CL1.

1. Open **Group Policy Management**.
1. In Group Policy Management, expand **Forest: ad.lab.test**, **Domains**, **ad.lab.test**.
1. In the context-menu of **Custom User Store Disable**, click **Edit...**
1. In Group Policy Management Editor, expand **User Configuration**, **Policies**, **Administrative Templates**, **Windows Components**, and click **Store**.
1. In the right pane, double-click **Turn off the Store application**.
1. In Turn off the Store application, click **Enabled** and click **OK**.

### Task 3: Verify GPO application

Perform this task on CL2.

1. Sign in as **ad\Bill**.
1. Open **Microsoft Store**.

    You should see a message that Microsoft Store is blocked.

    > The store is blocked, because Bill is a user in the Marketing organizational unit.

1. Sign out.
1. Sign in as **ad\Pia**.
1. Open **Microsoft Store**.

    The store should be shown without any restrictions.

    > The store is not blocked, because Pia is a user in the Managers organizational unit.

## Exercise 3: View Group Policy Results

[Create and examine a group policy results report](#task-create-and-examine-a-group-policy-results-report) for AD\Bill on AD\CL2.

### Task: Create and examine a group policy results report

Perform this task on CL1.

1. Open **Group Policy management**.
1. In Group Policy Management, expand **Forest: ad.lab.test** and click **Group Policy Results**.
1. In the context-menu of **Group Policy Results**, click **Group Policy Results Wizard...**.
1. In Group Policy Results Wizard, on page Welcome to the Group Policy Results Wizard, click **Next >**.
1. On page Computer Selection, click **Another computer** and, below, type **CL2**. Click **Next >**.
1. On page User Selection, click **AD\Bill** and click **Next >**.
1. On page Summary of Selections, click **Next >**.
1. On page Completing the Group Policy Results Wizard, click **Finish**.

    After a few seconds, you should see a report of the group policies applied to AD\bill on AD\CL2. Verify all sections of the report.

1. Click the tab **Policy Events**.
1. On the tab Policy Events, double click on events you are interested in and read the description.
