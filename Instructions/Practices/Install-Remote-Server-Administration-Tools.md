# Practice: Install Remote Server Administration Tools

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Microsoft Windows Update/WSUS and feature-on-demand endpoints.

**Risk, cost and optional status:** low; local-only; optional=true. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** The intended RSAT capabilities are Installed and their consoles open on CL1.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1

## Task

Install the Remote Server Administration Tools for Active Directory Domain Services, File Services, Group Policy management, and the Server Manager on CL1.

## Instructions

### Desktop experience

Perform these steps on CL1.

1. Sign in as **.\Administrator**.
1. Open **Settings**.
1. In Settings, click **System**.
1. In System, click **Optional features**.
1. In Optional features, click the button **View features**.
1. In View features, if necessary, click **See available features**. In the text field **Find an available optional feature**, type **RSAT**. Activate the check boxes of these tools:
    * RSAT: Active Directory Domain Services and Lightweight Directory Services Tools
    * RSAT: File Services tools
    * RSAT: Group Policy Management Tools
    * RSAT: Server Manager

    Click **Add (4)**.
1. If required, restart the computer.

### PowerShell

Perform these steps on CL1.

1. Sign in as **.\Administrator**.
1. In the context menu of **Start**, click **Terminal (Admin)**.
1. Add the windows capabilities
    * RSAT: Active Directory Domain Services and Lightweight Directory Services Tools
    * RSAT: File Services tools
    * RSAT: Server Manager

    ````powershell
    <# 
        Add-WindowsCapability does not support wildcards. Therefore, we use
        pipelines with the Get | Add pattern
    #>
    Get-WindowsCapability -Online -Name 'Rsat.ActiveDirectory.DS-LDS.Tools*' |
    Add-WindowsCapability -Online
    Get-WindowsCapability -Online -Name 'Rsat.FileServices.Tools*' | 
    Add-WindowsCapability -Online
    # With the File Services tools, Server Manager is installed automatically
    Get-WindowsCapability -Online -Name 'Rsat.GroupPolicy.Management.Tools*' |
    Add-WindowsCapability -Online    
    ````
