# Milestone H: optional and cost-gated topics

Milestone H is the final stage and is not part of the default three-VM or 32 GB host profile. It governs source topics that need extra VMs, disks, certificates, cloud services, elevated permissions, specialist licensing, or support validation. A topic may remain conceptual: that still preserves the learning objective without creating an unsafe or unbounded environment.

The hard Azure safety limit is **£10 per month**. It is a stop limit, not a target. Do not start a topic when its total cost, quota, cleanup, or support status cannot be bounded. Use the existing Entra tenant and Azure for Students subscription in **UK South** only. Use placeholders such as `<AZURE_SUBSCRIPTION_ID>`, `<AZURE_TENANT_ID>`, `<AZURE_RESOURCE_GROUP>`, `<AZURE_REGION>`, `<CERTIFICATE_TEMPLATE>`, and `<WITNESS_PATH>`.

## Decision workflow and go/no-go gate

For one selected topic, complete these steps in order:

1. **Preflight:** run the [read-only preflight checker](../../tools/Preflight-LearnerLab.ps1) with only the relevant VM names, ISO paths, subnet, DNS, and explicit Azure placeholders.
2. **Budget/quota/permission check:** verify current Azure cost, £10 headroom, UK South service/SKU availability, quota, required providers, and least-privilege role assignments. Confirm local CPU, RAM, storage, disks, and network capacity.
3. **Snapshot/backup:** snapshot disposable VMs and export/copy only disposable data. Use a supported backup or export for any data that must survive. Do not rely on snapshots for AD, clustered, replicated, PKI, or database state.
4. **Go/no-go:** proceed only when the objective, topology, support/licensing boundary, rollback, and cleanup owner are written in private notes. Stop when any value is `TBD` and cannot be resolved from current product documentation.
5. **Lab:** perform only the linked source procedure and only against disposable resources. Never broaden scope to the whole tenant, subscription, forest, or physical network.
6. **Verify:** run the source lab checks plus the read-only commands below. Record success/failure without secrets or identifiers.
7. **Deallocate/delete:** remove cloud resources, role assignments, identities, certificates, agents, data, VMs, disks, and public endpoints in the supported order. Deallocate is not deletion and may not stop all charges.
8. **Inventory check:** list the resource group and local VMs/disks, confirm no unexpected resources or recurring services remain, and verify the £10 limit is not at risk.
9. **Record outcome:** note the topic, date, product versions, checkpoint, result, cleanup result, and unresolved `TBD` items privately.

**No-go conditions:** unknown cost, no cleanup path, unsupported nested/cluster topology, missing quorum or witness, public endpoint required without a justified boundary, broad directory permission requirement, unverified certificate/private-key handling, or any request for instructor-style bulk accounts, invitations, password resets, tenant creation, or tenant deletion.

## Classification matrix

| Category | Objective | Class / estimated cost | Typical prerequisites and resources | Primary risk |
| --- | --- | --- | --- | --- |
| Azure managed databases and data services | Compare managed data platforms with local Windows administration | Cost-gated, **TBD** price | Existing subscription, region/SKU/quota check, dedicated resource group, service-specific permissions | Recurring compute, storage, backup, and transaction charges |
| Hosted compute, containers, AKS, and serverless | Understand cloud hosting and orchestration | Cost-gated/dedicated, **TBD** | VNet/subnets, registry/images, quotas, multiple nodes for AKS, current support matrix | Cluster/node and egress costs; privileged access |
| AI, search, and advanced Azure services | Explore source AI/search/automation concepts | Optional/cost-gated, **TBD** | Service availability, model quota, data classification, API permissions | Token/index/storage charges and sensitive data exposure |
| Multi-region and disaster recovery | Practice recovery objectives and failover design | Dedicated/cost-gated, **TBD** | Two supported regions, duplicated resources, backup/replication, documented RPO/RTO | Cost multiplication and destructive failover |
| PKI, certificates, AD CS, AD FS/federation | Learn trust, certificate lifecycle, and federation | Dedicated local / optional cloud | Separate CA/AD FS VMs, disposable forest, private keys, time/DNS | Trust compromise, key loss, identity lockout |
| Multi-domain/forest and AD migration | Learn trusts, sites, schema, and migration | Dedicated | Multiple isolated forests/domains, additional DCs, migration backups | Cross-forest identity and rollback complexity |
| Advanced clustering/large storage | Extend Milestone F to production-shaped topologies | Dedicated | Several nodes, disks, witness/quorum, separate networks, high storage | Data loss, split brain, unsupported snapshots |
| Specialized Windows services | Explore RMS, FSLogix, RDS HA, WDS/MDT, DHCP/IPAM, advanced security | Expanded/dedicated, cost/support TBD | Extra servers/clients, deployment media, certificates, policy boundaries | Licensing, external exposure, destructive policy changes |

The matrix is a planning classification, not live pricing or a promise of regional availability. Use `TBD` until current service documentation and the subscription portal establish the facts.

## H1. Azure managed databases and data services

