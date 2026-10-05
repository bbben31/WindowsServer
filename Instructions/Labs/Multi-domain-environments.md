# Lab: Multi-domain environments

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Deploying-domain-controllers.md; Instructions/Practices/Install-prerequisites-for-file-serving.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. VN1-SRV3 hosts the SQL instance required for historical ADMT; verify current ADMT limitations before this optional migration portion. AD forest ad.lab.test (AD), child clients.ad.lab.test (CLIENTS), same-forest tree extranet.lab.test (EXTRANET), and separate ad.contoso.com (CONTOSO) must keep their documented DNS and credential contexts distinct. The promoted/replacement root DC remains authoritative after VN1-SRV1 retirement.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); CL2 (VMware display: CL2; accepted display aliases: WIN-CL2; existing); CL3 (VMware display: CL3; accepted display aliases: WIN-CL3; existing); CL4 (VMware display: CL4; accepted display aliases: WIN-CL4; existing); PM-SRV1 (VMware display: PM-SRV1; accepted display aliases: WIN-PM-SRV1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; conditional until retired; supply the guest or explicitly confirm retirement with -RetiredVmName); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV7 (VMware display: VN1-SRV7; accepted display aliases: WIN-VN1-SRV7; existing); VN2-SRV1 (VMware display: VN2-SRV1; accepted display aliases: WIN-VN2-SRV1; existing); VN2-SRV2 (VMware display: VN2-SRV2; accepted display aliases: WIN-VN2-SRV2; existing); VN1-SRV3 (VMware display: VN1-SRV3; accepted display aliases: WIN-VN1-SRV3; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Lab Enterprise/Domain Administrator for the named forest/domain changes; Schema Admin only for schema extension. Local Administrator for guest setup. Remove temporary role membership afterward.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Approved DNS forwarders on UDP/TCP 53; public name resolution only; Official Microsoft ADMT download (download.microsoft.com); optional legacy migration component; Microsoft Windows Update capability service (*.windowsupdate.com, *.update.microsoft.com); RSAT DNS tools on CL3 when missing.

**Risk, cost and optional status:** high; local-only; optional=true. Enterprise multi-forest exercise. ADMT migration is a historical conceptual study on the Server 2025/Windows 11 baseline; verify the official limited-support policy and SQL prerequisites before any isolated legacy execution. Keep trust, UPN and DNS contexts distinct.

**Success verification:** Child/tree/forest DNS and trusts work; paused VMware machines resume; selective authentication allows only the intended test resource access.

**Rollback and cleanup:** Unpause only VMware VMs paused by this lab; verify DNS/AD recovery. Remove exercise trusts/principals only after dependent tests finish, then restore the coordinated multi-forest pre-lab environment and disconnect temporary NAT.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision only existing prerequisite machines, disks, cluster roles and certificates before starting; create machines marked Created during exercise in their designated tasks. Follow alternatives and conditional-retirement requirements instead of starting every named VM; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.








## Required VMs

* CL1
* CL2
* CL3
* CL4
* PM-SRV1
* VN1-SRV10
* VN1-SRV5
* VN1-SRV7
* VN2-SRV1
* VN2-SRV2
* VN1-SRV3
* Conditional until retired: VN1-SRV1

> **Conditional controller lifecycle:** Supply VN1-SRV1 while it remains the active original controller. After its documented retirement, confirm that VN1-SRV5 serves the original DNS address and the required directory roles, then pass `-RetiredVmName VN1-SRV1` to preflight; never restart a retired controller. Retirement requires the completed address/role handover, not merely completing controller promotion or switching off a guest. Steps concerning the retired server apply only to recorded historical state or removal of its stale directory objects.

## Setup

1. On **CL1**, sign in as **ad\\Administrator**.
1. Complete [Install prerequisites for file server](../Practices/Install-prerequisites-for-file-serving.md) and verify the IT, Users, and Finance shares before continuing.

1. On **CL4**, sign in as **.\\Administrator**.
1. On **VN2-SRV2** sign in as **contoso\\Administrator**.

You must have completed the lab [Deploying Domain Controllers](Deploying-domain-controllers.md). If you skipped the lab, on **CL3**, in **Terminal**, run ````Get-WindowsCapability -Online -Name 'Rsat.Dns.Tools*' | Add-WindowsCapability -Online````. You do not have to wait for the command to complete until exercise 2, task 3.

Exercises 5 and 6 require the CONTOSO forest created in [Exercise 2: Deploy a new forest](Deploying-domain-controllers.md#exercise-2-deploy-a-new-forest). Complete that prerequisite and validate its DNS before continuing; no classroom provisioning shortcut is available.

## Introduction

Adatum wants to partition Active Directory in a domain for clients (users and client computers) and an extranet domain. The domain for the clients should be named clients.ad.lab.test, the domain for the extranet should be named extranet.lab.test.

The user principal names for users in Adatum and Contoso should not change, regardless of the user's domain.

Adatum discovers, that a failure of the root domain causes authentication problems between the new clients and extranet domains. Adatum wants to mitigate that problems.

Currently, Contoso users cannot access resources in Adatum. Because Contoso collaborates closely with Adatum, resource access between the forests should be enabled.

## Exercises

1. [Managing user principal names](#exercise-1-managing-user-principal-names)
1. [Deploy a child domain](#exercise-2-deploy-a-child-domain)
1. [Deploy a domain in a new tree](#exercise-3-deploy-a-domain-in-a-new-tree)
1. [Create and validate shortcut trusts](#exercise-4-create-and-validate-shortcut-trusts)
1. [Create and validate a forest trust](#exercise-5-create-and-validate-a-forest-trust)
1. [Migrating users between domains](#exercise-6-migrating-users-between-domains)

## Exercise 1: Managing user principal names

1. [Add an UPN suffix](#task-1-add-an-upn-suffix) lab.test to the forest ad.lab.test
1. [Change the UPN of all users](#task-2-change-the-upn-of-all-users) in the organizational units

    * Development
    * IT
    * Managers
    * Marketing
    * Research
    * Sales

1. [Verify the login with the user principal name](#task-3-verify-the-login-with-the-user-principal-name) Larry@lab.test
1. [Add the Contoso UPN suffix](#task-4-add-the-contoso-upn-suffix) contoso.com to the forest ad.contoso.com
1. [Create a new user with an alternative UPN suffix](#task-5-create-a-new-user-with-an-alternative-upn-suffix) in ad.contoso.com

### Task 1: Add an UPN suffix

#### Desktop experience

Perform this task on CL1.

1. Open **Active Directory Domains and Trusts**.
1. In Active Directory Domains and Trusts, in the context-menu of **Active Directory Domain and Trusts**, click **Properties**.
1. In Active Directory Domains and Trusts, on tab UPN Suffixes, under **Alternative UPN suffixes**, enter **lab.test** and click **Add**.
1. Click **OK**.

#### PowerShell

Perform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. Add the UPN suffix **lab.test** to the forest **ad.lab.test**.

    ````powershell
    Set-ADForest -Identity ad.lab.test -UPNSuffixes @{ add = 'lab.test' }
    ````

### Task 2: Change the UPN of all users

#### Desktop experience

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **ad (local)**.
1. In ad (local), double-click **Development**.
1. In Development, click the column header **Type**, click any object in Development and press CTRL + A to select all objects. Hold down CTRL and click the group **Development** to unselect it.
1. In the context menu of any selected user object, click **Properties**.
1. In Multiple Users, activate **Logon UPN Suffix**, click **lab.test**, and click **OK**.

Repeat the steps 2 - 6 for the organizational units

* IT
* Managers
* Marketing
* Research
* Sales

#### PowerShell

Perform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. For users in the organizational units **Development**, **IT**, **Marketing**, **Research**, and **Sales**, replace the domain part of the user principal name with **lab.test**.

    ````powershell
    @('Development', 'IT', 'Managers', 'Marketing', 'Research', 'Sales') | ForEach-Object {
        Get-ADUser `
            -SearchBase "ou=$PSItem, DC=ad,DC=lab,DC=test" `
            -Filter * | 
        ForEach-Object { 
            $PSItem | Set-ADUser `
                -UserPrincipalName (
                    $PSItem.UserPrincipalName -replace `
                        # https://regex101.com/r/DaI5XD/1
                        '^(.*)(@ad.lab.test)$', '$1@lab.test'
                )
        }
    }
    ````

### Task 3: Verify the login with the user principal name

Perform this task on CL2.

1. Sign in as **Larry@lab.test**

    > Larry Rayford should be able to sign in successfully.

1. Sign out.

### Task 4: Add the Contoso UPN suffix

#### Desktop experience

Perform this task on VN2-SRV2 while signed in as **contoso\Administrator**.

1. Open **Active Directory Domains and Trusts**.
1. In the context menu of **Active Directory Domains and Trusts**, click **Properties**.
1. On the **UPN Suffixes** tab, under **Alternative UPN suffixes**, enter **contoso.com**, click **Add**, and click **OK**.

#### PowerShell

Perform this task on VN2-SRV2 while signed in as **contoso\Administrator**.

1. Open **Terminal** and add `contoso.com` to the `ad.contoso.com` forest.

    ````powershell
    Set-ADForest `
        -Identity ad.contoso.com `
        -UPNSuffixes @{ Add = 'contoso.com' }
    ````

1. Verify the suffix before creating the user.

    ````powershell
    (Get-ADForest -Identity ad.contoso.com).UPNSuffixes
    ````

### Task 5: Create a new user with an alternative UPN suffix

#### Desktop experience

Perform this task on VN2-SRV2 while signed in as **contoso\Administrator**.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center on VN2-SRV2, select **contoso (local)** and then **Users**.
1. In the **Tasks** pane under **Users**, click **New**, **User**.
1. In Create User, set **First name** to **Wil**, **Last name** to **Ruiz**, **User UPN logon** to **Wil@contoso.com**, and **User SamAccountName logon** to **CONTOSO\Wil**. Enter a unique lab-only password, require password change at next sign-in, and click **OK**.

#### PowerShell

Perform this task on VN2-SRV2 while signed in as **contoso\Administrator**.

1. In the context menu of **Start**, click **Terminal**.
1. In Terminal, set up parameter variables for the new user.

    ````powershell
    $firstName = 'Wil'
    $lastName = 'Ruiz'

    $name = "$firstName $lastName"
    $userPrincipalName = "$firstName@contoso.com"
    ````

1. Create the new user.

    ````powershell
    $aDUser = New-ADUser `
        -Path 'CN=Users,DC=ad,DC=contoso,DC=com' `
        -Name $name `
        -GivenName $firstName `
        -Surname $lastName `
        -DisplayName  $name `
        -UserPrincipalName $userPrincipalName `
        -SamAccountName $firstName `
        -PassThru
    ````

1. Reset the password.

    ````powershell
    $aDUser | Set-ADAccountPassword -Reset
    $aDUser | Set-ADUser -ChangePasswordAtLogon $true
    ````

    Beside **Password** and **Repeat Password**, enter a secure password.

1. Enable the user.

    ````powershell
    $aDUser | Enable-ADAccount
    ````

## Exercise 2: Deploy a child domain

1. [Install Active Directory Domain Services](#task-1-install-active-directory-domain-services) on VN1-SRV7
1. [Configure Active Directory Domain Services as new child domain](#task-2-configure-active-directory-domain-services-as-new-child-domain) clients.ad.lab.test on VN1-SRV7
1. [Optimize name resolution using conditional forwarders](#task-3-optimize-name-resolution-performance-using-conditional-forwarders) on VN1-SRV7

    > Why does the name resolution from the child domain to the root domain work without further configuration?

    > Why should you replace the general forwarder with a conditional forwarder?

1. [Configure DNS client settings on the new domain controller](#task-4-configure-dns-client-settings-on-the-new-domain-controller) to point to 10.1.1.56 and localhost
1. [Verify name resolution on the DNS server within the child domain](#task-5-verify-name-resolution-on-the-dns-server-within-the-child-domain)

    > Which IP addresses are returned when executing a query for ad.lab.test on VN1-SRV7?

    > Which IP address is returned when executing a query for clients.ad.lab.test on 10.1.1.8 (10.1.1.8 is either VN1-SRV1 or VN1-SRV5)?

    > Why does name resolution for clients.ad.lab.test work on VN1-SRV1 or VN1-SRV5 without further configuration?

1. [Change the DNS client settings](#task-6-change-the-dns-client-settings) on CL4 to use 10.1.1.56 (VN1-SRV7)
1. [Connect to domain](#task-7-connect-to-domain) clients.ad.lab.test on CL4.

### Task 1: Install Active Directory Domain Services

#### Desktop experience

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Features**.
1. In Add Roles and Features Wizard, on page Before You Begin, click **Next >**.
1. On page Installation Type, ensure **Role-based or feature-basedd installation** is selected and click **Next >**.
1. On page Server Selection, click **VN1-SRV7** and click **Next >**.
1. On page Server Roles, activate **Active Directory Domain Services**.
1. In the dialog **Add features that are required for Active Directory Domain Services?**, click **Add Features**
1. On page **Server Roles**, click **Next >**.
1. On page Features, click **Next >**.
1. On page **AD DS**, click **Next >**.
1. On page **Confirmation**, activate the checkbox **Restart the destination server automatically if required** and click **Install**.
1. On page **Results**, click **Close**.

#### PowerShell

Peform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. Install the windows feature **Active Directory Domain Services** on **VN1-SRV7**.

    ````powershell
    Install-WindowsFeature `
        -Name AD-Domain-Services `
        -IncludeManagementTools `
        -ComputerName VN1-SRV7 `
        -Restart
    ````

### Task 2: Configure Active Directory Domain Services as new child domain

#### Desktop experience

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, click *Notifications* (the flag with the yellow warning triangle), and under the message **Configuration required for Active Directory Domain Services at VN1-SRV7**, click **Promote this server to a domain controller**.
1. In Active Directory Domain Services Configuration Wizard, on page Deployment Configuration, click **Add a new domain to an existing forest**. In **Select domain type**, ensure **Child Domain** is selected. In **Parent domain name**, ensure **ad.lab.test** is filled in. In **New domain name**, type **clients**. Beside **\<No credentials provided\>**, click **Change...**.
1. In the dialog Credentials for deployment operation, enter the credentials for **Administrator@ad.lab.test** and click **OK**.
1. On page **Deployment Configuration**, click **Next >**.
1. On page **Domain Controller Options**, ensure **Domain Name System (DNS) server** is activated and deactivate **Global Catalog (GC)**. Under **Type the Directory Services Restore Mode (DSRM) password**, in **Password** and **Confirm password**, type a secure password and take a note. You will need the password for a later lab. Click **Next >**.
1. On page DNS Options, click **Next >**.
1. On page Additional Options, in **The NetBIOS domain name**, ensure **CLIENTS** is filled in and click **Next >**.
1. On page **Paths**, click **Next >**.

    Note: In real world, it is recommended to have the paths on a separate drive.

1. On page Review Options, click **Next >**.
1. On page Prerequisites Check, click **Install**.
1. On page Results, click **Close**.

#### PowerShell

Perform this task on CL1.

1. In the context menu of **Start**, click **Terminal (Admin)**.
1. Store the Directory Services Restore Mode (DSRM) password in a variable.

    ````powershell
    $safeModeAdministratorPasswordSecure = Read-Host `
        -Prompt 'Directory Services Restore Mode (DSRM) password' `
        -AsSecureString
    ````

1. At the prompt **Directory Services Restore Mode (DSRM) password** enter a secure password and take a note.
1. Prompt for the Enterprise Admin credential without converting it to plaintext.

    ````powershell
    $credential = Get-Credential `
        -UserName 'Administrator@ad.lab.test' `
        -Message 'Enterprise Admin credential for the child-domain deployment'
    ````

1. When prompted, enter the credentials for **Administrator@ad.lab.test**.
1. Install a child domain **clients** with the parent domain **ad.lab.test** on PM-SRV1. Install DNS at the same time, but do not make it a Global Catalog server.

    ````powershell
    $job = Invoke-Command `
        -ComputerName VN1-SRV7.ad.lab.test `
        -AsJob `
        -ArgumentList $credential, $safeModeAdministratorPasswordSecure `
        -ScriptBlock {
            param(
                [pscredential]$Credential,
                [securestring]$SafeModeAdministratorPassword
            )
            Install-ADDSDomain `
                -DomainType ChildDomain `
                -ParentDomainName ad.lab.test `
                -NewDomainName clients `
                -Credential $Credential `
                -SafeModeAdministratorPassword $SafeModeAdministratorPassword `
                -InstallDns `
                -Force
        }
    ````

1. Wait for the job to complete.

    ````powershell
    $job | Wait-Job
    ````

    This will take a few minutes.

1. Read the output of the job.

    ````powershell
    $job | Receive-Job
    ````

    The error message ````[VN1-SRV7.ad.lab.test] Closing the remote server shell instance failed with the following error message : Access is denied.```` can be ignored safely.

Before continuing to the next task, wait for the sign in prompt to appear on **VN1-SRV7**.

### Task 3: Optimize name resolution performance using conditional forwarders

#### Desktop experience

Perform this task on CL1.

1. Open **DNS**.
1. In **Connect to DNS Server**, click **The following computer**, type **VN1-SRV7.clients.ad.lab.test**, and click **OK**.
1. In DNS Manager, click and expand **VN1-SRV7.clients.ad.lab.test**, and click **Conditional Forwarders**.
1. In the context-menu of **Conditional Forwarders**, click **New Conditional Forwarder...**
1. In New Conditional Forwarder, under **DNS Domain**, type **ad.lab.test**. Under **IP addresses of the master servers**, click **\<Click here to add an IP Address or DNS Name\>**, and enter **10.1.1.8** and **10.1.2.8**. Activate the checkbox **Store this conditional forwarder in Active Directory** and, in the drop-downbelow, click **All DNS servers in this forsst**. Click **OK**.
1. In **DNS Manager**, click **VN1-SRV7.clients.ad.lab.test**.
1. In the right pane, double-click **Forwarders**.
1. In VN1-SRV7.clients.ad.lab.test Properties, on tab Forwarders, click **Edit...**
1. In Edit Forwarders, click **10.1.1.8**, and click **Delete**.

    > The name resolution to the root domain worked, because of the general forwarder.

1. In **\<Click here to add an IP Address or DNS Name\>**, enter **8.8.8.8**. Repeat this step with **8.8.4.4** and click **OK**.
1. In **VN1-SRV7.clients.ad.lab.test Properties**, click **OK**.

> You should prefer conditional forwarders, because general forwarding of all unresolved queries may impact the performance of external Internet services negatively.

#### PowerShell

Perform this task on CL1.

1. In the context menu of **Start**, click **Terminal (Admin)**.
1. Store the name of the DNS server **VN1-SRV7** in a variable.

    ````powershell
    $computerName = 'VN1-SRV7.clients.ad.lab.test'
    ````

1. On **VN1-SRV7**, add a conditional forwarder for zone **ad.lab.test** pointing to **10.1.1.8** and **10.1.2.8**. The forwarder should be replicated forest-wide.

    ````powershell
    Add-DnsServerConditionalForwarderZone `
        -Name ad.lab.test `
        -MasterServers 10.1.1.8, 10.1.2.8 `
        -ReplicationScope Forest `
        -ComputerName $computerName
    ````

1. On **VN1-SRV7**, set the DNS forwarders to **8.8.8.8** and **8.8.4.4**.

    ````powershell
    Set-DnsServerForwarder -IPAddress 8.8.8.8, 8.8.4.4 -ComputerName $computerName 
    ````

> The name resolution to the root domain worked, because of the general forwarder.

> You should prefer conditional forwarders, because general forwarding of all unresolved queries may impact the performance of external Internet services negatively.

### Task 4: Configure DNS client settings on the new domain controller

#### SConfig

Perform this task on VN1-SRV7.

1. Sign in as **clients\administrator**.
1. In SConfig, enter **8**.
1. In Network settings, enter **1**.
1. In Network adapter settings, enter **2**.
1. Beside Enter new preferred DNS server, enter **10.1.1.56**.

    Note: In real world, you should enter the IP address of a another DC of the same domain.

1. Beside Enter alternate DNS server, enter **127.0.0.1**.
1. Press ENTER to continue.
1. In SConfig, enter **12**.
1. Beside Are you sure you want to log off, enter **y**.

#### PowerShell

Perform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. Create a CIM session to **VN1-SRV7**.

    ````powershell
    $cimSession = New-CimSession -ComputerName VN1-SRV7.clients.ad.lab.test
    ````

1. Set the DNS client server address for **VN1-SRV7** to **10.1.1.56** and **127.0.0.1**.

    ````powershell
    Set-DnsClientServerAddress `
        -InterfaceAlias VNet1 `
        -ServerAddresses 10.1.1.56, 127.0.0.1 `
        -CimSession $cimSession
    ````

    Note: In real world, you should enter the IP address of a another DC of the same domain.

1. Close and remove the CIM session.

    ````powershell
    Remove-CimSession $cimSession
    ````

1. Sign out.

### Task 5: Verify name resolution on the DNS server within the child domain

Perform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. Try to resolve the DNS name **ad.lab.test** on the DNS server **VN1-SRV7.clients.ad.lab.test**.

    ````powershell
    Resolve-DnsName -Name ad.lab.test -Server VN1-SRV7.clients.ad.lab.test
    ````

    > The IP addresses 10.1.1.8, 10.1.1.40, and 10.1.2.8 should be returned.

1. Try to resolve the DNS name **clients.ad.lab.test** on the DNS server **VN1-SRV5.ad.lab.test**.

    ````powershell
    Resolve-DnsName -Name clients.ad.lab.test -Server 10.1.1.8
    ````

    > The IP address 10.1.1.56 should be returned.

    > The name resolution works, because the Active Directory Domain Services Configuration Wizard added a delegation for the clients domain to ad.lab.test.

### Task 6: Change the DNS client settings

#### Desktop experience

Perform this task on CL4.

1. Open **Settings**.
1. In Settings, in the left pane, click **Network & internet**.
1. In Network & internet, click **Ethernet**.
1. In Ethernet, beside **DNS server assignment**, click **Edit**.
1. In Edit IP Settings, under **Preferred DNS**, type **10.1.1.56** and click **Save**.
1. Sign out.

#### PowerShell

Perform this task on CL4.

1. In the context menu of **Start**, click **Terminal (Admin)**.
1. Set the DNS client server address on the interface **Ethernet** to **10.1.2.16**.

    ````powershell
    Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 10.1.1.56
    ````

### Task 7: Connect to domain

#### Desktop experience

Perform this task on CL4.

1. Open **Settings**.
1. In Settings, in the left pane, click **Accounts**.
1. In Accounts, click **Access work or school**.
1. In Access work or school, beside **Add a work or school account**, click **Connect**.
1. In Set up a work or school account, click the link **Join this device to a local Active Directory domain**.
1. In Join a domain, under **Domain name**, type **clients.ad.lab.test** and click **Next**.
1. In Windows Security, enter the credentials for **Administrator@clients.ad.lab.test**.
1. In Add an account, click **Skip**.
1. In Restart your PC, click **Restart now**.

#### PowerShell

1. In the context menu of **Start**, click **Terminal (Admin)**.
1. Add the computer to the domain **clients.ad.lab.test** and restart it.

    ````powershell
    Add-Computer -DomainName clients.ad.lab.test -Restart
    ````

1. In **Windows PowerShell credential request**, enter the the credentials of **Administrator@clients.ad.lab.test**.

## Exercise 3: Deploy a domain in a new tree

1. [Add Conditional Forwarders](#task-1-add-conditional-forwarders) on 10.1.1.8 (VN1-SRV1 or VN1-SRV5) for extranet.lab.test pointing to the IP address of PM-SRV1 (10.1.200.8)

    > Why do you need to add this conditional forwarder before deploying the new tree?

1. [Install Active Directory Domain Services on PM-SRV1](#task-2-install-active-directory-domain-services)
1. [Configure Active Directory Domain Services as new tree](#task-3-configure-active-directory-domain-services-as-new-tree) named extranet.lab.test on PM-SRV1
1. [Configure forwarders](#task-4-configure-forwarders) on PM-SRV1 as 8.8.8.8 and 8.8.4.4
1. [Configure DNS client settings](#task-5-configure-dns-client-settings) on PM-SRV1 to point to its own IP address and localhost
1. [Verify name resolution of the new tree](#task-6-verify-name-resolution-of-the-new-tree)

    > Which IP address is returned when querying for extranet.lab.test on VN1-SRV5.ad.lab.test?

    > Which IP address is returned when querying for extranet.lab.test on VN1-SRV7.clients.ad.lab.test?

    > Which IP address is returned when querying for ad.lab.test on PM-SRV1.extranet.lab.test?

    > Which IP address is returned when querying for clients.ad.lab.test on PM-SRV1.extranet.lab.test?

### Task 1: Add Conditional Forwarders

#### Desktop experience

Perform this task on CL1.

1. Sign in as **Administrator@ad.lab.test**.
1. Open **DNS**.
1. In **Connect to DNS Server**, click **The following computer**, type **10.1.1.8**, and click **OK**.

    10.1.1.8 is either VN1-SRV1 or VN1-SRV5.

1. In **DNS Manager**, click and expand **10.1.1.8**, and click **Conditional Forwarders**.
1. In the context-menu of **Conditional Forwarders**, click **New Conditional Forwarder...**
1. In New Conditional Forwarder, under **DNS Domain**, type **extranet.lab.test**. Under **IP addresses of the master servers**, click **\<Click here to add an IP Address or DNS Name\>**, and enter **10.1.200.8**. Activate the checkbox **Store this conditional forwarder in Active Directory** and, below, click **All DNS servers in this forest**. Click **OK**.

> You need to add this conditional forwarder to ensure name resolution for the new tree from the existing root domain. Without this name resolution, creation of the trust between the root domain and the new tree fails.

#### PowerShell

Perform this task on CL1.

1. Sign in as **Administrator@ad.lab.test**.
1. In the context menu of **Start**, click **Terminal (Admin)**.
1. On **VN1-SRV5**, add a conditional forwarder for zone **extranet.lab.test** pointing to **10.1.200.8**. The forwarder should be replicated forest-wide.

    ````powershell
    Add-DnsServerConditionalForwarderZone `
        -Name extranet.lab.test `
        -MasterServers 10.1.200.8 `
        -ReplicationScope Forest `
        -ComputerName 10.1.1.8
    ````

> You need to add this conditional forwarder to ensure name resolution for the new tree from the existing root domain. Without this name resolution, creation of the trust between the root domain and the new tree fails.

### Task 2: Install Active Directory Domain Services

#### Desktop experience

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Features**.
1. In Add Roles and Features Wizard, on page Before You Begin, click **Next >**.
1. On page Installation Type, ensure **Role-based or feature-basedd installation** is selected and click **Next >**.
1. On page Server Selection, click **PM-SRV1** and click **Next >**.
1. On page Server Roles, activate **Active Directory Domain Services**.
1. In the dialog **Add features that are required for Active Directory Domain Services?**, click **Add Features**
1. On page **Server Roles**, click **Next >**.
1. On page Features, click **Next >**.
1. On page **AD DS**, click **Next >**.
1. On page **Confirmation**, activate the checkbox **Restart the destination server automatically if required** and click **Install**.
1. On page **Results**, click **Close**.
1. Run **Terminal**.
1. In Terminal, configure the inbound rule for Windows Remote Management (HTTP-In) for public networks in Windows Firewall on PM-SRV1 to allow for connections beyond the local subnet.

    ````powershell
    Invoke-Command -ComputerName PM-SRV1 -ScriptBlock {
        Set-NetFirewallRule `
            -Name WINRM-HTTP-In-TCP-PUBLIC `
            -Profile Public `
            -RemoteAddress 10.1.1.0/24
    }
    ````

    *Important:* This is only necessary in the lab environment. Do not configure this firewall rule in real world. In the lab environment, because there will be only one domain controller for the new domain, the Windows Firewall will enable the public profile instead of the domain profile. The public profile only allows connections to WinRM from the local subnet by default. For this reason, in the lab environment only, we configure the rule to allow connections from any remote address.

#### PowerShell

Peform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. In Terminal, install the Windows feature **Active Directory Domain Services** on **PM-SRV1**.

    ````powershell
    Install-WindowsFeature `
        -Name AD-Domain-Services, DNS `
        -IncludeManagementTools `
        -Restart `
        -ComputerName PM-SRV1
    ````

1. Configure the inbound rule for Windows Remote Management (HTTP-In) for public networks in Windows Firewall on PM-SRV1 to allow for connections beyond the local subnet.

    ````powershell
    Invoke-Command -ComputerName PM-SRV1 -ScriptBlock {
        Set-NetFirewallRule `
            -Name WINRM-HTTP-In-TCP-PUBLIC `
            -Profile Public `
            -RemoteAddress 10.1.1.0/24
    }
    ````

    *Important:* This is only necessary in the lab environment. Do not configure this firewall rule in real world. In the lab environment, because there will be only one domain controller for the new domain, the Windows Firewall will enable the public profile instead of the domain profile. The public profile only allows connections to WinRM from the local subnet by default. For this reason, in the lab environment only, we configure the rule to allow connections from any remote address.

### Task 3: Configure Active Directory Domain Services as new tree

#### Desktop experience

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, click *Notifications* (the flag with the yellow warning triangle), and under the message **Configuration required for Active Directory Domain Services at PM-SRV1**, click **Promote this server to a domain controller**.
1. In Active Directory Domain Services Configuration Wizard, on page Deployment Configuration, click **Add a new domain to an existing forest**. In **Select domain type**, click **Tree Domain**. In **Forest name**, ensure **ad.lab.test** is filled in. In **New domain name**, type **extranet.lab.test**. Beside **\<No credentials provided\>**, click **Change...**.
1. In the dialog Credentials for deployment operation, enter the credentials for **Administrator@ad.lab.test** and click **OK**.
1. On page **Deployment Configuration**, click **Next >**.
1. On page **Domain Controller Options**, ensure **Domain Name System (DNS) server** is activated and deactivate **Global Catalog (GC)**. Under **Type the Directory Services Restore Mode (DSRM) password**, in **Password** and **Confirm password**, type a secure password and take a note. You will need the password for a later lab. Click **Next >**.
1. On page DNS Options, click **Next >**.
1. On page Additional Options, in **The NetBIOS domain name**, ensure **EXTRANET** is filled in and click **Next >**.
1. On page **Paths**, click **Next >**.

    Note: In real world, it is recommended to have the paths on a separate drive.

1. On page Review Options, click **Next >**.
1. On page Prerequisites Check, click **Install**.
1. On page Results, click **Close**.
1. Sign out.

#### PowerShell

Perform this task on CL1.

1. Run **Terminal**.
1. Store the Directory Services Restore Mode (DSRM) password in a variable.

    ````powershell
    $safeModeAdministratorPassword = Read-Host `
        -Prompt 'Directory Services Restore Mode (DSRM) password' `
        -AsSecureString
    ````

1. At the prompt **Directory Services Restore Mode (DSRM) password** enter a secure password and take a note.
1. Prompt for the Enterprise Admin credential without converting it to plaintext.

    ````powershell
    $credential = Get-Credential `
        -UserName 'Administrator@ad.lab.test' `
        -Message 'Enterprise Admin credential for the tree-domain deployment'
    ````

1. When prompted, enter the credentials for **Administrator@ad.lab.test**.
1. Install a new tree **extranet.lab.test** with the parent domain **ad.lab.test** on PM-SRV1. Install DNS at the same time, but do not make it a Global Catalog server.

    ````powershell
    $job = Invoke-Command `
        -ComputerName PM-SRV1 `
        -AsJob `
        -ArgumentList $credential, $safeModeAdministratorPassword `
        -ScriptBlock {
            param(
                [pscredential]$Credential,
                [securestring]$SafeModeAdministratorPassword
            )
            Install-ADDSDomain `
                -DomainType TreeDomain `
                -ParentDomainName ad.lab.test `
                -NewDomainName extranet.lab.test `
                -Credential $Credential `
                -SafeModeAdministratorPassword $SafeModeAdministratorPassword `
                -InstallDns `
                -Force
        }
    ````

1. Wait for the job to complete.

    ````powershell
    $job | Wait-Job
    ````

    This will take a few minutes.

1. Read the output of the job.

    ````powershell
    $job | Receive-Job
    ````

    The value of the property **Status** should be **Success**.

    The error message ````[PM-SRV1] Closing the remote server shell instance failed with the following error message : Access is denied.```` can be ignored safely.

Wait until the sign in screen appears on PM-SRV1.

### Task 4: Configure forwarders

#### Desktop experience

Perform this task on CL1.

1. Open **DNS**.
1. In **Connect to DNS Server**, click **The following computer**, type **PM-SRV1.extranet.lab.test**, and click **OK**.
1. In DNS Manager, click **PM-SRV1.extranet.lab.test**.
1. In PM-SRV1.extranet.lab.test, double-click **Forwarders**.
1. In PM-SRV1.extranet.lab.test, on tab Forwarders, click **Edit...**
1. In Edit Forwarders, click **10.1.1.8** and click **Delete**.
1. In **\<Click here to add an IP Address or DNS Name\>**, enter **8.8.8.8**. Repeat this step with **8.8.4.4** and click **OK**.
1. In **PM-SRV1.extranet.lab.test**, click **OK**.

#### PowerShell

Perform this task on CL1.

1. Sign in as **Administrator@extranet.lab.test**.
1. Run **Terminal**.
1. In Terminal, configure the forwarder on PM-SRV1 to **8.8.8.8** and **8.8.4.4**.

    ````powershell
    Set-DnsServerForwarder `
        -IPAddress 8.8.8.8, 8.8.4.4 -ComputerName PM-SRV1.extranet.lab.test
    ````

### Task 5: Configure DNS client settings

#### SConfig

Perform this task on PM-SRV1.

1. Sign in as **Administrator@extranet.lab.test**.
1. In SConfig, enter **8**.
1. In Network settings, enter **1**.
1. In Network adapter settings, enter **2**.
1. Beside Enter new preferred DNS server, enter **10.1.200.8**.
1. Beside Enter alternate DNS server, enter **127.0.0.1**.
1. Press ENTER to continue.
1. In SConfig, enter **12**.
1. Beside Are you sure you want to log off, enter **y**.

#### PowerShell

Perform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. In Terminal, create a CIM session to **PM-SRV1**.

    ````powershell
    $cimSession = New-CimSession -ComputerName PM-SRV1.extranet.lab.test
    ````

    If you receive the following error message, wait a few minutes and try again or use the SConfig method.

    ````text
    New-CimSession : WinRM cannot process the request. The following error occurred while using Kerberos authentication: Cannot find the computer PM-SRV1.extranet.lab.test. Verify that the computer exists on the network and that the name provided is spelled correctly.
    ````

1. For all net adapters, set the DNS client server address for **PM-SRV1** to **10.1.200.8** and **127.0.0.1**.

    ````powershell
    Get-NetAdapter -CimSession $cimSession |
    Set-DnsClientServerAddress `
        -ServerAddresses 10.1.200.8, 127.0.0.1 -CimSession $cimSession
    ````

    Note: In real world, you should enter the IP address of a another DC of the same domain.

1. Close and remove the CIM session.

    ````powershell
    Remove-CimSession $cimSession
    ````

### Task 6: Verify name resolution of the new tree

Perform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. Resolve the DNS name **extranet.lab.test** on server **10.1.1.8**.

    ````powershell
    Resolve-DnsName -Name extranet.lab.test -Server 10.1.1.8
    ````

    > The IP addresses 10.1.200.8 and 10.1.200.9 should be returned.

    Note: If you do not get the IP address, restart the DNS service on 10.1.1.8 and try again.

    ````powershell
    $computerName = (Resolve-DnsName 10.1.1.8).NameHost
    Invoke-Command -ComputerName $computerName -ScriptBlock {
        Restart-Service -Name DNS
    }
    ````

1. Resolve the DNS name **extranet.lab.test** on server **VN1-SRV7.clients.ad.lab.test**.

    ````powershell
    Resolve-DnsName -Name extranet.lab.test -Server VN1-SRV7.clients.ad.lab.test
    ````

    > The IP addresses 10.1.200.8 and 10.1.200.9 should be returned.

1. Resolve the DNS name **ad.lab.test** on server **PM-SRV1.extranet.lab.test**.

    ````powershell
    Resolve-DnsName -Name ad.lab.test -Server PM-SRV1.extranet.lab.test
    ````

    > The IP addresses 10.1.1.8 should be returned. Depending on the number of domain controllers, additional IP addresses may be returned.

1. Resolve the DNS name **clients.ad.lab.test** on server **PM-SRV1.extranet.lab.test**.

    ````powershell
    Resolve-DnsName -Name clients.ad.lab.test -Server PM-SRV1.extranet.lab.test
    ````

    > The IP address 10.1.1.56 should be returned.

## Exercise 4: Create and validate shortcut trusts

1. [Simulate a failure of an intermediate domain](#task-1-simulate-a-failure-of-an-intermediate-domain)
1. [Validate the effect of a missing intermediate domain](#task-2-validate-the-effects-of-an-failure-of-an-intermediate-domain) on CL2

    > Can a user of the domain clients.ad.lab.test sign in?

    > Can a user of domain clients.ad.lab.test access the shares on VN1-SRV7?

    > Can a user of domain clients.ad.lab.test access the shares on PM-SRV1?

    > Can a user of domain extranet.lab.test sign in?

1. [Recover from the failure of the intermediate domain](#task-3-recover-from-the-failure-of-the-intermediate-domain)
1. [Create a shortcut trust](#task-4-create-a-shortcut-trust) between clients.ad.lab.test and extranet.lab.test
1. [Simulate a failure of an intermediate domain](#task-5-simulate-a-failure-of-an-intermediate-domain)
1. [Validate the effect of the shortcut trust](#task-6-validate-the-effects-of-the-shortcut-trust) on CL2

    > Can a user of domain clients.ad.lab.test access the shares on PM-SRV1?

    > Can a user of domain extranet.lab.test sign in?

1. [Recover from the failure of the intermediate domain](#task-7-recover-from-the-failure-of-the-intermediate-domain)

### Task 1: Simulate a failure of an intermediate domain

Perform this task on the VMware Workstation host.

1. Record the current state and absolute `.vmx` path of **WIN-VN1-SRV1**, **WIN-VN1-SRV5**, and **WIN-VN2-SRV1**. Map those display names to their guest hostnames. Leave any already powered-off machine untouched.
1. For each running machine, choose **VM > Power > Pause**. Record exactly which machines were paused. Pause stops execution in memory; do not select **Suspend**.

Alternatively, use VMware's documented `vmrun` **pause** command for each running machine's recorded path:

````powershell
$vmxPath = '<ABSOLUTE_PATH_TO_RUNNING_VM.vmx>'
if ($vmxPath -match '^<.+>$') { throw 'Supply the recorded VMware VMX path first.' }
vmrun -T ws pause $vmxPath
if ($LASTEXITCODE -ne 0) { throw 'VMware pause failed; inspect the VM state.' }
````

### Task 2: Validate the effects of an failure of an intermediate domain

Perform this task on CL4.

1. Sign in as **Administrator@clients.ad.lab.test**.
1. Using **File Explorer**, try to navigate to `\\VN1-SRV7`.

    > You should see the shares NETLOGON and SYSVOL.

1. Using **File Explorer**, try to navigate to `\\PM-SRV1.extranet.lab.test`.

    > You will receive a prompt to enter network credentials with an error message that the system cannot contact a domain controller to service the authentication request.

1. In Enter network credentials, click **Cancel**.
1. Sign out.
1. Sign in as **Administrator@extranet.lab.test**.

    > The sign in will fail with an error message that the domain is not available.

1. Click **OK**.

### Task 3: Recover from the failure of the intermediate domain

Perform this task on the VMware Workstation host.

1. Select each VM recorded as paused during the preceding failure simulation: **WIN-VN1-SRV1**, **WIN-VN1-SRV5**, and **WIN-VN2-SRV1**, where present.
1. Choose **VM > Power > Pause** again to clear the paused state and resume execution. Do not select a machine that was already powered off or suspended before the simulation.
1. Verify AD DNS and domain connectivity recover before continuing.

Alternatively, use VMware's documented `vmrun` **unpause** command with each recorded absolute `.vmx` path. Substitute the path recorded when pausing; do not use guest hostnames as paths:

````powershell
$vmxPath = '<ABSOLUTE_PATH_TO_PAUSED_VM.vmx>'
if ($vmxPath -match '^<.+>$') { throw 'Supply the recorded VMware VMX path first.' }
vmrun -T ws unpause $vmxPath
if ($LASTEXITCODE -ne 0) { throw 'VMware unpause failed; inspect the VM state.' }
````

### Task 4: Create a shortcut trust

#### Desktop experience

Perform this task on CL1.

1. Open **Active Directory Domains and Trusts**.
1. In Active Directory Domains and Trusts, in the context-menu of **extranet.lab.test**, click **Properties**.
1. In extranet.lab.test Properties, click the tab **Trusts**.
1. On the tab Trusts, click **New Trust...**
1. In the New Trust Wizard, on page Welcome to the New Trust Wizard, click **Next >**.
1. On the page Trust Name, under **Name**, type **clients.ad.lab.test** and click **Next >**.
1. On the page Direction of Trust, ensure **Two-way** is selected and click **Next >**.
1. On the page Sides of Trust, select **Both this domain and the specified domain** and click **Next >**.
1. On the page User Name and password, for **Specified domain: clients.ad.lab.test** type the credentials of **Administrator@clients.ad.lab.test** and click **Next >**.
1. On the page Trust Selections Complete, click **Next >**.
1. On the page Trust Creation Complete, click **Next >**.
1. On the page Confirm Outgoing Trust, click **Yes, confirm the outgoing trust** and click **Next >**.
1. On the page Confirm Incoming Trust, click **Yes, confirm the incoming trust** and click **Next >**.
1. On the page Completing the New Trust Wizard, click **Finish**.
1. In **extranet.lab.test Properties**, click **OK**.

#### PowerShell

Perform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. Create DirectoryContext objects for the domains **clients.ad.lab.test** and **extranet.lab.test**.

    ````powershell
    $clientsContext = New-Object `
        -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext `
        -ArgumentList 'Domain', 'clients.ad.lab.test'
    $extranetContext = New-Object `
        -TypeName System.DirectoryServices.ActiveDirectory.DirectoryContext `
        -ArgumentList 'Domain', 'extranet.lab.test'
    ````

1. Get the domains **clients.ad.lab.test** and **extranet.lab.test**.

    ````powershell
    $clientsDomain = `
        [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain(
            $clientsContext
        )
    $extranetDomain = `
        [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain(
            $extranetContext
        )
    ````

1. Create a bidrectional trust relationship between the clients and the extranet domain.

    ````powershell
    $clientsDomain.CreateTrustRelationship($extranetDomain, 'Bidirectional')
    ````

### Task 5: Simulate a failure of an intermediate domain

Perform this task on the VMware Workstation host.

1. Record the current state and absolute `.vmx` path of **WIN-VN1-SRV1**, **WIN-VN1-SRV5**, and **WIN-VN2-SRV1**. Map those display names to their guest hostnames. Leave any already powered-off machine untouched.
1. For each running machine, choose **VM > Power > Pause**. Record exactly which machines were paused. Pause stops execution in memory; do not select **Suspend**.

Alternatively, use VMware's documented `vmrun` **pause** command for each running machine's recorded path:

````powershell
$vmxPath = '<ABSOLUTE_PATH_TO_RUNNING_VM.vmx>'
if ($vmxPath -match '^<.+>$') { throw 'Supply the recorded VMware VMX path first.' }
vmrun -T ws pause $vmxPath
if ($LASTEXITCODE -ne 0) { throw 'VMware pause failed; inspect the VM state.' }
````

### Task 6: Validate the effects of the shortcut trust

Perform this task on CL4.

1. Sign in as **Administrator@clients.ad.lab.test**.
1. Using **File Explorer**, try to navigate to `\\PM-SRV1.extranet.lab.test`.

    > You should see the shares NETLOGON and SYSVOL.

1. Sign out.
1. Sign in as **Administrator@extranet.lab.test**.

    > The sign in should succeed.

1. Sign out.

### Task 7: Recover from the failure of the intermediate domain

Perform this task on the VMware Workstation host.

1. Select each VM recorded as paused during the preceding failure simulation: **WIN-VN1-SRV1**, **WIN-VN1-SRV5**, and **WIN-VN2-SRV1**, where present.
1. Choose **VM > Power > Pause** again to clear the paused state and resume execution. Do not select a machine that was already powered off or suspended before the simulation.
1. Verify AD DNS and domain connectivity recover before continuing.

Alternatively, use VMware's documented `vmrun` **unpause** command with each recorded absolute `.vmx` path. Substitute the path recorded when pausing; do not use guest hostnames as paths:

````powershell
$vmxPath = '<ABSOLUTE_PATH_TO_PAUSED_VM.vmx>'
if ($vmxPath -match '^<.+>$') { throw 'Supply the recorded VMware VMX path first.' }
vmrun -T ws unpause $vmxPath
if ($LASTEXITCODE -ne 0) { throw 'VMware unpause failed; inspect the VM state.' }
````

## Exercise 5: Create and validate a forest trust

1. [Implement DNS name resolution of ad.contoso.com](#task-1-implement-dns-name-resolution-of-adcontosocom)
1. [Implement DNS name resolution of ad.lab.test and extranet.lab.test](#task-2-implement-dns-name-resolution-of-adlabtest)
1. [Verify DNS name resolution between the forests](#task-3-verify-dns-name-resolution-between-the-forests)
1. [Create a forest trust](#task-4-create-a-forest-trust)
1. [Add a principal from an external forest to a domain-local group](#task-5-add-a-principal-from-an-external-forest-to-a-domain-local-group): Add Wil to Marketing Read.
1. [Verify the effect of selective authentication accessing resources](#task-6-verify-the-effect-of-selective-authentication-accessing-resources) by trying to access `\\VN1-SRV10` with the user Wil@contoso.com.
1. [Verify the effect of selective authentication on sign in](#task-7-verify-the-effect-of-selective-authentication-on-sign-in) by traing to sign in to CL4 as Wil@contoso.com.
1. [Allow users from the external forest to access computers](#task-8-allow-users-from-the-external-forest-to-access-computers) VN1-SRV10 and CL4
1. [Verify sign in and resource access over a forest trust](#task-9-verify-sign-in-and-resource-access-over-a-forest-trust) with the user Wil@contoso.com signing into CL4 and accessing `\\VN1-SRV10\Marketing.`

### Task 1: Implement DNS name resolution of ad.contoso.com

#### Desktop experience

Perform this task on CL1.

1. Open **DNS**.
1. In **Connect to DNS Server**, click **The following computer**, type **10.1.1.8**, and click **OK**.
1. In **DNS Manager**, click and expand **10.1.1.8**, and click **Conditional Forwarders**.
1. In the context-menu of **Conditional Forwarders**, click **New Conditional Forwarder...**
1. In New Conditional Forwarder, under **DNS Domain**, type **ad.contoso.com**. Under **IP addresses of the master servers**, click **\<Click here to add an IP Address or DNS Name\>**, and enter **10.1.2.16**. Activate the checkbox **Store this conditional forwarder in Active Directory** and, below, click **All DNS servers in this forest**. Click **OK**.

#### PowerShell

Perform this task on CL1.

1. In the context menu of **Start**, click **Terminal (Admin)**.
1. On **10.1.1.8**, add a conditional forwarder for zone **ad.contoso.com** pointing to **10.1.2.16**. The forwarder should be replicated forest-wide.

    ````powershell
    Add-DnsServerConditionalForwarderZone `
        -Name ad.contoso.com `
        -MasterServers 10.1.2.16 `
        -ReplicationScope Forest `
        -ComputerName 10.1.1.8
    ````

### Task 2: Implement DNS name resolution of ad.lab.test

#### Desktop experience

Perform this task on VN2-SRV2.

1. Open **DNS**.
1. In **DNS Manager**, click and expand **VN2-SRV2**, and click **Conditional Forwarders**.
1. In the context-menu of **Conditional Forwarders**, click **New Conditional Forwarder...**
1. In New Conditional Forwarder, under **DNS Domain**, type **ad.lab.test**. Under **IP addresses of the master servers**, click **\<Click here to add an IP Address or DNS Name\>**, and enter **10.1.1.8** and **10.1.2.8**. Activate the checkbox **Store this conditional forwarder in Active Directory** and, below, click **All DNS servers in this forest**. Click **OK**.
1. In the context-menu of **Conditional Forwarders**, click **New Conditional Forwarder...**
1. In New Conditional Forwarder, under **DNS Domain**, type **extranet.lab.test**. Under **IP addresses of the master servers**, click **\<Click here to add an IP Address or DNS Name\>**, and enter **10.1.200.8**. Activate the checkbox **Store this conditional forwarder in Active Directory** and, below, click **All DNS servers in this forest**. Click **OK**.

#### PowerShell

Perform this task on VN2-SRV2.

1. In the context menu of **Start**, click **Windows PowerShell**.
1. Add a conditional forwarder for zone **ad.lab.test** pointing to **10.1.1.8** and **10.1.2.8**. The forwarder should be replicated forest-wide.

    ````powershell
    Add-DnsServerConditionalForwarderZone `
        -Name ad.lab.test `
        -MasterServers 10.1.1.8, 10.1.2.8 `
        -ReplicationScope Forest
    ````

1. Add a conditional forwarder for zone **extranet.lab.test** pointing to **10.1.200.8**. The forwarder should be replicated forest-wide.

    ````powershell
    Add-DnsServerConditionalForwarderZone `
        -Name extranet.lab.test `
        -MasterServers 10.1.200.8 `
        -ReplicationScope Forest
    ````

### Task 3: Verify DNS name resolution between the forests

Perform this task on CL1.

1. In the context menu of **Start**, click **Terminal**.
1. Verify the DNS name resolution for **ad.contoso.com** on the server **10.1.1.8**.

    ````powershell
    Resolve-DnsName -Name ad.contoso.com -Server 10.1.1.8
    ````

    > You should get the IP address 10.1.2.16.

1. Verify the DNS name resolution for **ad.lab.test** on the server **10.1.2.16**.

    ````powershell
    Resolve-DnsName -Name ad.lab.test -Server 10.1.2.16
    ````

    > You should get the IP address 10.1.1.8. Additional IP addresses may be returned.

1. Verify the DNS name resolution for **clients.ad.lab.test** on the server **10.1.2.16**.

    ````powershell
    Resolve-DnsName -Name clients.ad.lab.test -Server 10.1.2.16
    ````

    > You should get the IP address 10.1.1.56.

1. Verify the DNS name resolution for **extranet.lab.test** on the server **10.1.2.16**.

    ````powershell
    Resolve-DnsName -Name extranet.lab.test -Server 10.1.2.16
    ````

    > You should get the IP address 10.1.200.8 and 10.1.200.9.

### Task 4: Create a forest trust

Perform this task on CL1.

1. Open **Active Directory Domains and Trusts**.
1. In the context-menu of **ad.lab.test**, click **Properties**.
1. In ad.lab.test Properties, click the tab **Trusts**.
1. On tab Trusts, click **New Trust...**.
1. In New Trust Wizard, on page Welcome to the New Trust Wizard, click **Next >**.
1. On page Trust Name, in **Name**, type **ad.contoso.com** and click **Next >**.
1. On page Trust Type, click **Forest trust** and click **Next >**.
1. On page Direction of Trust, ensure Two-way is selected and click **Next >**.
1. On page Side of Trust, click **Both this domain and the specified domain** and click **Next >**.
1. On page User name and Password, type the credentials for **Administrator@ad.contoso.com**.
1. On page **Outgoing Trust Authentication Level-Local Forest**, click **Selective authentication** and click **Next >**.
1. On page **Outgoing Trust Authentication Level-Specified Forest**, click **Forest-wide authentication** and click **Next >**.
1. On page Trust Selections Complete, click **Next >**.
1. On page Trust Creation Complete, click **Next >**.
1. On page Confirm Outgoing Trust, click **Yes, confirm the outgoing trust** and click **Next >**.
1. On page Confirm Incoming Trust, click **Yes, confirm the incoming trust** and click **Next >**.
1. On page Completing the New Trust Wizard, click **Finish**.
1. In **ad.lab.test Properties**, click **OK**.

### Task 5: Add a principal from an external forest to a domain-local group

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **ad (local)**.
1. In ad (local), double-click **Entitling groups**.
1. In Entitling groups, double-click **Marketing Read**.
1. In Marketing Read, in the left pane, click **Members**.
1. Under Members, click **Add...**.
1. In Select Users, Contacts, or Other Objects, click **Locations...**.
1. In Locations, click **ad.contoso.com** and click **OK**.
1. In **Select Users, Contacts, or Other Objects**, in **Enter the object names to select**, type **Wil** and click **Check Names**.
1. In **Select Users, Contacts, or Other Objects**, click **OK**.
1. In **Marketing Read**, click **OK**.

### Task 6: Verify the effect of selective authentication accessing resources

Perform this task on CL3.

1. Sign in as **Wil@contoso.com**.
1. Using **File Explorer**, navigate to `\\VN1-SRV10.ad.lab.test.`

    > You will receive an error message like in [figure 1].

### Task 7: Verify the effect of selective authentication on sign in

Perform this task on CL4.

1. Sign in as **Wil@contoso.com**.

    > You will receive an error message like in [figure 2].

### Task 8: Allow users from the external forest to access computers

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **Global Search**.
1. In Global Search, in **Search**, type **VN1-SRV10** and click **Search**.
1. Double-click **VN1-SRV10**.
1. In VN1-SRV10, click **Extensions**.
1. In Extensions, on tab **Security**, click **Add...**.
1. In **Select Users, Contacts, or Other Objects**, in **Enter the object names to select**, type **Marketing Read** and click **OK**.
1. In **VN1-SRV10**, under **Permissions for Marketing Read**, in column **Allow**, activate the checkbox **Allowed to authenticate** and click **OK**.
1. In **Active Directory Administrative Center**, on the menu, click **Manage**, **Add Navigation Nodes...**
1. In Add Navigation Nodes, in the middle pane, click **clients**, click **>>**, and click **OK**.
1. In **Active Directory Administrative Center**, click **clients**.
1. In clients, double-click **Computers**.
1. In Computers, double-click **CL4**.
1. In CL4, click **Extensions**.
1. In Extensions, on tab **Security**, click **Add...**.
1. In Select Users, Computers, Service Accounts, or Groups, click **Locations...**.
1. In Locations, click **ad.contoso.com** and click **OK**.
1. In **Select Users, Contacts, or Other Objects**, in **Enter the object names to select**, type **Wil** and click **Check Names**.
1. In **Select Users, Contacts, or Other Objects**, click **OK**.
1. In **CL4**, under **Permissions for Wil**, in column **Allow**, activate the checkbox **Allowed to authenticate** and click **OK**.

### Task 9: Verify sign in and resource access over a forest trust

Perform this task on CL4.

1. Sign in as **Wil@contoso.com**.

    > You should be able sign in.

1. Using File Explorer, navigate to `\\VN1-SRV10.ad.lab.test\Marketing`.

    > You should be able to access the share.

1. Sign out.

## Exercise 6: Migrating users between domains

> **ADMT compatibility gate:** This is an optional historical migration study. Microsoft's [ADMT support policy](https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/support-policy-and-known-issues-for-admt) excludes modern client/server combinations and does not establish support for this Server 2025/Windows 11 baseline. Preserve the migration, trust and SID-history objectives as a conceptual walkthrough here. Attempt execution only in a separate disposable legacy compatibility environment with its SQL and credential prerequisites verified; do not disable current security protections or downgrade the primary forest to make ADMT run.

1. [Install the Active Directory Migration Tool](#task-1-install-the-active-directory-migration-tool)
1. [Create the target organizational group](#task-2-create-the-target-organizational-group) Marketing in domain clients.ad.lab.test
1. [Migrate users within a forest](#task-3-migrate-users-within-a-forest): Migrate all users in the organizational unit Marketing to the clients domain
1. [Verify the results of users migration within a forest](#task-4-verify-the-migration-of-users-within-a-forest)
1. [Verify resource access after user migration within a forest](#task-5-verify-resource-access-after-user-migration-within-a-forest)
1. [Set permissions in the target forest](#task-6-grant-permissions-in-the-target-forest) ad.contoso.com
1. [Create the target organizational group](#task-7-create-the-target-organizational-group) Development in domain ad.contoso.com
1. [Migrate a user between forests](#task-8-migrate-users-between-forests): Migrate all users in the organizational unit Development to the contoso domain
1. [Verify the migration of users between forests](#task-9-verify-the-migration-of-users-between-forests)
1. [Verify sign in after user migration between forests](#task-10-verify-sign-in-after-user-migration-between-forests) on CL3

### Task 1: Install the Active Directory Migration Tool

Perform this task on CL1.

1. With Microsoft Edge, navigate to <https://www.microsoft.com/en-us/download/details.aspx?id=56570>.
1. On page Active Directory Migration Tool version 3.2 (has known problems and limited support), click **Download**.
1. Open the downloaded file.
1. In Active Directory Migratin Tool Installation Wizard, on page Welcome to the Active Directory Migration Tool Installation, click **Next >**.
1. On page License Agreement, click **I agree** and click **Next >**.
1. On page Customer Experience Improvement Program, click **I don't want to join the program at this time** and click **Next >**.
1. On page Database Selection, in **Database (Server\Instance)**, type **VN1-SRV3** and click **Next >**.
1. On the next page, click **Finish**.

### Task 2: Create the target organizational group

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **clients**.

    If you do not have a **clients** node in Active Directory Administrative Center, add the navigation node:

    1. In **Active Directory Administrative Center**, on the menu, click **Manage**, **Add Navigation Nodes...**
    1. In Add Navigation Nodes, in the middle pane, click **clients**, click **>>**, and click **OK**.

1. In the context-menu of **clients (local)**, click **New**, **Organizational Unit**.
1. In Create Organizational Unit, in **Name**, type **Marketing** and click **OK**.

### Task 3: Migrate users within a forest

Perform this task on CL1.

1. Open the **Active Directory Migration Tool**.
1. In migrator - [Active Directory Migration Tool], in the context-menu of **Active Directory Migration Tool**, click **User Account Migration Wizard**.
1. In User Account Migration Wizard, on page Welcome to the User Account Migration Wizard, click **Next >**.
1. On page Domain Selection, under **Source**, in **Domain**, type **ad.lab.test**. Under **Target**, in **Domain**, type **clients.ad.lab.test**. Click **Next >**.
1. On page User Selection Option, ensure **Select users from domain** is selected and click **Next >**.
1. On page User Selection, click **Add...**
1. In Select users, click **Locations...**
1. In Locations, expand **ad.lab.test**, click **Marketing** and click **OK**.
1. In **Select Users**, cick **Advanced...**
1. In Select Users (Advanced), click **Find Now**.
1. Below **Search results** select all users: Click **Ada Russell**, hold down SHIFT, scroll down and click **Zan Kustrin**. Click **OK**.
1. In **Select Users**, click **OK**.
1. On page **User Selection**, click **Next >**.
1. On page Organizational Unit Selection, click **Browse...**
1. In Browse for Container, click **Marketing** and click **OK**.
1. On page **Organizational Unit Selection**, click **Next >**.
1. On page User Options, activate the checkbox **Migrate associated user groups** and **Update previously migrated objects**, and click **Next >**.
1. On page Conflict Management, ensure **Do no migrate source object if a conflict is detected in the target domain** is selected and  click **Next >**.
1. On page Completing the User Account Migration Wizard, click **Finish**.
1. In Migration Process, wait until **Status** changes to **Completed** and click **Close**.

### Task 4: Verify the migration of users within a forest

Perform this task on CL1.

1. Open the **Active Directory Migration Tool**.
1. In migrator - [Active Directory Migration Tool], in the context-menu of **Active Directory Migration Tool**, click **Reporting Wizard**.
1. In Reporting Wizard, on page **Welcome to the Reporting Wizard**, click **Next >**.
1. On page Domain Selection, under **Source**, in **Domain**, ensure **ad.lab.test** is filled in. Under **Target**, in **Domain**, ensure **clients.ad.lab.test** is filled in. Click **Next >**.
1. On page Folder Selection, click **Next >**.
1. On page Report Selection, click **Migrated accounts**, and click **Next >**.
1. On page Completing the Reporting Wizard, click **Finish**.
1. In **migrator - [Active Directory Migration Tool]**, expand **Reports** and click **Migrated User, Group and Managed Service Accounts**. Review the report.
1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **ad (local)**.
1. In ad (local), double-click **Marketing**.

    > The organizational unit Marketing should not contain objects anymore.

1. Click **ad (local)** and double-click **Entitling Groups**.
1. In Entitling Groups, double-click **Marketing Modify**.
1. In Marketing Modify, click **Members** and review the members.

    > The migrated group Marketing should be a member. The Active Directory Domain Services Folder reads clients-Marketing-Marketing.

1. Click **Cancel**.
1. In **Active Directory Administrative Center**, click **clients**.
1. In clients, double-click **Marketing**.

    > You should see the migrated users as well as the migrated group **Marketing**.

1. Double-click the **Group** **Marketing**.
1. In Marketing Properties, click the tab **Members**.

    > All migrated users should be member of Marketing.

1. Click **Cancel**.
1. In **Active Directory Administrative Center**, in the organizational unit Marketing, double-click **Ada Russell**.
1. In **Ada Russel**, click **Extensions**.
1. In Extensions, click the tab **Attribute Editor**.
1. On tab Attribute Editor, click **Filter**, **Show only attributes that have values**.
1. Find the attribute **sIDHistory** and notice the value. Find the attribute **objectSid** and notice the value. Compare the number after **S-1-5-21-**.

    > The number after S-1-5-21- is the domain SID. It is different in the attrributes objectSid and sIDHistory, which indicates, that the value in in sIDHistory is the SID from a different domain.

1. Click **Cancel**.

### Task 5: Verify resource access after user migration within a forest

Perform this task on CL2.

1. Sign in as **ada@lab.test**.

    > You will have to change the password.

1. Using **File Explorer**, navigate to `\\VN1-SRV10\Marketing.`

    > Ada should still have access.

1. Sign out.

### Task 6: Grant permissions in the target forest

Perform this task on VN2-SRV2.

1. Open **Active Directory Users and Computers**.

    Note: Because of a bug in Active Directory Administrative center, you must use Active Directory Users and Computers in this task.

1. In Active Directory Users and Computers, expand **ad.contoso.com** and click **Builtin**.
1. In Builtin, double-click **Administrators**.
1. In Administrators Properties, click the tab **Members**.
1. On tab Members, click **Add...**.
1. In Select Users, Contacts, Computers, Service Accounts, or Groups, click **Locations...**
1. In Locations, click **ad.lab.test** and click **OK**.
1. In **Select Users, Contacts, Computers, Service Accounts, or Groups**, in Enter the object names to select, type **Administrator** and click **Check Names**.
1. In Windows Security, enter the credentials of **Administrator@ad.lab.test**.
1. In Multiple Names Found, in the column **In Folder**, click **ad.lab.test/Users** and click **OK**.
1. In **Select Users, Contacts, Computers, Service Accounts, or Groups**, click **OK**.
1. In **Administrators Properties**, click **OK**.

### Task 7: Create the target organizational group

Perform this task on VN2-SRV2.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, in  the context-menu of **ad (local)**, click **New**, **Organizational Unit**.
1. In New Object - Organizational Unit, in **Name**, type **Development** and click **OK**.

### Task 8: Migrate users between forests

Perform this task on CL1.

1. Sign in as **Administrator@ad.lab.test**.
1. Open the **Active Directory Migration Tool**.
1. In migrator - [Active Directory Migration Tool], in the context-menu of **Active Directory Migration Tool**, click **User Account Migration Wizard**.
1. In User Account Migration Wizard, on page Welcome to the User Account Migration Wizard, click **Next >**.
1. On page Domain Selection, under **Source**, in **Domain**, ensure **ad.lab.test** is filled in. Under **Target**, in **Domain**, type **ad.contoso.com**. Click **Next >**.
1. On page User Selection Option, ensure **Select users from domain** is selected and click **Next >**.
1. On page User Selection, click **Add...**
1. In Select users, click **Locations...**
1. In Locations, expand **ad.lab.test**, click **Development** and click **OK**.
1. In **Select Users**, cick **Advanced...**
1. In Select Users (Advanced), click **Find Now**.
1. Below **Search results** select all users: Click **Anete Auzina**, hold down SHIFT, scroll down and click **Zoja Bobanec**. Click **OK**.
1. In **Select Users**, click **OK**.
1. On page **User Selection**, click **Next >**.
1. On page Organizational Unit Selection, click **Browse...**
1. In Browse for Container, click **Development** and click **OK**.
1. On page **Organizational Unit Selection**, click **Next >**.
1. On page Password Options, click **Generate complex passwords**, and activate **Do not update passwords for existing users**. Take a note of the path displayed under **Location to store password file**. Optionally, you can change the location. Click **Next >**.
1. On page Account Transition Options, ensure **Target same as source** is selected. Activate **Disable source accounts** and **Migrate user SIDs to target domain**. Click **Next >**.
1. In the message box **Auditing is currently not enabled on the source domain.  Would you like to enable auditing?**, click **Yes**.
1. In the message box **Auditing is currently not enabled on the target domain.  Would you like to enable auditing?**, click **Yes**.
1. In the message box **The local group AD$$$ does not exist on ad.lab.test.  This group is required to migrate SIDs.  Would you like to create it?**, click **Yes**.
1. In **User Account Migration Wizard**, on page **User Account**, type the credentials of **Administrator** in the Domain **AD**.
1. On page User Options, ensure the checkboxes **Migrate associated user groups**, **Update previously migrated objects** and **Fix users' group memberships** are activated, and click **Next >**.
1. On page Object Property Exclusion, ensure the checkbox **Exclude specific object properties from migration** is deactivated and click **Next >**.
1. On page Conflict Management, ensure **Do not migrate source object if a conflict is detected in the target domain** is selected and click **Next >**.
1. On page Completing the User Account Migration Wizard, click **Finish**.
1. In Migration Process, wait until **Status** changes to **Completed** and click **Close**.

### Task 9: Verify the migration of users between forests

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **ad (local)**.
1. In ad (local), double-click **Development**.

    > All users in the organizational unit should be disabled.

1. On the menu, click **Manage**, **Add Navigation Nodes...**
1. In Add Navigation Nodes, click **Connect to other domains...** (in the bottom right). Beside **Connect to**, type **ad.contoso.com** and click **OK**.
1. In **Active Directory Users and Computers**, in the context-menu of **ad.lab.test**, click **Change Domain...**
1. In Change domain, type **ad.contoso.com** and click **OK**.
1. In the left pane, ensure **ad** is selected and click **>>** and click **OK**.
1. In **Active Directory Administrative Center**, in the context-menu of **ad**, click **Rename...**
1. In Rename, under **Please input the new name**, type **ad.contoso.com** and click **OK**.
1. In **Active Directory Administrative Center**, click **ad.contoso.com**.
1. In ad.contoso.com, double-click **Development**.

    > You should see the migrated users as well as the migrated group **Development**. The users should be enabled.

1. Double-click the **Group** **Development**.
1. In Development, click **Members**.

    > All migrated users should be member of Development.

1. Click **Cancel**.
1. In **Active Directory Administrative Center**, in the organizational unit **Development**, double-click **Anete Auzina**.

    If you receive an error message Failed to retrieve the object, close Active Directory Administrative Center and open it again.

    > The User UPN logon shuld be Anete@ad.contoso.com.

1. Click **Extensions**.
1. Click the tab **Attribute Editor**.
1. Find the attribute **sIDHistory** and notice the value. Find the attribute **objectSid** and notice the value. Compare the number after **S-1-5-21-**.

    > The number after S-1-5-21- is the domain SID. It is different in the attrributes objectSid and sIDHistory, which indicates, that the value in in sIDHistory is the SID from a different domain.

1. Click **Cancel**.
1. Open the password file you took note of (probably **C:\\Windows\\ADMT\\Logs\\passwords.txt**). Take a note of the password of **Anete**.

### Task 10: Verify sign in after user migration between forests

Perform this task on CL3.

1. Sign in as **anete@ad.contoso.com**.

    You will have to change the password.

    > The sign in should succeed.

1. Sign out.

[figure 1]: /images/Authentication-Firewall-Error.png
[figure 2]: /images/Authentication-Firewall-Error-signin.png
