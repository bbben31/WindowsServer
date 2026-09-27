# Learner setup

This document replaces the instructor prerequisite workflow. It describes what one learner must prepare without creating accounts, tenants, or credentials automatically.

## Host and VMware Workstation Pro

The supported baseline for this edition is a **Windows 11** host, **VMware Workstation Pro 17**, **Intel Core i7-14700KF**, **32 GB RAM**, and approximately **2 TB of free storage**. These resources are sufficient for staged operation, not for running every VM simultaneously. Power on only the machines required by the current practice or lab; shut down and snapshot the rest.

* Use a supported Windows 10/11 host with enough CPU, RAM, and SSD space for the current lab. Storage-heavy, clustering, RDS, AD FS, and Storage Spaces Direct labs need substantially more resources than the foundation.
* Create VMware custom networks for `LAB-AD`, `LAB-SRV`, `LAB-STORAGE`, and `LAB-CLIENT`. Prefer host-only networks for isolated experiments. Add a NAT adapter only to a VM that needs updates or Azure access.
* Keep the VMware DHCP service disabled on the AD and server segments when Windows DHCP is being studied. On the client segment, either use Windows DHCP from the lab or VMware DHCP, never both.
* Enable CPU virtualization in firmware. Enable nested virtualization only for the Hyper-V, containers, or nested-lab exercises that need it.
* Store VM files under a host path you control, such as `D:\VMs\WindowsServerLab`, and use `C:\WindowsServerLab\Resources` inside the guest for ISOs and lab data. These are examples, not required paths.

Configure the VMnets and adapter placement using [VMware segmented networking](VMware-Segmented-Networking.md) before assigning static addresses or creating the AD forest. That guide is the source of truth for VMnet10/20/30, the optional NAT path, gateways, and DNS reachability.

## Media, licensing, and snapshots

Obtain the **Windows Server 2025 Evaluation ISO** and **Windows 10 ISO** from official Microsoft download pages. Server 2022 evaluation media is an optional substitution where a lab requires it. Do not commit ISO files or product keys. Evaluation editions have time limits; record the activation date and comply with the license terms.

Take a clean snapshot after OS installation, a second snapshot after VMware networking and updates, and a foundation snapshot after `ad.lab.test` is healthy. Never use snapshots as a backup for production data. Before destructive storage, schema, federation, or cluster exercises, export or copy only disposable lab data.

## Foundation build

Start with `VN1-SRV1` as the first domain controller and DNS server, `VN1-SRV4` as a management/server node, and `CL1` as the Windows 10 management client. Add `VN1-SRV5` as a second domain controller before practicing availability, replication, or upgrade scenarios. Add `VN1-SRV20`, `VN1-SRV21`, `CL3`, `VN2-SRV1`, `VN2-SRV2`, and lab-specific cluster/storage nodes only when the dependency map calls for them.

Use static addresses on domain controllers and infrastructure servers. Set the preferred DNS server on domain members to the AD DNS address, not to a public resolver. Create the forest/domain `ad.lab.test`; replace every example address with the address from your own plan. Verify forward and reverse name resolution before joining additional machines.

Create a small number of personal test accounts manually, with unique temporary passwords stored outside Git. Do not reuse a real Microsoft account password. For service-account, AD FS, RMS, or delegation practices, use disposable accounts and certificates issued only inside the lab.

## Azure and Microsoft Entra prerequisites

Use your **existing Microsoft Azure for Students subscription** and Microsoft Entra tenant; do not create a dedicated tenant for this curriculum. The default region is **UK South**. The hard monthly safety limit is **£10**, not a target to spend: configure a budget alert and spending notifications before creating anything, and stop if projected or actual charges could exceed it. You need Owner or User Access Administrator access for setup, but assign the minimum per-lab role after the resource group and policies exist. Record only placeholders in notes: `<AZURE_SUBSCRIPTION_ID>`, `<AZURE_TENANT_ID>`, `<AZURE_RESOURCE_GROUP>`, and `<AZURE_REGION>` (use `UK South` as the default region value, never a real identifier).

The default Azure scope is **core services only**: VMs, storage, networking, Entra ID, Monitor, Arc, and Automation. Other source services are optional and cost-gated; treat them as conceptual unless the current price, quota, and £10 impact are understood before provisioning. Before each Azure lab, check its dependencies, required providers, region/SKU availability, role assignments, quotas, estimated cost, and whether a public endpoint is necessary. Azure Arc, Azure File Sync, hybrid identity, Azure VM, and related labs may require a managed identity or a service principal created through the documented product flow; never create broad directory permissions by default. Read the current Microsoft documentation and each lab's prerequisites before provisioning. Never paste client secrets, certificates, access tokens, invitation links, tenant IDs, subscription IDs, or personal identifiers into Markdown, PowerShell history, or issue comments. Remove lab resources, role assignments, identities, and diagnostic data when the lab is complete, then verify the resource group is empty. Deallocate VMs; stopping an operating system is not always enough to stop billing.

The following source instructor actions are not prerequisites for a single learner and must not be reproduced: creating a tenant, bulk user creation, password or MFA resets, guest invitations, granting Global Administrator, or deleting a tenant. Use the existing tenant's own test identities and the least privilege required by the lab.

## Missing classroom automation

The instructor repository contained scripts and data for provisioning entire classes and handling student credentials. They are intentionally absent here. References to `C:\WindowsServerLab\Resources` identify where a learner may place personally reviewed installers, sample files, or a one-off helper script. If a lab references a source-only `Solutions` script, follow the surrounding GUI steps manually and create only the minimum disposable test data required for that lab.

## Reset and troubleshooting

Record the snapshot name, lab date, software versions, and any placeholder values used. If DNS, AD replication, time synchronization, or a cluster becomes inconsistent, stop dependent VMs, revert only the disposable lab machines to a known-good snapshot, and revalidate the foundation before continuing.
