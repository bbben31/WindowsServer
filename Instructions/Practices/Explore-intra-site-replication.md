# Practice: Explore intra-site replication

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Deploying-domain-controllers.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; conditional until retired; supply the guest or explicitly confirm retirement with -RetiredVmName); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing). Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments. Temporary VMnet8 NAT on CL1 only for Windows Update RSAT capability installation; preserve the AD NIC/DNS and disconnect after setup.

**Permissions:** Delegated AD/GPO rights for the named OU, account and policy changes; lab Domain Administrator only where the procedure requires it. Local Administrator for guest setup.

**Outbound access:** Windows Update downloads Windows 11 RSAT Features on Demand on CL1 during the documented setup/fallback. Before installing capabilities, attach a temporary second VMware NIC to VMnet8 NAT; retain the AD NIC and its AD DNS, disable DNS registration on the NAT NIC, and record adapters/routes/DNS. Disconnect VMnet8 immediately after installation. If the required tools are already installed, the download step needs no outbound access. Endpoints: *.windowsupdate.com (Windows Update service/content); *.update.microsoft.com (Microsoft Update service); *.delivery.mp.microsoft.com (Windows Update delivery); https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-security (current service endpoint guidance).

**Risk, cost and optional status:** high; local-only; optional=true. Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware. Verify current support for optional products before execution.

**Success verification:** repadmin output identifies the actual configured DC replication partners and converged replication; example output is not a VM requirement.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Disconnect the temporary VMnet8 NIC after capability installation and restore recorded adapters/routes/DNS; retain installed RSAT until dependent exercises finish.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV5
* Conditional until retired: VN1-SRV1

> **Conditional controller lifecycle:** Supply VN1-SRV1 while it remains the active original controller. After its documented retirement, confirm that VN1-SRV5 serves the original DNS address and the required directory roles, then pass `-RetiredVmName VN1-SRV1` to preflight; never restart a retired controller. Retirement requires the completed address/role handover, not merely completing controller promotion or switching off a guest. Steps concerning the retired server apply only to recorded historical state or removal of its stale directory objects.

## Setup

If you skipped the practice [Install Remote Server Administration Tools](Install-Remote-Server-Administration-Tools.md), on **CL1**, in **Terminal**, execute ````C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1````.

If you did not deploy additional domain controllers and domains in the previous labs, the results of this practice may be limited.

## Task

Explore the automatically created connection objects and write a documentation of the replication topology for each naming context.

## Instructions

Perform these steps on CL1.

1. Sign in as **Administrator@ad.lab.test**.
1. Open **Active Directory Sites and Services**.
1. Expand **Default-First-Site-Name** and **Servers**.
1. For each server, do the following:

    1. Expand the server and click **NTDS Settings**.
    1. Double-click each connection object.
    1. In \<automatically generated\> Properties, take a note of the following properties to fill a table like the example shown below:

        * Under **Replicate from** the property **Server**
        * **Replicated Naming Context(s)** (move the text cursor to the end of the text field, to see all naming contexts)
        * **Partially Replicated Naming Context(s)**

        | Naming context               | Partial | From server | To server |
        | ---------------------------- | ------- | ----------- | --------- |
        | ForestDnsZones.ad.lab.test |         | PM-SRV1     | VN1-SRV5  |
        |                              |         | VN2-SRV1    | VN2-SRV5  |
        |                              |         | PM-SRV1     | VN1-SRV7  |
        |                              |         | VN2-SRV1    | VN1-SRV7  |
        |                              |         | VN1-SRV7    | VN2-SRV1  |
        |                              |         | VN1-SRV5    | VN2-SRV1  |
        |                              |         | VN1-SRV5    | PM-SRV1   |
        |                              |         | VN1-SRV7    | PM-SRV1   |
        | DomainDnsZones.ad.lab.test |         | VN2-SRV1    | VN1-SRV5  |
        |                              |         | VN1-SRV5    | VN2-SRV1  |
        | ad.lab.test                |         | VN2-SRV1    | VN2-SRV5  |
        |                              |         | VN1-SRV5    | VN2-SRV1  |
        | Schema                       |         | PM-SRV1     | VN1-SRV5  |
        |                              |         | VN2-SRV1    | VN2-SRV5  |
        |                              |         | PM-SRV1     | VN1-SRV7  |
        |                              |         | VN2-SRV1    | VN1-SRV7  |
        |                              |         | VN1-SRV7    | VN2-SRV1  |
        |                              |         | VN1-SRV5    | VN2-SRV1  |
        |                              |         | VN1-SRV5    | PM-SRV1   |
        |                              |         | VN1-SRV7    | PM-SRV1   |
        | Configuration                |         | PM-SRV1     | VN1-SRV5  |
        |                              |         | VN2-SRV1    | VN2-SRV5  |
        |                              |         | PM-SRV1     | VN1-SRV7  |
        |                              |         | VN2-SRV1    | VN1-SRV7  |
        |                              |         | VN1-SRV7    | VN2-SRV1  |
        |                              |         | VN1-SRV5    | VN2-SRV1  |
        |                              |         | VN1-SRV5    | PM-SRV1   |
        |                              |         | VN1-SRV7    | PM-SRV1   |
        | All other domains            | Yes     | PM-SRV1     | VN1-SRV5  |
        |                              |         | VN2-SRV1    | VN2-SRV5  |
        |                              |         | PM-SRV1     | VN1-SRV7  |
        |                              |         | VN2-SRV1    | VN1-SRV7  |
        |                              |         | VN1-SRV7    | VN2-SRV1  |
        |                              |         | VN1-SRV5    | VN2-SRV1  |
        |                              |         | VN1-SRV5    | PM-SRV1   |
        |                              |         | VN1-SRV7    | PM-SRV1   |

        > Why are there so my connection objects for ForestDnsZones, Schema, Configuration, and all other domains, while there are only two for DomainDnsZones and ad.lab.test?

    1. If time permits, draw a diagram of the replication topology for each naming context.
