# Practice: Install prerequisites for file serving

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/General/Learner-Account-Fixtures.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. VN1-SRV10 has FS-FileServer and a recorded disposable NTFS D: data volume; manually prepare the exact global/domain-local groups, named users, least-privilege departmental ACLs and private Users\User1 test folder. Stage the reviewed sample helper on VN1-SRV10. Use licensed compatible desktop Office on CL2 for genuine XLSX/PPTX fixtures; without it record Office-dependent checks as blocked, not complete.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV2 (VMware display: VN1-SRV2; accepted display aliases: WIN-VN1-SRV2; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); CL2 (VMware display: CL2; accepted display aliases: WIN-CL2; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Authorized lab directory OU/user/global/domain-local group creation and membership rights for only the named disposable fixtures; Local Administrator on VN1-SRV10 for roles/volumes/shares/NTFS ACLs. Ordinary named nonadministrator users for positive/negative access tests; authorized staging administrator on CL2 for licensed Office fixture preparation.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Office-dependent tests require an authorized compatible desktop Office installation on CL2.

**Success verification:** Finance/IT/Marketing/Users shares and exact group ACLs match the named-user allowed/denied read/write matrix, not merely Administrator access. IT data exceeds 50 MB but fits within 75 MB; Travel Packages exceeds 100 MB; recorded old/recent expiration samples and valid Sheet1/Argumentum XLSX and named PPTX fixtures are ready.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10
* VN1-SRV2
* VN1-SRV4
* VN1-SRV5
* CL2

## Task

Prepare the file-serving environment manually for subsequent practices and labs. The source automation helper is intentionally not included in the learner edition.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Install [Remote Server Administration Tools](Install-Remote-Server-Administration-Tools.md) on CL1, including File Services/Server Manager, and add VN1-SRV10 to Server Manager. Verify remote management before using its share wizard.
1. Verify the **File Server (FS-FileServer)** role on VN1-SRV10 with `Get-WindowsFeature -ComputerName VN1-SRV10 -Name FS-FileServer`. If absent, follow [Install roles using Server Manager](Install-roles-using-Server-Manager.md) and wait for success.
1. Confirm `D:` is an **NTFS data volume**, not the OS disk, optical media or a cluster/iSCSI LUN. If it is absent, attach a blank VMware data disk in the powered-off file-server snapshot, record its guest unique ID, then initialize/partition/format only that recorded disk as NTFS D:. Use at least 10 GB for disposable file-serving data. Do not run the destructive storage-lab formatting tasks against existing shares.
1. Manually create/verify the global security groups **Managers**, **IT**, **Marketing**, **Sales** and their authorized disposable test users with Active Directory Users and Computers. Bill belongs to Marketing, Lara to IT, and Pia to Managers for the basic access matrix. Do not give these users administrator membership. Use [Learner account fixtures](../General/Learner-Account-Fixtures.md) for the selected exercise's additional RMS/DAC/delegation users and exact OU/group baseline; passwords are entered interactively and kept outside Git.
1. In the domain-root **Entitling Groups** OU, manually create/verify these **domain-local security groups**, using the exact names including spaces. Follow [Manage file sharing, Tasks 1–2](../Labs/Manage-file-sharing.md#task-1-create-an-organization-unit) for the creation workflow. If they exist, inspect scope/membership rather than recreate or overwrite them:

   | Group | Members |
   | --- | --- |
   | Finance Read | None initially |
   | Finance Modify | Managers |
   | IT Read | Managers |
   | IT Modify | IT |
   | Marketing Read | Sales, Managers |
   | Marketing Modify | Marketing |

1. Using Server Manager's remote Shares wizard, create **D:\Shares\Finance**, **IT**, **Marketing**, and **Users**, plus **D:\Shares\Users\User1**. For Finance/IT/Marketing, use the detailed [share/NTFS workflow](../Labs/Manage-file-sharing.md#task-3-create-shares-and-configure-file-system-and-share-permissions): preserve Administrators/SYSTEM/CREATOR OWNER NTFS entries; remove inherited broad Users access; grant the corresponding **Read** group NTFS Read & execute and share Read, and **Modify** group NTFS Modify and share Change. Grant local Administrators share Full Control. Enable access-based enumeration and remove Everyone. Do not substitute placeholder IT-Users groups.
1. For **Users**, retain administrator/SYSTEM access; grant **ad\Domain Users** share Change and NTFS Read & execute on **this folder only**. On **User1**, grant the intended quota-test user **ad\Pia** NTFS Modify on this folder/subfolders/files (administrators remain able to perform the documented copy tests). Do not grant ordinary users access to other users' private home folders.
1. Copy repository Resources to **C:\WindowsServerLab\Resources on VN1-SRV10** and run `Solutions\Initialize-SampleDocuments.ps1` there. It creates a 64 MB IT dataset, content-classification text, an offline-guide folder, old/recent expiration samples and 120 MB Travel Packages. Prepare the Office fixtures below, then manually copy the contents of each source department folder to its matching share. Keep Travel Packages in the source tree for quota tests, not in IT.
1. Verify Finance/IT/Marketing/Users using `Get-SmbShare -CimSession VN1-SRV10`, `Get-SmbShareAccess` on the server, and folder Security properties. On CL2, sign in separately as Bill, Lara and Pia and verify the access matrix in [Manage file sharing](../Labs/Manage-file-sharing.md#exercise-1-manage-file-shares-and-permissions), including denied shares and denied writes. Successful tests as Administrator do not prove test-user permissions.
1. Record **source IT total size >50 MB and <=75 MB**, Travel Packages **>100 MB**, and old/recent file timestamps before quota/expiration labs. Keep these disposable fixtures until dependent labs finish.

### Prepare valid Office fixtures

On **CL2**, use an authorized compatible desktop Office installation and an authorized lab administrator for staging to `\\VN1-SRV10\C$\WindowsServerLab\Resources\Sample Documents`. Do not install Office on Server Core or rename text files to Office extensions. If licensed Office is unavailable, retain the Office-dependent tests as blocked; the text/quota tests can still run, but this is not full completion.

1. In Excel, create a workbook with worksheet **Sheet1**, header **Argumentum** in A1, **Amount** in B1, and two disposable data rows. Save actual **Excel Workbook (.xlsx)** copies in the source Finance folder named **3 Month Snapshot.xlsx**, **6 Month Snapshot.xlsx**, and **Payroll.xlsx**. Include the word **payroll** in Payroll.xlsx for classification.
1. In PowerPoint, create a one-slide disposable presentation and save actual **PowerPoint Presentation (.pptx)** copies in the source Marketing folder named **Marketing With Partners.pptx**, **Building Partnerships.pptx**, and **Upcoming Campaign.pptx**. Include **vertraulich** in Upcoming Campaign.pptx for classification. Close all documents.
1. Verify every workbook/presentation opens without repair prompts, then copy these files to their matching Finance/Marketing shares. Verify Sheet1/Argumentum before the VSS edit/delete exercise. During the offline-files exercise, open only Marketing With Partners.pptx before disconnecting CL2; opening Building Partnerships.pptx first invalidates the expected uncached-file test.
