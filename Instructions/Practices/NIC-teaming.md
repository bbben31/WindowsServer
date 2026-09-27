# Practice: NIC teaming

## Required VMs

* VN1-SRV1
* PM-SRV3
* CL1

## Task

On PM-SRV3, configure the network adapters in a team and assign it the IP address 10.10.20.26.

## Instructions

> **Topology note:** The original Hyper-V switch-level NIC-team exercise is source-specific and is not part of the default VMware path. VMware Workstation does not expose Hyper-V's **Advanced Features** or **Enable this network adapter to be part of a team in guest operating system** controls. Do not follow those UI steps or ignore a faulted virtual switch.

For a VMware learner, use the following guest-only demonstration only when two virtual NICs are connected to the same intended network and the guest supports NIC teaming. Power off **PM-SRV3**, add two VMware virtual network adapters on VMnet20, then power on the guest. Do not bridge or route the isolated network through the physical host. Perform the remaining steps from CL1.

1. Open **Server Manager**.
1. In Server Manager, click **All Servers**.
1. Under All Servers, in the context-menu of **PM-SRV3**, click **Configure NIC Teaming**.
1. In NIC Teaming, under **TEAMS**, click **TASKS**, **New Team**.
1. In NIC Teaming, under **Team name**, type **Perimeter**. Under **Member adapters**, select the two guest adapters that are actually connected to VMnet20. Click **Additional Properties**, review the settings, and click **OK**. No VMware host adapter setting is required.

    > Leave at least one adapter out of the team to not loose the remote connection to the server.

1. Close **NIC Teaming**.
1. Close **Server Manager**.
1. Open **Terminal**.
1. Open a CIM session to **PM-SRV3**.

    ````powershell
    $cimSession = New-CimSession PM-SRV3
    ````

1. Assign IP address **10.10.20.26/24** to **Perimeter**. Leave the default gateway unset on isolated VMnet20.

    ````powershell
    $interfaceAlias = 'Perimeter'
    New-NetIPAddress `
        -InterfaceAlias $interfaceAlias `
        -IPAddress 10.10.20.26 `
        -PrefixLength 24 `
        -AddressFamily IPv4 `
        -CimSession $cimSession
    ````

1. Set the DNS server address **10.10.10.10** for **Perimeter**.

    ````powershell
    Set-DnsClientServerAddress `
        -InterfaceAlias $interfaceAlias `
        -ServerAddresses 10.10.10.10 `
        -CimSession $cimSession
    ````

1. Remove the CIM session.

    ````powershell
    Remove-CimSession $cimSession
    ````

1. Clear the DNS client cache.

    ````powershell
    Clear-DnsClientCache
    ````

1. Open **Server Manager**.
1. In Server Manager, click **All Servers**.
1. Under All Servers, in the context-menu of **PM-SRV3**, click **Configure NIC Teaming**.
1. In NIC Teaming, under **TEAMS**, click **Perimeter**. Under **ADAPTERS AND INTERFACES**, on tab **Network Adapters**, under **Available to be added to a team (1)**, in the context-menu of **Permieter0**, click **Add to Team "Perimeter"**.

Note: VMware virtual NICs on the same isolated VMnet do not provide physical-link redundancy. The purpose of this optional guest-only practice is to demonstrate the Windows teaming workflow; if the guest build or driver does not support it, record the limitation and leave the activity deferred rather than applying Hyper-V-only settings.
