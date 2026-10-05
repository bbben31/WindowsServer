# Practice: Create a custom Microsoft Management Console

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-Remote-Server-Administration-Tools.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary VMnet8 NAT on CL1 only for Windows Update RSAT capability installation; preserve the AD NIC/DNS and disconnect after setup.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Windows Update downloads Windows 11 RSAT Features on Demand on CL1 during the documented setup/fallback. Before installing capabilities, attach a temporary second VMware NIC to VMnet8 NAT; retain the AD NIC and its AD DNS, disable DNS registration on the NAT NIC, and record adapters/routes/DNS. Disconnect VMnet8 immediately after installation. If the required tools are already installed, the download step needs no outbound access. Endpoints: *.windowsupdate.com (Windows Update service/content); *.update.microsoft.com (Microsoft Update service); *.delivery.mp.microsoft.com (Windows Update delivery); https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-security (current service endpoint guidance).

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Reopen the saved MMC and verify the requested snap-ins and remote targets are retained.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Disconnect the temporary VMnet8 NIC after capability installation and restore recorded adapters/routes/DNS; retain installed RSAT until dependent exercises finish.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1

## Setup

If you skipped the practice [Install Remote Server Administration Tools](Install-Remote-Server-Administration-Tools.md), on CL1, run ````C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1````.

## Task

On CL1, create a custom Microsoft Management Console with the snap-ins Active Directory Users and Computers and Computer Management and save it to the desktop of all users.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Open **File Explorer**.
1. In File Explorer, click **View**, **Show**, **Hidden items**.
1. Close File Explorer.
1. Run **mmc**.
1. On the menu, click **File**, **Add/Remove Snap-in...**
1. In Add or Remove Snap-Ins, under **Available snap-ins**, click **Active Directory Users and Computers** and click **Add >**.
1. Click **Computer Management** and click **Add >**.
1. In Computer Management, make sure, **Local computer** is selected and click **Finish**.
1. Click **OK**.
1. In the context menu of **Console Root**, click **Rename**.
1. Type **Basic Administration** and press ENTER.
1. On the menu, click **File**, **Save As...**.
1. Save the console as **C:\Users\Public\Desktop\Basic Administration.msc**.

   *Note*: In the dialog, the folder Desktop is displayed as **Public Desktop**.

1. Close the console.
