# Practice: Install app compatibility feature on demand

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Official Microsoft evaluation and Languages/Optional Features media downloads during staging only.

**Risk, cost and optional status:** low; local-only; optional=true. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** Get-WindowsCapability reports the staged AppCompatibility capability installed and the requested management tool launches.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* VN1-SRV1
* VN1-SRV5

## Setup

On **VN1-SRV5**, logon as **ad\Administrator**.

### Task

On VN1-SRV5, install the application compatibility feature and verify the functionality.

### Instructions

Perform this task on VN1-SRV5.

1. In SConfig, enter **15**.
1. Mount the Windows Server Languages and Optional Features ISO image file.

    ````powershell
    $imagePath = 'C:\WindowsServerLab\Resources\26100.1.240331-1435.ge_release_amd64fre_SERVER_LOF_PACKAGES_OEM.iso'
    if (!(Test-Path -LiteralPath $imagePath -PathType Leaf)) { throw 'Stage the matching official Languages/Optional Features ISO first.' }
    $diskImage = Mount-DiskImage -ImagePath $imagePath -PassThru
    $driveLetter = ($diskImage | Get-Volume).DriveLetter
    ````

1. Install the Application Compatibility Feature.

    ````powershell
    $name = 'ServerCore.AppCompatibility~~~~0.0.1.0'
    $source = "${driveLetter}:\LanguagesAndOptionalFeatures\"
    Add-WindowsCapability -Online -Name $name -Source $source -LimitAccess
    ````

1. Restart the computer.

    ````powershell
    Restart-Computer
    ````

1. Login as **ad\Administrator**.
1. In SConfig, enter **15**.
1. Try the following tools. The AppCompatibility package supplies graphical components but not every role's management prerequisites: Failover Cluster Manager needs Failover Clustering/its tools and Hyper-V Manager needs Hyper-V management tools. Record a missing unselected role/tool as such; do not assume installing AppCompatibility installed the role.

    ````powershell
    mmc.exe
    eventvwr.msc
    perfmon.exe
    resmon.exe
    devmgmt.msc
    explorer.exe
    powershell_ise.exe
    diskmgmt.msc
    CluAdmin.msc
    taskschd.msc
    virtmgmt.msc
    ````

1. Close all open graphical applications.
