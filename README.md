# Windows Server self-learner lab

This repository is a self-paced adaptation of the Enterprise Training Center Windows Server curriculum. It preserves the original practices and labs, including Azure, identity, storage, networking, clustering, containers, Windows Admin Center, and hybrid-cloud topics, while removing instructor-only provisioning and credential workflows.

The baseline is **Windows Server 2025 Evaluation** and **Windows 11** running in **VMware Workstation Pro 17** on a **Windows 11** host with an **Intel Core i7-14700KF, 32 GB RAM, and 2 TB free storage**. Obtain the Windows Server 2025 Evaluation ISO and Windows 11 ISO from official Microsoft sources; do not commit media or keys. Windows Server 2022 can be substituted where a lab or product requirement calls for it. The labs are intentionally scalable: stage a small foundation first, then add, power on, and snapshot the machines and Azure resources named by each lab. Do not try to force the entire curriculum onto a three-VM environment.

## Start here

1. Read [learner setup](Instructions/General/Learner-Setup.md), including the safety and licensing notes.
2. Choose an [environment profile](Instructions/General/Environment-Profiles.md), then configure the [segmented VMware networks](Instructions/General/VMware-Segmented-Networking.md) before creating the foundation VMs.
3. Use the [curriculum index and dependency map](Instructions/General/Curriculum-Index.md) to choose a learning path.
4. Follow the [staged lab roadmap](Instructions/General/Staged-Lab-Roadmap.md), using the [base-image guide](Instructions/General/Base-Images-and-Templates.md) and [compatibility matrix](Instructions/General/Compatibility-Matrix.md).
5. Build the foundation topology, then follow the [Milestone C AD DS/DNS foundation runbook](Instructions/General/AD-DNS-Foundation.md) to establish `ad.lab.test`.
6. Follow the [Milestone D member-server and client runbook](Instructions/General/Member-Servers-and-Clients.md), validate the members, then use the [Milestone E core administration runbook](Instructions/General/Core-Windows-Administration.md).
7. Use the [Milestone F advanced infrastructure guide](Instructions/General/Advanced-Infrastructure.md) only for the selected storage, Hyper-V, RDS, clustering, deployment, or optional Linux/container topic.
8. Use the [Milestone G Azure and hybrid services guide](Instructions/General/Azure-Hybrid-Services.md) only after a budget, scope, permission, and cleanup plan is ready.
9. Use the [Milestone H optional and cost-gated guide](Instructions/General/Optional-Cost-Gated-Topics.md) for advanced or unsupported-by-default topics, and stop when the £10 cap or rollback boundary cannot be maintained.
10. Run the read-only preflight checker, resolve blockers and warnings, snapshot the stage, perform the lab, verify the result, and clean up.
11. Complete the practices before their dependent labs; each document names additional machines, roles, and Azure prerequisites.

## Scope and safety

This is a personal lab using an **existing Microsoft Azure for Students subscription** and **Microsoft Entra tenant**. The default Azure region is **UK South** and the hard monthly safety limit is **£10**. It never creates a dedicated tenant or provisions student tenants, users, invitations, passwords, or subscription resources for anyone else. Azure access is expected to be **Owner** or **User Access Administrator**; use narrower per-lab roles where possible. Never commit passwords, recovery codes, tenant IDs, subscription IDs, invitation URLs, exported certificates, private keys, or access tokens. Use placeholders such as `<AZURE_SUBSCRIPTION_ID>`, `<AZURE_TENANT_ID>`, `<AZURE_RESOURCE_GROUP>`, and `<AZURE_REGION>`; do not replace them with real values in documentation.

Some source procedures used instructor automation or shared classroom assets. The learner must now complete the linked prerequisite or the documented manual setup. A procedure must not depend on an unavailable helper script. Treat every script downloaded from the Internet as untrusted until its source and hash have been verified.

Advanced exercises intentionally preserve enterprise-scale addresses, additional forests, nested Hyper-V guests, and dedicated Azure resources. Use the [enterprise expansion profile](Instructions/General/Environment-Profiles.md#profile-2-enterprise-expansion) for those exercises. Keep it isolated from the `10.10.10.0/24`, `10.10.20.0/24`, and `10.10.30.0/24` core profile; do not mix profiles inside one snapshot lineage.

## VMware topology

Use host-only or custom VMware networks for isolated lab traffic, and add NAT only when a lab explicitly needs Internet access. The concrete Milestone A plan is:

| Segment | Example network | Purpose |
| --- | --- | --- |
| `VMnet10` | `10.10.10.0/24` | Management, AD, and DNS |
| `VMnet20` | `10.10.20.0/24` | Server workloads and optional storage/cluster traffic |
| `VMnet30` | `10.10.30.0/24` | Windows 11 clients |
| `VMnet8` | VMware NAT | Temporary, controlled outbound access |

Use the [Milestone A VMware runbook](Instructions/General/VMware-Segmented-Networking.md) to create these networks and host adapters. Reserve `10.10.10.10` for `VN1-SRV1` (AD DS/DNS), `10.10.10.11` for `VN1-SRV5` (second DC/DNS), `10.10.10.20` for `VN1-SRV4`, and `10.10.30.20` for `CL1` when using static client addressing. DHCP ranges, host adapter addresses, VMware NAT gateway values, and any overlapping home-network values are host-specific placeholders; do not copy them blindly.

Recommended recognizable names are `VN1-SRV1`, `VN1-SRV4`, `VN1-SRV5`, `VN2-SRV1`, `VN2-SRV2`, `VN1-SRV20`, `VN1-SRV21`, `CL1`, and `CL3`. Retain additional source names such as `PM-SRV*` and `WIN-*` when they identify distinct enterprise roles. The primary AD forest/domain is **`ad.lab.test`**; alternate forests exist only inside exercises that explicitly create them.

## Local VMware versus Azure

VMware Workstation Pro is the outer virtualization platform. Labs that teach the Windows Server Hyper-V role remain in the curriculum and may require nested virtualization; enable it only when needed and expect lower performance. Azure labs are limited by default to core services: VMs, storage, networking, Entra ID, Monitor, Arc, and Automation. Other source services remain documented as optional and cost-gated; do not enable them under the £10 limit without checking current pricing and obtaining an explicit decision. Use a dedicated resource group, budget alert, preflight dependency check, per-lab permissions, and cleanup checklist. Delete or deallocate cloud resources after each exercise and verify that the resource group is empty.

See [Instructor content mapping](Instructions/General/Instructor-Content-Mapping.md) for the safe single-learner material retained from the source prerequisites and the multi-student automation intentionally excluded.

## Contributing

Keep links relative to this repository, preserve the lab objective, and document any environment-specific value as a named placeholder. Do not add instructor provisioning, bulk-account creation, or credential-handling automation.

Regenerate and validate curriculum metadata before committing changes:

````powershell
.\tools\Update-CurriculumManifest.ps1
.\tools\Validate-Curriculum.ps1
git diff --exit-code -- metadata/curriculum-manifest.json
````

The same checks run automatically for pull requests and pushes to `main`.
