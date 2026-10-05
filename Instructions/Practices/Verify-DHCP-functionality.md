# Practice: Verify DHCP functionality

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Authorize-DHCP-server-and-activate-scope.md; Instructions/Practices/Configure-DHCP-server-options.md; Instructions/Practices/Add-DHCP-reservations.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV11 (VMware display: VN1-SRV11; accepted display aliases: WIN-VN1-SRV11; existing); VN1-SRV12 (VMware display: VN1-SRV12; accepted display aliases: WIN-VN1-SRV12; existing); VN1-SRV13 (VMware display: VN1-SRV13; accepted display aliases: WIN-VN1-SRV13; existing); VN1-SRV2 (VMware display: VN1-SRV2; accepted display aliases: WIN-VN1-SRV2; existing); VN1-SRV3 (VMware display: VN1-SRV3; accepted display aliases: WIN-VN1-SRV3; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV6 (VMware display: VN1-SRV6; accepted display aliases: WIN-VN1-SRV6; existing); VN1-SRV8 (VMware display: VN1-SRV8; accepted display aliases: WIN-VN1-SRV8; existing); VN1-SRV9 (VMware display: VN1-SRV9; accepted display aliases: WIN-VN1-SRV9; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware.

**Success verification:** Each targeted VNet1 guest receives the reserved address, gateway 10.1.1.1 and AD DNS 10.1.1.8.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Environment profile:** This practice validates the enterprise-expansion `VNet1` scope (`10.1.1.0/24`). Keep the AD DNS server at `10.1.1.8` and do not run these address changes against the core learner profile.

## Required VMs

* CL1
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
* VN1-SRV8
* VN1-SRV9

## Task

On CL1 and all servers on VNet1, except for VN1-SRV6 and VN1-SRV7, change the IP assignment mode of the network adapter connected to VNet1 to use DHCP.

## Instructions

### PowerShell

Perform this task on CL1.

1. On VN1-SRV1, configure network adapters connected to VNet1 to use DHCP.

    ````powershell
    $computerName = 'vn1-srv1.ad.lab.test'
    Invoke-Command -ComputerName $computerName -ScriptBlock {
        $interfaceIndex = (
                Get-NetIPAddress -AddressFamily IPv4 |
                Where-Object { $PSItem.IPAddress -like '10.1.1.*' }
            ).InterfaceIndex
        
        Get-NetRoute -InterfaceIndex $interfaceIndex |
        Remove-NetRoute -Confirm:$false
        
        Set-NetIPInterface -InterfaceIndex $interfaceIndex -Dhcp Enabled
        
        Set-DnsClientServerAddress `
            -InterfaceIndex $interfaceIndex -ResetServerAddresses
    }
    ````

1. Verify the IP configuration.

    ````powershell
    Get-NetIPConfiguration -ComputerName $computerName
    ````

    At least one network adapter should haven an IP address in the 10.1.1.0 subnet, the IPv4DefaultGateway of 10.1.1.1 and DNSServer of 10.1.1.8.

    If the command fails, try again after a few minutes. If it still fails, sign in to the server and execute

    ````shell
    ipconfig.exe /renew
    ````

Repeat these steps for VN1-SRV2, VN1-SRV3, VN1-SRV4, VN1-SRV5, VN1-SRV8, VN1-SRV9,VN1-SRV10, VN1-SRV11, VN1-SRV12, VN1-SRV13, and CL1. To save time, you may define $computerName as an array, like

````powershell
$computerName = @(
        'VN1-SRV1'
        'VN1-SRV2'
        'VN1-SRV3'
        'VN1-SRV4'
        'VN1-SRV5'
        'VN1-SRV8'
        'VN1-SRV9'
        'VN1-SRV10'
        'VN1-SRV11'
        'VN1-SRV12'
        'VN1-SRV13'
        'CL1'
    )
````

If you used an array for ````$computerName````, you must change verification command like this:

````powershell
$computerName | ForEach-Object { Get-NetIPConfiguration -ComputerName $PSItem }
````

### SConfig

Perform this task on VN1-SRV1, VN1-SRV3, VN1-SRV4, VN1-SRV5, VN1-SRV11, VN1-SRV12, and VN1-SRV13.

1. Sign in as **ad\Administrator**.
1. On **VN1-SRV1** only: Start **SConfig**.

    ````shell
    sconfig
    ````

1. In SConfig, enter **8**.
1. In Network settings, enter the **Index#** of a network adapter with an **IP address** starting with **10.1.1**.
1. In Network Adapter Settings, enter **1**.
1. Enter **D**.
1. On **VN1-SRV2**, **VN1-SRV3**, **VN1-SRV4**, **VN1-SRV5**, and **VN1-SRV7**: Under a number auf success messages, press ENTER.
1. Enter **4**.

    If the server has more than one network adapter connected to VNet1, repeat from step 3.

1. In **SConfig**, enter **15**.
1. Verify the IP configuration.

    ````shell
    ipconfig.exe /all
    ````

    The network adapters should have received the IP address you added as reservation. The DNS Servers should be 10.1.1.8 and the Default Gateway should be 10.1.1.1. If the IP address is an APIPA address, try to execute

    ````shell
    ipconfig.exe /renew
    ````

1. Sign out.

    ````shell
    logoff.exe
    ````

### Desktop experience (Windows Server)

Perform this task on VN1-SRV2, VN1-SRV8, VN1-SRV9, and VN1-SRV10.

1. Sign in as **.\Administrator**.
1. In **Server Manager**, click **Local Server**.

    Under Local Server, under **PROPERTIES**, take a note of all network adapters with an IP address starting with **10.1.1**.

1. Click any IP address.
1. In Network Connections, in the context-menu of the network adapter, you took note of before, click **Properties**.
1. In network adapter's Properties, click **Internet Protocol Version 4 (TCP/IPv4)** and click **Properties**.
1. In Internet Protocol Version 4 (TCP/IPv4) Properties, click **Obtain an IP address automatically** and **Obtain DNS server address automatically**. Click **OK**.
1. In network adapter's **Properties**, click **Close**.
1. Double-click the ntwork adpater you just configured.
1. In network adapter's status, click **Details...**

    The network adapters should have received the IP address you added as reservation. The DNS Servers should be 10.1.1.8 and the Default Gateway should be 10.1.1.1. If the IP address is an APIPA address, try to execute

    ````shell
    ipconfig.exe /renew
    ````

    For other network adapters connected to VNet1, repeat from step 4.

1. Sign out.

### Desktop experience (Windows 11)

Perform this task on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Settings**.
1. In Settings, click **Network & internet**.
1. In Network & internet, click **Ethernet**.
1. In Ethernet, right to **IP assignment**, click **Edit**.
1. In Edit IP settings, in the drop-down at the top, click **Automatic (DHCP)** and click **Save**.

    In **Ethernet**, verify that the computer has received an IP address in the 10.1.1.0 subnet (such as 10.1.1.2) and IPv4 DNS servers of 10.1.1.8.

### Windows Admin Center

Perform this task on CL1.

1. Open **Microsoft Edge**
1. In Microsoft Edge, navigate to <https://admincenter>
1. In Windows Admin Center, click **vn1-srv1.ad.lab.test**.
1. Connected to vn1-srv1.ad.lab.test, under **Tools**, click **Networks**.
1. Under Networks, click any network with an **IPv4 Address** starting with **10.1.1** and click **Settings**
1. Under IPv4, click **Obtain an IP address automatically** and **Obtain DNS server address automatically**. Click **Save**.
1. In the message box Update IPv4 settings for ..., click **Yes**.
1. In the top-left corner, click **Windows Admin Center**.
1. In Windows Admin Center, click **vn1-srv1.ad.lab.test** again.

    If the connection fails, try again after a few minutes. If it still fails, sign in to the server and execute

    ````shell
    ipconfig.exe /renew
    ````

1. Connected to vn1-srv1.ad.lab.test, under **Tools**, click Networks.
1. Under Networks, click the network you just configured.

    In the bottom pane, verify that IPv4 DHCP is set to Yes, the computer has obtained the IP address you added as reservation, the IPv4 Default Gateway is 10.1.1.1 and the IPv4 DNS Servers is 10.1.1.8.

1. In the top-left corner, click **Windows Admin Center**.

Repeat from step 3 for VN1-SRV2, VN1-SRV3, VN1-SRV4, VN1-SRV5, VN1-SRV8, VN1-SRV9,VN1-SRV10, VN1-SRV11, VN1-SRV12, VN1-SRV13, and CL1.

To add CL1 to the Windows Admin Center, on the connections page, click **Add**. In the pane Add or create resources, under **Windows PCs**, click **Add**. In **Computer name**, type **CL1** and click **Add**.
