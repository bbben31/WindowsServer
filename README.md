# Windows Server self-learner lab

This repository is a self-paced adaptation of the Enterprise Training Center Windows Server curriculum. It preserves the original practices and labs, including Azure, identity, storage, networking, clustering, containers, Windows Admin Center, and hybrid-cloud topics, while removing instructor-only provisioning and credential workflows.

The baseline is **Windows Server 2025 Evaluation** and **Windows 10** running in **VMware Workstation Pro 17** on a **Windows 11** host with an **Intel Core i7-14700KF, 32 GB RAM, and 2 TB free storage**. Obtain the Windows Server 2025 Evaluation ISO and Windows 10 ISO from official Microsoft sources; do not commit media or keys. Windows Server 2022 can be substituted where a lab or product requirement calls for it. The labs are intentionally scalable: stage a small foundation first, then add, power on, and snapshot the machines and Azure resources named by each lab. Do not try to force the entire curriculum onto a three-VM environment.

## Start here

1. Read [learner setup](Instructions/General/Learner-Setup.md), including the safety and licensing notes.
2. Use the [curriculum index and dependency map](Instructions/General/Curriculum-Index.md) to choose a learning path.
3. Build the foundation topology, create snapshots, and establish `ad.lab.test`.
4. Complete the practices before their dependent labs; each document names additional machines, roles, and Azure prerequisites.

## Scope and safety

This is a personal lab using an **existing Microsoft Azure for Students subscription** and **Microsoft Entra tenant**. The default Azure region is **UK South** and the hard monthly safety limit is **£10**. It never creates a dedicated tenant or provisions student tenants, users, invitations, passwords, or subscription resources for anyone else. Azure access is expected to be **Owner** or **User Access Administrator**; use narrower per-lab roles where possible. Never commit passwords, recovery codes, tenant IDs, subscription IDs, invitation URLs, exported certificates, private keys, or access tokens. Use placeholders such as `<AZURE_SUBSCRIPTION_ID>`, `<AZURE_TENANT_ID>`, `<AZURE_RESOURCE_GROUP>`, and `<AZURE_REGION>`; do not replace them with real values in documentation.

Some source procedures refer to instructor automation or shared classroom assets. Those assets were deliberately not copied. Paths were normalized to `C:\WindowsServerLab\Resources` as a learner-controlled working directory; when a procedure names a missing automation script, perform the documented GUI task manually or replace it with your own reviewed local script. Treat every script downloaded from the Internet as untrusted until inspected.

## VMware topology

Use host-only or custom VMware networks for isolated lab traffic, and add NAT only when a lab explicitly needs Internet access. A practical scalable starting point is:

| Segment | Example network | Purpose |
| --- | --- | --- |
| `LAB-AD` | `192.168.50.0/24` | Domain, DNS, DHCP, management |
| `LAB-SRV` | `192.168.60.0/24` | Server and cluster traffic |
| `LAB-STORAGE` | `192.168.70.0/24` | iSCSI, CSV, Storage Replica, or SMB |
| `LAB-CLIENT` | `192.168.80.0/24` | Windows 10 clients and test users |
| `LAB-AZURE` | NAT/Internet | Azure Arc, Azure Stack HCI-related, and cloud exercises |

Use one private, documented address plan rather than copying classroom addresses. Reserve `.10-.49` for infrastructure, `.50-.199` for servers, and `.200-.249` for clients. The first domain controller can be `192.168.50.10`, the second `192.168.50.11`, and the client can use DHCP or a reserved address. Change these examples consistently if they overlap with the host or home network.

Recommended recognizable names are `VN1-SRV1`, `VN1-SRV4`, `VN1-SRV5`, `VN2-SRV1`, `VN2-SRV2`, `VN1-SRV20`, `VN1-SRV21`, `CL1`, and `CL3`. Use additional names from each lab (for example cluster, storage, RDS, or Azure Arc nodes) when that lab requires them. The AD forest/domain for this repository is **`ad.lab.test`**.

## Local VMware versus Azure

VMware Workstation Pro is the outer virtualization platform. Labs that teach the Windows Server Hyper-V role remain in the curriculum and may require nested virtualization; enable it only when needed and expect lower performance. Azure labs are limited by default to core services: VMs, storage, networking, Entra ID, Monitor, Arc, and Automation. Other source services remain documented as optional and cost-gated; do not enable them under the £10 limit without checking current pricing and obtaining an explicit decision. Use a dedicated resource group, budget alert, preflight dependency check, per-lab permissions, and cleanup checklist. Delete or deallocate cloud resources after each exercise and verify that the resource group is empty.

See [Instructor content mapping](Instructions/General/Instructor-Content-Mapping.md) for the safe single-learner material retained from the source prerequisites and the multi-student automation intentionally excluded.

## Contributing

Keep links relative to this repository, preserve the lab objective, and document any environment-specific value as a named placeholder. Do not add instructor provisioning, bulk-account creation, or credential-handling automation.
