# Practice: Configure a fine-grained password policy

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-Remote-Server-Administration-Tools.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; conditional until retired; supply the guest or explicitly confirm retirement with -RetiredVmName); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary VMnet8 NAT on CL1 only for Windows Update RSAT capability installation; preserve the AD NIC/DNS and disconnect after setup.

**Permissions:** Delegated AD/GPO rights for the named OU, account and policy changes; lab Domain Administrator only where the procedure requires it. Local Administrator for guest setup.

**Outbound access:** Windows Update downloads Windows 11 RSAT Features on Demand on CL1 during the documented setup/fallback. Before installing capabilities, attach a temporary second VMware NIC to VMnet8 NAT; retain the AD NIC and its AD DNS, disable DNS registration on the NAT NIC, and record adapters/routes/DNS. Disconnect VMnet8 immediately after installation. If the required tools are already installed, the download step needs no outbound access. Endpoints: *.windowsupdate.com (Windows Update service/content); *.update.microsoft.com (Microsoft Update service); *.delivery.mp.microsoft.com (Windows Update delivery); https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-security (current service endpoint guidance).

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Get-ADUserResultantPasswordPolicy for the test user returns the intended fine-grained policy and precedence.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Disconnect the temporary VMnet8 NIC after capability installation and restore recorded adapters/routes/DNS; retain installed RSAT until dependent exercises finish.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV5
* Conditional until retired: VN1-SRV1

> **Conditional controller lifecycle:** Supply VN1-SRV1 while it remains the active original controller. After its documented retirement, confirm that VN1-SRV5 serves the original DNS address and the required directory roles, then pass `-RetiredVmName VN1-SRV1` to preflight; never restart a retired controller. Retirement requires the completed address/role handover, not merely completing controller promotion or switching off a guest. Steps concerning the retired server apply only to recorded historical state or removal of its stale directory objects.

## Setup

If you skipped the practice [Install Remote Server Administration Tools](Install-Remote-Server-Administration-Tools.md), on **CL1**, in **Terminal**, execute ````C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1````.

## Task

In the ad.lab.test, configure password settings for Domain Admins, that require complex passwords of at least 10 character in length.

## Instructions

Perform these steps on CL1.

1. Sign in as **Administrator@ad.lab.test**.
1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **ad (local)**.
1. In ad (local), double-click **System**.
1. In System, double-click **Password Settings Container**.
1. In Password Settings Container, in the **Tasks** pane, click **New**, **Password Settings**.
1. In Create Password Settings, configure the following settings:

    * **Name**: Domain Administrators Password Settings
    * **Precendence**: 10
    * **Enforce minimum password length**: Activated
    * **Minimum password length (characters)**: 10
    * **Enforce password history**: Activated
    * **Number of passwords remembered**: 24
    * **Password must meet complexity requirements**: Activated
    * **Store password using reversible encryption**: Deactivated
    * **Protect from accidental deletion**: Activated
    * **Enforce minimum password age**: Deactivated
    * **Enforce maximum password age**: Deactivated
    * **Enforce account lockout policy**: Deactivated

1. Under **Directly Applies To**, click **Add...**
1. In Select Users or Groups, in **Enter the object names to select**, type **Domain Admins** and click **OK**.
1. In **Create Password Settings: Domain Administrators Password Settings**, click **OK**.
1. Use VMware **VM > Send Ctrl+Alt+Del** (or **Ctrl+Alt+Insert**) in the guest console and click **Change a password**.
1. Try to set a password with 8 or 9 letters, e.g. **cabaletta**

    > You should receive a message, that the pasword does not meet the requirements of the domain.

1. Try to set a non-complex password with 10 letters at least, e.g. **puzzlement**

    > You should receive a message, that the pasword does not meet the requirements of the domain.

1. Try to set a complex password with 10 letters at least. Don't forget to take a note.

    > The password should be accepted.

1. Sign out.
