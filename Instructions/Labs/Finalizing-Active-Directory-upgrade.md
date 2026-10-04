# Lab: Finalizing Active Directory upgrade

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Deploying-domain-controllers.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN2-SRV1 (VMware display: VN2-SRV1; accepted display aliases: WIN-VN2-SRV1; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments.

**Permissions:** Lab Enterprise/Domain Administrator for the named forest/domain changes; Schema Admin only for schema extension. Local Administrator for guest setup. Remove temporary role membership afterward.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=true. Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware. Verify current support for optional products before execution.

**Success verification:** All surviving DCs replicate, forest/domain levels match the intended upgrade, and removed DC metadata is absent.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision every VM, extra disk, cluster member, certificate, and client named by this lab; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV4
* VN1-SRV5
* VN2-SRV1

## Setup

1. On **CL1**, sign in as **ad\\Administrator**.
1. On **VN1-SRV1**, sign in as **ad\\Administrator**.
1. On **VN1-SRV5**, sign in as **ad\\Administrator**.

Complete [Deploying domain controllers](../Labs/Deploying-domain-controllers.md), then allow AD DS replication to converge and verify `dcdiag` and `repadmin /replsummary` before continuing.

Complete [Install Windows Admin Center using a script](../Practices/Install-Windows-Admin-Center-using-a-script.md) on **VN1-SRV4** before continuing.

## Introduction

After deploying the new domain controllers running the latest version of Windows Server, you want to decommission the old domain controller, raise the domain and forest functional level and enable support for 32K database pages.

## Exercises

1. [Decommission a domain controller](#exercise-1-decommission-a-domain-controller)
1. [Raise domain and forest functional level](#exercise-2-raise-the-domain-and-forest-functional-level)
1. [Enable database 32K pages](#exercise-3-enable-database-32k-pages)

## Exercise 1: Decommission a domain controller

1. On CL1, change the DNS client server addresses to 10.1.1.40.

    ```powershell
    $interfaceAlias = 'Ethernet'
    $serverAddresses = '10.1.1.40'
    ```

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

1. On CL1, clear the DNS client cache.

    ````powershell
    Clear-DnsClientCache
    ````

1. Demote **VN1-SRV1** as domain controller.

    [Demoting a domain controller](../General/Demoting-a-domain-controller.md)

    If you have trouble demoting the domain controller, wait for at least 15 minutes and try again.

1. On CL1, remove the roles **Active Directory Domain Services** (```AD-Domain-Services```), **DNS Server** (```DNS```), and **File Server** (```FS-FileServer```) from VN1-SRV1.

    [Removing roles and features on Windows Server](../General/Removing-roles-and-features-on-Windows-Server.md)

## Exercise 2: Raise the domain and forest functional level

1. On CL1, raise the domain functional level of **ad.lab.test**.

    [Raising the domain functional level](../General/Raising-the-domain-functional-level.md)

1. On CL1, raise the forest functional level of **ad.lab.test**.

    [Raising the forest functional level](../General/Raising-the-forest-functional-level.md)

## Exercise 3: Enable database 32K pages

1. On CL1, verify the that the domain **DC=ad,DC=lab,DC=test** has a 32k page capable database.

    [Verifying a 32k page capable database](../General/Verifying-a-32k-page-capable-database.md)

1. On CL1, enable the Database 32k pages optional feature in the domain **ad.lab.test** on server **VN1-SRV5**.

    [Enabling the Database 32k pages option](../General/Enabling-the-Database-32k-pages-option.md)