**Objective:** compare Azure-managed database, storage, messaging, or data-platform responsibilities with local Windows administration. Source material may name a service without proving that the Azure for Students subscription supports it at no cost.

**Prerequisites/resources:** existing tenant/subscription, a dedicated `<AZURE_RESOURCE_GROUP>`, UK South availability, current SKU/quota/pricing, service-specific provider registration, and a disposable schema/data set. Required permissions are **TBD** per service; do not assume Owner is necessary or sufficient.

**Go/no-go:** reject the topic if the service has no current student entitlement, cost cannot be capped below £10, private access is unavailable where required, or cleanup cannot remove databases, backups, private endpoints, keys, and diagnostic data.

**Safe sequence:** create one small disposable instance only after the gate; use synthetic data; disable public access where supported; never store connection strings, access keys, SAS tokens, or passwords in Git; verify with the service’s read-only portal/CLI view; delete the instance, databases, backups, networking, and identities.

```powershell
az resource list --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --query "[].{name:name,type:type,location:location}" -o table
az monitor activity-log list --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --max-events 20 --query "[].{operation:operationName.value,status:status.value}" -o table
```

Support, free-tier eligibility, backup retention, and exact service commands are **TBD** until checked for the selected service. Do not invent a database SKU or price.

## H2. Hosted compute, containers, AKS, and serverless

**Objective:** understand managed compute, image delivery, scaling, and operational boundaries without turning the £10 lab into a permanent cluster.

**Prerequisites/resources:** source lab requirements, a disposable VNet/subnet/NSG, image registry if needed, current quota/SKU check, and— for AKS—supported node count, identity, CNI, and Kubernetes version. Local Windows containers, WSL, and nested Hyper-V remain governed by [Milestone F](Advanced-Infrastructure.md).

**Go/no-go:** do not create AKS or a multi-node hosted compute platform unless the total node-hours, disks, load balancer, public IP, registry, and egress are bounded and the cluster can be deleted immediately after verification. If the source only requires conceptual understanding, use diagrams or read-only inspection instead.

**Safe sequence:** deploy the smallest supported disposable footprint; use private/restricted endpoints; use synthetic images/data; verify node and workload state; scale to zero or deallocate where supported; delete the cluster, node pools, disks, load balancers, public IPs, registry artifacts, and role assignments.

```powershell
az resource list --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --query "[].{name:name,type:type,location:location}" -o table
az vm list --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --show-details --query "[].{name:name,power:powerState}" -o table
```

AKS support, quota, node minimums, control-plane billing, and regional availability are **TBD** until checked. Never place registry credentials, kubeconfig files, tokens, or private keys in Git.

## H3. AI, search, and advanced services

**Objective:** evaluate AI, search, speech, document, or other advanced source services while protecting data and controlling usage.

**Prerequisites/resources:** a documented synthetic dataset, service availability and quota, content/data classification, approved region, least-privilege identity, and an explicit request for any service outside the core G scope.

**Go/no-go:** do not upload personal, tenant, customer, or copyrighted datasets; stop when token/index/page/transaction costs cannot be bounded; treat `TBD` model availability and pricing as no-go until resolved.

**Safe sequence:** create the smallest disposable service/index/deployment; use synthetic records; set usage limits where supported; test one query or document; inspect resource/usage metadata; remove deployments, indexes, data sources, keys, diagnostic settings, and the service.

```powershell
az resource list --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --query "[].{name:name,type:type,location:location}" -o table
az monitor activity-log list --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --max-events 20 --query "[].{operation:operationName.value,status:status.value}" -o table
```

Do not store prompts containing secrets, API keys, embeddings, search indexes, model deployment keys, or uploaded documents in Git. Current quotas, model/service availability, and exact cost are **TBD** until verified.

## H4. Multi-region and disaster recovery

**Objective:** reason about RPO/RTO, backup, restore, failover, and regional dependencies.

**Prerequisites/resources:** a disposable primary workload, a supported secondary region, duplicated networking/storage/identity, backup retention, a written RPO/RTO, and an explicit cost decision. The default UK South region alone cannot demonstrate regional failover.

**Go/no-go:** stop if a second region, replicated data, backup retention, or failback cost cannot be bounded below £10; do not test failover against production or the shared Entra tenant’s critical objects.

**Safe sequence:** document dependencies; create synthetic data; take supported backups; test restore before failover; perform one planned failover; verify DNS/identity/data consistency; fail back or delete all secondary resources. Never use a stale VM snapshot as a regional recovery proof.

```powershell
az resource list --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --query "[].{name:name,type:type,location:location}" -o table
```

RPO/RTO results are workload-specific. Record them as `TBD` until measured; do not claim disaster recovery from a single-region deployment.

## H5. PKI, certificates, AD CS, AD FS, and federation

**Objective:** learn certificate issuance, trust chains, renewal, federation, and private-key protection in a disposable forest.

