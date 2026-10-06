# Practice: Install the DHCP server role

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-Remote-Server-Administration-Tools.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Verify CL1's Server Manager/RSAT and established remote server connection. Use the WAC branch only with a verified working gateway and target connection; otherwise follow the Server Manager/PowerShell path.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV6 (VMware display: VN1-SRV6; accepted display aliases: WIN-VN1-SRV6; existing); VN1-SRV7 (VMware display: VN1-SRV7; accepted display aliases: WIN-VN1-SRV7; existing); VN2-SRV2 (VMware display: VN2-SRV2; accepted display aliases: WIN-VN2-SRV2; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware.

**Success verification:** Get-WindowsFeature DHCP reports Installed on VN1-SRV6, VN1-SRV7 and VN2-SRV2; confirm post-install groups/configuration.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV4
* VN1-SRV6
* VN1-SRV7
* VN2-SRV2

## Task

Install the DHCP server role on VN1-SRV6, VN1-SRV7, and VN2-SRV2.

## Instructions

Before using a graphical branch, install [RSAT](Install-Remote-Server-Administration-Tools.md) on CL1 and add the named target servers to Server Manager. Use the WAC alternative only if the selected gateway and those server connections already work; otherwise use Server Manager/PowerShell rather than assume an admincenter DNS name exists.

### Desktop Experience

Perform this task on CL1.

1. Sign in as **ad\administrator**.
1. Open **Server Manager**.
1. In Server Manager, in the menu, click **Manage**, **Add Roles and Reatures**.
1. In the Add Rules and Features Wizard, on the page **Before You Begin**, click **Next >**.
1. On the page Installation Type, ensure **Role-based or feature-based installation** is selected and click **Next >**.
1. On the page Server Selection, click **VN1-SRV6.ad.lab.test** and click **Next >**.
1. On the page Server Roles, activate the checkbox next to **DHCP Server** and click **Next >**.
1. On the page Features, click **Next >**.
1. On the page DHCP Server, click **Next >**.
1. On the page Confirmation, verify your selection and click **Install**.
1. On the page **Results**, click **Close**.
1. In **Server Manager**, when a yellow warning triangle appears beside the Notifications icon, click the *Notifications* icon, **Complete DHCP configuration**.
1. In the DHCP Post-Install configuration wizard, on page Description, click **Next >**.
1. On page Authorization, click **Skip AD authorization** and click **Commit**.
1. On page Summary, click **Close**.

Repeat the steps of this task to install the role on **VN1-SRV7** and **VN2-SRV2**.

### Windows Admin Center

Perform this task on CL1.

1. Sign in as **ad\administrator**.
1. Using Microsoft Edge, navigate to <https://admincenter>.
1. In Windows Admin Center, on the connections page, click **vn1-srv6.ad.lab.test**.
1. Connected to vn1-srv6.ad.lab.test, under **Tools**, click **Roles & features**.
1. In Roles and features, activate the checkbox beside **DHCP Server** and click **Install**.
1. In the pane Install Role and Features, activate the checkbox **Reboot the server automatically, if required** and click **Yes**.

    After a few minutes, a notification **Install Roles and Features** appears. If you missed the notification, a small number appears beside the icon *Notifications* (in form of a bell) at the top-right of Windows Admin Center.

1. Under **Tools**, click **PowerShell**.
1. Under PowerShell, enter the password for AD\Administrator.
1. Add security groups to DHCP servers.

    ````powershell
    Add-DhcpServerSecurityGroup
    ````

1. Notify Server Manager that post-install DHCP configuration is complete.

    ````powershell
    Set-ItemProperty `
        -Path HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12 `
        -Name ConfigurationState `
        -Value 2
    ````

1. Exit from the PowerShell session.

    ````powershell
    Exit-PSSession
    ````

Repeat the steps of this task to install the role on **VN1-SRV7** and **VN2-SRV2**.

From step 7 on, alternatively, open **Server Manager** and refer to the steps from 11 in section [Desktop experience](#desktop-experience). You can also use the local **Terminal** instead.

````powershell
$computerName = 'VN1-SRV6', 'VN1-SRV7', 'VN2-SRV2'
Invoke-Command -ComputerName $computerName -ScriptBlock {
    Add-DhcpServerSecurityGroup 
    Set-ItemProperty `
        -Path HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12 `
        -Name ConfigurationState `
        -Value 2
}
````

### PowerShell

Perform this task on CL1.

1. Sign in as **ad\administrator**.
1. Open **Terminal**.
1. Install DHCP role on VN1-SRV6, VN1-SRV7, and VN2-SRV2.

    ````powershell
    $computerName = 'VN1-SRV6', 'VN1-SRV7', 'VN2-SRV2'
    Invoke-Command -ComputerName $computerName -ScriptBlock {
        Install-WindowsFeature -Name DHCP -IncludeManagementTools -Restart 
    }
    ````

1. Add security groups to DHCP servers.

    ````powershell
    Invoke-Command -ComputerName $computerName -ScriptBlock {
        Add-DhcpServerSecurityGroup 
    }
    ````

1. Notify Server Manager that post-install DHCP configuration is complete.

    ````powershell
    Invoke-Command -ComputerName $computerName -ScriptBlock {
        Set-ItemProperty `
            -Path HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12 `
            -Name ConfigurationState `
            -Value 2
    }
    ````
