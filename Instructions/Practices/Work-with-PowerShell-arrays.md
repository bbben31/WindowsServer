# Practice: Work with PowerShell arrays

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV2 (VMware display: VN1-SRV2; accepted display aliases: WIN-VN1-SRV2; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Standard lab user for local read-only queries and user-owned files; no local elevation. If the explicitly documented system-help prerequisite is selected under Windows PowerShell 5.1, use a separate authorized elevated session.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The displayed array indexing, count and loop results match the expected values in the procedure.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10
* VN1-SRV2
* VN1-SRV4
* VN1-SRV5

## Task

On CL1, query the running services on VN1-SRV1, VN1-SRV2, VN1-SRV4, VN1-SRV5, VN1-SRV10 with a single command using iteration.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. From the context-menu of **Start** (you can press WIN + X), launch **Terminal** as Administrator.
1. Store the strings VN1-SRV1, VN1-SRV4, VN1-SRV10, VN1-SRV5, VN1-SRV2 in the variable $servers.

    ````powershell
    $servers = @('VN1-SRV1', 'VN1-SRV2', 'VN1-SRV4', 'VN1-SRV5', 'VN1-SRV10')
    ````

1. Iterate through the array $servers and list the running services on each of the servers while measuring the executing time

    ````powershell
    Measure-Command {
        $servers | 
        ForEach-Object { 
            Get-Service -ComputerName $PSItem | 
            Where-Object { 
                $PSItem.Status -eq 'Running' 
            }
        } |
        Out-Default
    }
    ````

    Note: Get-Service may fail on some of the servers. This is no problem for this practice, but shows, that the iteration worked.

1. List the services on the computers in $array without iteration while measuring the execution time.

    ````powershell
    Measure-Command {
        Get-Service -ComputerName $servers | 
        Where-Object { 
            $PSItem.Status -eq 'Running' 
        } |
        Out-Default
    }
    ````

Note: Iteration takes more time, but sometimes it is necessary, because not all parameters accept arrays as values.
