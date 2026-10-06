# Practice: Restrict the Administrators group for clients

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-group-policy-management.md; Instructions/Labs/Multi-domain-environments.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. CL4 is joined to clients.ad.lab.test. Reuse/create only recorded root Helpdesk and child Entitling Groups/CLIENTS entitlement fixtures; preserve existing OUs.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); CL4 (VMware display: CL4; accepted display aliases: WIN-CL4; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; conditional until retired; supply the guest or explicitly confirm retirement with -RetiredVmName); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV7 (VMware display: VN1-SRV7; accepted display aliases: WIN-VN1-SRV7; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments.

**Permissions:** Authorized root-domain group-creation rights, child-domain OU/group/GPO administration and CL4 local elevation for the named restricted-group test.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Enterprise expansion profile; retain the child-domain CL4, its recorded AD DNS/VMnet and directory/GPO lineage.

**Success verification:** CL4's local Administrators includes its retained local built-in Administrator and the intended CLIENTS entitlement group; CLIENTS\Administrator is not a substitute for the local account.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* CL4
* VN1-SRV5
* VN1-SRV7
* Conditional until retired: VN1-SRV1

> **Conditional controller lifecycle:** Supply VN1-SRV1 while it remains the active original controller. After its documented retirement, confirm that VN1-SRV5 serves the original DNS address and the required directory roles, then pass `-RetiredVmName VN1-SRV1` to preflight; never restart a retired controller. Retirement requires the completed address/role handover, not merely completing controller promotion or switching off a guest. Steps concerning the retired server apply only to recorded historical state or removal of its stale directory objects.

## Setup

For this practice, you must have completed exercise 2 of the lab [Multi domain environments](../Labs/Multi-domain-environments.md#exercise-2-deploy-a-child-domain). In this exercise you deployed the clients.ad.lab.test domain. If you did not deploy this domain, skip this exercise.

On **CL1**, first use an account authorized to create groups in the root **ad.lab.test** domain. Confirm the **Helpdesk** security group exists there; if it does not, create the empty global security group below. Do not add broad administrative membership merely to satisfy this practice. Switch to the child-domain administrator for the instructions that follow.

````powershell
$helpdesk = Get-ADGroup -Filter "SamAccountName -eq 'Helpdesk'" -Server ad.lab.test
if (!$helpdesk) {
    New-ADGroup -Name Helpdesk -SamAccountName Helpdesk -GroupCategory Security -GroupScope Global -Path 'CN=Users,DC=ad,DC=lab,DC=test' -Server ad.lab.test
}
````

If the **Devices**, **Client computers**, or **Entitling Groups** OUs already exist, reuse them rather than creating duplicates. Record their distinguished names and confirm CL4 is in the child domain before moving its computer account.

## Task

In the clients.ad.lab.test, create a group Client Computer Administrators and add the Helpdesk group as a member. Restrict the Administrators group of client computer in the domain to contain only the Client Computer Administrators group and the default Administrator only.

## Instructions

Perform these steps on CL1.

1. Sign in as **Administrator@clients.ad.lab.test**.
1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, click **clients (local)**.
1. In clients (local), in the **Tasks** pane, under **clients (local)**, click **New**, **Organizational Unit**.
1. In Create Organizational Unit, in **Name**, type **Devices** and click **OK**.
1. In **Active Directory Administrative Center**, in **clients (local)**, double-click **Devices**.
1. In Devices, in the **Tasks** pane, under **Devices**, click **New**, **Organizational Unit**.
1. In Create Organizational Unit, in **Name**, type **Client computers** and click **OK**.
1. In **Active Directory Administrative Center**, click **clients (local)**.
1. In clients (local), double-click **Computers**.
1. In Computers, in the context-menu of **CL4**, click **Move...**
1. In Move, in the middle-pane, click **Devices**, in the right pane, click **Client computers** and click **OK**.
1. In **Active Directory Administrative Center**, click **clients (local)**.
1. If **Entitling Groups** is absent, in the **Tasks** pane choose **New**, **Organizational Unit**, enter **Entitling Groups**, and click **OK**.
1. In clients (local), double-click **Entitling Groups**.
1. In Entitling Groups, in the **Tasks** pane, under **Entitling Groups**, click **New**, **Group**.
1. In Create Group, in **Group name**, type **Client Computer Administrators**. In **Group type**, ensure **Security** is selected. In **Group scope**, click **Domain local**. Click **Members**.
1. Under Members, click **Add...**.
1. In Select Users, Contacts, Computers, Service Accounts, or Groups, click **Locations...**.
1. In Locations, click **Entire Directory** (or **ad.lab.test**) and click **OK**.
1. In **Select Users, Contacts, Computers, Service Accounts, or Groups**, under **Enter the object names to select**, type **Helpdesk** and click **OK**.
1. In **Create Group: Client Computer Administrators**, click **OK**.
1. Open **Group Policy Management**.
1. In Group Policy Management, expand **Forest: ad.lab.test**, **Domains**, **clients.ad.lab.test**, **Devices**, and click **Client computers**.
1. In the context-menu of **Client computers**, click **Create a GPO in this domain, and Link it here...**
1. In New GPO, unter **Name**, type **Custom Computer Restricted Groups Administrators to Clients Computer Administrators**.
1. In the context-menu of **Custom Computer Restricted Groups Administrators to Clients Computer Administrators**, click **Edit**
1. In Group Policy Management Editor, expand **Computer Configuration**, **Policies**, **Windows Settings**, **Security Settings**, and click **Restricted Groups**.
1. In the context-menu of **Restricted Groups**, click **Add Group...**.
1. In Add Group, click **Browse...**
1. In Select Groups, under **Enter object names to select**, type **Administrators** and click **OK**.
1. In **Add Group**, click **OK**.
1. In Administrators Properties, under **Members of this group**, click **Add...**
1. In Add Member, click **Browse...**
1. In Select Users, Service Accounts, or Groups, cick **Locations**.
1. In Locations, click **Entire Directory** and click **OK**.
1. In **Select Users, Service Accounts, or Groups**, click **Object Types**.
1. In Object Types, activate **Groups** and click **OK**.
1. In **Select Users, Service Accounts, or Groups**, under **Enter the object names to select**, type **Client Computer Administrators** and click **OK**.
1. Include only **CLIENTS\Client Computer Administrators** in the policy's explicit member list. Do not select the domain Administrator account as a substitute for the client's local built-in Administrator. Restricted Groups preserves the local built-in Administrator automatically; see [Restricted Groups membership behavior](https://learn.microsoft.com/en-us/troubleshoot/windows-server/group-policy/description-of-group-policy-restricted-groups).
1. In **Group Membership**, click **OK**.
1. In **Administrators Properties**, click **OK**.
1. Close **Group Policy Management Editor**.

Perform these steps on CL4.

1. Sign in as **.\Administrator**.
1. In the context-menu of *Start*, click **Windows PowerShell (Admin)**.
1. In Administrator: Windows Powershell, update group policies.

    ````powershell
    gpupdate.exe /force
    ````

1. In the context-menu of *Start*, click **Computer Management**.
1. In Computer Management, expand **Local Users and Groups** and click **Groups**.
1. Double-click **Administrators**.

    > The client's local built-in Administrator and CLIENTS\Client Computer Administrators should be members. Verify the Administrator is the local account, not CLIENTS\Administrator.

1. In Administrators Properties, click **Cancel**.
1. Sign out.
