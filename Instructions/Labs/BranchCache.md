# Lab: BranchCache

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-prerequisites-for-file-serving.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); CL3 (VMware display: CL3; accepted display aliases: WIN-CL3; existing); CL4 (VMware display: CL4; accepted display aliases: WIN-CL4; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN3-SRV1 (VMware display: VN3-SRV1; accepted display aliases: WIN-VN3-SRV1; existing).  Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments.

**Permissions:** Delegated AD/GPO rights for the named OU, account and policy changes; lab Domain Administrator only where the procedure requires it. Local Administrator for guest setup.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=true. local-only Optional configuration study: no reliable VMware-local performance gain is guaranteed; record cache state and skip unobservable portions. See the local adapted issue 201 explanation.

**Success verification:** Get-BCStatus shows the intended hosted/distributed mode, SCP registration and imported cache data; timing improvement is optional.

**Rollback and cleanup:** Restore coordinated pre-lab guests; remove only the exercise BranchCache GPOs, exported/imported packages and copied client data. No outer bandwidth limit was applied. Remove temporary outbound access.

<!-- END GENERATED COMPLETION CONTRACT -->


> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision every VM, extra disk, cluster member, certificate, and client named by this lab; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Required VMs

* CL1
* CL3
* CL4
* VN1-SRV1
* VN1-SRV10
* VN1-SRV4
* VN3-SRV1

## Setup

1. On the host, open **VMware Workstation**.
1. Shut down CL3 and CL4. In VMware Workstation, attach each lab NIC to the custom VMnet mapped to source **VNet3**, then start both guests.
1. Sign in to each guest with its local Administrator account and verify that it received or was assigned the VNet3 address, can reach the AD DNS server, and resolves `ad.lab.test`.
1. On each guest, run the following from an elevated PowerShell session and provide an authorized domain-join credential interactively:

    ````powershell
    Add-Computer `
        -DomainName 'ad.lab.test' `
        -Credential (Get-Credential -Message 'Authorized domain-join account') `
        -Restart
    ````
1. The timing comparison is optional. This VMware adaptation does not prescribe an unverified WAN throttle. Record transfer times as observations only; a local virtual network does not reproduce a slow WAN. Complete the configuration and cache-status checks even if the timing comparison is skipped.
1. On CL1, sign in as **ad\Administrator**.
1. On CL3, sign in as **ad\Administrator**.
1. On CL4, sign in as **ad\Administrator**.

## Introduction

Adatum wants to improve the performance accessing the file server from VNet2 and VNet3 using BranchCache. Because on VNet2 several servers are installed, one of the servers should be configured in hosted cache mode. This procedure uses VN3-SRV1 and CL3 on VNet3 for the hosted-cache phase, then CL3 and CL4 on that same segment for distributed mode. On VNet3 the distributed cache mode should be used and validated.

## Known Issues

This lab is optional. [Upstream issue 201](https://github.com/EnterpriseTrainingCenter/WindowsServer/issues/201) reports no measurable performance gain in hosted-cache exercise 2 task 8 or distributed-cache exercise 3 task 2; its suspected Windows 11 cause is unconfirmed. VMware-local throughput and client caching can also obscure timing. Do not require a faster second transfer to pass. Verify `Get-BCStatus`, hosted-cache registration, imported cache data, client mode, and policy application instead. If those results cannot be observed on the selected Windows edition, record the limitation and skip the affected portion.

## Exercises

1. [Configuring the file server and Active Directory for BranchCache](#exercise-1-configuring-the-file-server-and-active-directory-for-branchcache)
1. [Configuring and validating centralized BranchCache](#exercise-2-configuring-and-validating-branchcache-in-hosted-cache-mode)
1. [Configuring and validating peer-to-peer BranchCache](#exercise-3-configuring-and-validating-branchcache-in-distributed-cache-mode)

## Exercise 1: Configuring the file server and Active Directory for BranchCache

1. [Validate a slow network connection to VN1-SRV10](#task-1-validate-a-slow-network-connection-to-vn1-srv10)
1. [Install the BranchCache service role](#task-2-install-the-branchcache-service-role) on VN1-SRV10
1. [Enable hash publication for BranchCache](#task-3-enable-hash-publication-for-branchcache)
1. [Enable BranchCache for shares](#task-4-enable-branchcache-for-shares) IT and Marketing on VN1-SRV10

### Task 1: Validate a slow network connection to VN1-SRV10

Perform this task on CL3.

1. Open **Terminal**.
1. Copy the content of the IT share to the Documents folder while measuring the duration of the command.

    ````powershell
    Measure-Command -Expression { 
        Copy-Item \\vn1-srv10\IT\ ~\Documents\ -Recurse -Force
    }
    ````

    Record the measured duration; it depends on the dataset and host. Timing is optional and has no fixed expected duration.

### Task 2: Install the BranchCache service role

#### Desktop experience

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Reatures**.
1. In the Add Rules and Features Wizard, on the page **Before You Begin**, click **Next >**.
1. On the page Installation Type, ensure **Role-based or feature-based installation** is selected and click **Next >**.
1. On the page Server Selection, click **VN1-SRV10.ad.lab.test** and click **Next >**.
1. On the page Server Roles, expand **File and Storage Services**, **File and iSCSI Services**, and activate the checkbox next to **BranchCache for Network Files** and click **Next >**.
1. On the page Features, click **Next >**.
1. On the page Confirmation, verify your selection and click **Install**.
1. On the page **Results**, click **Close**.

#### Windows Admin Center

Perform this task on CL1.

1. Using Microsoft Edge, navigate to <https://admincenter>.
1. In Windows Admin Center, on the connections page, click **vn1-srv10.ad.lab.test**.
1. Connected to vn1-srv10.ad.lab.test, under **Tools**, click **Roles & features**.
1. In Roles and features, expand **File and Storage Services**, **File and iSCSI Services**, click **BranchCache for Network Files**, and click **Install**.
1. In the pane Install Role and Features, activate the checkbox **Reboot the server automatically, if required** and click **Yes**.

    After a few minutes, a notification **Install Roles and Features** appears. If you missed the notification, a small number appears beside the icon *Notifications* (in form of a bell) at the top-right of Windows Admin Center.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Install the BranchCache for Network Files role service on VN1-SRV10.

    ````powershell
    Install-WindowsFeature `
        -ComputerName VN1-SRV10 `
        -Name FS-BranchCache `
        -IncludeManagementTools `
        -Restart 
    ````

### Task 3: Enable hash publication for BranchCache

Perform this task on CL1.

1. Open **Group Policy Management**.
1. In Group Policy Management, expand **Group Policy Management**, **Forest: ad.lab.test**, **Domains**, and **ad.lab.test**.
1. In the context-menu of **ad.lab.test**, click **Create a GPO in this domain, and Link it here...**
1. In New GPO, in **Name**, type **Custom Computer BranchCache File Server** and click **OK**.
1. In **Group Policy Management**, in the context-menu of **Custom Computer BranchCache File Server**, click **Edit...**
1. In Group Policy Management Editor, expand **Computer Configuration**, **Policies**, **Administrative Templates**, **Network**, and click **Lanman Server**.
1. In the right pane, double-click **Hash Publication for BranchCache**.
1. In Hash Publication for BranchCache, click **Enabled**. Under **Hash publication actions**, click **Allow hash publication only for shared folder on which BranchCache is enabled**. Click **OK**.
1. Close **Group Policy Management Editor**.
1. Open **Terminal**.
1. Update group policies on **VN1-SRV10**.

    ````powershell
    Invoke-GPUpdate -Computer VN1-SRV10
    ````

### Task 4: Enable BranchCache for shares

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, click **File and Storage Services**.
1. In File and Storage Services, click **Shares**.
1. In Shares, in the context-menu of **IT**, click **Properties**.
1. In IT Properties, click the page **Settings**.
1. On page Settings, activate **Allow caching of share** and **Enable BranchCache on the file share**.

Repeat from step 4 for the share **Marketing**.

## Exercise 2: Configuring and validating BranchCache in hosted cache mode

1. [Install the BranchCache feature](#task-1-install-the-branchcache-feature) on VN3-SRV1
1. [Configure the hosted cache](#task-2-configure-the-hosted-cache) on VN3-SRV1
1. [Configure BranchCache for clients](#task-3-configure-branchcache-for-clients) on VNet2
1. [Prehash and export a BranchCache package](#task-4-prehash-and-export-a-branchcache-package) of share IT on VN1-SRV10
1. [Remove the bandwidth limit on virtual machine](#task-5-remove-the-bandwidth-limit-on-virtual-machine) WIN-VN1-SRV10
1. [Import the BranchCache package](#task-6-import-the-branchcache-package) on VN3-SRV1
1. [Set the bandwidth limit on virtual machine](#task-7-set-the-bandwidth-limit-on-virtual-machine) WIN-VN1-SRV10 (optional timing-only placeholder; no VMware throttle is applied)
1. [Validate BranchCache](#task-8-validate-branchcache) on CL3

### Task 1: Install the BranchCache feature

#### Desktop experience

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Reatures**.
1. In the Add Rules and Features Wizard, on the page **Before You Begin**, click **Next >**.
1. On the page Installation Type, ensure **Role-based or feature-based installation** is selected and click **Next >**.
1. On the page Server Selection, click **VN3-SRV1.ad.lab.test** and click **Next >**.
1. On the page Server Roles, click **Next >**.
1. On the page Features, activate **BranchCache** and click **Next >**.
1. On the page Confirmation, verify your selection and click **Install**.
1. On the page **Results**, click **Close**.

#### Windows Admin Center

Perform this task on CL1.

1. Using Microsoft Edge, navigate to <https://admincenter>.
1. In Windows Admin Center, on the connections page, click **VN3-SRV1.ad.lab.test**.
1. Connected to VN3-SRV1.ad.lab.test, under **Tools**, click **Roles & features**.
1. In Roles and features, under **Features**, click **BranchCache**, and click **Install**.
1. In the pane Install Role and Features, activate the checkbox **Reboot the server automatically, if required** and click **Yes**.

    After a few minutes, a notification **Install Roles and Features** appears. If you missed the notification, a small number appears beside the icon *Notifications* (in form of a bell) at the top-right of Windows Admin Center.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Install the BranchCache feature on VN3-SRV1.

    ````powershell
    Install-WindowsFeature `
        -ComputerName VN3-SRV1 `
        -Name BranchCache `
        -IncludeManagementTools `
        -Restart
    ````

### Task 2: Configure the hosted cache

Perform this task on CL1.

1. Open **Terminal**.
1. Create a CIM session to **VN3-SRV1**.

    ````powershell
    $cimSession = New-CimSession -ComputerName VN3-SRV1
    ````

1. Configure VN3-SRV1 as a hosted cache server and register a service connection point in Active Directory for automatic hosted cache server discovery by client computers.

    ````powershell
    Enable-BCHostedServer -CimSession $cimSession -RegisterSCP
    ````

1. Verify the correct configuration of the hosted cache server.

    ````powershell
    Get-BCStatus -CimSession $cimSession
    ````

    Under **HostedCacheServerConfiguration**, **HostedCacheServerIsEnabled** and **HostedCacheScpRegistrationEnabled** should be **True**. Under **DataCache**, take a note of **CurrentActiveCacheSize**. This should be 0.

1. Remove the CIM session.

    ````powershell
    Remove-CimSession -CimSession $cimSession
    ````

### Task 3: Configure BranchCache for clients

Perform this task on CL1.

1. Open **Group Policy Management**.
1. In Group Policy Management, expand **Group Policy Management**, **Forest: ad.lab.test**, **Domains**, **ad.lab.test** and click **ad.lab.test**.
1. In the context-menu of **ad.lab.test**, click **Create a GPO in this domain and Link it here...**.
1. In New GPO, under **Name**, type **Custom Computer BranchCache Client** and click **OK**.
1. In **Group Policy Management**, in the context-menu of **Custom Computer BranchCache Client**, click **Edit**.
1. In Group Policy Management Editor, expand **Computer Configuration**, **Policies**, **Administrative Templates**, **Network** and click **BranchCache**.
1. In the right pane, double-click **Turn on BranchCache**.
1. In Turn on BranchCache, click **Enabled** and click **OK**.
1. In **Group Policy Management Editor**, double-click **Enable Automatic Hosted Cache Discovery By Service Connection Point**.
1. In Enable Automatic Hosted Cache Discovery By Service Connection Point, click **Enabled** and click **OK**.
1. In **Group Policy Management Editor**, double-click **Configure BranchCache for network files**.
1. In Configure BranchCache for network files, click **Enabled**. Under **Type the maximum round trip network latency (milliseconds) after which caching begins**, type **0**. Click **OK**.
1. In **Group Policy Management Editor**, expand **Computer Configuration**, **Policies**, **Windows Settings**, **Security Settings**, **Windows Defender Firewall with Advanced Security**, **Windows Defender Firewall with Advanced Security**, and click **Outbound Rules**.
1. In the context-menu of **Outbound Rules**, cick **New Rule...**
1. In New Outbound Rule Wizard, in step Rule Type, click **Predefined**, **BranchCache - Hosted Cache Client (Uses HTTPS)**, and click **Next >**.
1. In step Predefined Rules, click **Next >**.
1. In step Action, click **Allow the connection** and click **Finish**.
1. Close **Group Policy Management Editor**.
1. Open **Terminal**.
1. Update the group policies on **CL3**.

    ````powershell
    Invoke-Command -ComputerName CL3 -ScriptBlock { gpupdate.exe }
    ````

### Task 4: Prehash and export a BranchCache package

Perform this task on CL1.

1. Open **Terminal**.
1. Create a CIM session to **VN1-SRV10**.

    ````powershell
    $cimSession = New-CimSession -ComputerName VN1-SRV10
    ````

1. On VN1-SRV10, generate hashes and stage data of **D:\Shares\IT**.

    ````powershell
    Publish-BCFileContent `
        -CimSession $cimSession -StageData -Path D:\Shares\IT -Recurse
    ````

1. Export a BranchCache package to **D:\Shares\BCCachePackage**.

    ````powershell
    Export-BCCachePackage -CimSession $cimSession -Destination D:\Shares\BCCachePackage
    ````

1. Remove the CIM session.

    ````powershell
    Remove-CimSession -CimSession $cimSession
    ````

### Task 5: Remove the bandwidth limit on virtual machine

No outer bandwidth setting is changed in this VMware adaptation. Skip this timing-only step; retain the package export/import and cache configuration tasks.

### Task 6: Import the BranchCache package

Perform this task on CL1.

1. Open **Terminal**.
1. Create a remote PowerShell session to VN3-SRV1.

    ````powershell
    $pSSession = New-PSSession -ComputerName VN3-SRV1
    ````

1. Copy the BranchCache package from VN1-SRV10 to VN3-SRV1.

    ````powershell
    Copy-Item `
        -Path '\\vn1-srv10\d$\Shares\BCCachePackage' `
        -ToSession $pSSession `
        -Destination c:\
    ````

1. Enter the remote PowerShell session.

    ````powershell
    Enter-PSSession -Session $pSSession
    ````

1. Import the BranchCache package.

    ````powershell
    Import-BCCachePackage -Path C:\BCCachePackage
    ````

1. Verify the status of the hosted cache server.

    ````powershell
    Get-BCStatus
    ````

    Under **DataCache**, take a note of **CurrentActiveCacheSize**. Record the imported cache size and compare it with the actual package; the classroom 68 MB value is an example.

1. Exit and remove the remote PowerShell session

    ````powershell
    Exit-PSSession
    Remove-PSSession $pSSession
    ````

### Task 7: Set the bandwidth limit on virtual machine

No outer bandwidth setting is changed in this VMware adaptation. Skip this timing-only step; retain the package export/import and cache configuration tasks.

### Task 8: Validate BranchCache

Perform this task on CL3.

1. Open **Terminal**.
1. Copy the content of the IT share to the Documents folder while measuring the duration of the command.

    ````powershell
    Measure-Command -Expression { 
        Copy-Item \\vn1-srv10\IT\ ~\Documents\ -Recurse -Force
    }
    ````

    > Record the duration without requiring a speedup. Use the cache-status checks below for configuration verification.

## Exercise 3: Configuring and validating BranchCache in distributed cache mode

1. [Configure BranchCache for distributed cache mode](#task-1-configure-branchcache-for-distributed-cache-mode)
1. [Validate BranchCache](#task-2-validate-branchcache) on CL3
1. [Validate BranchCache](#task-3-validate-branchcache) on CL4

### Task 1: Configure BranchCache for distributed cache mode

Perform this task on CL1.

1. Open **Group Policy Management**.
1. In Group Policy Management, expand **Group Policy Management**, **Forest: ad.lab.test**, **Domains**, **ad.lab.test** and click **ad.lab.test**.
1. In **Group Policy Management**, in the context-menu of **Custom Computer BranchCache Client**, click **Edit**.
1. In Group Policy Management Editor, expand **Computer Configuration**, **Policies**, **Administrative Templates**, **Network** and click **BranchCache**.
1. Double-click **Enable Automatic Hosted Cache Discovery by Service Connection Point**.
1. In Enable Automatic Hosted Cache Discovery by Service Connection Point, click **Not Configured** and click **OK**.
1. In **Group Policy Management Editor**, double-click **Set BranchCache Distributed Cache Mode**.
1. In Set BranchCache Distributed Cache Mode, click **Enabled** and click **OK**.
1. In **Group Policy Management Editor**, expand **Computer Configuration**, **Policies**, **Windows Settings**, **Security Settings**, **Windows Defender Firewall with Advanced Security**, **Windows Defender Firewall with Advanced Security**, and click **Inbound Rules**.
1. In the context-menu of **Inbound Rules**, click **New Rule...**
1. In New Inbound Rule Wizard, in step Rule Type, click **Predefined**, **BranchCache - Content Retrieval (Uses HTTP)**, and click **Next >**.
1. In step Predefined Rules, click **Next >**.
1. In step Action, ensure **Allow the connection** is selected and click **Finish**.
1. In **Group Policy Management Editor**, in the context-menu of **Inbound Rules**, click **New Rule...**
1. In New Inbound Rule Wizard, in step Rule Type, click **Predefined**, **BranchCache - Peer Discovery (Uses WSD)**, and click **Next >**.
1. In step Predefined Rules, click **Next >**.
1. In step Action, ensure **Allow the connection** is selected and click **Finish**.
1. In **Group Policy Management Editor**, click **Outbound Rules**.
1. In the context-menu of **Outbound  Rules**, click **New Rule...**
1. In New Outbound Rule Wizard, in step Rule Type, click **Predefined**, **BranchCache - Content Retrieval (Uses HTTP)**, and click **Next >**.
1. In step Predefined Rules, click **Next >**.
1. In step Action, click **Allow the connection** is selected and click **Finish**.
1. In **Group Policy Management Editor**, in the context-menu of **Outbound Rules**, click **New Rule...**
1. In New Outbound Rule Wizard, in step Rule Type, click **Predefined**, **BranchCache - Peer Discovery (Uses WSD)**, and click **Next >**.
1. In step Predefined Rules, click **Next >**.
1. In step Action, click **Allow the connection** and click **Finish**.
1. Close **Group Policy Management Editor**.

### Task 2: Validate BranchCache

Perform this task on CL3.

1. Open **Terminal**.
1. Update the group policies.

    ````powershell
    gpupdate.exe
    ````

1. Copy the content of the IT share to the Documents folder while measuring the duration of the command.

    ````powershell
    Copy-Item \\vn1-srv10\IT\ ~\Documents\ -Recurse -Force
    ````

1. Get the status of BranchCache.

    ````powershell
    Get-BCStatus
    ````

    Under **DataCache**, record **CurrentActiveCacheSize** and compare it with the transferred dataset; the classroom 60 MB value is not a pass threshold.

### Task 3: Validate BranchCache

Perform this task on CL4.

1. Open **Terminal**.
1. Update the group policies.

    ````powershell
    gpupdate.exe
    ````

1. Copy the content of the IT share to the Documents folder while measuring the duration of the command.

    ````powershell
    Measure-Command -Expression { 
        Copy-Item \\vn1-srv10\IT\ ~\Documents\ -Recurse -Force
    }
    ````

1. Get the status of BranchCache.

    ````powershell
    Get-BCStatus
    ````

    Under **DataCache**, record **CurrentActiveCacheSize** and compare it with the transferred dataset; the classroom 60 MB value is not a pass threshold.

## Cleanup

Restore the coordinated pre-lab VMware snapshots of the file server, cache server, clients, and affected domain controllers. Remove the two lab BranchCache GPOs only if they were created by this exercise; verify their links no longer apply. Remove the exported/imported package and copied client files. No outer bandwidth setting was changed. Disconnect any temporary VMnet8 adapter.
