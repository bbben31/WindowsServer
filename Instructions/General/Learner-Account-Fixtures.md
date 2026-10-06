# Manual learner account fixtures

This supporting setup inventory supplies the identities referenced by the existing labs. It is not a bulk account builder or a separate curriculum exercise. Prepare only the rows required by the selected lab in the isolated **ad.lab.test** forest; one learner uses separate disposable sign-ins to exercise the enterprise access matrix. Do not use production identities or put passwords in Git.

## Manual preparation

1. On CL1, use Active Directory Users and Computers with an authorized lab account. Verify the selected domain/profile and healthy AD replication. Inspect any existing object by exact sAMAccountName and distinguished name before changing it; never reset a shared account merely to make a test pass. Take the coordinated recovery point for the selected identity-sensitive lab.
1. At the domain root, create/verify only the required baseline OUs: **IT**, **Development**, **Research**, **Sales**, **Marketing**, **Managers**, and **Entitling Groups**. Keep organizational OUs distinct from similarly named security groups. In each departmental OU, create its matching global security group (for example CN=IT,OU=IT); group membership does not place a user in an OU or populate the Department attribute. Devices/Servers and their exercise-specific children are created by the selected computer/GPO tasks if absent; do not bypass those teaching steps by precreating an unexplained tree.
1. For each required row below, use the intended OU's **New > User** wizard. Set the listed object/display name and exact logon name; initial UPN is `<logon>@ad.lab.test`. Enter a unique private lab password interactively. Complete any first-sign-in password change before access tests. Accounts must be enabled, with no privileged group membership. Add only the listed global groups through **Properties > Member Of**, and set Department through **Organization** where specified. Leave the ordinary default Domain Users membership intact.
1. Verify the **Name**, **User logon name (pre-Windows 2000)**, OU, Department and group membership before testing; full-name filters and short logon names are not interchangeable. Sign in once with each test account on the intended client to verify its password/domain. Sign out between subjects; do not reuse cached administrator tokens or make a denied user an administrator.
1. If a later task creates an OU/group already supplied by this inventory, inspect and reuse that exact object, skipping only duplicate creation. Still perform its membership/ACL/policy task. If its current state belongs to another exercise, restore the appropriate coordinated baseline rather than overwrite it.

## Required ordinary identities

Literal full names required by any dependent procedure take precedence over first-name-only references; use one object for each exact short logon, not duplicate users to satisfy different screenshots. For rows without a prescribed OU, the existing domain **Users** container is sufficient. Apply the explicitly selected per-lab OU lineage described below when a later exercise moves/reuses a fixture.

| Object/display name | Exact logon | Placement | Global memberships / attributes | Used by |
| --- | --- | --- | --- | --- |
| Bill Norman | Bill | OU=Marketing | Marketing; Department=Marketing | File access and [Group Policies Management](../Labs/Group-Policies-Management.md); literal full name also used by user-management reset tests. |
| Lara Raisic | Lara | OU=IT | IT; Department=IT; not Research | File serving/FSRM/RMS; helpdesk delegation and user-management membership tests. |
| Pia | Pia | OU=Managers | Managers; leave title blank/not Data Protection Manager | Finance audit/quota tests; DAC negative test with ordinary Managers access. |
| Ilga | Ilga | OU=Research | Research; Department=Research | RMS document owner/author. |
| Max Pennekamp | Max | OU=Research | Research; Department=Research | RMS Research positive test; literal full name used by the Pilot Users membership task. |
| Claire | Claire | OU=Research | Research; Department=Research | RDS/FSLogix and DAC Research user-claim positive test. |
| Milton | Milton | OU=Sales | Sales; Department=Sales, not Research | DAC Research-share negative test. |
| Harry Lawrence | Harry | OU=Managers | Managers; Department=Finance; leave title blank until DAC assigns it | DAC Finance positive test; exact full name is opened in AD Administrative Center. |
| Elise Hughes | Elise | OU=Marketing | Marketing; Department=Marketing; leave title blank until DAC assigns it | DAC Marketing positive test; title becomes Data Protection Manager in its task. |
| Teddy | Teddy | OU=Marketing | Marketing; Department=Marketing; title blank/not Data Protection Manager | DAC confidential Marketing-file negative test, ordinary Marketing-file positive test. |
| Ida Alksne | Ida | OU=IT | IT; Department=IT; not a privileged account | RODC allow-list, cache, compromise and password-reset tests; AD FS example sign-in. |
| Beth Burke | Beth | OU=IT | IT; Department=IT; no domain-wide administrator membership | Delegated RODC installation/sign-in after the RODC lab grants its specific delegation. |
| Logan Boyle | Logan | OU=IT | IT; Department=IT; no domain-wide administrator membership | Second member of the RODC delegated-administrator group. |
| Ada Russell | Ada | OU=Sales for helpdesk baseline; OU=Marketing for migration baseline | Sales or Marketing according to the recorded selected baseline; ordinary Domain Users | RDS/FSLogix uses the same Ada logon; delegation and migration require different OU placement as described below. |
| Boyd | Boyd | Users container | Domain Users only; no departmental requirement | RDS concurrent-session and FSLogix isolation tests. |
| Pam | Pam | OU=Sales | Sales; ordinary unprivileged user | AD FS/IIS example Windows-authentication sign-in. |
| Abbi Skinner | Abbi | OU=IT | IT; Department=IT | Hybrid synchronization and the delegated CL2-computer join fixture. Not Abbie Parsons. |

