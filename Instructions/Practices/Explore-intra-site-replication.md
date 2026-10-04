# Practice: Explore intra-site replication

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Deploying-domain-controllers.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; conditional); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing).  Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Delegated AD/GPO rights for the named OU, account and policy changes; lab Domain Administrator only where the procedure requires it. Local Administrator for guest setup.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=true. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** repadmin output identifies the actual configured DC replication partners and converged replication; example output is not a VM requirement.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV5

If you did not complete the lab [Deploying domain controllers](../Labs/Deploying-domain-controllers.md), in addition to the VMs above, **VN1-SRV1** is required. If VN1-SRV1 is already shut down after the lab, do not start it.

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
