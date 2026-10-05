# Practice: Configure password and account lockout policies

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-group-policy-management.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; conditional until retired; supply the guest or explicitly confirm retirement with -RetiredVmName); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary VMnet8 NAT on CL1 only for Windows Update RSAT capability installation; preserve the AD NIC/DNS and disconnect after setup.

**Permissions:** Delegated AD/GPO rights for the named OU, account and policy changes; lab Domain Administrator only where the procedure requires it. Local Administrator for guest setup.

**Outbound access:** Windows Update downloads Windows 11 RSAT Features on Demand on CL1 during the documented setup/fallback. Before installing capabilities, attach a temporary second VMware NIC to VMnet8 NAT; retain the AD NIC and its AD DNS, disable DNS registration on the NAT NIC, and record adapters/routes/DNS. Disconnect VMnet8 immediately after installation. If the required tools are already installed, the download step needs no outbound access. Endpoints: *.windowsupdate.com (Windows Update service/content); *.update.microsoft.com (Microsoft Update service); *.delivery.mp.microsoft.com (Windows Update delivery); https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-security (current service endpoint guidance).

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The target user/computer receives the configured password and lockout policy; record resultant policy and controlled test results.

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

For the ad.lab.test domain, configure the password policy to require passwords of at least 8 character in length. The passwords should not need to be complex and should not need to be changed regularly.

Configure a password lockout policy after 100 invalid attempts in 10 minutes. The account should be locked out for 10 minutes. Exclude the default administrator from the lockout policy.

## Instructions

Perform these steps on CL1.

1. Sign in as **Administrator@ad.lab.test**.
1. Open **Group Policy Management**.
1. In Group Policy Management, expand **Forest: ad.lab.test**, **Domains**, and click **ad.lab.test**.
1. In the context-menu of **ad.lab.test**, click **Create a GPO in this domain, and Link it here...**
1. In New GPO, under **Name**, type **Custom Domain Account Policies** and click **OK**.
1. In **Group Policy Management**, in the context-menu of **Custom Domain Account Policies**, click **Edit...**
1. In Group Policy Management Editor, under **Computer Configuration**, expand **Policies**, **Windows Settings**, **Security Settings**, **Account Policies** and click **Password Policy**.
1. In Password Policy, double-click **Maximum password age**.
1. In Maximum password age Properties, activate **Define this policy setting**. Under **Password will expire in**, type **0** and click **OK**.
1. In Suggested Value Changes, click **OK**.
1. In **Group Policy Management Editor**, in **Password Policy**, double-click **Minimum password age**.
1. In Minimum password age Properties, ensure **Define this policy setting** is activated. Under **Password can be changed after**, type **0** and click **OK**.
1. In **Group Policy Management Editor**, in **Password Policy**, double-click **Minimum password length**.
1. In Minimum password length Properties, activate **Define this policy setting**. Under **No password required**, type **8** (the label will change to **Password must be at least**) and click **OK**.
1. In **Group Policy Management Editor**, in **Password Policy**, double-click **Password must meet complexity requirements**.
1. In Password must meet complexity requirements Properties, activate **Define this policy setting**, ensure **Disabled** is selected, and click **OK**.
1. In **Group Policy Management Editor**, click **Account Lockout**.
1. In **Account lockout duration**, activate **Define this policy setting**, enter **10** minutes, and click **OK**.
1. In **Reset account lockout counter after**, activate **Define this policy setting**, enter **10** minutes, and click **OK**.
1. In Account Lockout, double-click **Account lockout threshold**.
1. In Account lockout threshold Properties, activate **Define this policy setting**. Under **Account will lock out after**, type **100** and click **OK**.
1. In Suggested Value Changes, click **OK**.
1. In **Group Policy Management Editor**, in **Account Lockout**, double-click **Allow Administrator account lockout**.
1. In Allow Administrator account lockout Properties, ensure **Define this policy setting** is activated, click **Disabled**, and click **OK**.
1. Close **Group Policy Management Editor**.
1. In **Group Policy Management**, in **ad.lab.test**, click the tab **Linked Group Policy Objects**.
1. On the tab Linked Group Policy Objects, click **Custom Domain Account Policies** and to the left, click the icon *Move link up*.
1. In the left pane, in the context menu of **Domain Controllers**, click **Group Policy Update...**
1. In Force Group Policy update, click **Yes**.
1. In Remote Group Policy update results, ensure the update has succeeded on all computers and click **Close**.
1. Sign out.
1. Sign as **Dita@ad.lab.test**.
1. If you are not prompted to change the password at sign in, use VMware **VM > Send Ctrl+Alt+Del** (or **Ctrl+Alt+Insert**) in the guest console and click **Change a password**.
1. Try to set a password shorter than 8 characters.

    > You should receive a message, that the pasword does not meet the requirements of the domain.

1. Try to set a non-complex passwords with 8 character at least.

    > The password should be accepted.

1. Sign out.
