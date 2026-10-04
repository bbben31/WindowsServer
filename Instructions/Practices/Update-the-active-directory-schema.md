# Practice: Update the Active Directory schema

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Deploying-domain-controllers.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Lab Enterprise/Domain Administrator for the named forest/domain changes; Schema Admin only for schema extension. Local Administrator for guest setup. Remove temporary role membership afterward.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Schema version and replication reflect the intended upgrade; preserve the coordinated forest backup for recovery.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1

## Task

On CL1, update the Active Directory schema to the current version.

## Instructions

Perform these steps on the host.

1. This is an advanced, dedicated operation. Take a full backup/snapshot of the forest and do not use a snapshot as the only rollback mechanism after schema changes.
1. In VMware Workstation, open the CL1 VM settings, attach the verified Windows Server 2025 Evaluation ISO from `C:\WindowsServerLab\ISOs\<WINDOWS_SERVER_2025_EVALUATION_ISO>` to the virtual CD/DVD drive, and mount it in the guest.

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Terminal**.
1. Prepare the forest for the latest version of Windows Server.

    ````powershell
    D:\support\adprep\adprep.exe /forestprep
    ````

1. Enter **c** to continue.
1. Prepare the domain for the latest version of Windows Server.

    ````powershell
    D:\support\adprep\adprep.exe /domainprep /gpprep
    ````

Perform these steps on the host.

1. In the menu of **"WIN-CL1" on "..." - Connection to virtual computer**, click **Media**, **DVD Drive**, **Eject "2025_x64_EN_Eval.iso"**.
