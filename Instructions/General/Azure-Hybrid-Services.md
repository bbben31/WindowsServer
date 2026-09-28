# Milestone G: Azure and hybrid services

Milestone G follows the validated local stages and is deliberately cost-gated. It uses the existing Microsoft Azure for Students subscription and Microsoft Entra tenant in **UK South**; it never creates a tenant or subscription. The hard monthly safety limit is **£10**. Use placeholders only: `<AZURE_SUBSCRIPTION_ID>`, `<AZURE_TENANT_ID>`, `<AZURE_RESOURCE_GROUP>`, `<AZURE_REGION>`, and `<AZURE_STORAGE_ACCOUNT>`.

## Safety gate and ordering

1. Complete [Milestone F](Advanced-Infrastructure.md) only for the local topic needed by the hybrid exercise.
2. Confirm Owner or User Access Administrator access and the minimum per-lab role. Do not request Global Administrator or broad directory permissions.
3. Create or select one dedicated resource group and budget alert through the portal or the source procedure. Verify the existing subscription, UK South region, quota, and current cost before provisioning.
4. Run the read-only [preflight checker](../../tools/Preflight-LearnerLab.ps1). Azure checks run only when explicit parameters are supplied and an already-authenticated CLI context exists; the checker does not log in.
5. Snapshot the local VM as `G-before-azure-connection`, connect VMnet8 only for the approved outbound operation, perform one service exercise, verify it, then disconnect VMnet8 and clean up.

Do not paste tenant IDs, subscription IDs, client secrets, certificates, tokens, invitation URLs, or personal identifiers into this repository. If the £10 limit is at risk, stop, deallocate VMs, remove disposable resources, and verify the resource group.

## Service classes

| Class | Services | Default treatment |
| --- | --- | --- |
| **Core** | Azure VMs, storage, networking, Entra ID, Monitor, Arc, Automation | Allowed only with budget, quota, and cleanup checks |
| **Hybrid extension** | Arc-enabled servers, WAC in Azure, Azure File Sync, hybrid monitoring | Extra permissions/outbound access; one disposable server first |
| **Optional/cost-gated** | Other source services, policy-heavy exercises, additional managed services | Conceptual until current price and permission impact are understood |

### G1. Existing subscription, resource group, and budget

**Objective:** establish a bounded cloud scope without creating a tenant or subscription.

**Prerequisites:** existing Azure for Students subscription, existing Entra tenant, UK South availability, and Owner/User Access Administrator access. Use the source Azure setup/prerequisite material, but replace instructor-selected identifiers with placeholders.

**Safe sequence:** in the portal, select the existing subscription; create or select `<AZURE_RESOURCE_GROUP>`; set a budget alert below the £10 hard limit; record no identifiers in Git; verify role assignments and resource locks/policies relevant to the selected lab. Do not use source procedures that create a subscription or tenant.

If the CLI is already authenticated, these are read-only checks:

```powershell
az account show --query "{subscriptionId:id,tenantId:tenantId,name:name}" -o table
az group show --name '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --query "{name:name,location:location}" -o table
az resource list --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --query "length(@)"
```

Do not run these commands with real values in a committed document or report. The expected state is one bounded resource group, known region, budget alert, and no unexpected resources.

### G2. Azure Arc for one disposable member — Core/Hybrid extension

**Objective:** project `VN1-SRV20` as an Azure resource and learn hybrid inventory/management.

**Prerequisites/topology:** validated `VN1-SRV20`, VMnet10 AD/DNS, temporary VMnet8 outbound access, an Arc-supported Windows Server build, resource-group scope, and the [Add server to Azure Arc](../Practices/Add-server-to-Azure-Arc.md) practice. The source’s `VN1-SRV8` can be substituted with the learner’s disposable member.

**Safe sequence:** snapshot `G-before-arc`; connect VMnet8; use the portal’s Arc onboarding flow or reviewed generated onboarding command; authenticate interactively through the approved tenant; select `<AZURE_RESOURCE_GROUP>` and UK South; use the narrowest available role; wait for the connected state; disconnect VMnet8. Never place the onboarding script, token, service-principal secret, or certificate in Git.

```powershell
Get-Service -Name himds,ExtensionService -ErrorAction SilentlyContinue
Get-NetIPConfiguration
Test-NetConnection '<AZURE_ARC_ENDPOINT>' -Port 443
```

From an existing CLI context, verify metadata without printing secrets:

```powershell
az connectedmachine show --name 'VN1-SRV20' --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --query "{name:name,status:status,location:location}" -o table
```

Expected state is one connected machine in the intended resource group. Clean up by disconnecting/removing the Arc resource and extensions using the supported product flow, then verify the resource group and local agent state. Arc may incur monitoring/storage costs.

### G3. Windows Admin Center and Monitor — Core/Hybrid extension