## Additional existing lookup targets

These rows are required by [Delegate password reset permissions](../Practices/Delegate-password-reset-permissions.md), [Manage domain users, groups and computers](../Labs/Manage-domain-users-groups-and-computers.md), and the named [Multi-domain environments](../Labs/Multi-domain-environments.md) verification tasks. For user-management rows with no required department/OU in the lookup, **Users** is a deliberate minimal staging container, not a claim about an absent classroom dataset. Set the exact first/surname and object/display name listed; the short logons below provide unique first-name fixture identities where that task uses name selection rather than an explicit different logon.

| Existing object/display name | Logon | Required placement / baseline condition |
| --- | --- | --- |
| Dante Dabney | Dante | OU=IT; IT group; helpdesk target. |
| Stefan Deboer | Stefan | OU=IT; IT group; helpdesk target. |
| Abbie Parsons | Abbie | OU=Sales; Sales group; password-reset target. Distinct from Abbi Skinner. |
| Colette Lichtenberg | Colette | Users; initial surname Lichtenberg, changed to Kendall in the rename task. |
| Evangelina Reeves | Evangelina | Users; initial surname Reeves, changed to Snow in the rename task. |
| Holly Spencer | Holly | Users; password-reset target. |
| Libby Hayward | Libby | Users; password-reset target. |
| Alfie Power | Alfie | Users; password-reset target. |
| Alyson Winters | Alyson | Users; later added to Project Managers. |
| Damian Hadden | Damian | Users; later added to Project Managers. |
| Isobel Wilkins | Isobel | Users; later added to Project Managers. |
| Peter Laamers | Peter | Users; later added to Project Managers. |
| Adam Hobbs | Adam | Users; later added to Data Protection Managers. |
| Mary Skinner | Mary | Users; later added to Data Protection Managers. |
| Huong Tang | Huong | Users; later added to Apprentices. |
| Huu Hoang | Huu | Users; later added to Apprentices. |
| Brigita Krastina | Brigita | Users; later added to Apprentices. |
| Doris David | Doris | Users; later added to Pilot Users. |
| Nestor Fiore | Nestor | Users; later added to Pilot Users. |
| Laura Atkins | Laura | Users; later added to Pilot Users. |
| Ella Perry | Ella | Users; later added to Pilot Users. |
| Erin Bull | Erin | Users; later added to Pilot Users. |
| Larry Rayford | Larry | Choose/record OU=IT among the six changed-UPN OUs; initial UPN Larry@ad.lab.test, changed by the Multi-domain task before its Larry@lab.test sign-in. |
| Anete Auzina | Anete | Source ad.lab.test OU=Development; Development group. The migration task creates the target identity Anete@ad.contoso.com; do not precreate that target user. |
| Zoja Bobanec | Zoja | Source ad.lab.test OU=Development; Development group; last named source selection endpoint for cross-forest migration. |
| Zan Kustrin | Zan | Source OU=Marketing; Marketing group; ordinary unprivileged last named source selection endpoint for within-forest migration. |

The helpdesk baseline requires **Ada Russell and Abbie Parsons in OU=Sales**, and **Dante Dabney, Ida Alksne, Lara Raisic and Stefan Deboer in OU=IT**. Its task creates the Helpdesk group and Sales-only reset delegation; do not grant that delegation beforehand. Manually create/record a separate ordinary negative-test user outside Sales (for example OU=Research), without preexisting delegated reset rights. Do not use an administrator as that negative subject.

The migration baseline instead requires Ada Russell under source **OU=Marketing**, and Development with its source group/users. Record Ada's original OU/memberships before the lab-scoped move or use a separate coordinated baseline; these are alternative states, not two Ada accounts with the same logon. Revert/reset the user-management name experiments before a dependent RODC lookup expects **Logan Boyle**: that task renames him to **Logan Stanley**. Likewise, restoring a password-reset baseline must not overwrite a live shared identity or an active cloud-sync dependency.

