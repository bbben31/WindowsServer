# Staged self-learner lab roadmap

Build only the stage you need. Keep the previous stage powered off but snapshotted when resources are constrained. Every stage uses VMware Workstation Pro 17, the `VMnet10` management/AD network (`10.10.10.0/24`), `VMnet20` server network (`10.10.20.0/24`), and `VMnet30` client network (`10.10.30.0/24`) as described in [segmented networking](VMware-Segmented-Networking.md). Azure stages use the existing Microsoft Azure for Students subscription in UK South, with a hard £10 monthly safety limit.

Before each stage, run the [read-only preflight checker](../../tools/Preflight-LearnerLab.ps1), resolve blockers, create the named checkpoint, perform the work, verify the expected state, and clean up. Labs marked **extra capacity** need additional VMs, disks, or Azure resources; do not infer that the low profile can run them.

## Stage A — Host and VMware network foundation

**Objective:** Establish an isolated, repeatable VMware environment.

**Prerequisites:** Windows 11 host, VMware Workstation Pro 17, Intel Core i7-14700KF, 32 GB RAM, 2 TB free storage, and official Windows media.

**VMs/networks:** No guest is required initially. Create VMnet10, VMnet20, VMnet30, and optional VMnet8 NAT. Confirm host VMware adapters and avoid bridged networking.

**Practices/labs:** Read [Learner setup](Learner-Setup.md) and complete [VMware segmented networking](VMware-Segmented-Networking.md).

**Verification:** `Get-NetAdapter`; `Get-NetIPConfiguration`; `Get-NetRoute -AddressFamily IPv4`; run preflight without Azure parameters.

**Expected state:** The three isolated VMnets exist, DHCP is enabled only where chosen, and no isolated segment has an unintended default gateway.

**Checkpoint:** `A-network-foundation`.

**Rollback and cleanup:** Remove only unneeded VMnet definitions after recording the address plan. Do not reset the host network broadly. Keep the network design documented before proceeding.

## Stage B — Base Windows images and templates

**Objective:** Create clean, reusable Windows Server 2025 Evaluation and Windows 10 base images.

**Prerequisites:** Stage A and official Windows Server 2025 Evaluation ISO plus Windows 10 ISO.

**VMs/networks:** One temporary Server VM and one temporary Windows 10 VM, disconnected from the domain. Use VMnet10 for management and VMnet8 only for controlled updates.

**Practices/labs:** [Install Windows Server manually](../Practices/Install-Windows-Server-manually.md), [Install Windows Server with Desktop Experience manually](../Practices/Install-Windows-Server-with-Desktop-Experience-manually.md), and [Create and install a virtual machine](../Practices/Create-and-install-a-virtual-machine.md). Follow the full [Milestone B base-image runbook](Base-Images-and-Templates.md).

**Verification:** `winver`; `Get-ComputerInfo`; `Get-WindowsFeature`; `Get-NetIPConfiguration`; run preflight with ISO paths.

**Expected state:** Clean, updated, VMware Tools-equipped, non-domain-joined templates exist with documented snapshots and no personal data or secrets.

**Checkpoint:** `B-clean-base-images`.

**Rollback and cleanup:** Revert to the clean template snapshot if customization becomes inconsistent. Do not generalize or clone domain controllers, certificates, or identity-bearing machines.

## Stage C — AD DS and DNS foundation

**Objective:** Build the disposable `ad.lab.test` forest and reliable DNS foundation.

**Prerequisites:** Stages A-B; one Server 2025 template; static address plan.

**VMs/networks:** `VN1-SRV1` at `10.10.10.10/24` on VMnet10; optional `VN1-SRV5` at `10.10.10.11/24` after the first controller is healthy. No public DNS on the domain NIC.

**Practices/labs:** Follow the [Milestone C AD DS/DNS foundation runbook](AD-DNS-Foundation.md), then use [Configure AD DS as a new forest](Configuring-Active-Directory-Domain-Services-as-a-new-forest.md), [Configure AD DS as an additional domain controller](Configuring-Active-Directory-Domain-Services-as-an-additional-domain-controller.md), and [Deploying domain controllers](../Labs/Deploying-domain-controllers.md) for the source-aligned detail.

**Verification:** `Resolve-DnsName ad.lab.test -Server 10.10.10.10`; `dcdiag /test:dns /v`; `repadmin /replsummary` when a second controller exists.

**Expected state:** `ad.lab.test` resolves, the first controller is authoritative for DNS, and the optional second controller replicates.

**Checkpoint:** `C-ad-dns-foundation`.

**Rollback and cleanup:** Stop dependent VMs before reverting. Revert the disposable forest only as a unit; never restore an old domain-controller snapshot into a changed production domain.

## Stage D — Member servers and clients

**Objective:** Join management, server, and client machines to the foundation.

**Prerequisites:** Stage C and healthy DNS.

**VMs/networks:** `VN1-SRV4` on VMnet10 with optional VMnet20; `CL1` on VMnet30; add `VN1-SRV5`, `VN1-SRV20`, `VN1-SRV21`, or `CL3` only when a lab requires them.

**Practices/labs:** Follow the [Milestone D member-server and client runbook](Member-Servers-and-Clients.md), then use [Join Windows 11 to a local AD domain](Joining-Windows-11-to-a-local-Active-Directory-domain.md), [Adding servers to Server Manager](Adding-servers-to-Server-Manager.md), and [Manage domain users, groups, and computers](../Labs/Manage-domain-users-groups-and-computers.md).

