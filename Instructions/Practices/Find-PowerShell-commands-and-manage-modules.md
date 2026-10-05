# Practice: Find PowerShell commands, get help, and manage modules

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Standard lab user for local read-only queries and user-owned files; no local elevation. If the explicitly documented system-help prerequisite is selected under Windows PowerShell 5.1, use a separate authorized elevated session.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: www.powershellgallery.com and its documented package CDN; Microsoft help endpoints if Update-Help is selected.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Record discovery/help output and Graph module versions/paths; verify import and unload, then absence after exercise uninstall.

**Rollback and cleanup:** Unload and uninstall only the Graph module installed for this practice; verify it is absent. Restore the disposable user/snapshot and recorded execution policy/help/provider settings; disconnect VMnet8 and verify AD DNS.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1

## Task

On CL1, discover local-user commands and their help, explore command syntax, then find, install, list, import, update, unload, and uninstall a Microsoft Graph PowerShell module. No tenant connection or directory changes are needed.

## Instructions

Perform these steps on CL1 with a standard lab user in **PowerShell 7**. Microsoft recommends PowerShell 7 for Graph; if using Windows PowerShell 5.1, first satisfy the .NET/PowerShellGet prerequisites in [Microsoft's installation guide](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation). Install modules only for the current user. Record any approved execution-policy change and restore it afterward; do not override organizational policy.

1. Record the guest's current adapters, routes, DNS, and VMware settings. Temporarily attach **NAT (VMnet8)** for HTTPS access to PowerShell Gallery and help endpoints. Keep AD DNS on the domain NIC; disable DNS registration on the NAT NIC. Remove temporary NAT when finished.
1. Open **Terminal**, select PowerShell, and discover commands:

    ````powershell
    Get-Command -Verb New -Noun *User*
    Get-Command -Noun LocalUser
    Get-Help New-LocalUser
    Get-Help about_*
    Get-Help about_Command_Syntax
    ````

    This is discovery only; do not create a user. Available local-user commands depend on the engine/platform. If help is incomplete, fetch help for an installed module that supports it. For example, `Update-Help -Module Microsoft.PowerShell.Utility -Scope CurrentUser` in PowerShell 7 writes user-scoped help. Windows PowerShell's system help update may require a separately elevated session. Wait for completion and repeat the help query; record unavailable endpoints rather than assuming all topics are present.

1. Inventory available modules and find the small Graph authentication module. Check the repository URL before accepting any Gallery/provider prompt:

    ````powershell
    Get-Module -ListAvailable
    Get-PSRepository -Name PSGallery
    Find-Module -Name Microsoft.Graph.Authentication -Repository PSGallery
    Get-InstalledModule -Name Microsoft.Graph.Authentication -AllVersions -ErrorAction SilentlyContinue
    ````

    Use a disposable user/snapshot without an existing Graph installation. If it already exists, record its versions and stop before uninstalling anything owned by another exercise.

1. Install and inspect its location:

    ````powershell
    Install-Module -Name Microsoft.Graph.Authentication -Scope CurrentUser -Repository PSGallery
    Get-InstalledModule -Name Microsoft.Graph.Authentication
    Get-Module -Name Microsoft.Graph.Authentication -ListAvailable | Format-List Name, Version, ModuleBase
    ````

1. Import it explicitly, inspect loaded modules and exported commands, then unload it:

    ````powershell
    Import-Module Microsoft.Graph.Authentication
    Get-Module Microsoft.Graph.Authentication
    Get-Command -Module Microsoft.Graph.Authentication
    Remove-Module Microsoft.Graph.Authentication
    Get-Module Microsoft.Graph.Authentication
    ````

    Unloading affects this session; it does not uninstall files. Do not run `Connect-MgGraph`, request consent, or create a tenant merely to manage modules.

1. Update and inspect installed versions. An already-current version is a successful observation:

    ````powershell
    Update-Module -Name Microsoft.Graph.Authentication
    Get-InstalledModule -Name Microsoft.Graph.Authentication -AllVersions
    Get-Module -Name Microsoft.Graph.Authentication -ListAvailable
    ````

1. Remove the module installed for this exercise. Close other sessions that imported it first:

    ````powershell
    Remove-Module Microsoft.Graph.Authentication -ErrorAction SilentlyContinue
    Uninstall-Module -Name Microsoft.Graph.Authentication -AllVersions
    Get-Module -Name Microsoft.Graph.Authentication -ListAvailable
    Get-InstalledModule -Name Microsoft.Graph.Authentication -ErrorAction SilentlyContinue
    ````

    The final two commands should find no remaining exercise installation. Restore the pre-lab snapshot if provider/help dependencies or user settings changed. Disconnect/remove VMnet8 and verify domain DNS remains usable.