For [RMS](../Labs/Active-Directory-Rights-Management-Service.md), its Setup sets mail only on Ilga/Max/Lara and on the **IT** and **Research** global groups. Verify those attributes and refresh the relevant sign-in before the authorized/unauthorized/super-user comparison. Neither Lara nor the domain Administrator belongs to Research in this fixture.

For [DAC](../Labs/Dynamic-Access-Control.md), its task assigns **title=Data Protection Manager** to Harry and Elise; do not assign that title to Pia or Teddy. The device-claim task assigns **CL2.department=Research**; keep CL1's department absent/different for the negative device comparison. Do not preapply resource claims, central access policy or permissive ACLs that bypass the lesson.

For [hybrid synchronization](../Labs/Deploying-a-hybrid-cloud-model.md), the selected OUs are IT, Research and Sales. Change UPN suffixes only through the lab's verified tenant/domain task, record each original UPN, and verify Abbi's resulting synchronized identity before her client sign-in. Do not invent a tenant, purchase a domain, or place cloud credentials here.

## Entitling groups and private folders

Create/verify these exact **domain-local security groups** in **OU=Entitling Groups**. Use the manual membership/share/NTFS workflow in [Install prerequisites for file serving](../Practices/Install-prerequisites-for-file-serving.md) and [Manage file sharing](../Labs/Manage-file-sharing.md). Names include spaces; do not replace them with placeholder `IT-Users` names.

| Domain-local group | Initial global-group members |
| --- | --- |
| Finance Read | None initially |
| Finance Modify | Managers |
| IT Read | Managers |
| IT Modify | IT |
| Marketing Read | Sales, Managers |
| Marketing Modify | Marketing |

The file-serving practice prepares **D:\Shares\Users\User1** for quota tests with **Pia** allowed to modify that private folder; User1 is a folder name, not an instruction to create an AD user named User1. The later User11 folder is created during the quota exercise. Administrators retain recovery access; ordinary users do not gain access to other private home/profile containers.

## Objects created during their own exercises

Do not precreate these as ordinary users or skip their teaching tasks:

| Object | Creation/delegation task |
| --- | --- |
| SvcRMS and OU=Service Accounts | RMS Exercise 1 Task 1 creates the service user and its OU. No domain administrator membership; use the private password/service/database permissions documented there. |
| PSService / PowerShell Service, OU=Service accounts | Delegated managed service accounts Setup prepares this one manual service user and limited file/service-logon permissions. Its migrated dMSA is created in the lab; retain the original for supported rollback. |
| AdatumADFS$ | AD FS farm setup creates/reuses the genuine gMSA only after a valid replicated KDS key; never create a same-named ordinary user. |
| VNet3 RODC Administrators | RODC lab creates a domain-local group containing Beth Burke and Logan Boyle, then delegates only that RODC. |
| VNet3 RODC password replication allowed | RODC lab creates a domain-local group containing Ida and CL2, applies the allow-list and verifies actual cached accounts. Do not pre-cache other fixture users. |
| FSLogix Profile Users | FSLogix share task creates/uses the group with Ada, Boyd and Claire and verifies user-container isolation. |
| RD connection brokers / OU=Organizational Groups | RDS HA creates its security group with the actual VN2-SRV1/VN2-SRV2 computer accounts, not user lookalikes. |
| Witness Modify / Hyper-V Data Full Control | Cluster/S2D tasks create their permission groups and add the actual consuming computer accounts/CNOs at the correct phase. |
| Helpdesk | Password-reset delegation task creates its global group in IT and grants only the documented Sales reset permissions. |
| Project Managers / Data Protection Managers / Apprentices / Pilot Users | User-management lab creates these groups and Organizational Groups OU, populates the literal full-name members above, and deletes Pilot Users in its designated task. Group membership does not set the DAC title attribute. |
| Twelve new user-management users | The user-management lab's Task 1 creates its own twelve named rows; do not precreate them from this baseline inventory. |
| Wil Ruiz | Multi-domain lab creates this ordinary user in the isolated CONTOSO forest in its task; do not create a same-name ad.lab.test substitute. |

Do not fabricate computer accounts, SPNs or CNOs to satisfy a lookup. Obtain normal computer accounts through the documented domain join and cluster objects through the cluster task. Keep the existing lab Administrator for tasks explicitly requiring its privileges, separate from all ordinary test subjects. During cleanup remove only exercise-owned accounts/groups/attributes after no dependent lab needs them, restore recorded values/memberships, and preserve the coordinated AD lineage.