**Verification:** `Test-NetConnection 10.10.10.10 -Port 53`; `whoami /fqdn`; `Get-ComputerInfo`; `Resolve-DnsName _ldap._tcp.ad.lab.test`.

**Expected state:** Required members resolve the domain and can be managed without public DNS on the domain NIC.

**Checkpoint:** `D-members-and-clients`.

**Rollback and cleanup:** Remove a failed member from the domain before deleting it. Revert only disposable members; preserve the healthy AD foundation snapshot.

## Stage E — Core Windows administration

**Objective:** Establish everyday administration skills before advanced infrastructure.

**Prerequisites:** Stage D.

**VMs/networks:** `VN1-SRV4`, `CL1`, and the minimum member servers named by each practice. Use VMnet10 for management and VMnet30 for clients.

**Practices/labs:** Follow the [Milestone E core Windows administration runbook](Core-Windows-Administration.md), then complete the mapped practices and core labs under administration, DNS, DHCP, Group Policy, file sharing, Windows Admin Center, monitoring, and update services in the [curriculum index](Curriculum-Index.md).

**Verification:** Use preflight with supplied VM names and DNS; run `Get-WinEvent`, `Get-Service`, `Get-SmbShare`, `Get-DnsServerZone`, or the verification commands documented by the selected procedure.

**Expected state:** You can administer the selected members, resolve names, and verify role state without classroom automation.

**Checkpoint:** `E-core-administration`.

**Rollback and cleanup:** Snapshot before role changes. Remove temporary shares, test users, scheduled tasks, and downloaded installers after verification.

## Stage F — Storage, Hyper-V, RDS, and advanced infrastructure

**Objective:** Practice advanced local Windows Server capabilities.

**Prerequisites:** Stage E and the selected lab's manifest entry.

**VMs/networks:** **Extra capacity:** clusters, Storage Spaces Direct, Storage Replica, iSCSI, RDS high availability, AD FS, RMS, deployment services, and nested Hyper-V may require several additional VMs, disks, certificates, or VMnet20/30 paths.

**Practices/labs:** Follow the [Milestone F advanced infrastructure guide](Advanced-Infrastructure.md), then select the relevant practices/Labs entries in the manifest; do not combine unrelated advanced stacks without sufficient RAM and storage.

**Verification:** Use the lab's documented checks plus `Get-Cluster`, `Get-Volume`, `Get-IscsiSession`, `Get-WindowsFeature`, or preflight where applicable.

**Expected state:** The selected disposable topology reaches the lab's documented success condition.

**Checkpoint:** `F-advanced-local-infrastructure-<lab>`.

**Rollback and cleanup:** Snapshot every node and data disk before changes. Destroy or revert only disposable clusters and remove certificates, shares, disks, and nested guests after verification.

## Stage G — Azure and hybrid services

**Objective:** Connect selected local learning objectives to Azure core services.

**Prerequisites:** Stage E, an existing Entra tenant and Azure for Students subscription, UK South availability, budget alert, and explicit permissions.

**VMs/networks:** Use only the local VMs and outbound VMnet8 NICs required by the selected lab. **Extra capacity:** Azure VMs, Arc, File Sync, Monitor, Automation, and storage may incur costs or require additional resources.

**Practices/labs:** Follow the [Milestone G Azure and hybrid services guide](Azure-Hybrid-Services.md), then filter the manifest for `azure.required=true`; examples include [Add server to Azure Arc](../Practices/Add-server-to-Azure-Arc.md), [Register Windows Admin Center with Azure](../Practices/Register-Windows-Admin-Center-with-Azure.md), and [Managing hybrid servers using Azure Arc](../Labs/Managing-hybrid-servers-using-Azure-Arc.md).

**Verification:** Run preflight with explicit placeholders and `az account show` only when the CLI context already exists. Verify the service-specific state documented by the lab.

**Expected state:** Only the selected resources exist in the lab resource group, with least-privilege access and known cost.

**Checkpoint:** `G-azure-<lab>`.

**Rollback and cleanup:** Deallocate VMs, remove disposable resources, identities, role assignments, and diagnostic data, and verify the resource group is empty. Stop if the £10 safety limit is at risk.

## Stage H — Optional and cost-gated topics

**Objective:** Explore source topics that are not part of the core low-cost path.

**Prerequisites:** All relevant earlier stages, current pricing/quota review, and an explicit decision that the topic fits the £10 safety limit.

**VMs/networks:** **Extra capacity:** use the manifest's topology and `TBD` values where source evidence is insufficient. Keep optional services isolated from the core foundation.

**Practices/labs:** Follow the [Milestone H optional and cost-gated guide](Optional-Cost-Gated-Topics.md), then filter the manifest for `compatibility.optional=true` or `riskCost.cost=cost-gated`.

**Verification:** Use the H decision workflow: preflight, budget/quota/permission check, snapshot/backup, lab, verify, deallocate/delete, inventory check, and private outcome record.

**Expected state:** The optional experiment is complete, documented, and removable without affecting the core foundation.

**Checkpoint:** `H-optional-<lab>`.

**Rollback and cleanup:** Delete/deallocate all optional cloud and local resources, confirm no recurring charges or assignments remain, and retain only the notes and final verification.
