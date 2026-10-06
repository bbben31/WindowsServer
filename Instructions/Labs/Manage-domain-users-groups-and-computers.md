# Lab: Manage domain users, groups, and computers

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Manage-local-groups.md; Instructions/Practices/Enable-the-Active-Directory-Recycle-Bin.md; Instructions/Labs/Explore-Windows-Admin-Center.md; Instructions/General/Learner-Account-Fixtures.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); CL2 (VMware display: CL2; accepted display aliases: WIN-CL2; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary VMnet8 NAT on the configured WAC gateway guest and CL1 browser during extension installation only; retain isolated AD NICs/DNS and disconnect afterward.

**Permissions:** Delegated AD/GPO rights for the named OU, account and policy changes; lab Domain Administrator only where the procedure requires it. Local Administrator for guest setup. WAC gateway Administrator for installing the extension; Local Administrator on gateway/browser guests only for temporary NIC configuration.

**Outbound access:** Download the WAC Active Directory extension from the configured official Microsoft extension feed. Before extension installation, attach temporary VMnet8 NAT NICs to the existing WAC gateway guest and CL1 browser guest (one NIC if they are the same machine); preserve the AD NIC/DNS, disable NAT NIC DNS registration, and record adapters/routes/DNS. Disconnect these NICs after installation. If the extension is already installed, this setup step needs no download. Endpoints: https://aka.ms/wac-public-extensions (official feed redirect); https://pkgs.dev.azure.com (gateway extension packages); *.vsblob.visualstudio.com (gateway package content); https://winadmincenterassets.blob.core.windows.net (browser extension assets); https://js.monitor.azure.com (browser extension assets); https://nuget.org (browser extension management); https://announcements.blob.core.windows.net (browser extension management).

**Risk, cost and optional status:** high; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. The Active Directory extension must be compatible with the installed WAC gateway version; verify its publisher/version before installation.

**Success verification:** The intended test accounts/groups/computer objects exist with correct membership and permissions; recovery restores the deleted object.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Disconnect temporary VMnet8 NICs on the gateway/browser and restore recorded adapters/routes/DNS. Retain the Active Directory extension until dependent labs finish; uninstall only an exercise-installed extension when no dependent lab needs it.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision only existing prerequisite machines, disks, cluster roles and certificates before starting; create machines marked Created during exercise in their designated tasks. Follow alternatives and conditional-retirement requirements instead of starting every named VM; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.








## Required VMs

* CL1
* CL2
* VN1-SRV1
* VN1-SRV4

## Setup

On **CL1**, logon as **ad\Administrator**.

On **CL2**, logon as **.\LocalAdmin**.

Complete [Manage local groups](../Practices/Manage-local-groups.md) before continuing.

Complete [Enable the Active Directory Recycle Bin](../Practices/Enable-the-Active-Directory-Recycle-Bin.md) before continuing.

Complete [Explore Windows Admin Center](../Labs/Explore-Windows-Admin-Center.md), including adding the required server connections, before continuing.

## Introduction

You want to manage users and groups. You want to evaluate the Active Directory Recycle Bin. Moreover, you want to evaluate several scenarios in the lifecycle the domain membership of a computer.

## Exercises

1. [Manage domain users](#exercise-1-manage-domain-users)
1. [Manage domain groups](#exercise-2-manage-domain-groups)
1. [Manage domain computers](#exercise-3-manage-domain-computers)

## Exercise 1: Manage domain users

1. [Create domain users](#task-1-create-domain-users)

    | First name | Last name   | Organizational unit |
    |------------|-------------|---------------------|
    | Luca       | Perry       | IT                  |
    | Aimie      | Draper      | IT                  |
    | Otto       | Jensen      | Development         |
    | Taylan     | Long        | Development         |
    | Eduardo    | Conner      | Managers            |
    | Azra       | Hendrix     | Managers            |
    | Caspar     | Nixon       | Marketing           |
    | Bianka     | Fulton      | Marketing           |
    | Alton      | Sampson     | Research            |
    | Giulia     | Allan       | Research            |
    | Keegan     | O'Gallagher | Sales               |
    | Millicent  | Brock       | Sales               |

1. [Rename domain users](#task-2-rename-domain-users)

    | First name | Old last name | New last name |
    |------------|---------------|---------------|
    | Colette    | Lichtenberg   | Kendall       |
    | Logan      | Boyle         | Stanley       |
    | Evangelina | Reeves        | Snow          |

1. [Reset the password of domain users](#task-3-reset-the-password-of-domain-users)

    * Holly Spencer
    * Bill Norman
    * Libby Hayward
    * Alfie Power

### Task 1: Create domain users

Create the users according to the table above in the given organizational unit. Use the different administration tools for this task. Below, generic instructions for each tool are provided.

#### Active Directory Users and Computers

Perform this task on CL1.

1. On the desktop, open **Basic Administration**.
1. In Basic Administration, expand **Active Directory Users and Computers**, **ad.lab.test**
1. In the context-menu of the organizational unit for the new user, click **New**, **User**.
1. In New Object - User, enter **First name** and  **Last name**.
1. In **User logon name** and **User logon name (pre-Windows 2000)**, enter the first name and click **Next >**
1. In **Password** and **Confirm password**, enter a secure password and click **Next >**.
1. Click **Finish**.

#### Active Directory Administrative Center

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **ad (local)**.
1. In the context-menu of the organizational unit for the new user, click **New**, **User**.
1. In Create User, enter **First name** and **Last name**.
1. In **User UPN logon** and **User SamAccountName logon**, enter the first name.
1. In **Password** and **Confirm password**, enter a secure password and click **OK**.

#### Windows Admin Center

Perform this task on CL1.

1. Using Microsoft edge, navigate to <https://admincenter>.
1. In Windows Admin Center, click **VN1-SRV1.ad.lab.test**.
1. Connected to VN1-SRV1.ad.lab.test, under Tools, click **Active Directory**.

    > Note: If you do not see **Active Directory**, you have to install the extension first. Refer to [Lab: Explore Windows Admin Center, Exercise 3](Explore-Windows-Admin-Center.md#exercise-3-install-extensions) for detailed instructions.

1. In Active Directory Domain Service, click **Create**, **User**.
1. In the panel Add User, under **Name**, type the **First name** and **Last name**, separated by a space.
1. Under **Sam Account Name**, type **First name**.
1. Under **Password**, type a secure password.
1. Under **Given Name**, type **First name**.
1. Under **Surname**, type **Last name**.
1. Click **Change...**.
1. Click the organizational unit for the new user and click **Select**.
1. Click **Create**.
1. In **Search Active Directory**, type parts of the user name and click **Search**.
1. Click the user.
1. Click **Properties**.
1. In User properties: ..., under **User UPN logon**, type **First name**, followed by **@ad.lab.test**
1. Click **Save**.
1. Click **Close**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Set up parameter variables for the domain. This step is required once for all users.

    ````powershell
    # You need to set up these variables once only
    $domainFQDN = 'ad.lab.test'
    $domainDN = 'DC=ad, DC=lab, DC=test'
    $domainNetBIOS = 'AD'
    ````

    Alternative, more sophisticated version, which builds everything from ````$domainFQDN````:

    ````powershell
    $domainFQDN = 'ad.lab.test'
    $domainDN = `
        (
            $domainFQDN -split '\.' | ForEach-Object { "DC=$PSItem" }
        ) -join ','
    ````

1. Set up parameter variables for the new user.

    ````powershell
    # Learner input: Fill the data of the new user between the quotes
    $ouName = ''
    $firstName = ''
    $lastName = ''

    $path = "OU=$ouName, $domainDN"
    $name = "$firstName $lastName"
    $userPrincipalName = "$firstname@$domainFQDN"
    ````

1. Create the new user.

    ````powershell
    $aDUser = New-ADUser `
        -Path $path `
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

### Task 2: Rename domain users

Rename the users according to the table above. Use the different administration tools for this task. Below, generic instructions for each tool are provided.

#### Active Directory Users and Computers

Perform this task on CL1.

1. From the desktop, open **Basic Administration**.
1. In Basic Administration, expand **Active Directory Users and Computer**, **ad.lab.test**.
1. In the context-menu of **ad.lab.test**, click **Find...**.
1. In Find Users, Contacts, and Groups, in **Name**, enter the first name.
1. In the context-menu of the found user, click **Rename**.
1. Change **Full name** to Firstname New last name.
1. Change **Last name** to the new last name and click **OK**.

#### Active Directory Administrative Center

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **Gloabl Search**.
1. In Global Search, in **Search**, enter the first name and click **Search**.
1. Double-click the found user.
1. Change **Last name** to the new last name and click **OK**.

#### Windows Admin Center

Perform this task on CL1.

1. Using Microsoft edge, navigate to <https://admincenter>.
1. In Windows Admin Center, click **VN1-SRV1.ad.lab.test**.
1. Connected to VN1-SRV1.ad.lab.test, under Tools, click **Active Directory**.
1. In Active Directory Domain Service, in **Search Active Directory**, type parts of the user name to rename and click **Search**.
1. Click the user to rename.
1. Click **Properties**.
1. In User properties: ..., under **Name**, change the last name to the new last name.
1. Change **Last Name** to the new last name.
1. Click **Save**.
1. Click **Close**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Set the parameter values for the user.

    ````powershell
    # Learner input: Fill the user data in the quotes
    $firstName = ''
    $oldLastName = ''
    $newLastname = ''
    ````

1. Build old name and new name.

    ````powershell
    $oldName = "$firstName $oldLastName"
    $newName = "$firstname $newLastName"
    ````

1. Rename the user.

    ````powershell
    Get-ADUser -Filter "Name -eq '$oldName'" | 
    Rename-ADObject -NewName $newName -PassThru | 
    Set-ADUser -DisplayName $newName -Surname $newLastName
    ````

### Task 3: Reset the password of domain users

Reset the password of the users from the list above. Use the different administration tools for this task. Below, generic instructions for each tool are provided.

#### Active Directory Users and Computers

Perform this task on CL1.

1. From the desktop, open **Basic Administration**.
1. In Basic Administration, expand **Active Directory Users and Computer**, **ad.lab.test**.
1. In the context-menu of **ad.lab.test**, click **Find...**.
1. In Find Users, Contacts, and Groups, in **Name**, enter user's name.
1. In the context-menu of the found user, click **Reset Password...**
1. In Reset Password, in **New password** and **Confirm password** enter a secure password.
1. Activate the checkbox **Unlock the user's account** and click **OK**.
1. In the message box **The password for ... has been changed.**, click **OK**.

#### Active Directory Administrative Center

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **Gloabal Search**.
1. In Global Search, in **Search**, enter the user name and click **Search**.
1. In the context-menu of the found user, click **Reset password...**
1. In Reset Password, in **New password** and **Confirm password** enter a secure password.
1. If possible, activate the checkbox **Unlock account** and click **OK**.

#### Windows Admin Center

Perform this task on CL1.

1. Using Microsoft edge, navigate to <https://admincenter>.
1. In Windows Admin Center, click **VN1-SRV1.ad.lab.test**.
1. Connected to VN1-SRV1.ad.lab.test, under Tools, click **Active Directory**.
1. In Active Directory Domain Services, in **Search Active Directory**, type the user's name and click **Search**.
1. Click the found user.
1. Click **Reset Password**.
1. In Reset Password, click **Confirm**.
1. Notice the temporary password and click **OK**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Set up parameter variables for the user.

    ````powershell
    # Learner input: Fill the data of the new user between the quotes
    $firstName = ''
    ````

1. Reset the password, make the user change password at next logon, and unlock the account.

    ````powershell
    Get-ADUser -Identity $firstName | 
    Set-ADAccountPassword -Reset -Passthru |
    Set-ADUser -ChangePasswordAtLogon $true -Passthru |
    Unlock-ADAccount
    ````

    Beside **Password** and **Repeat Password**, enter a secure password.

## Exercise 2: Manage domain groups

1. [Add members to domain groups](#task-1-add-members-to-a-domain-group)

    | First name | Last name   | Group       |
    |------------|-------------|-------------|
    | Luca       | Perry       | IT          |
    | Aimie      | Draper      | IT          |
    | Otto       | Jensen      | Development |
    | Taylan     | Long        | Development |
    | Eduardo    | Conner      | Managers    |
    | Azra       | Hendrix     | Managers    |
    | Caspar     | Nixon       | Marketing   |
    | Bianka     | Fulton      | Marketing   |
    | Alton      | Sampson     | Research    |
    | Giulia     | Allan       | Research    |
    | Keegan     | O'Gallagher | Sales       |
    | Millicent  | Brock       | Sales       |

1. [Create an organizational unit at domain level named Organizational groups](#task-2-create-an-organizational-unit)
1. [Create domain groups in the organization unit Organizational groups and add members](#task-3-create-domain-groups)

    | Group Name               | Members                                                                       |
    |--------------------------|-------------------------------------------------------------------------------|
    | Project Managers         | Alyson Winters, Damian Hadden, Isobel Wilkins, Peter Laamers                  |
    | Data Protection Managers | Adam Hobbs, Mary Skinner                                                      |
    | Apprentices              | Lara Raisic, Huong Tang, Huu Hoang, Brigita Krastina                          |
    | Pilot Users              | Doris David, Nestor Fiore, Laura Atkins, Ella Perry, Max Pennekamp, Erin Bull |

1. [Delete the group Pilot Users](#task-4-delete-a-domain-group)
1. [Restore the group Pilot Users](#task-5-restore-a-domain-group)

### Task 1: Add members to a domain group

Add users to groups according to the table above. Use the different administration tools for this task. Below, generic instructions for each tool are provided.

#### Active Directory Users and Computers

Perform this task on CL1.

1. From the desktop, open **Basic Administration**.
1. In Basic Administration, expand **Active Directory Users and Computer**, **ad.lab.test**.
1. In the context-menu of **ad.lab.test**, click **Find...**.

##### Variant A: Add a single user to multiple groups

4. In Find Users, Contacts, and Groups, in **Name**, enter user's name.
1. In the context-menu of the found user, click **Add to a group...**
1. In Select Groups, in **Enter the object names to select**, type the name of the group and click **OK**. You could type multiple groups separated by semicolon.
1. In the message box **The Add to Group operation was successfully completed**, click **OK**.

##### Variant B: Add multiple users to a group

4. In Find Users, Contacts, and Groups, in **Name**, enter group's name.
1. Double-click the found group.
1. Click the tab **Members**.
1. On the tab Members, click **Add...**.
1. In Select Groups, Contacts, Computers, Service Accounts, or Groups, in **Enter the object names to select**, type the name of the user. You can type multiple users separted by semicolon.
1. Click **OK**.
1. On the tab **Members**, click **OK**.

#### Active Directory Administrative Center

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.

##### Variant A: Add a single user to multiple groups

2. In Active Directory Administrative Center, click **Gloabal Search**.
1. In Global Search, in **Search**, enter the user name and click **Search**.
1. In the context-menu of the found user, click **Add to group...**
1. In Select Groups, in **Enter the object names to select**, type the name of the group and click **OK**. You could type multiple groups separated by semicolon.

##### Variant B: Add multiple users to a group

2. In Active Directory Administrative Center, click **Gloabal Search**.
1. In Global Search, in **Search**, enter the group's name and click **Search**.
1. Double-click the found group.
1. In the left pane, click **Members**
1. Under Members, click **Add...**.
1. In Select Groups, Contacts, Computers, Service Accounts, or Groups, in **Enter the object names to select**, type the name of the user. You can type multiple users separted by semicolon.
1. Click **OK**.
1. Click **OK**.

#### Windows Admin Center

Perform this task on CL1.

1. Using Microsoft edge, navigate to <https://admincenter>.
1. In Windows Admin Center, click **VN1-SRV1.ad.lab.test**.
1. Connected to VN1-SRV1.ad.lab.test, under Tools, click **Active Directory**.

##### Variant A

4. In Active Directory Domain Services, in **Search Active Directory**, type the user's name and click **Search**.
1. Click the found user.
1. Click **Properties**.
1. In User properties: ..., on the left, click **Membership**.
1. Click **Add**.
1. In the pane Add Group Membership, under **Group Sam Account Name**, type the name of the group and click **Add**.
1. Click **Save**.
1. Click **Close**.

##### Variant B

4. In Active Directory Domain Services, in **Search Active Directory**, type the group's name and click **Search**.
1. Click the found group.
1. Click **Properties**.
1. In Group properties: ..., on the left, click **Membership**.
1. Click **Add**.
1. In the pane Add Group Membership, under **User SamAccountname**, type the first name of the user and click **Add**.
1. Click **Save**.
1. Click **Close**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Add users to group.

    ````powershell
    # Fill in the data in quotes

    $groupName = ''
    # you can provide multiple user names separated by comma, e.g . 'Alton', 'Giulia'
    $userNames = ''

    Add-ADGroupMember -Identity $groupName -Members $userNames
    ````

### Task 2: Create an organizational unit

#### Active Directory Users and Computer

Perform this task on CL1.

1. From the desktop, open **Basic Administration**.
1. In Basic Administration, expand **Active Directory Users and Computer**, **ad.lab.test**.
1. In the context-menu of **ad.lab.test**, click **New**, **Organizational Unit**.
1. In New Object - Organizational Unit, in **Name**, enter **Organizational Groups** and click **OK**.

#### Active Directory Administrative Center

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In the context-menu of **ad (local)**, click **New**, **Organizational Unit**.
1. In Create Organizational Unit, in **Name**, enter **Organizational Groups** and click **OK**.

#### Windows Admin Center

Perform this task on CL1.

1. Using Microsoft edge, navigate to <https://admincenter>.
1. In Windows Admin Center, click **VN1-SRV1.ad.lab.test**.
1. Connected to VN1-SRV1.ad.lab.test, under Tools, click **Active Directory**.
1. Under Active Directory Domain Services, click the tab **Browse**.
1. Click **DC=ad,DC=lab,DC=test**.
1. In the right pane, click **Create**, **OU**.
1. In the pane Add Organizational Unit, in **Name**, enter **Organizational Groups** and click **Create**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Create the organizational unit **Organizational Groups** at the domain level.

    ````powershell
    New-ADOrganizationalUnit `
        -Path 'DC=ad,DC=lab,DC=test' `
        -Name 'Organizational Groups'
    ````

### Task 3: Create domain groups

Create groups in the organizational unit Organizational groups and add users as members according to the table above. Use the different administration tools for this task. Below, generic instructions for each tool are provided.

#### Active Directory Users and Computers

Perform this task on CL1.

1. From the desktop, open **Basic Administration**.
1. In Basic Administration, expand **Active Directory Users and Computer**, **ad.lab.test**.
1. Click **Organizational Groups**.
1. In the context-menu of Organizational Groups, click **New**, **Group**.
1. In New Object - Group, in **Group name**, type the name of the group. **Group scope** should be **Global** and **Group type** should be **Security**. Click **OK**.
1. Double-click the new group.
1. In ... Properties, click the tab **Members**.
1. On the tab Members, click **Add...**.
1. In Select Groups, Contacts, Computers, Service Accounts, or Groups, in **Enter the object names to select**, type the name of the user. You can type multiple users separted by semicolon.
1. Click **OK**.
1. On the tab **Members**, click **OK**.

#### Active Directory Administrative Center

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. Click **ad (local)**.
1. Double-click **Organizational groups**.
1. In the pane **Tasks**, click **New**, **Group**.
1. In Create Group, in **Group name**, enter the name of the new group.
1. On the left, click **Members**.
1. Under Members, click **Add...**.
1. In Select Groups, Contacts, Computers, Service Accounts, or Groups, in **Enter the object names to select**, type the name of the user. You can type multiple users separted by semicolon.
1. Click **OK**.
1. Click **OK**.

#### Windows Admin Center

Perform this task on CL1.

1. Using Microsoft edge, navigate to <https://admincenter>.
1. In Windows Admin Center, click **VN1-SRV1.ad.lab.test**.
1. Connected to VN1-SRV1.ad.lab.test, under Tools, click **Active Directory**.
1. Under Active Directory Domain Services, click the tab **Browse**.
1. In the tree pane, click **Organizational Groups**.
1. In the right pane, click **Create**, **Group**.
1. In the pane Add Group, in **Name**, type the name of the new group.
1. Under **Group Scope**, click **Global**.
1. In **Sam Account Name**, type the name of the new group again.
1. Right to **Create in**, click **Change...**.
1. In Select Path, click **Organizational Groups**.
1. Click **Select**.
1. Click **Create**.
1. In the right pane, left to the search box, click the icon *Refresh*.
1. Click the new group.
1. click **Properties**.
1. In Group properties: ..., on the left, click **Membership**.
1. Click **Add**.
1. In the pane Add Group Membership, under **User SamAccountname**, type the first name of the user and click **Add**.
1. Repeat the last two steps for additional users.
1. Click **Save**.
1. Click **Close**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Define the location for the new group.

    ````powershell
    $path = 'OU=Organizational Groups, DC=ad,DC=lab,DC=test'
    ````

1. Define the parameters for the new group.

    ````powershell
    # Fill in the data in quotes

    $groupName = ''
    # you can provide multiple user names separated by comma, e.g . 'Alton', 'Giulia'
    $userNames = ''
    ````

1. Create the group and add the members.

    ````powershell
    New-ADGroup -Name $groupName -Path $path -GroupScope Global -PassThru |
    Add-ADGroupMember -Members $userNames
    ````

### Task 4: Delete a domain group

#### Active Directory Users and Computers

Perform this task on CL1.

1. From the desktop, open **Basic Administration**.
1. In Basic Administration, expand **Active Directory Users and Computer**, **ad.lab.test**.
1. In the context-menu of **ad.lab.test**, click **Find...**.
1. In Find Users, Contacts, and Groups, in **Name**, type **Pilot Users** and click **Find Now**.
1. In the context menu of **Pilot Users**, click **Delete**.
1. In the message box **Are you sure you want to delete the group named 'Pilot Users'?**, click **Yes**.

#### Active Directory Administrative Center

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **Global search**.
1. Under GLOBAL SEARCH, in **Search**, type **Pilot Users** and click **Search**.
1. In the context menu of **Pilot Users**, click **Delete**.
1. In the message box **Are you sure you want to delete the Group 'Pilot Users'?**, click **Yes**.

#### Windows Admin Center

Perform this task on CL1.

1. Using Microsoft edge, navigate to <https://admincenter>.
1. In Windows Admin Center, click **VN1-SRV1.ad.lab.test**.
1. Connected to VN1-SRV1.ad.lab.test, under Tools, click **Active Directory**.
1. In Active Directory Domain Services, in **Search Active Directory**, type **Pilot Users** and click **Search**.
1. Click the found group.
1. Click **Delete**.
1. In the message box **Delete group** click **Confirm**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Delete the group **Pilot Users**.

    ````powershell
    Remove-ADGroup 'Pilot Users'
    ````

1. Under the message **Performing the operation "Remove" on target "CN=Pilot Users,OU=Organizational Groups,DC=ad,DC=lab,DC=test".**, enter **Y**.

### Task 5: Restore a domain group

#### Active Directory Administrative Center

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **ad (local)**.
1. Under ad (local), double-click **Deleted Objects**.
1. Under Deleted Objects, in the context-menu of **Pilot Users**, click **Restore**.
1. In the left pane, click **ad (local)**.
1. Under ad (local), double click **Organizational groups**.
1. Under Organizational Groups, double-click **Pilot Users**.
1. In Pilot Users, click **Members** and verify, that all previous members are still present.

#### Windows Admin Center

Perform this task on CL1.

1. Using Microsoft Edge, navigate to <https://admincenter>.
1. In Windows Admin Center, click **VN1-SRV1.ad.lab.test**.
1. Connected to VN1-SRV1.ad.lab.test, under Tools, click **Active Directory**.
1. Unter Active Directory Domain Services, in **Search Active Directory**, type **CL2** and click **Search**.
1. Click **CL2**.
1. Click **Delete**.
1. In the message box **Delete computer**, click **Confirm**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Find the deleted group.

    ````powershell
    Get-ADObject -Filter 'Name -like "Pilot*"' -IncludeDeletedObjects
    ````

    > An object should be returned.

1. Restore the deleted group.

    ````powershell
    Get-ADObject -Filter 'Name -like "Pilot*"' -IncludeDeletedObjects | 
    Restore-ADObject
    ````

1. Verify the location of the group.

    ````powershell
    Get-ADGroup 'Pilot Users'
    ````

    > **DistinguishedName** should contain **OU=Organizational Groups**.

1. Verify the members of the group.

    ````powershell
    Get-ADGroupMember 'Pilot Users'
    ````

    > All previous members should be listed.

## Exercise 3: Manage domain computers

1. [Unjoin CL2 from the domain](#task-1-unjoin-cl2-from-the-domain)
1. [Delete the CL2 computer account](#task-2-delete-the-computer-account)
1. [Create a computer account CL2 and allow Abbi Skinner to join a computer to this account](#task-3-create-a-computer-account-cl2)
1. [Join CL2 to the domain as standard user](#task-4-join-cl2-to-the-domain)
1. [Reset the computer account CL2](#task-5-reset-the-computer-account)
1. [Restore the trust relationship of CL2 with the domain](#task-6-restore-the-trust-relationship-of-cl2-with-the-domain)

### Task 1: Unjoin CL2 from the domain

#### Desktop Experience

Perform this task on CL2.

1. Open **Settings**.
1. In Settings, click **Accounts**.
1. Under Accounts, click **Access work or school**.
1. Under Access work or school, expand **ad.lab.test** and click **Disconnect**.
1. In the message **Are you sure you want to remove this account?...**, click **Yes**.
1. In the message box **Disconnect from the organization**, click **Disconnect**.
1. In the message box **Restart your PC**, click **Restart now**.

#### PowerShell

Perform this task on CL2.

1. Open **Terminal (Admin)**.
1. Unjoin the computer from the domain.

    ````powershell
    Remove-Computer -Restart -UnjoinDomainCredential ad\Administrator
    ````

1. Enter the credentials of ad\Administrator.
1. Under **After you leave the domain, you will need to know the password of the local Administrator account to log onto this computer. Do you wish to continue?**, enter **y**.

### Task 2: Delete the computer account

#### Active Directory Users and Computers

Perform this task on CL1.

1. On the desktop, open **Basic Administration**.
1. In Basic Administration, expand **Active Directory Users and Computer**.
1. In the context-menu of **ad.lab.test**, click **Find...**.
1. In Find Users, Contacts, and Groups, in **Find**, click **Computers**
1. In **Computer name**, enter **CL2**.
1. Under **Search results**, in the context-menu of **CL2**, click **Delete**.
1. In the message box **Are you sure you want to delete the computer named 'CL2'?**, click **Yes**.
1. In the message box **Object CL2 contains other objects. Are you sure you want to delete CL2 and all of the objects it contains?**, click **Yes**.

#### Active Directory Administrative Center

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **Global Search**.
1. Under GLOBAL SEARCH, in **Search**, type **CL2** and click **Search**.
1. In the context-menu of **CL2**, click **Delete**.
1. In the message box **Are you sure you want to delete the Computer 'CL2'?**, click **Yes**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal (Admin)**.
1. Delete the computer object.

    ````powershell
    Get-ADComputer CL2 | Remove-ADObject -Recursive
    ````

1. In the message box **Confirm**, click **Yes**.

### Task 3: Create a computer account CL2

#### Active Directory Users and Computers

Perform this task on CL1.

1. On the desktop, open **Basic Administration**.
1. In Basic Administration, expand **Active Directory Users and Computer**, **ad.lab.test**.
1. In the context-menu of **Computers**, click **New**, **Computer**.
1. In New Object - Computer, in **Computer name**, type CL2.
1. Under **User or group**, click **Change...**
1. In Select User or Group, in **Enter the object name to select**, type **Abbi Skinner** and click **OK**.
1. In **New Object - Computer**, click **OK**.

#### Active Directory Administrative Center

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. Click **ad (local)**.
1. In the context-menu of **Computers**, click **New**, **Computer**.
1. In Create Computer, in **Computer name**, type **CL2**.
1. To the right of **User or Group**, click **Change...**.
1. In Select User or Group, in **Enter the object name to select**, type **Abbi Skinner** and click **OK**.
1. In **Create Computer: CL2**, click **OK**.

### Task 4: Join CL2 to the domain

#### Desktop Experience

Perform this task on CL2.

1. Login as **.\LocalAdmin**.
1. In Settings, click **Accounts**.
1. Under Accounts, click **Access work or school**.
1. Under Access work or school, click **Connect**.
1. In Microsoft Account, click **Join this device to a local Active Directory domain**.
1. In Join a domain, in **Domain name**, type **ad.lab.test** and click **Next**.
1. In Join a domain, in **User name**, enter the credentials of **Abbi** and click **OK**.
1. In Add an account, make sure in **Account type**, **Standard User** is selected and click **Next**.
1. In Restart your PC, click **Restart now**.

#### PowerShell

Perform this task on CL2.

1. Open **Terminal (Admin)**.
1. Join the computer to the domain **ad.lab.test**.

    ````powershell
    Add-Computer -DomainName ad.lab.test -Restart
    ````

1. Enter the credentials of ad\Administrator.

### Task 5: Reset the computer account

#### Active Directory Users and Computers

Perform this task on CL1.

1. On the desktop, open **Basic Administration**.
1. In Basic Administration, expand **Active Directory Users and Computer**.
1. In the context-menu of **ad.lab.test**, click **Find...**.
1. In Find Users, Contacts, and Groups, in **Find**, click **Computers**
1. In **Computer name**, enter **CL2**.
1. Under **Search results**, in the context-menu of **CL2**, click **Reset Account**.
1. In the message box **Are you sure you want to reset this computer account?**, click **Yes**.
1. In the message box **Account CL2 was sucessfully reset.**, click **OK**.

#### Active Directory Administrative Center

Perform this task on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **Global Search**.
1. Under GLOBAL SEARCH, in **Search**, type **CL2** and click **Search**.
1. In the context-menu of **CL2**, click **Reset account...**.
1. Confirm only the **reset account** operation for CL2. If the dialog asks to **delete** the computer, click **No/Cancel** and reselect Reset account; deleting the object is not this task.

#### PowerShell

Perform this task on CL1.

1. Reset the computer account of **CL2**.

    ````powershell
    Get-ADComputer -Identity CL2 | 
    Set-ADAccountPassword -Reset -Passthru |
    Set-ADComputer -ChangePasswordAtLogon $true -Passthru |
    Unlock-ADAccount
    ````

1. Beside **Password** and **Repeat Password**, enter a secure password.

#### Task 6: Restore the trust relationship of CL2 with the domain

Perform this task on CL2.

1. Restart the computer.
1. Sign in with the credentials of **Abbi**.

    > A message **The trust relationship between this workstation and the primary domain failed.** is displayed.

1. Click **OK**.
1. Login as **LocalAdmin**.
1. Open **Terminal (Admin)**.
1. Reset the computer account password.

    ````powershell
    Reset-ComputerMachinePassword -Credential ad\Administrator
    ````

1. Enter the credentials of **ad\Administrator**.
1. Restart the computer.

    ````powershell
    Restart-Computer
    ````

1. Sign in with the credentials of **Abbi**.

    > This time you should be successful.

1. Sign out.
