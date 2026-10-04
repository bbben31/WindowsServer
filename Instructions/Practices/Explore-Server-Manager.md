# Practice: Explore Server Manager

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-Remote-Server-Administration-Tools.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV1 (VMware display: PM-SRV1; accepted display aliases: WIN-PM-SRV1; existing); PM-SRV2 (VMware display: PM-SRV2; accepted display aliases: WIN-PM-SRV2; existing); PM-SRV3 (VMware display: PM-SRV3; accepted display aliases: WIN-PM-SRV3; existing); PM-SRV4 (VMware display: PM-SRV4; accepted display aliases: WIN-PM-SRV4; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV11 (VMware display: VN1-SRV11; accepted display aliases: WIN-VN1-SRV11; existing); VN1-SRV12 (VMware display: VN1-SRV12; accepted display aliases: WIN-VN1-SRV12; existing); VN1-SRV13 (VMware display: VN1-SRV13; accepted display aliases: WIN-VN1-SRV13; existing); VN1-SRV2 (VMware display: VN1-SRV2; accepted display aliases: WIN-VN1-SRV2; existing); VN1-SRV3 (VMware display: VN1-SRV3; accepted display aliases: WIN-VN1-SRV3; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV6 (VMware display: VN1-SRV6; accepted display aliases: WIN-VN1-SRV6; existing); VN1-SRV7 (VMware display: VN1-SRV7; accepted display aliases: WIN-VN1-SRV7; existing); VN1-SRV8 (VMware display: VN1-SRV8; accepted display aliases: WIN-VN1-SRV8; existing); VN1-SRV9 (VMware display: VN1-SRV9; accepted display aliases: WIN-VN1-SRV9; existing); VN2-SRV1 (VMware display: VN2-SRV1; accepted display aliases: WIN-VN2-SRV1; existing); VN2-SRV2 (VMware display: VN2-SRV2; accepted display aliases: WIN-VN2-SRV2; existing); VN3-SRV1 (VMware display: VN3-SRV1; accepted display aliases: WIN-VN3-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary VMnet8 NAT on CL1 only for Windows Update RSAT capability installation; preserve the AD NIC/DNS and disconnect after setup.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Windows Update downloads Windows 11 RSAT Features on Demand on CL1 during the documented setup/fallback. Before installing capabilities, attach a temporary second VMware NIC to VMnet8 NAT; retain the AD NIC and its AD DNS, disable DNS registration on the NAT NIC, and record adapters/routes/DNS. Disconnect VMnet8 immediately after installation. If the required tools are already installed, the download step needs no outbound access. Endpoints: *.windowsupdate.com (Windows Update service/content); *.update.microsoft.com (Microsoft Update service); *.delivery.mp.microsoft.com (Windows Update delivery); https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-security (current service endpoint guidance).

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Server Manager lists the provisioned enterprise inventory and refreshes the intended remote server without connection errors.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Disconnect the temporary VMnet8 NIC after capability installation and restore recorded adapters/routes/DNS; retain installed RSAT until dependent exercises finish.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* PM-SRV1
* PM-SRV2
* PM-SRV3
* PM-SRV4
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
* VN1-SRV7
* VN1-SRV8
* VN1-SRV9
* VN2-SRV1
* VN2-SRV2
* VN3-SRV1

## Setup

If you skipped the practice [Install Remote Server Administration Tools](Install-Remote-Server-Administration-Tools.md), on CL1, run ````C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1````.

## Task

On CL1, in Server Manager, add all Servers with a name starting with VN or PM and explore Server Manager.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Open **Server Manager**.
1. In the dialog **Try managing server with Windows Admin Center**, activate **Don't show this message again** and close it.
1. On the menu, click **Manage**, **Add Servers**.
1. In Add Servers, on tab **Active Directory**, in **Name (CN)**, type **VN** and click **Find Now**.
1. Select all Servers found, and click the arrow button to move them to the list box **Selected**.
1. In **Name (CN)**, type **PM** and click **Find Now**.
1. Select all Servers found, and click the arrow button to move them to the list box **Selected**.
1. Click **OK**.
1. Click **Tools** and explore the menu items.
1. In the left pane, click **All Servers**.
1. Explore the differences in the context menu of various servers, especially of **VN1-SRV1** and others.
1. Take some time to, explore the other options in the left pane.