**Objective:** manage a selected hybrid server and observe its health without opening public management ports.

**Prerequisites/topology:** `CL1`/`VN1-SRV4` WAC path from Milestone E, an Arc-connected disposable server if using portal WAC, and the source [Register Windows Admin Center with Azure](../Practices/Register-Windows-Admin-Center-with-Azure.md), [Windows Admin Center lab](../Labs/Windows-Admin-Center.md), and [Monitor hybrid servers](../Labs/Managing-hybrid-servers-using-Azure-Arc.md).

**Safe sequence:** register the existing WAC installation interactively; grant only the documented WAC login role to the intended learner; use portal WAC or Monitor for one server; avoid public RDP/WinRM endpoints; inspect metrics/logs; remove the registration, role assignment, workspace/diagnostic settings, and test connection after verification.

```powershell
Get-Service -Name ServerManagementGateway -ErrorAction SilentlyContinue
Test-NetConnection VN1-SRV20 -Port 5985
Get-WinEvent -LogName System -MaxEvents 20
```

The portal should show the selected server and data only after the required agent/workspace path is healthy. Log Analytics ingestion and retention are cost-gated; do not enable broad collection by default.

### G4. Azure VM, storage, and networking — Core but cost-gated

**Objective:** compare local VMware roles with one disposable Azure VM, storage account, or VNet.

**Prerequisites/topology:** quota and pricing review, UK South SKU availability, resource-group budget, a documented subnet/NSG plan, and a cleanup time. Use only a small supported SKU and no public management endpoint unless the selected lab explicitly requires it.

**Safe sequence:** validate the intended SKU and estimate cost; create one resource at a time; use private access or restricted source IPs; deallocate the VM when idle; delete the entire disposable resource set after the lab; verify no disks, public IPs, NICs, snapshots, storage containers, or diagnostic settings remain.

Read-only checks from an existing CLI context:

```powershell
az vm list --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --show-details --query "[].{name:name,power:powerState,location:location}" -o table
az resource list --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --query "[].{name:name,type:type,location:location}" -o table
az storage account list --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --query "[].{name:name,location:location,sku:sku.name}" -o table
```

Never record access keys or SAS tokens. Azure VMs, managed disks, public IPs, storage transactions, and snapshots can exceed £10 quickly.

### G5. Azure Automation and policy/monitoring concepts — Optional/cost-gated

**Objective:** understand inventory, update/orchestration, policy, and automation without reproducing classroom-wide assignments.

**Prerequisites/topology:** one selected resource, explicit permission scope, and the source [Create an Automation account](../Practices/Create-an-Automation-account.md) or hybrid monitoring lab. Do not create broad policy assignments or runbooks against the whole subscription.

**Safe sequence:** inspect existing definitions and scope; use a disposable resource group; review runbook code before import; do not embed credentials; run in test mode where available; remove schedules, identities, alerts, workspaces, and assignments after testing.

```powershell
az automation account list --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --query "[].{name:name,location:location}" -o table
az monitor activity-log list --resource-group '<AZURE_RESOURCE_GROUP>' --subscription '<AZURE_SUBSCRIPTION_ID>' --max-events 20 --query "[].{operation:operationName.value,status:status.value,eventTimestamp:eventTimestamp}" -o table
```

Automation identities and policy assignments can grant access or incur charges. Do not use source steps that assume an instructor can assign Global Administrator, invite guests, or reset users.

### G6. Azure File Sync and hybrid file services — Optional/cost-gated

**Objective:** extend the F4 disposable file server into Azure File Sync while preserving local AD/DNS boundaries.

**Prerequisites/topology:** validated `VN1-SRV20`/`VN1-SRV21`, disposable file data, storage account and sync service in UK South, outbound HTTPS, and the [DFS/Azure File Sync lab](../Labs/Distributed-File-System-and-Azure-File-Sync.md).

**Safe sequence:** use a dedicated storage account and sync group; sync only test data; record the authoritative copy; monitor conflicts and cloud tiering; disconnect the VMnet8 NIC after the exercise; remove the server endpoint, cloud endpoint, sync group, storage data, and resource group in supported order.

```powershell
Get-SmbShare -CimSession VN1-SRV20
Get-Volume -CimSession VN1-SRV20
Test-NetConnection '<AZURE_STORAGE_ENDPOINT>' -Port 443
```

Cloud storage, transactions, bandwidth, and retained snapshots are cost-gated. Do not use sync as a backup or revert a local snapshot while synchronization is active.

## G verification and cleanup

Milestone G is complete only for the selected service when the local prerequisite, Azure scope, permission, region, cost estimate, verification result, and cleanup evidence are recorded privately. Run the curriculum validator and preflight again. Deallocate Azure VMs, remove disposable resources, role assignments, identities, agents, diagnostic settings, and data, and verify the resource group is empty. No live Azure deployment is implied by this guide.
