# Practice: Verify the SYSVOL replication mode

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Deploying-domain-controllers.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; conditional); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Delegated AD/GPO rights for the named OU, account and policy changes; lab Domain Administrator only where the procedure requires it. Local Administrator for guest setup.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** dfsrmig/repadmin show the actual SYSVOL replication state and consistent results on the declared DCs.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV5

If you did not complete the lab [Deploying domain controllers](../Labs/Deploying-domain-controllers.md), in addition to the VMs above, **VN1-SRV1** is required. If VN1-SRV1 is already shut down after the lab, do not start it.

## Setup

You must have completed the lab [Deploying domain controllers](../Labs/Deploying-domain-controllers.md). If you skipped the lab, VM **VN1-SRV1** is required. In step 3 replace **VN1-SRV5** with **VN1-SRV1**.

## Task

Verify that SYSVOL is replicated using DFSR.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Open **Terminal**.
1. Open a remote PowerShell session to VN1-SRV5.

    ````powershell
    Enter-PSSession -ComputerName VN1-SRV5
    ````

1. Get the global SYSVOL replication migration status.

    ````powershell
    dfsrmig /getglobalstate
    ````

    This should return the global state 'Eliminated'.

1. Exit the remote PowerShell session.

    ````powershell
    Exit-PSSession
    ````
