# Practice: Configure Kerberos constrained delegation

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-Windows-Admin-Center-using-a-script.md; Instructions/Labs/Multi-domain-environments.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); CL2 (VMware display: CL2; accepted display aliases: WIN-CL2; existing); CL4 (VMware display: CL4; accepted display aliases: WIN-CL4; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; conditional until retired; supply the guest or explicitly confirm retirement with -RetiredVmName); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV7 (VMware display: VN1-SRV7; accepted display aliases: WIN-VN1-SRV7; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments. Temporary VMnet8 NAT on CL1 only for Windows Update RSAT capability installation; preserve the AD NIC/DNS and disconnect after setup.

**Permissions:** Delegated AD/GPO rights for the named OU, account and policy changes; lab Domain Administrator only where the procedure requires it. Local Administrator for guest setup.

**Outbound access:** Windows Update downloads Windows 11 RSAT Features on Demand on CL1 during the documented setup/fallback. Before installing capabilities, attach a temporary second VMware NIC to VMnet8 NAT; retain the AD NIC and its AD DNS, disable DNS registration on the NAT NIC, and record adapters/routes/DNS. Disconnect VMnet8 immediately after installation. If the required tools are already installed, the download step needs no outbound access. Endpoints: *.windowsupdate.com (Windows Update service/content); *.update.microsoft.com (Microsoft Update service); *.delivery.mp.microsoft.com (Windows Update delivery); https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-security (current service endpoint guidance).

**Risk, cost and optional status:** low; local-only; optional=false. Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware.

**Success verification:** Delegation is restricted to the intended service; the specified second-hop resource works for the authorized test principal.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Disconnect the temporary VMnet8 NIC after capability installation and restore recorded adapters/routes/DNS; retain installed RSAT until dependent exercises finish.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* CL2
* CL4
* VN1-SRV4
* VN1-SRV5
* VN1-SRV7
* Conditional until retired: VN1-SRV1

> **Conditional controller lifecycle:** Supply VN1-SRV1 while it remains the active original controller. After its documented retirement, confirm that VN1-SRV5 serves the original DNS address and the required directory roles, then pass `-RetiredVmName VN1-SRV1` to preflight; never restart a retired controller. Retirement requires the completed address/role handover, not merely completing controller promotion or switching off a guest. Steps concerning the retired server apply only to recorded historical state or removal of its stale directory objects.

## Setup

If you skipped the practice [Install Remote Server Administration Tools](Install-Remote-Server-Administration-Tools.md), on **CL1**, in **Terminal**, execute ````C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1````.

Complete [Install Windows Admin Center using a script](Install-Windows-Admin-Center-using-a-script.md) on **VN1-SRV4** before continuing.

If you skipped exercise 2 of the lab [Multi domain environments](../Labs/Multi-domain-environments.md#exercise-2-deploy-a-child-domain) (meaning, you do not have the clients.ad.lab.test domain),  join **CL4** to the domain **ad.lab.test**. Moreover, in the command ````Set-ADComputer```` remove the parameter ````-Server````.

## Task

Allow Windows Admin Center to use single-sign on to CL4.

## Instructions

Perform these steps on CL2.

1. Sign in as **Stefan@ad.lab.test**.
1. Use Microsoft Edge to navigate to <https://admincenter>.
1. In Windows Admin Center, click **Add**.
1. In the pane Add or create resources, under **Windows PCs**, click **Add**.
1. In the right pane, under **Computer name**, type **CL4**.

    > An error message is displayed, that credentials are needed.

1. Click **Add**.
1. Click **CL4**.

    > A pane will prompt you to specify your credentials.

1. In the pane **Specify your credentials**, click **Cancel**.

Perform these steps on CL1.

1. Sign in as **Administrator@ad.lab.test**.
1. Run **Terminal**.
1. Retrieve the computer account of **VN1-SRV4** and store it in a variable.

    ````powershell
    $wacComputer = Get-ADComputer VN1-SRV4
    ````

1. Allow CL4 to be delegated to the Windows Admin Center computer.

    ````powershell
    Set-ADComputer `
        -Identity CL4 `
        -Server VN1-SRV7 `
        -PrincipalsAllowedToDelegateToAccount $wacComputer
    ````

Perform these steps on CL2.

1. In Windows Admin Center, click **CL4**.

    > The connection should be successful without requiring additional credentials.

1. Sign out.
