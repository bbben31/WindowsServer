# Practice: Update the Active Directory schema

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/General/AD-DNS-Foundation.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Use the active core forest schema/infra masters; the enterprise DC-retirement lab is not a prerequisite. Confirm current schema version before adprep; a Windows Server 2025-created forest may already be current. Never downgrade or replay an upgrade unnecessarily. Before preparation, verify the AD RSAT module, recorded official media/drive, required Schema Admins/Enterprise Admins/Domain Admins rights and live schema/infrastructure FSMO reachability. Distinguish schema/forest and separately required domain preparation.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Lab Enterprise/Domain Administrator for the named forest/domain changes; Schema Admin only for schema extension. Local Administrator for guest setup. Remove temporary role membership afterward.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Record expected schema objectVersion, successful adprep native exits/logs and healthy replication, or a justified already-prepared skip.

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
1. Open **Terminal** as Administrator, with the Active Directory RSAT module installed.
1. Check the current schema before attempting an upgrade. If the forest already has the target schema, record its version and skip forest preparation; separately confirm whether domain preparation is already satisfied. Use a deliberately older supported forest for the actual schema-upgrade exercise; never downgrade a forest to replay it. Confirm the schema and infrastructure masters are reachable. Forest preparation requires Schema Admins/Enterprise Admins and Domain Admins in the schema master's domain; domain preparation requires Domain Admins.

    ````powershell
    Get-ADObject (Get-ADRootDSE).schemaNamingContext -Properties objectVersion |
        Select-Object objectVersion
    ````

    Windows Server 2025 uses schema objectVersion **91**; confirm the selected media and intended target using [Microsoft's schema-version table](https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/replication-error-8418). A forest already at that version does not need this schema extension. Schema preparation and domain preparation are distinct; record any separately required domain preparation instead of assuming objectVersion alone proves it.

1. Record the actual mounted ISO drive letter; it is not necessarily D:. Resolve adprep from that verified media.

    ````powershell
    Get-Volume | Where-Object DriveType -eq 'CD-ROM'
    $isoDrive = Read-Host 'Verified ISO drive letter, without colon'
    if ($isoDrive -notmatch '^[A-Za-z]$') { throw 'Enter one drive letter.' }
    $adprepPath = "$($isoDrive):\support\adprep\adprep.exe"
    if (!(Test-Path -LiteralPath $adprepPath -PathType Leaf)) { throw 'adprep was not found on the recorded ISO.' }
    ````

1. Prepare the forest only when its recorded schema requires an upgrade. Enter **c** when prompted, then require a successful exit and inspect the adprep log before continuing.

    ````powershell
    & $adprepPath /forestprep
    if ($LASTEXITCODE -ne 0) { throw "Forest preparation failed: $LASTEXITCODE" }
    ````

1. Wait for the forest preparation changes to replicate successfully to the infrastructure master and the remaining live controllers. Prepare each intended upgrade domain only when domain preparation is still required.

    ````powershell
    & $adprepPath /domainprep /gpprep
    if ($LASTEXITCODE -ne 0) { throw "Domain preparation failed: $LASTEXITCODE" }
    ````

1. Re-query schema objectVersion and record the expected value, successful adprep logs and replication health. A launched command or an unexplained native exit is not completion.

    ````powershell
    Get-ADObject (Get-ADRootDSE).schemaNamingContext -Properties objectVersion |
        Select-Object objectVersion
    repadmin.exe /replsummary
    ````

Perform these steps on the host.

1. In VMware Workstation, select CL1 and open **VM > Settings > CD/DVD**. Clear **Connected** and **Connect at power on** for the installation ISO; retain the original recorded device configuration.
