# Practice: Delegate password reset permissions

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-Remote-Server-Administration-Tools.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; conditional); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV7 (VMware display: VN1-SRV7; accepted display aliases: WIN-VN1-SRV7; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary VMnet8 NAT on CL1 only for Windows Update RSAT capability installation; preserve the AD NIC/DNS and disconnect after setup.

**Permissions:** Delegated AD/GPO rights for the named OU, account and policy changes; lab Domain Administrator only where the procedure requires it. Local Administrator for guest setup.

**Outbound access:** Windows Update downloads Windows 11 RSAT Features on Demand on CL1 during the documented setup/fallback. Before installing capabilities, attach a temporary second VMware NIC to VMnet8 NAT; retain the AD NIC and its AD DNS, disable DNS registration on the NAT NIC, and record adapters/routes/DNS. Disconnect VMnet8 immediately after installation. If the required tools are already installed, the download step needs no outbound access. Endpoints: *.windowsupdate.com (Windows Update service/content); *.update.microsoft.com (Microsoft Update service); *.delivery.mp.microsoft.com (Windows Update delivery); https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-security (current service endpoint guidance).

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The delegated user can reset a test password in the intended OU and cannot administer unrelated OUs.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Disconnect the temporary VMnet8 NIC after capability installation and restore recorded adapters/routes/DNS; retain installed RSAT until dependent exercises finish.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV5
* VN1-SRV7

If you did not complete the lab [Deploying domain controllers](../Labs/Deploying-domain-controllers.md), in addition to the VMs above, **VN1-SRV1** is required. If VN1-SRV1 is already shut down after the lab, do not start it.

## Setup

If you skipped the practice [Install Remote Server Administration Tools](Install-Remote-Server-Administration-Tools.md), on **CL1**, in **Terminal**, execute ````C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1````.

## Task

The users Dante Dabney, Ida Alksne, Lara Raisic, and Stefan Deboer from the helpdesk at Adatum should be granted permissions to reset passwords for users in the organizational unit Sales.

## Instructions

Perform these steps on CL1.

1. Sign in as **Administrator@ad.lab.test**.
1. Open **Active Directory Users and Computers**.
1. In Active Directory Users and computers, expand **ad.lab.test**, and click **IT**.
1. In the context-menu of **IT**, click **New**, **Group**.
1. In New Object - Group, in **Group name**, type **Helpdesk**. Under **Group scope**, ensure **Global** is selected. Under **Group type**, ensure **Security** is selected. Click **OK**.
1. In **Active Directory Users and Computers**, in **IT**, click **Dante Dabney**, hold down CTRL, and click **Ida Alksne**, **Lara Raisic**, and  **Stefan Deboer**.
1. In the **Tasks** pane, under **4 items selected**, click **Add to group...**.
1. In Select Groups, under **Enter the object names to select**, type **Helpdesk** and click **OK**.
1. In **Active Directory Users and Computers**, click **Entitling groups**.
1. In the context-menu of **Entitling Groups**, click **New**, **Group**.
1. In New Object - Group, in **Group name**, type **OU Sales Password Reset**. Under **Group scope**, click **Domain local**. Under **Group type**, ensure **Security** is selected. Click **OK**.
1. In **Active Directory Users and Computers**, in **Entitling Groups**, double-click **OU Sales Password Reset**.
1. In OU Sales Password Reset Properties, click the tab **Members**.
1. On tab Members, click **Add...**.
1. In **Select Users, Contacts, Computers, Service Accounts, or Groups**, under **Enter the object names to select**, type **Helpdesk** and click **OK**.
1. In **OU Sales Password Reset Properties**, click **OK**.
1. In **Active Directory Users and Computers**, in the context-menu of **Sales**, click **Delegate Control...**.
1. In Delegation of Control Wizard, on page Welcome to the Delegation of Control Wizard, click **Next >**.
1. On page Users or Groups, click **Add...**.
1. In Select Users, Computers, or Groups, under **Enter the object names to select**, type **OU Sales Password Reset** and click **OK**.
1. In **Delegation of Control Wizard**, on page **Users or Groups**, click **Next >**.
1. On page Tasks to Delegate, ensure **Delegate the following common tasks** is selected, activate **Reset user passwords and force password change at next logon** and click **Next >**
1. On page Completing the Delegation of Control Wizard, click **Finish**.
1. Sign out.
1. Sign in as **ad\ida**.
1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, on the menu, click **Manage**, **Add Navigation Nodes...**.
1. In Add Navigation Nodes, in the middle pane, click **Sales**, click **>>**, and click **OK**.
1. In **Active Directory Administrative Center**, in the left pane, click **ad-Sales**.
1. In ad-Sales, in the context-menu of **Ada Russell**, click **Properties**.

    > You cannot edit any properties.

1. In Abbie Parsons, click **Cancel**.
1. In **Active Directory Administrative Center**, in **ad-Sales**, in the context-menu of **Abbie Parsons**, click **Reset password...**.
1. In Reset Password, in **Password** and **Confirm password**, type a secure password. Click to deactivate **User must change password at next log on** and click **OK**.

    > You have reset the password of a user successfully.
