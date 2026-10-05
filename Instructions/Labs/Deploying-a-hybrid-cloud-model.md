# Lab: Deploying a hybrid cloud model

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Deploying-domain-controllers.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); CL2 (VMware display: CL2; accepted display aliases: WIN-CL2; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; conditional until retired; supply the guest or explicitly confirm retirement with -RetiredVmName); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN2-SRV1 (VMware display: VN2-SRV1; accepted display aliases: WIN-VN2-SRV1; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Lab Enterprise/Domain Administrator for the named forest/domain changes; Schema Admin only for schema extension. Local Administrator for guest setup. Remove temporary role membership afterward. Hybrid Identity Administrator assigned directly; temporary AD DS Enterprise Admin for connector setup only

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: login.microsoftonline.com; management.azure.com; Service-specific endpoints in the linked Microsoft product requirements.

**Risk, cost and optional status:** high; cost-gated; optional=true. Estimate current service charges before deployment; stop at the GBP 10 monthly safety limit. Confirm deletion and billing after completion. Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware. Verify current support for optional products before execution.

**Success verification:** Sync status and the intended test-user/device sign-in match the procedure; record dsregcmd state without exposing tenant data.

**Rollback and cleanup:** Delete only resources created for this exercise in the disposable resource group; remove exercise-specific assignments, agents/registrations and identities after checking dependencies. Verify the group is empty, no schedules remain and no recurring charges continue. Retain required prerequisite resources until dependent exercises finish. Disconnect temporary VMnet8 and restore recorded guest DNS/adapters.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision only existing prerequisite machines, disks, cluster roles and certificates before starting; create machines marked Created during exercise in their designated tasks. Follow alternatives and conditional-retirement requirements instead of starting every named VM; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.



> **Azure safety:** This lab can create or modify Azure resources. Use only your own subscription and tenant, substitute <AZURE_SUBSCRIPTION_ID>, <AZURE_TENANT_ID>, <AZURE_RESOURCE_GROUP>, and <AZURE_REGION>, apply least privilege and a budget, and remove disposable resources afterward.




## Required VMs

* CL1
* CL2
* VN1-SRV5
* VN2-SRV1
* Conditional until retired: VN1-SRV1

> **Conditional controller lifecycle:** Supply VN1-SRV1 while it remains the active original controller. After its documented retirement, confirm that VN1-SRV5 serves the original DNS address and the required directory roles, then pass `-RetiredVmName VN1-SRV1` to preflight; never restart a retired controller. Retirement requires the completed address/role handover, not merely completing controller promotion or switching off a guest. Steps concerning the retired server apply only to recorded historical state or removal of its stale directory objects.

## Setup

* On **CL1**, logon as **ad\Administrator**.
* On **VN2-SRV1**, logon as **ad\Administrator**.

## Introduction

Adatum wants to move various services into the cloud. As a first step, Adatum wants to synchronize users and groups into Microsoft Entra ID. To simplify sign in and device management, Adatum wants the client computers to use Microsoft Entra hybrid join.

## Exercises

1. [Synchronize Active Directory with Microsoft Entra ID](#exercise-1-synchronize-active-directory-users-and-groups-with-microsoft-entra-id)
<!-- 1. Manage Active Directory in a hybrid cloud -->
1. [Configure Microsoft Entra hybrid join](#exercise-2-configure-microsoft-entra-hybrid-join)

## Exercise 1: Synchronize Active Directory users and groups with Microsoft Entra ID

1. [Add the Microsoft Entra ID domain as UPN to users](#task-1-add-the-microsoft-entra-id-domain-as-upn-to-users) in organization units IT, Research, and Sales
1. [Enable Active Directory Recycle Bin](#task-2-enable-active-directory-recycle-bin)
1. [Download Microsoft Entra Connect](#task-3-download-microsoft-entra-connect)
1. [Install and configure Microsoft Entra Connect](#task-4-install-and-configure-microsoft-entra-connect) to synchronize the organizational units IT, Research, and Sales with the sign-in option password hash sync
1. [Verify the synchronization](#task-5-verify-the-synchronization)

### Task 1: Add the Microsoft Entra ID domain as UPN to users

Perform this task on CL1.

1. Open **Active Directory Domains and Trusts**.
1. In Active Directory Domains and Trusts, in the context-menu of **Active Directory Domains and Trusts**, click **Properties**.
1. In Active Directory Domains and Trusts, on tab UPN Suffixes, under **Alternative UPN suffixes**, type the domain name of your Microsoft Entra ID instance, click **Add** and click **OK**.
1. Open **Terminal**.
1. In Terminal, change the UPN name of users in IT, Research, and Sales to the Microsoft Entra ID domain suffix.

    ````powershell
    $suffix = '<VERIFIED_ENTRA_DOMAIN>'
    @('IT', 'Research', 'Sales') | ForEach-Object { 
        Get-ADUser `
            -SearchBase "ou=$PSItem,dc=ad,dc=lab,dc=test" `
            -Filter * | 
        ForEach-Object { 
            $PSItem | Set-ADUser `
                -UserPrincipalName (
                    $PSItem.UserPrincipalName -replace `
                        '^(.*)@(.*)$', "`$1@$suffix"
                )
        }
    }
    ````

### Task 2: Enable Active Directory Recycle Bin

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **ad (local)**.
1. In the context-menu of **ad (local)**, click **Enable Recycle Bin ...**.

    If the command is greyed out, the Recycle Bin has already been enabled. Skip to the next task.

1. In Enable Recycle bin Confirmation, click **OK**.
1. In Please refresh AD Administrative Center now, click **OK**.
1. In **Active Directory Administrative Center**, click *Refresh*.

### Task 3: Download Microsoft Entra Connect

Perform this task on VN2-SRV1.

1. Review the current [Microsoft Entra Connect installation roadmap](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-install-roadmap) and confirm VN2-SRV1 meets its prerequisites.
1. Using **Microsoft Edge**, navigate to <https://entra.microsoft.com>.
1. Sign in with your existing authorized tenant identity. Do not create or record a password in this repository.
1. In the Microsoft Entra admin center, open **Microsoft Entra Connect**, select **Connect sync**, and use the current download link for Microsoft Entra Connect.

### Task 4: Install and configure Microsoft Entra Connect

Perform this task on VN2-SRV1.

1. In **Downloads**, open **AzureADConnect.msi**.
1. In Microsoft Microsoft Entra ID Connect, on page Welcome to Microsoft Entra Connect, activate **I agree to the license terms and privacy notice** and click **Continue**.
1. On page Express Settings, click **Customize**.
1. On page Install required components, click **Install**.

    The installation will take a minute or two.

1. On page User Sign-in, ensure **Password Hash Synchronization** is selected and click **Next**.
1. On **Connect to Microsoft Entra ID**, sign in with an account assigned the **Hybrid Identity Administrator** role directly. Use a more privileged role only when a currently documented feature explicitly requires it.
1. On page Connect your directories, under **DIRECTORY TYPE**, ensure **Active Directory** is selected. Under **FOREST**, ensure **ad.lab.test** is selected and click **Add Directory**.
1. In AD forest account, under **Select account option**, ensure **Create new AD account** is selected. Under **ENTERPRISE ADMIN USERNAME**, type the credentials of **ad\Administrator** and click **OK**.
1. In **Microsoft Microsoft Entra ID Connect**, on page **Connect your directories**, click **Next**.
1. On Azure AD sign-in configuration, under **USER PRINCIPAL NAME**, ensure **userPrincipalName** is selected. Activate **Continue without matching all UPN suffixes to verified domains** and click **Next**.
1. On page Domain and OU filtering, click **Sync selected domains and OUs**. Deactivate **ad.lab.test**. Expand **ad.lab.test**. Activate **IT**, **Research**, and **Sales**. Click **Next**.
1. On page Uniquely identifying your users, click **Next**.
1. On page Filter users and devices, ensure **Synchronize all users and devices** is selected and click **Next**.
1. On page Optional features, click **Next**.
1. On page Ready to configure, click **Install**.

    The configuration will take a minute or two.

1. When you see **Configuration complete**, click **Exit**.

### Task 5: Verify the synchronization

Perform this task on VN2-SRV1.

1. Open **Event Viewer**.
1. In Event Viewer, expand **Windows Logs** and click **Application**. Review the events with the source Directory Synchronization.
1. Using **Microsoft Edge**, navigate to <https://entra.microsoft.com>.
1. Sign in with the authorized Hybrid Identity Administrator account used for this exercise.
1. In the Microsoft Entra admin center, click **Users**.

    You should see users from your Active Directory.

## Exercise 2: Configure Microsoft Entra hybrid join

1. [Move client computers into a synchronized organizational unit](#task-1-move-client-computers-into-a-synchronized-organizational-unit)
1. [Configure Microsoft Entra Connect for Microsoft Entra hybrid join](#task-2-configure-microsoft-entra-connect-for-microsoft-entra-hybrid-join)
1. [Verify Microsoft Entra hybrid join](#task-3-verify-microsoft-entra-hybrid-join)

### Task 1: Move client computers into a synchronized organizational unit

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **Global Search**.
1. Under Global Search, in **Search**, type **CL** and click **Search**.
1. Click **CL1**, hold down CTRL and click **CL2**.
1. In the context-menu of **CL1**, click **Move...**
1. In Move, click **IT** and click **OK**.

### Task 2: Configure Microsoft Entra Connect for Microsoft Entra hybrid join

Perform this task on VN2-SRV1.

1. On the desktop, open **Microsoft Entra Connect**.
1. In Microsoft Microsoft Entra ID Connect, on page Welcome to Microsoft Entra Connect, click **Configure**.
1. On page Additional tasks, click **Configure device options** and click **Next**.
1. On page Overview, click **Next**.
1. On **Connect to Microsoft Entra ID**, sign in with the directly assigned **Hybrid Identity Administrator** account used for this disposable hybrid-identity exercise.
1. On page Device options, ensure **Configure Microsoft Entra hybrid join** is selected, and click **Next**.
1. On page Device operating systems, activate **Windows 10 or later domain-joined devices**, and click **Next**.
1. On page SCP configuration, activate **ad.lab.test**. Under **Authentication service**, click **Microsoft Entra ID** and click **Add**.
1. In Enterprise Admin Credentials, enter the credentials of **ad\Administrator**.
1. In **Microsoft Microsoft Entra ID Connect**, on page **SCP configuration**, under **Enterprise Admin**, ensure **ad\Administrator** is displayed and click **Next**.
1. On page Configure, click **Configure**.
1. When you see **Configuration complete**, click **Exit**.
1. Open **Windows PowerShell**.
1. Start a sync cycle.

    ````powershell
    Start-ADSyncSyncCycle -PolicyType Delta
    ````

1. Using **Microsoft Edge**, navigate to <https://aad.portal.azure.com>.
1. Sign in with the existing authorized tenant identity used for this exercise.
1. In Microsoft Entra ID admin center, in the left pane, click **Microsoft Entra ID**.
1. Under Adatum Corporation, in the left pane, under **Manage**, click **Devices**.
1. In Devices, click **All devices**.

    You should see **CL2**. If you do not see the computer, wait for 2 minutes and click **Refresh**.

### Task 3: Verify Microsoft Entra hybrid join

Perform this task on CL2.

1. Click *Power*, **Restart**.
1. Sign in with **ad\abbi**.
1. Open **Terminal** or **Windows PowerShell**.
1. Check the status of the Microsoft Entra hybrid join.

    ````powershell
    dsregcmd.exe /status
    ````

    Under **Device State**, **AzureADJoined** should be **Yes**.

1. Sign out.
1. Sign in with **ad\abbi**.
1. Open **Settings**.
1. In Settings, click **Accounts**.
1. In Accounts, click **Email & accounts**

    Under Accounts used by other apps, the Microsoft Entra account of Abbi should be displayed.

1. Expand Abbi's Microsoft Entra account.

    Note: You cannot remove this account.

1. Click **Manage**.
1. In Microsoft Edge, in **Sync your profile**, click **Sync**.

    The page **My account** opens withot further sign in.

1. Navigate to <https://myapps.microsoft.com>

    You should see various apps without further sign in.
