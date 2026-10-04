# Lab: Explore Windows Admin Center

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-Windows-Admin-Center-using-a-script.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); CL2 (VMware display: CL2; accepted display aliases: WIN-CL2; existing); PM-SRV1 (VMware display: PM-SRV1; accepted display aliases: WIN-PM-SRV1; existing); PM-SRV2 (VMware display: PM-SRV2; accepted display aliases: WIN-PM-SRV2; existing); PM-SRV3 (VMware display: PM-SRV3; accepted display aliases: WIN-PM-SRV3; existing); PM-SRV4 (VMware display: PM-SRV4; accepted display aliases: WIN-PM-SRV4; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV11 (VMware display: VN1-SRV11; accepted display aliases: WIN-VN1-SRV11; existing); VN1-SRV12 (VMware display: VN1-SRV12; accepted display aliases: WIN-VN1-SRV12; existing); VN1-SRV13 (VMware display: VN1-SRV13; accepted display aliases: WIN-VN1-SRV13; existing); VN1-SRV2 (VMware display: VN1-SRV2; accepted display aliases: WIN-VN1-SRV2; existing); VN1-SRV3 (VMware display: VN1-SRV3; accepted display aliases: WIN-VN1-SRV3; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV6 (VMware display: VN1-SRV6; accepted display aliases: WIN-VN1-SRV6; existing); VN1-SRV7 (VMware display: VN1-SRV7; accepted display aliases: WIN-VN1-SRV7; existing); VN1-SRV8 (VMware display: VN1-SRV8; accepted display aliases: WIN-VN1-SRV8; existing); VN1-SRV9 (VMware display: VN1-SRV9; accepted display aliases: WIN-VN1-SRV9; existing); VN2-SRV1 (VMware display: VN2-SRV1; accepted display aliases: WIN-VN2-SRV1; existing); VN2-SRV2 (VMware display: VN2-SRV2; accepted display aliases: WIN-VN2-SRV2; existing); VN3-SRV1 (VMware display: VN3-SRV1; accepted display aliases: WIN-VN3-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary VMnet8 NAT on the configured WAC gateway guest and CL1 browser during extension installation only; retain isolated AD NICs/DNS and disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access. WAC gateway Administrator for installing the extension; Local Administrator on gateway/browser guests only for temporary NIC configuration.

**Outbound access:** Download the WAC Active Directory extension from the configured official Microsoft extension feed. Before extension installation, attach temporary VMnet8 NAT NICs to the existing WAC gateway guest and CL1 browser guest (one NIC if they are the same machine); preserve the AD NIC/DNS, disable NAT NIC DNS registration, and record adapters/routes/DNS. Disconnect these NICs after installation. If the extension is already installed, this setup step needs no download. Endpoints: https://aka.ms/wac-public-extensions (official feed redirect); https://pkgs.dev.azure.com (gateway extension packages); *.vsblob.visualstudio.com (gateway package content); https://winadmincenterassets.blob.core.windows.net (browser extension assets); https://js.monitor.azure.com (browser extension assets); https://nuget.org (browser extension management); https://announcements.blob.core.windows.net (browser extension management).

**Risk, cost and optional status:** high; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. The Active Directory extension must be compatible with the installed WAC gateway version; verify its publisher/version before installation.

**Success verification:** WAC reaches every declared enterprise connection and displays the requested management tools on the selected targets.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Disconnect temporary VMnet8 NICs on the gateway/browser and restore recorded adapters/routes/DNS. Retain the Active Directory extension until dependent labs finish; uninstall only an exercise-installed extension when no dependent lab needs it.

<!-- END GENERATED COMPLETION CONTRACT -->


> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision every VM, extra disk, cluster member, certificate, and client named by this lab; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.








## Required VMs

* CL1
* CL2
* PM-SRV1
* PM-SRV2
* PM-SRV3
* PM-SRV4
* VN1-SRV1
* VN1-SRV10
* VN1-SRV11
* VN1-SRV12
* VN1-SRV13
* VN1-SRV2
* VN1-SRV3
* VN1-SRV4
* VN1-SRV5
* VN1-SRV6
* VN1-SRV7
* VN1-SRV8
* VN1-SRV9
* VN2-SRV1
* VN2-SRV2
* VN3-SRV1

## Setup

On **CL1**, logon as **ad\Administrator**.

Complete [Install Windows Admin Center using a script](../Practices/Install-Windows-Admin-Center-using-a-script.md) on VN1-SRV4 before continuing.

## Introduction

After you installed Windows Admin Center, you want to find out, what you can do with it. For this purpose, you create connections to all servers and clients and explore the available administration features. Moreover, you browse through the the available extensions and try to install one.

## Exercises

1. [Connect](#exercise-1-connect)
1. [Manage connections](#exercise-2-manage-connections)
1. [Install extensions](#exercise-3-install-extensions)
1. [Explore the available administration features](#exercise-4-explore-the-available-administration-features)
1. [Use tags](#exercise-5-use-tags)

## Exercise 1: Connect

[Using Microsoft Edge, navigate to https://admincenter.ad.lab.test](#task-using-microsoft-edge-navigate-to-httpsadmincenteradlabtest).

    > Why do you need to enter username and password?

### Task: Using Microsoft Edge, navigate to https://admincenter.ad.lab.test

Perform this task on CL1.

1. In Microsoft Edge, navigate to https://admincenter.ad.lab.test.
1. On page Sign in- Windows Admin Center, sign in with **ad\Administrator**.

## Exercise 2: Manage connections

[In Windows Admin Center, add connections](#task-in-windows-admin-center-add-connections) to VN1-SRV1, VN1-SRV5, VN1-SRV6, VN1-SRV2, CL1, and CL2.

### Task: In Windows Admin Center, add connections

Perform this task on CL1.

1. In Windows Admin Center, on the connections page, click **Add**.
1. In the panel **Add or create resources**, under **Server**, click **Add**.
1. On the tab **Add one**, in **Server name**, enter **VN3-SRV1**.
1. After VN3-SRV1 was found, click **Add**.
1. Click **Add**.
1. In the panel **Add or create resources**, under **Windows PCs**, click **Add**.
1. Click the tab **Search Active Directory**.
1. Enter **CL1** and click **Search**.
1. Activate the checkbox left to **CL1.ad.lab.test** and click **Add**.
1. In the panel **Add or create resources**, under **Windows PCs**, click **Add**.
1. Click the tab **Search Active Directory**.
1. Enter **CL2** and click **Search**.
1. Activate the checkbox left to **CL2.ad.lab.test** and click **Add**.
1. In the panel **Add or create resources**, under **Server**, click **Add**.
1. Click the tab **Search Active Directory**.
1. Enter **VN1-\*** and click **Search**.
1. Activate the checkbox left to the column header **Name** to select all servers and click **Add**.

## Exercise 3: Install extensions

[Install the Active Directory extension](#task-install-the-active-directory-extension).

### Task: Install the Active Directory extension

Perform all tasks on CL1.

1. In Windows Admin Center, click the icon **Settings**.
1. In Settings, click **Extensions**.
1. On tab Available extensions, click **Active Directory** and click **Install**.

## Exercise 4: Explore the available administration features

1. [Explore networks, updates, and the settings for power configuration and Remote Desktop](#task-1-explore-networks-updates-and-the-settings-for-power-configuration-and-remote-desktop) on VN1-SRV1
2. [Find installed apps and running processes](#task-2-find-installed-apps-and-running-processes) on VN1-SRV4
3. [Explore the registry, the scheduled tasks and the security](#task-3-explore-the-registry-the-scheduled-tasks-and-the-security) of VN1-SRV6
4. [Explore apps, features, devices](#task-4-explore-apps-features-devices) on CL2

### Task 1: Explore networks, updates, and the settings for power configuration and Remote Desktop

Perform this task on CL1.

1. In Windows Admin Center, on the connections page, click **VN1-SRV1.ad.lab.test**. Explore the information on in the Overview tool.
1. In the Tools pane, click **Networks** and explore the available features.
1. In the Tools pane, click **Updates** and explore the available features.
1. In the Tools pane, click **Settings**.
1. In Settings, click **Power configuration** and explore the available features. 
1. In Settings, click **Remote Desktop** and explore the available features.

### Task 2: Find installed apps and running processes

Perform this task on CL1.

1. In Windows Admin Center, click **Windows Admin Center** in the top-left corner to return to the connections page.
1. On the connections page, click **VN1-SRV4.ad.lab.test**. Explore the information on in the Overview tool.
1. In the Tools pane, click **Installed apps** and explore the available features.
1. In the Tools pane, click **Processes** and explore the available features.

### Task 3: Explore the registry, the scheduled tasks and the security

Perform this task on CL1.

1. In Windows Admin Center, click **Windows Admin Center** in the top-left corner to return to the connections page.
1. On the connections page, click **VN1-SRV6.ad.lab.test**. Explore the information on in the Overview tool.
1. In the Tools pane, click **Registry** and explore the available features.
1. In the Tools pane, click **Scheduled tasks** and explore the available features.
1. In the Tools pane, click **Security** and explore the available features.

### Task 4: Explore apps, features, devices

Perform this task on CL1.

1. In Windows Admin Center, click **Windows Admin Center** in the top-left corner to return to the connections page.
1. On the connections page, click **CL2.ad.lab.test**. Explore the information on in the Overview tool.
1. In the Tools pane, click **Apps & features** and explore the available features.
1. In the Tools pane, click **Devices** and explore the available features.

## Exercise 5: Use tags

1. [Add tags to the connections according to table below](#task-1-add-tags-to-the-connections).

    | Name                   | Tags                                                                  |
    |------------------------|-----------------------------------------------------------------------|
    | VN1-SRV1.ad.lab.test  | core, dc, gc, domain naming, schema, primary, infrastructure, rid |
    | VN1-SRV2.ad.lab.test  | desktop, pki                                                         |
    | VN1-SRV4.ad.lab.test  | core, windows admin center                                           |
    | VN1-SRV5.ad.lab.test  | core                                                                 |
    | VN1-SRV10.ad.lab.test | desktop, file                                                        |
    | cl2.ad.lab.test       | win11, office                                                        |

    > What is the most efficient way to add the tags manually?

    > Are tags case-sensitive?

1. [Filter the connection list to only show connections with the tag **core**](#task-2-filter-the-connection-list).

    > Which connections are displayed?

### Task 1: Add tags to the connections

Perform this task on CL1.

1. In Windows Admin Center, on the connections page, activate the checkbox left to **VN1-SRV5.ad.lab.test**.
1. Click **Edit Tags**.
1. In Available tags, click **Add tags**, enter **core** and press ENTER.
1. Click **Save**.
1. Deactivate the checkbox left to **VN1-SRV5.ad.lab.test**.
1. Activate the checkbox left to **VN1-SRV4.ad.lab.test**.
1. Click **Edit Tags**.
1. In Available tags, activate **core**.

    > You can reuse tags.

1. Click **Add tags**, enter **Windows Admin Center** (with capitals) and press ENTER.

    > Tags can contain spaces. Moreover, the tags are normalized to lower case.

1. Click **Save**.
1. Dectivate the checkbox left to **VN1-SRV4.ad.lab.test**.
1. Activate the checkboxes left to **VN1-SRV2.ad.lab.test**, and **VN1-SRV10.ad.lab.test**.
1. Click **Edit Tags**.
1. In Available tags, click **Add tags**, enter **desktop** and press ENTER.
1. Click **Save**.

    > You can add tags to multiple connections in a single operation.

1. Activate and deactivate the checkbox left to the column header **Name** to clear all selections.
1. Activate the checkbox left to **cl2.ad.lab.test**.
1. Click **Add tags**, enter **win11, office** and press ENTER.

    > You can create multiple tags in a single operation by separating them with a comma.

1. Click **Save**.
1. Repeat the appropriate steps to add the remaining tags to the connections according to the table below.

    | Name                    | Tags                                                              |
    |-------------------------|-------------------------------------------------------------------|
    | VN1-SRV1.ad.lab.test  | core, dc, gc, domain naming, schema, primary, infrastructure, rid |
    | VN1-SRV2.ad.lab.test  | pki                                                               |
    | VN1-SRV10.ad.lab.test | file                                                              |

### Task 2: Filter the connection list

Perform this task on CL1.

1. In Windows Admin Center, on the connections page, click the icon *Filter*.
1. In Filter connections, activate the checkbox left to **core** and click **Save**.

    > Only the connections **VN1-SRV1.ad.lab.test**, **VN1-SRV4.ad.lab.test**, and **VN1-SRV5.ad.lab.test** should be displayed.

1. Click the icon *Filter* again.
1. In Filter connections, click **Clear filter** and click **Save**.
