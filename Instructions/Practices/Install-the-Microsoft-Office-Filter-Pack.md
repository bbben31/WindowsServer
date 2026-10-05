# Practice: Install the Microsoft Office Filter Pack

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Official Microsoft product download endpoints and installer dependencies.

**Risk, cost and optional status:** low; local-only; optional=true. Historical optional compatibility exercise; use only isolated disposable legacy media from official sources. Skip installation if official media/support prerequisites cannot be met.

**Success verification:** The historical filter pack is installed only if official media and compatible OS are available; otherwise record a conceptual skip.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10

## Task

Download and install the Microsoft Office 2010 Filter Packs on VN1-SRV10.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Using **Microsoft Edge**, navigate to <https://www.microsoft.com/en-US/download/details.aspx?id=17062>
1. On the page Download Microsoft Office 2010 Filter Packs, click **Download**.
1. Activate the checkbox **FilterPack64bit.exe** and click **Next**.
1. Copy the file **FilterPack64bit.exe** to **\\\\VN1-SRV10\\IT**.
1. Open **Terminal**.
1. Install the **Microsoft Office Filter Pack** on **VN1-SRV10**.

    ````powershell
    Invoke-Command -ComputerName VN1-SRV10 -ScriptBlock {
        Unblock-File -Path D:\Shares\IT\FilterPack64bit.exe 
        Start-Process `
            -FilePath D:\Shares\IT\FilterPack64bit.exe `
            -ArgumentList '/extract:c:\FilterPack', '/quiet' `
            -Wait
        Start-Process `
            -FilePath msiexec.exe `
            -ArgumentList '/i C:\filterpack\FilterPack.msi', '/q' `
            -Wait
    }
    ````

    The installation should complete in a few seconds. If it does not complete, perform the following troubleshooting steps:

    1. On VN1-SRV10, sign in as **Administrator**.
    1. Open **Terminal**.
    1. In Terminal, extract the Microsoft Office Filter Pack.

        ````shell
        D:\Shares\IT\FilterPack64bit.exe /extract:c:\FilterPack /quiet
        `````

    1. Install the Microsoft Office Filter Pack.

        ````shell
        msiexec.exe /i C:\FilterPack\FilterPack.msi /qb
        ````
