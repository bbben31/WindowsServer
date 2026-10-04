# Practice: Enable the Active Directory Recycle Bin

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-Remote-Server-Administration-Tools.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary VMnet8 NAT on CL1 only for Windows Update RSAT capability installation; preserve the AD NIC/DNS and disconnect after setup.

**Permissions:** Lab Enterprise/Domain Administrator for the named forest/domain changes; Schema Admin only for schema extension. Local Administrator for guest setup. Remove temporary role membership afterward.

**Outbound access:** Windows Update downloads Windows 11 RSAT Features on Demand on CL1 during the documented setup/fallback. Before installing capabilities, attach a temporary second VMware NIC to VMnet8 NAT; retain the AD NIC and its AD DNS, disable DNS registration on the NAT NIC, and record adapters/routes/DNS. Disconnect VMnet8 immediately after installation. If the required tools are already installed, the download step needs no outbound access. Endpoints: *.windowsupdate.com (Windows Update service/content); *.update.microsoft.com (Microsoft Update service); *.delivery.mp.microsoft.com (Windows Update delivery); https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-security (current service endpoint guidance).

**Risk, cost and optional status:** high; local-only; optional=true. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** Get-ADOptionalFeature shows Recycle Bin enabled for the disposable forest; record that enabling it is irreversible in-place.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Disconnect the temporary VMnet8 NIC after capability installation and restore recorded adapters/routes/DNS; retain installed RSAT until dependent exercises finish.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1

## Setup

If you skipped the practice [Install Remote Server Administration Tools](Install-Remote-Server-Administration-Tools.md), on CL1, run ````C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1````.

## Task

Enable the Active Directory  using either Active Directory Administrative Center or PowerShell.

## Instructions

### Active Directory Administrative Center

Perform these steps on CL1.

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, in the left pane, click **ad (local)**.
1. In the pane **Tasks**, under **ad (local)**, click **Enable Recycle Bin...**.
1. In Enable Recycle Bin Confirmation, click **OK**.
1. In the top right, click the icon *Refresh*.

### PowerShell

Perform these steps on CL1

1. Open **Terminal**.
1. Enable the Active Directory Recycle Bin.

    ````powershell
    $domainFQDN = 'ad.lab.test'
    $domainDN = 'DC=ad, DC=lab, DC=test'
    Enable-ADOptionalFeature `
        -Identity `
            "CN=Recycle Bin Feature, CN=Optional Features, CN=Directory Service, CN=Windows NT, CN=Services, CN=Configuration, $domainDN" `
        -Scope ForestOrConfigurationSet `
        -Target $domainFQDN
    ````