**Prerequisites/resources:** separate CA and federation/member VMs, validated `ad.lab.test`, synchronized time, isolated VMnet10/20, disposable private keys, and the source practices/labs for certificate templates, AD FS, RMS, and PKI. Use [Implementing AD FS](../Labs/Implementing-Active-Directory-Federation-Services.md) and certificate-related practices.

**Go/no-go:** no production certificates, public names, real identities, or real private keys; no broad trust to the physical network; no federation rollout into the existing Entra tenant without a separately approved design.

**Safe sequence:** snapshot `H5-before-pki`; create a lab-only CA hierarchy; issue only short-lived test certificates; record thumbprints, not private keys; validate chain, EKU, time, and revocation behavior; remove certificates, templates, CA databases, federation trusts, service accounts, and VMs during cleanup.

```powershell
Get-ChildItem Cert:\LocalMachine\My
Get-Service CertSvc,adfssrv -ErrorAction SilentlyContinue
Get-WinEvent -LogName 'CertificateServicesClient-AutoEnrollment/Operational' -MaxEvents 20 -ErrorAction SilentlyContinue
```

CA databases and federation state must not be restored from arbitrary snapshots after trust changes. Private keys, PFX files, federation metadata, signing certificates, and service credentials must never be stored in Git.

## H6. Multi-domain/forest, migration, and advanced AD

**Objective:** explore trusts, sites, replication, schema/functional-level changes, RODC, migration, and multi-forest administration.

**Prerequisites/resources:** additional isolated forests and DCs (for example `VN2-SRV1`/`VN2-SRV2`), separate VMnet segments, extra RAM/storage, validated backups, and a written trust/migration plan. Use the source multi-domain, migration, sites/replication, RODC, schema, and functional-level labs.

**Go/no-go:** no change to the learner’s only forest when rollback is uncertain. Build a second disposable forest instead of altering `ad.lab.test` for migration demonstrations.

**Safe sequence:** create each forest from clean templates; validate DNS/time/replication independently; establish only the documented temporary trust; test one migration object; capture read-only state; remove trust and destroy the secondary forest only after cleanup.

```powershell
Get-ADForest
Get-ADDomain
Get-ADDomainController -Filter *
repadmin /replsummary
Get-ADTrust -Filter *
```

Never clone promoted DCs, restore stale DC snapshots into an active forest, or automate bulk users/passwords/guest invitations. Schema, forest-mode, trust, and migration changes may be irreversible or difficult to unwind.

## H7. Advanced clustering and large storage

**Objective:** extend Milestone F into production-shaped quorum, S2D, Storage Replica, stretched-cluster, and large storage exercises.

**Prerequisites/resources:** the [Milestone F advanced infrastructure guide](Advanced-Infrastructure.md), multiple patched nodes, dedicated disks, separate storage/management networks, quorum/witness design, supported hardware/VM configuration, and data backups.

**Go/no-go:** no cluster without a quorum plan, no S2D without eligible disks/nodes, no Storage Replica without disposable target data, and no large-storage topic when host free space or recovery time is unknown.

**Safe sequence:** run validation; snapshot all nodes only as a pre-change reference; use supported backups; create one disposable role; test planned failure; verify quorum, storage health, replication, and recovery; remove roles and data through supported procedures.

```powershell
Get-ClusterNode
Get-ClusterQuorum
Get-ClusterGroup
Get-StoragePool
Get-VirtualDisk
Get-SRGroup -ComputerName VN1-SRV20 -ErrorAction SilentlyContinue
```

Do not use snapshots as cluster/replication backups, delete VHDX files to simulate failure, or leave witness, disks, public endpoints, or replication jobs running.

## H8. Other support-sensitive Windows topics

Use the source labs for RDS HA/external access, FSLogix, RMS, IPAM, DHCP fault tolerance, WDS/MDT, advanced DNS security, delegated service accounts, and similar topics. Classify them as **Expanded** or **Dedicated** when they require multiple roles, deployment media, certificates, clients, public access, or policy changes. Review [Milestone F](Advanced-Infrastructure.md) first, then apply the same go/no-go, snapshot, verification, and cleanup workflow. Exact support matrix, licensing, and resource requirements are `TBD` until checked for the selected Windows build and lab.

## Final curriculum completion checklist

The curriculum is complete only when:

- A-F local foundations were validated in order and their checkpoints are known.
- The manifest still reports 89 Practices and 50 Labs, and every selected item has its prerequisites and cleanup understood.
- Each optional topic has an objective, classification, permissions, topology, cost decision, checkpoint/backup plan, verification, and deletion plan.
- Azure checks use the existing tenant/subscription, UK South default, placeholders, and a hard £10 stop limit.
- No instructor automation, credentials, tokens, tenant/subscription identifiers, private keys, invitations, or secrets were added.
- Every selected local/cloud resource is deallocated or deleted, and the final inventory is empty or explicitly explained.
- The outcome and unresolved `TBD` items are recorded privately.

Run the repository validator and `git diff --check` before committing documentation changes. This runbook does not claim any live service deployment or support certification.
