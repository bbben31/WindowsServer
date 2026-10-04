# Practice: Install prerequisites for file serving

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV2 (VMware display: VN1-SRV2; accepted display aliases: WIN-VN1-SRV2; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing).  Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** The required file-server role, volumes, sample data, Users/IT/Finance/Marketing shares and test ACLs exist.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10
* VN1-SRV2
* VN1-SRV4
* VN1-SRV5

## Task

Prepare the file-serving environment manually for subsequent practices and labs. The source automation helper is intentionally not included in the learner edition.

> Note: If you receive an error message, that Windows Admin Center cannot be installed, you can safely ignore it.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. On **VN1-SRV10**, confirm that `D:` is the intended data volume. Create these downstream folders:
   * `D:\Shares\IT`
   * `D:\Shares\Users`
   * `D:\Shares\Finance`
1. Create shares named **IT**, **Users**, and **Finance** using Server Manager or the documented file-serving practice. Use placeholder domain groups such as `ad\IT-Users`, `ad\Users-Users`, and `ad\Finance-Users` only after you have created or verified the corresponding groups manually. Apply least-privilege share and NTFS permissions; do not copy permissions from an unreviewed script.
1. From CL1, verify the concrete shares with `Test-Path \\VN1-SRV10\IT`, `Test-Path \\VN1-SRV10\Users`, `Test-Path \\VN1-SRV10\Finance`, and `Get-SmbShare -CimSession VN1-SRV10`.
1. Record the manual choices privately; do not create accounts, permissions, or shares from an unreviewed script.
