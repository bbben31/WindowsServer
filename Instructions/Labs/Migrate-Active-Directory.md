# Lab: Migrate Active Directory

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Deploying-domain-controllers.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV9 (VMware display: VN1-SRV9; accepted display aliases: WIN-VN1-SRV9; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments. Temporary VMnet8 NAT on CL1 only for Windows Update RSAT capability installation; preserve the AD NIC/DNS and disconnect after setup.

**Permissions:** Lab Enterprise/Domain Administrator for the named forest/domain changes; Schema Admin only for schema extension. Local Administrator for guest setup. Remove temporary role membership afterward.

**Outbound access:** Windows Update downloads Windows 11 RSAT Features on Demand on CL1 during the documented setup/fallback. Before installing capabilities, attach a temporary second VMware NIC to VMnet8 NAT; retain the AD NIC and its AD DNS, disable DNS registration on the NAT NIC, and record adapters/routes/DNS. Disconnect VMnet8 immediately after installation. If the required tools are already installed, the download step needs no outbound access. Endpoints: *.windowsupdate.com (Windows Update service/content); *.update.microsoft.com (Microsoft Update service); *.delivery.mp.microsoft.com (Windows Update delivery); https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-security (current service endpoint guidance).

**Risk, cost and optional status:** high; local-only; optional=true. local-only Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware. Verify current support for optional products before execution.

**Success verification:** The intended migrated accounts/service retain their required identity/access and AD replication is healthy afterward.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Disconnect the temporary VMnet8 NIC after capability installation and restore recorded adapters/routes/DNS; retain installed RSAT until dependent exercises finish.

<!-- END GENERATED COMPLETION CONTRACT -->


> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision every VM, extra disk, cluster member, certificate, and client named by this lab; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV4
* VN1-SRV5
* VN1-SRV9

## Setup

1. On **CL1**, sign in as **ad\\Administrator**.
1. On **VN1-SRV9**, sign in as **ad\\Administrator**.
1. Open **Terminal**.
1. In Terminal, run the script ````C:\WindowsServerLab\Resources\Solutions\Install-Service.ps1````

Complete [Explore Server Manager](../Practices/Explore-Server-Manager.md) on **CL1** before continuing.

Complete [Install Windows Admin Center using a script](../Practices/Install-Windows-Admin-Center-using-a-script.md) on **VN1-SRV4** before continuing.

## Introduction

The domain controller still running Windows Server 2022 must be replaced by a Windows Server 2025 domain controller. After the upgrade, you want to enable database 32K pages. Moreover, you want to validate delegated managed service accounts.

## Exercises

1. [Deploy an additional domain controller](#exercise-1-deploy-an-additional-domain-controller)
1. [Check domain controller health](#exercise-2-check-domain-controller-health)
1. [Transfer flexible single master operation roles](#exercise-3-transfer-flexible-single-master-operation-roles)
1. [Optimize DNS](#exercise-4-optimize-dns)
1. [Decommission a domain controller](#exercise-5-decommission-a-domain-controller)
1. [Raise domain and forest functional level](#exercise-6-raise-the-domain-and-forest-functional-level)
1. [Enable database 32K pages](#exercise-7-enable-database-32k-pages)
1. [Validate delegated managed service accounts](#exercise-8-validate-delegated-managed-service-accounts)

## Exercise 1: Deploy an additional domain controller

1. On CL1 install the optional feature **RSAT: DNS Server Tools** (```Rsat.Dns.Tools```).

    You do not need to wait for the installation to complete.

    [Installing optional features on Windows 11](../General/Installing-optional-features-on-Windows-11.md)

1. On CL1, disable the network adapters **SAN1**, **SAN2**, and **CLST1** on **VN1-SRV5**.

   [Enabling or disabling network adapters](../General/Enabling-or-disabling-network-adapters.md)

1. On CL1, install the role **Active Directory Domain Services** (```AD-Domain-Services```) on **VN1-SRV5**.

    [Installing roles and features on Windows Server](../General/Installing-roles-and-features-on-Windows-Server.md)

1. Configure Active Directory Domain Services as additional domain controller

    * Computername: **VN1-SRV5**
    * Domain: **ad.lab.test**
    * **DNS server**
    * **Global Catalog** at the same time
    * Do not update the DNS delegation (this is not possibly anyways, ignore the warning)

    Leave all other parameters as default. If you want to use PowerShell, you may perform this task on either VN1-SRV5 locally or from CL1 remotely.

    *Note:* In a real-world scenario it is recommended to save the database and logs to a separate volume with host-based write-back caching disabled.

    ```powershell
    $computerName = 'VN1-SRV5.ad.lab.test' 

    $domainName = 'ad.lab.test'
    $siteName = $null
    $installDns = $true
    $noGlobalCatalog = $false
    $createDnsDelegation = $false
    $dnsDelegationCredential = $null
    $replicationSourceDC = $null
    $databasePath = 'C:\Windows\NTDS'
    $logPath = 'C:\Windows\NTDS'
    $sysvolPath = 'C:\Windows\SYSVOL'
    ```

    [Configuring Active Directory Domain Services as an additional Domain Controller](../General/Configuring-Active-Directory-Domain-Services-as-an-additional-domain-controller.md)

## Exercise 2: Check domain controller health

1. On CL1, retrieve the expected DNS records from VN1-SRV5.

    ````powershell
    $computerName = 'VN1-SRV5.ad.lab.test'
    $expectedDNSRecords = Invoke-Command `
        -ComputerName $computerName -ScriptBlock {
            Get-Content -Path 'C:\Windows\System32\config\netlogon.dns'
        }
    $expectedDNSRecords
    ````

    Notice, that the file is space separated. The first column contains the name of the record. The fourth column contains the type of the record. Depending on the type, additional columns may follow. The last column contains the target name.

    Do not close the terminal! You will need the variables of the session in the next task.

1. On CL1, query the DNS servers **10.1.1.8** and **10.1.1.40** for the expected DNS records and ensure, all are present. You can use this PowerShell script. Alternatively, you can either check the records in the DNS console on each server or resolve the records manually.

    ````powershell
    $dnsServers = '10.1.1.8', '10.1.1.40'

    # Query each DNS server
    foreach ($server in $dnsServers) {

        # Go through the list of all expected DNS records line by line
        foreach ($expectedDNSRecord in $expectedDNSRecords) {

            # Split the line into columns using the space delimiter
            $expectedDNSRecordSplit = $expectedDNSRecord -split ' '

            # First column is the name
            $name = $expectedDNSRecordSplit[0]
            # Fourth column is the type
            $type = $expectedDNSRecordSplit[3]
            # Last column is the target
            $target = $expectedDNSRecordSplit[-1]

            <# 
                If the target ends with a dot, remove it.
                Resolve-DnsName will return the target without the ending dot.
            #>
            if ($target[-1] -eq '.' ) {
                $target = $target.Substring(0, $target.Length - 1)
            }

            # Try to resolve the record
            $dnsRecords = Resolve-DnsName -Name $name -Type $type -Server $server

            <# 
                Check if target is in the result.
                Unfortunately the property name for the target varies depending
                on the type. Therefore, we mus handle each type separately.
            #>
            $missingRecord = $false
            switch ($type) { 
                'A' {  
                    if ($dnsRecords.IPAddress -notcontains $target) {
                        $missingRecord = $true
                    }
                }
                'SRV' {  
                    if ($dnsRecords.NameTarget -notcontains $target) {
                        $missingRecord = $true
                    }
                }
                'CNAME' {
                    if ($dnsRecords.NameHost -notcontains $target) {
                        $missingRecord = $true
                    }
                }
                Default {
                    Write-Warning "Type $type not expected."
                }
            }

            # If record found write information
            if (-not $missingRecord) {
                Write-Host `
                    "$type record $name targeting $target found on $server"
            }

            # If record is missing write a warning
            if ($missingRecord) {
                Write-Warning `
                    "$type record $name targeting $target missing on $server"
            }
        }
    }
    ````

    If any records are missing, wait at least 15 minutes and check again. If the problem persists, run `dcdiag /test:dns /v`, `repadmin /replsummary`, and an SRV-record lookup; correct DNS client settings or replication before continuing.

1. On CL1, verify that the shares **NETLOGON** and **SYSVOL** are present on **VN1-SRV5**.

    [Managing shares](../General/Managing-shares.md)

1. On CL1, run the Best Practices Analyzer for **DNS** (```Microsoft/Windows/DNSServer```) and **AD DS** (```Microsoft/Windows/DirectoryServices```) on **VN1-SRV5**.

    Review any warnings or errors, if present. If time permits, you can try to fix the warning and errors and run the the BPA scan again.

    [Running Best Practices Analyzer scans and managing scan results](../General/Running-Best-Practices-Analyzer-and-managing-scan-results.md)

## Exercise 3: Transfer flexible single master operation roles

1. On CL1, transfer the **RID master**, **PDC emulator** and **Infrastructure master** roles to **VN1-SRV5**.

    [Transferring flexible single master operation roles](../General/Transferring-flexible-single-master-operation-roles.md)

1. On CL1, transfer the **Domain Naming master** and the **Schema master** role to **VN1-SRV5**.

    [Transferring flexible single master operation roles](../General/Transferring-flexible-single-master-operation-roles.md)

## Exercise 4: Optimize DNS

1. On CL1, configure the forwarders of the DNS Server on **VN1-SRV5** to **8.8.8.8** and **8.8.4.4**. Other forwarders should be deleted.

    [Configuring forwarders](../General/Configuring-forwarders.md)

1. On CL1 or, if you want to use SConfig, on VN1-SRV5 configure the DNS client settings for VN1-SRV5 as follows:

    Preferred DNS server: 10.1.1.8
    Secondary DNS server: 127.0.0.1

    ````powershell
    $serverAddresses = '10.1.1.8', '127.0.0.1'
    ````

    [Changing TCP/IP settings on Windows Server](../General/Changing-TCP-IP-settings-on-Windows-Server.md)

1. On CL1 or, if you want to use SConfig, on VN1-SRV1 configure the DNS client settings for VN1-SRV1 as follows:

    Preferred DNS server: 10.1.1.40 (VN1-SRV5)
    Secondary DNS server: 10.1.1.8 (VN1-SRV1)

    ````powershell
    $serverAddresses = '10.1.1.40', '10.1.1.8'
    ````

    [Changing TCP/IP settings on Windows Server](../General/Changing-TCP-IP-settings-on-Windows-Server.md)

## Exercise 5: Decommission a domain controller

1. On CL1, change the DNS client server addresses to 10.1.1.40.

    [Changing TCP/IP settings on Windows 11](../General/Changing-TCP-IP-settings-on-Windows-11.md)

1. On CL1, add the IP address  **10.1.1.9** to the interface **Ethernet** on **VN1-SRV1**. You need to use PowerShell for this task.

    ````powershell
    $computerName = 'VN1-SRV1'
    $interfaceAlias = 'Ethernet'
    $ipAddress = '10.1.1.9'
    $prefixLength = 24
    ````

    [Changing TCP/IP settings on Windows Server](../General/Changing-TCP-IP-settings-on-Windows-Server.md)

1. On CL1, remove the IP address  **10.1.1.8** from the interface **Ethernet** on **VN1-SRV1**.

    ````powershell
    $computerName = 'VN1-SRV1'
    $interfaceAlias = 'Ethernet'
    $ipAddress = '10.1.1.8'
    $prefixLength = 24
    ````

    [Changing TCP/IP settings on Windows Server](../General/Changing-TCP-IP-settings-on-Windows-Server.md)

1. On CL1, add the IP address **10.1.1.8** to the interface **VNet1** on **VN1-SRV5**. You need to use PowerShell for this task to leave the old IP address operational.

    ````powershell
    $computerName = 'VN1-SRV5'
    $interfaceAlias = 'VNet1'
    $ipAddress = '10.1.1.8'
    $prefixLength = 24
    ````

    [Changing TCP/IP settings on Windows Server](../General/Changing-TCP-IP-settings-on-Windows-Server.md)

    Note: In this exercise, we add the IP address of the decommissioned domain controller to the new domain controller, so we do not have to reconfigure the DNS client settings on the other computers on the network. If all computers use DHCP, you could reconfigure the DHCP option DNS server instead. You would do this before task 1 and then wait for the DHCP lease period to expire before proceeding. Moreover, you would skip tasks 2 and 3.

1. Demote **VN1-SRV1** as domain controller.

    [Demoting a domain controller](../General/Demoting-a-domain-controller.md)

1. On CL1, remove the roles **Active Directory Domain Services** (```AD-Domain-Services```), **DNS Server** (```DNS```), and **File Server** (```FS-FileServer```) from VN1-SRV1.

    [Removing roles and features on Windows Server](../General/Removing-roles-and-features-on-Windows-Server.md)

## Exercise 6: Raise the domain and forest functional level

1. On CL1, raise the domain functional level of **ad.lab.test**.

    [Raising the domain functional level](../General/Raising-the-domain-functional-level.md)

1. On CL1, raise the forest functional level of **ad.lab.test**.

    [Raising the forest functional level](../General/Raising-the-forest-functional-level.md)

## Exercise 7: Enable database 32K pages

1. On CL1, verify the that the domain **DC=ad,DC=lab,DC=test** has a 32k page capable database.

    [Verifying a 32k page capable database](../General/Verifying-a-32k-page-capable-database.md)

1. On CL1, enable the Database 32k pages optional feature in the domain **ad.lab.test** on server **VN1-SRV5**.

    [Enabling the Database 32k pages option](../General/Enabling-the-Database-32k-pages-option.md)

## Exercise 8: Validate delegated managed service accounts

1. On VN1-SRV9, inspect the service **PSService** and `C:\WindowsServerLab\Resources\service.ps1`. Verify that the startup type is Automatic, the service is running, and the executable path is correct.

    > Which account does the service use?

    nssm.exe is a tool to run any program as service. In our case, it runs the PowerShell script C:\WindowsServerLab\Resources\service.ps1. See <https://nssm.cc/> for more information about NSSM.

    Every 30 seconds, the script service.ps1 writes all GPO objects found in SYSVOL to C:\Logs\Policies.log.

    [Managing services](../General/Managing-services.md)

1. On CL1, generate the KDS root key

    [Generating the KDS root key](../General/Generating-the-KDS-root-key.md)

1. On CL1, create a delegated managed service account:

    ```powershell
    $path = 'ou=Service accounts, DC=ad,DC=lab,DC=test'
    $name = 'dMSA_PSService'
    $dNSHostname = 'vn1-srv9.ad.lab.test'
    ```

    [Creating a delegated managed service account](../General/Creating-a-delegated-managed-service-account.md)

1. On CL1, add the registry value DelegatedMSAEnabled on VN1-SRV9 and set it to 1.

    ```powershell
    $computerName = 'VN1-SRV9'
    $path = `
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters'
    $name = 'DelegatedMSAEnabled'
    $type = 'DWORD'
    $value = 1
    ```

    [Adding a registry value](../General/Adding-a-registry-value.md)

1. Migrate the service account to the dMSA.

    ```powershell
    $identity = `
        'cn=dMSA_PSService, ou=Service accounts, DC=ad,DC=lab,DC=test'
    $supersededAccount = `
        'cn=Powershell Service, ou=Service accounts, DC=ad,DC=lab,DC=test'
    ```

    [Migrating a service account to a dMSA](../General/Migrating-a-service-account-to-a-dMSA.md)

    If time allows, check that the service is still configured to log on with the superseded service account.
