# Lab: Managing sites and replication

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Deploying-domain-controllers.md; Instructions/Labs/Deploying-and-managing-read-only-domain-controllers.md; Instructions/Labs/Multi-domain-environments.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); CL2 (VMware display: CL2; accepted display aliases: WIN-CL2; existing); PM-SRV1 (VMware display: PM-SRV1; accepted display aliases: WIN-PM-SRV1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; conditional until retired; supply the guest or explicitly confirm retirement with -RetiredVmName); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV7 (VMware display: VN1-SRV7; accepted display aliases: WIN-VN1-SRV7; existing); VN2-SRV1 (VMware display: VN2-SRV1; accepted display aliases: WIN-VN2-SRV1; existing); VN3-SRV1 (VMware display: VN3-SRV1; accepted display aliases: WIN-VN3-SRV1; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments. Temporary VMnet8 NAT on CL1 only for Windows Update RSAT capability installation; preserve the AD NIC/DNS and disconnect after setup.

**Permissions:** Lab Enterprise/Domain Administrator for the named forest/domain changes; Schema Admin only for schema extension. Local Administrator for guest setup. Remove temporary role membership afterward.

**Outbound access:** Windows Update downloads Windows 11 RSAT Features on Demand on CL1 during the documented setup/fallback. Before installing capabilities, attach a temporary second VMware NIC to VMnet8 NAT; retain the AD NIC and its AD DNS, disable DNS registration on the NAT NIC, and record adapters/routes/DNS. Disconnect VMnet8 immediately after installation. If the required tools are already installed, the download step needs no outbound access. Endpoints: *.windowsupdate.com (Windows Update service/content); *.update.microsoft.com (Microsoft Update service); *.delivery.mp.microsoft.com (Windows Update delivery); https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-security (current service endpoint guidance).

**Risk, cost and optional status:** high; local-only; optional=true. Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware. Verify current support for optional products before execution.

**Success verification:** Sites/subnets and replication schedules match the declared topology; repadmin and client site discovery show expected partners/site.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Disconnect the temporary VMnet8 NIC after capability installation and restore recorded adapters/routes/DNS; retain installed RSAT until dependent exercises finish.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision only existing prerequisite machines, disks, cluster roles and certificates before starting; create machines marked Created during exercise in their designated tasks. Follow alternatives and conditional-retirement requirements instead of starting every named VM; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.








## Required VMs

* CL1
* CL2
* PM-SRV1
* VN1-SRV5
* VN1-SRV7
* VN2-SRV1
* VN3-SRV1
* Conditional until retired: VN1-SRV1

> **Conditional controller lifecycle:** Supply VN1-SRV1 while it remains the active original controller. After its documented retirement, confirm that VN1-SRV5 serves the original DNS address and the required directory roles, then pass `-RetiredVmName VN1-SRV1` to preflight; never restart a retired controller. Retirement requires the completed address/role handover, not merely completing controller promotion or switching off a guest. Steps concerning the retired server apply only to recorded historical state or removal of its stale directory objects.

## Setup

On **CL1**, sign in as **ad\\Administrator**.
On **CL2**, sign in as **ad\\Administrator**.

If you skipped the practice [Install Remote Server Administration Tools](../Practices/Install-Remote-Server-Administration-Tools.md), on **CL1**, in **Terminal**, execute ````C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1````.

If you did not complete exercise 1 of lab [Deploying domain controllers](Deploying-domain-controllers.md#exercise-1-deploy-additional-domain-controllers) and exercises 2 and 3 of lab [Multi-domain environments](Multi-domain-environments.md), you will not be able to perform all steps in this lab. However, try as many steps as possible in this lab to get used to the tools.

## Introduction

The virtual networks in Adatum represent different locations. Adatum wants to minimize replication traffic between the locations and keep logon traffic local, if possible. For this purpose, Adatum wants you to implement sites and site links in Active Directory and optimize the replication infrastrucutre

## Exercises

1. [Create sites](#exercise-1-create-sites)
1. [Configure global catalogs](#exercise-2-configure-global-catalogs)
1. [Create site links](#exercise-3-create-site-links)
1. [Verify the replication topology changes](#exercise-4-verify-replication-topology-changes)

## Exercise 1: Create sites

1. [Verify the site of client](#task-1-verify-the-site-of-client) CL2

    > What is the site of CL2 before creating sites in Active Directory?

1. [Create sites](#task-2-create-sites) VNet1 (rename Default-First-Site-Name), VNet2, VNet3 and Perimeter
1. [Create subnets](#task-3-create-subnets) according to the table below

    | Subnet        | Site      |
    |---------------|-----------|
    | 10.1.1.0/24   | VNet1     |
    | 10.1.2.0/24   | VNet2     |
    | 10.1.3.0/24   | VNet3     |
    | 10.1.200.0/24 | Perimeter |

1. [Move domain controllers into sites](#task-4-move-domain-controllers-into-sites)
1. [Verify the site of client](#task-5-verify-the-site-of-client) CL2

    > What is the site of CL2 after configuring sites?

    > What is the domain controller, CL2 authenticated with after configuring sites?

1. [Verify sites in DNS](#task-6-verify-sites-in-dns)

### Task 1: Verify the site of client

#### Desktop experience

Perform this task on CL2.

1. Open **Registry Editor**.
1. In Registry Editor, expand **Computer**, **HKEY_LOCAL_MACHINE**, **SYSTEM**, **CurrentControlSet**, **Services**, **Netlogon**, **Parameters**.

    > The value DynamicSiteName should be Default-First-Site-Name.

#### PowerShell

Perform this task on CL1.

1. Create a remote PowerShell session to **CL2**.

    ````powershell
    Enter-PSSession CL2
    ````

1. Query the site of **CL2**.

    ````powershell
    nltest.exe /DSGETSITE
    ````

    > You should get Default-First-Site-Name.

1. Close the remote PowerShell session.

    ````powershell
    Exit-PSSession
    ````

### Task 2: Create sites

#### Desktop experience

Perform this task on CL1.

1. Open **Active Directory Sites and Services**.
1. In Active Directory Sites and Services, in the context-menu of **Default-First-Site-Name**, click **Rename** and enter **VNet1**.
1. In the context-menu of **Sites**, click **New Site...**
1. In New Object - Site, in **Name**, type **VNet2**, click **DEFAULTIPSITELINK** and click **OK**.
1. In the message box

    **Site VN2 has been created. To finish configuration of VN2:**

    **Ensure that VN2 is linked to other sites with site links as appropriate.**

    **Add subnets for VN2 to the Subnets container.**

    **Install one or more Domain Controllers in VN2, or move existing DCs into the site.**

    **You will not see this message again until the next time you start Active Directory Sites and Services.**

    click **OK**.

Repeat steps 3 - 5 to create the sites **VNet3** and **Perimeter**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Rename the site **Default-First-Site-Name** to **VNet1**.

    ````PowerShell
    Get-ADReplicationSite -Identity Default-First-Site-Name | Rename-ADObject -NewName VNet1
    ````

1. Create the sites **Vnet2**, **VNet3**, and **Perimeter**.

    ````powershell
    'VNet2', 'VNet3', 'Perimeter' | 
    ForEach-Object { New-ADReplicationSite -Name $PSItem }
    ````

### Task 3: Create subnets

#### Desktop experience

Perform this task on CL1.

1. Open **Active Directory Sites and Services**.
1. In Active Directory Sites and Services, in the context-menu of **Subnets**, click **New Subnet...**
1. In New Object - Subnet, under **Prefix**, type 10.1.1.0/24. Click **VNet1** and click **OK**.

Repeat steps 2 and 3 to create the subnets according to the table above.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Create subnets and associate them with the sites according to the table above.

    ````powershell
    New-ADReplicationSubnet -Name 10.1.1.0/24 -Site VNet1
    New-ADReplicationSubnet -Name 10.1.2.0/24 -Site VNet2
    New-ADReplicationSubnet -Name 10.1.3.0/24 -Site VNet3
    New-ADReplicationSubnet -Name 10.1.200.0/24 -Site Perimeter
    ````

### Task 4: Move domain controllers into sites

#### Desktop experience

Perform this task on CL1.

1. Open **Active Directory Sites and Services**.
1. In Active Directory Sites and Services, expand **VNet1** and **Servers**.
1. Check the recorded controller lifecycle and `Get-ADDomainController -Filter *`. If **VN1-SRV1 is still a live controller**, retain its server and NTDS Settings objects and skip deletion. Only after documented demotion/retirement and healthy replication may you delete its verified stale server object; review the exact object and any child objects before confirming. Do not recursively delete a live controller to satisfy this exercise.
1. In the context-menu of **VN2-SRV1**, click **Move...**.
1. In Move Server, click **VNet2** and click **OK**.
1. In the context-menu of **PM-SRV1**, click **Move...**.
1. In Move Server, click **Perimeter** and click **OK**.
1. If the prerequisite topology includes live **VN3-SRV1** as a DC/RODC, move its server object to **VNet3**. Confirm its subnet mapping and actual domain before moving; do not invent a controller object for an unpromoted member.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. List domain controllers in site VNet1.

    ````powershell
    $adReplicationSite = Get-ADReplicationSite -Identity VNet1
    Get-ADObject `
        -SearchBase "CN=Servers, $($adReplicationSite.DistinguishedName)" `
        -Filter 'ObjectClass -eq "server"'
    ````

1. Remove only a verified stale VN1-SRV1 server object after documented retirement. If VN1-SRV1 remains live, skip this step and retain its replication objects.

    ````powershell
    if (Get-ADDomainController -Filter * | Where-Object Name -eq 'VN1-SRV1') {
        Write-Host 'VN1-SRV1 is live; retain its server object.'
    } else {
        $retirementConfirmed = Read-Host 'Enter RETIRED only after verifying completed demotion, handover and healthy replication'
        if ($retirementConfirmed -eq 'RETIRED') {
            Get-ADObject `
                -SearchBase "CN=Servers,$($adReplicationSite.DistinguishedName)" `
                -Filter 'ObjectClass -eq "server" -and Name -eq "VN1-SRV1"' |
                Remove-ADObject -Recursive -Confirm
        }
    }
    ````

1. Only if the verified stale object is being removed, review the prompt

    ````text
    Are you sure you want to perform this action?
    Performing the operation "Remove" on target
    "CN=VN1-SRV1,CN=Servers,CN=VNet1,CN=Sites,CN=Configuration,DC=ad,DC=lab,DC=test".
    ````

    enter **y**.

1. Move the domain controller **VN2-SRV1** to site **VNet2**.

    ````powershell
    Move-ADDirectoryServer -Identity VN2-SRV1 -Site VNet2
    ````

1. Move the domain controller **PM-SRV1** to site **Perimeter**.

    ````powershell
    Move-ADDirectoryServer -Identity PM-SRV1 -Site Perimeter
    ````

1. For the live VN3-SRV1 DC/RODC in the prerequisite topology, run `Move-ADDirectoryServer -Identity VN3-SRV1 -Site VNet3` and verify its resulting site. If it is not promoted in the selected lineage, record that instead of creating a fictitious server object.

### Task 5: Verify the site of client

#### Desktop experience

Perform this task on CL2.

1. Restart the computer.
1. Sign in as **ad\Administrator**.
1. Open **Registry Editor**.
1. In Registry Editor, expand **Computer**, **HKEY_LOCAL_MACHINE**, **SYSTEM**, **CurrentControlSet**, **Services**, **Netlogon**, **Parameters**.

    > The value DynamicSiteName should be VNet2.

#### PowerShell

Perform this task on CL1.

1. Restart **CL2**.

    ````powershell
    Restart-Computer CL2 -WsmanAuthentication Default
    ````

1. Create a remote PowerShell session to **CL2**.

    ````powershell
    Enter-PSSession CL2
    ````

1. Query the site of **CL2**.

    ````powershell
    nltest.exe /DSGETSITE
    ````

    > You should get VNet2.

1. Query the domain controller for **ad.lab.test**.

    ````powershell
    nltest /DSGETDC:ad.lab.test
    ````

    > You should get \\\\VN2-srv1.ad.lab.test.

1. Close the remote PowerShell session.

    ````powershell
    Exit-PSSession
    ````

### Task 6: Verify sites in DNS

Perform this task on CL1.

1. Open **DNS**.
1. In **Connect to DNS Server**, click **The following computer**, type **VN1-SRV5**, and click **OK**.
1. In DNS, expand **Forward Lookup Zones**, **ad.lab.test**, **_sites**, and the site names below.
1. For each site, click **_tcp**. Note the **Service Location (SRV)** records.

## Exercise 2: Configure global catalogs

[Remove the global catalog](#task-remove-the-global-catalog) from VN1-SRV5.

### Task: Remove the global catalog

#### Desktop experience

Perform this task on CL1.

1. Open **Active Directory Sites and Services**.
1. In Active Directory Sites and Services, expand **VNet1**, **Servers**, and **VN1-SRV5**.
1. Under VN1-SRV5, in the context menu of **NTDS Settings**, click **Properties**.
1. In NTDS Settings Properties, on tab General, deactivate **Global Catalog**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Store site **VNet1** in a variable.

    ````powershell
    $adReplicationSite = Get-ADReplicationSite -Identity VNet1
    ````

1. Find the server **VN1-SRV5** in the site.

    ````powershell
    $server = Get-ADObject `
        -SearchBase "CN=Servers, $($adReplicationSite.DistinguishedName)" `
        -Filter 'ObjectClass -eq "server" -and Name -eq "VN1-SRV5"'

    ````

1. Disable the Global Catalog on the server.

    ````powershell
    $ntds = Get-ADObject -Identity "CN=NTDS Settings,$($server.DistinguishedName)" -Properties options
    # Clear only the Global Catalog bit; preserve other NTDS option flags.
    Set-ADObject -Identity $ntds -Replace @{ options = ([int]$ntds.options -band -bnot 1) }
    ````

## Exercise 3: Create site links

1. [Create site links](#task-1-create-site-links) to create a hub and spoke topology connecting all sites with VNet1 as hub
1. [Disable the default site link bridging](#task-2-disable-the-default-site-link-bridging)
1. [Configure the site links for notification-based replication](#task-3-configure-the-site-links-for-notification-based-replication)
1. [Run the Inter-Site topology generator](#task-4-run-the-inter-site-topology-generator)

### Task 1: Create site links

#### Desktop experience

Perform this task on CL1.

1. Open **Active Directory Sites and Services**.
1. In Active Directory Sites and Services, expand **Inter-Site Transports** and click **IP**.
1. In the context-menu of **IP**, click **New Site Link**.
1. In New Object - Site Link, in **Name**, type **VNet1 - VNet2**. In the list **Sites not in the site link**, click **VNet1** and click **Add \>\>**. Click **VNet2** and click **Add \>\>**. Click **OK**.
1. In **Active Directory Sites and Services**, under **IP**, double-click the **Site Link** **VNet1 - VNet2**.
1. In VNet1 - VNet2 Properties, in **Cost**, type **1**, in **Replicate every**, type **15**, and click **OK**.

Repeat steps 3 - 6 to create the site links **VNet1 - VNet3** and **VNet1 - Perimeter**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Create a new site link between VNet1 and VNet2 with the cost 1 replicating every 15 minutes.

    ````powershell
    New-ADReplicationSiteLink `
        -Name 'VNet1 - VNet2' `
        -SitesIncluded VNet1, VNet2 `
        -InterSiteTransportProtocol IP `
        -Cost 1 `
        -ReplicationFrequencyInMinutes 15
    ````

1. Create a new site link between VNet1 and VNet3 with the cost 1 replicating every 15 minutes.

    ````powershell
    New-ADReplicationSiteLink `
        -Name 'VNet1 - VNet3' `
        -SitesIncluded VNet1, VNet3 `
        -InterSiteTransportProtocol IP `
        -Cost 1 `
        -ReplicationFrequencyInMinutes 15
    ````

1. Create a new site link between VNet1 and Perimeter with the cost 1 replicating every 15 minutes.

    ````powershell
    New-ADReplicationSiteLink `
        -Name 'VNet1 - Perimeter' `
        -SitesIncluded VNet1, Perimeter `
        -InterSiteTransportProtocol IP `
        -Cost 1 `
        -ReplicationFrequencyInMinutes 15
    ````

### Task 2: Disable the default site link bridging

#### Desktop experience

Perform this task on CL1.

1. Open **Active Directory Sites and Services**.
1. In Active Directory Sites and Services, expand **Inter-Site Transports** and click **IP**.
1. In IP, in the context-menu of DEFAULTIPSITELINK, click Delete.
1. In the message box **Are you sure you want to delete the Site link named 'DEFAULTIPSITELINK'?**, click **Yes**.
1. Under Inter-Site Transports, in the context-menu of **IP**, click **Properties**.
1. In IP Properties, deactivate **Bridge all site links** and click **OK**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Delete the site link **DEFAULTIPSITELINK**.

    ````powershell
    Remove-ADReplicationSiteLink -Identity DEFAULTIPSITELINK
    ````

1. At the prompt Performing the operation "Remove" on target "CN=DEFAULTIPSITELINK,CN=IP,CN=Inter-Site Transports,CN=Sites,CN=Configuration,DC=ad,DC=lab,DC=test", enter **Y**.

1. Store the **IP** object including the property **options** of **Inter-Site Transports** in a variable.

    ````powershell
    $configurationNamingContext = 'CN=Configuration, DC=ad,DC=lab,DC=test'
    $aDObject = Get-ADObject `
        -Identity `
            "CN=IP,CN=Inter-Site Transports,CN=Sites,$configurationNamingcontext" `
        -Properties options
    ````

1. On the options property, set the flag BR (NTDSTRANSPORT_OPT_BRIDGES_REQUIRED). The flag is bit # 1 (decimal value of 2).

    ````powershell
    $aDObject | Set-ADObject -Replace @{"options" = $aDObject.options -bor 2 }
    ````

### Task 3: Configure the site links for notification-based replication

#### Desktop experience

Perform this task on CL1.

1. Open **Active Directory Sites and Services**.
1. In Active Directory Sites and Services, expand **Inter-Site Transports** and click **IP**.
1. In IP, double-click **VNet1 - Perimeter**.
1. In Vnet1 - Perimeter Properties, click the tab **Attribute Editor**.
1. On tab Attribute Editor, click under **Atributes**, click **options** and click **Edit**.

    If you do not see the attribute options, click **Filter**, **Show only attributes that have values** (deactivate this filter).

1. In Integer Attribute Editor, under **Value**, type one of the following and click **OK**.

    * If Value is **\<not set\>**, type **1**.
    * For any other value, in a **Terminal**, execute this command and type the result.

        ````powershell
        $value -bor 1 # replace $value with the current value of the attribute
        ````

1. In **Vnet1 - Perimeter Properties**, click **OK**.

Repeat steps 3 - 6 for **VNet1 - VNet2** and **VNet1 - VNet3**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. 1. On the options property of all site links, set the flag UN (NTDSSITELINK_OPT_USE_NOTIFY). The flag is bit # 0 (decimal value of 1).

    ````powershell
    Get-ADReplicationSiteLink -Filter * -Properties options | ForEach-Object { 
        $PSItem | Set-ADObject -Replace @{ 'options' = $PSItem.options -bor 1 } 
    }
    ````

### Task 4: Run the Inter-Site topology generator

#### Desktop Experience

Perform this task on CL1.

1. Open **Active Directory Sites and Services**.
1. In Active Directory Sites and Services, and click **VNet1**.
1. In **VNet1**, double-click **NTDS Site Settings**.
1. In NTDS Site Settings Properties, under **Inter-Site Topology Generator**, take a note of the value in **Server**. Click **Cancel**.
1. Expand **VNet1**, **Servers** and the server noted in the previous step.
1. Under the server noted, in the context-menu of **NTDS Settings**, click **All Tasks**, **Check Replication Topology**.
1. In the message box **Check Replication Topology**, click **OK**.

Repeat steps 2 - 7 for the sites **VNet2** and **VNet3**.

#### PowerShell

Perform this task on CL1.

1. Open **Terminal**.
1. Retrieve the DNS host names of the inter-site topology generators (ISTG) for each site and store them in a variable.

    ````powershell
    $istgDNSHostName = (
        Get-ADReplicationSite -Filter * | 
        Where-Object { $PSItem.InterSiteTopologyGenerator } | 
        Select-Object -ExpandProperty InterSiteTopologyGenerator
    ) -replace 'CN=NTDS Settings,', '' | 
    Get-ADObject -Properties dNSHostName | 
    Select-Object -ExpandProperty dNSHostName
    ````

1. Run the knowledge consistency checker on the ISTG servers.

    ````powershell
    $istgDNSHostName | ForEach-Object {  repadmin.exe /kcc $PSItem }
    ````

## Exercise 4: Verify replication topology changes

This is an optional exercise, if time permits.

Wait for at least 1 hour  after completing exercise 3 in this lab, before performing this exercise.

Refer to [Practice: Explore intra-site replication](../Practices/Explore-intra-site-replication.md) to document the changes in replication topology caused by the new site design.
