# Practice: Configure Windows Admin Center

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-Windows-Admin-Center-using-a-script.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Official Microsoft Windows Admin Center download/extension endpoints.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** WAC opens on the lab gateway, connects to the recorded inventory and lists the installed AD extension.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV4

## Task

On CL1, add the URL https://admincenter.ad.lab.test to the Local intranet zone. In Windows Admin Center, add connections to all servers starting with VN and PM, and to all clients starting with CL. Furthermore, install the Active Directory extension.

## Instructions

### Desktop experience/Windows Admin Center

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. Click **Start**, and type **Internet Options**.
1. Click **Internet Options**.
1. In Internet Properties, click the tab **Security**.
1. On tab Security, click **Local intranet**.
1. Click the button **Sites**.
1. In Local intranet, click the button **Advanced**.
1. In Local intranet, under **Add this website to the zone**, enter **https://admincenter.ad.lab.test**, click **Add** and click **Close**.
1. In **Local intranet**, click **OK**.
1. In **Internet Properties**, click **OK**.
1. Open **Microsoft Edge**.
1. In Microsoft Edge, navigate to **https://admincenter.ad.lab.test**.
1. In Windows Admin Center, on the connections page, click **Add**.
1. In the panel **Add or create resources**, under **Server**, click **Add**.
1. In the panel, click the tab **Search Active Directory**.
1. On tab Search Active Directory, enter **VN\*** and click **Search**.
1. To the left of the column header **Name** activate the checkbox to select all servers starting with VN and click **Add**.
1. In Windows Admin Center, on the connections page, click **Add**.
1. In the panel **Add or create resources**, under **Server**, click **Add**.
1. In the panel, click the tab **Search Active Directory**.
1. On tab Search Active Directory, enter **PM\*** and click **Search**.
1. To the left of the column header **Name** activate the checkbox to select all servers starting with PM and click **Add**.
1. In Windows Admin Center, on the connections page, click **Add**.
1. In the panel **Add or create resources**, under **Windows PCs**, click **Add**.
1. In the panel, click the tab **Search Active Directory**.
1. On tab Search Active Directory, enter **CL\*** and click **Search**.
1. To the left of the column header **Name** activate the checkbox to select all computers starting with CL and click **Add**.
1. In Windows Admin Center, click the icon **Settings**.
1. In Settings, click **Extensions**.
1. On tab Available extensions, click **Active Directory** and click **Install**.

### PowerShell

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Terminal**.
1. In Terminal, add https://admincenter.ad.lab.test to the Intranet Zone.

    ````powershell
    $path = `
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\admincenter.ad.lab.test'
    New-Item -Path $path -Force
    New-ItemProperty `
        -Path $path -Name 'https' -Value 1 -PropertyType DWORD -Force
    ````

1. Create a CSV file with all server computers.

    ```powershell
    $path = '~\Documents\computers.csv'
    Get-ADComputer -Filter { Name -like 'VN*-*' -or Name -like 'PM-*' } |
    Select-Object `
        @{ name = 'name'; expression = { $PSItem.DNSHostName } }, `
        @{
            name = 'type'
            expression = { 'msft.sme.connection-type.server' }
        }, `
        @{ name = 'tags'; expression = {} }, `
        @{ name = 'groupId'; expression = { } } |
    Export-Csv -Path $path -NoTypeInformation -Force

    ```

1. Append all client computers to the CSV file.

    ```powershell
    Get-ADComputer -Filter { Name -like 'CL*' } |
    Select-Object `
        @{ name = 'name'; expression = { $PSItem.DNSHostName } }, `
        @{ 
            name = 'type'
            expression = { 'msft.sme.connection-type.windows-client' }
        }, `
        @{ name = 'tags'; expression = {} }, `
        @{ name = 'groupId'; expression = { } } |
    Export-Csv -Path $path -Append

    ```

1. Copy the Windows Admin Center modules to the client.

    ```powershell
    $pSSession = New-PSSession -ComputerName VN1-SRV4
    Copy-Item `
        -FromSession $pSSession `
        -Path `
            "$env:ProgramFiles\WindowsAdminCenter\PowerShellModules\*\" `
        -Destination '~\Documents\WindowsPowerShell\Modules\' `
        -Container `
        -Recurse `
        -Force
    Remove-PSSession $pSSession
    ```

1. Import connections.

    ```powershell
    Import-WACConnection `
        -GatewayEndpoint https://admincenter.ad.lab.test `
        -fileName $path
    ```

1. Open **Microsoft Edge**.
1. In Microsoft Edge, navigate to **https://admincenter.ad.lab.test**.
1. In Windows Admin Center, click the icon **Settings**.
1. In Settings, click **Extensions**.
1. On tab Available extensions, click **Active Directory** and click **Install**.
