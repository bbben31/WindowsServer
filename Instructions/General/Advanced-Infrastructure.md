# Milestone F: storage, Hyper-V, RDS, and advanced infrastructure

Milestone F follows the validated [Milestone E administration stage](Core-Windows-Administration.md). It is a catalogue and safe execution order for advanced topics; the linked practices and labs remain the detailed source procedures. Do not assume the 32 GB Windows 11 host can run every topology at once.

## Capacity classes and global safety rules

| Class | Meaning | Typical F topics |
| --- | --- | --- |
| **Standard** | One or two staged members and one or two disposable virtual disks | local storage, file serving, FSRM, basic SSH/containers |
| **Expanded** | Several guests, multiple virtual disks, or sustained RAM/CPU use | iSCSI/MPIO, DFS, WSUS, RDS, WDS |
| **Optional** | Useful curriculum extension, but not needed for the core path | WSL, containers, Azure File Sync |
| **Dedicated** | Requires extra VMs/disks, nested virtualization, Azure resources, or a quorum design | failover clusters, S2D, Storage Replica, RDS HA, nested Hyper-V |

Before every selected practice/lab, run preflight with its manifest `-CurriculumPath`, record its declared VMs/disks, and take a named checkpoint. The core `VN1-SRV20`/`VN1-SRV21` snippets below illustrate administration checks, not the prerequisites for every linked enterprise lab. Use each lab's exact named roles, addresses, disks, and setup in a separate enterprise lineage; do not replace those machines with the core members. Execute Windows administration snippets in Windows PowerShell 5.1 in the indicated guest. Do not use snapshots as backups for data, domain controllers, clusters, or replicated storage. Never revert one node of an active cluster or replicated pair while its peers continue running. Stop dependent guests first.

## Topic runbooks

### F1. Local storage, disks, shares, and FSRM — Standard

**Objective:** inspect disks and volumes, create a disposable data volume, serve files, and apply file-server resource management.

**Prerequisites/topology:** a domain-joined disposable file server and the selected procedure's exact disk/role baseline. The linked enterprise labs use `VN1-SRV10` and their declared management/AD guests; `VN1-SRV20` below is only an independent core illustration. Use [Manage local storage](../Labs/Manage-local-storage.md), [Manage file sharing](../Labs/Manage-file-sharing.md), [Install prerequisites for file serving](../Practices/Install-prerequisites-for-file-serving.md), and [Install File Server Resource Manager](../Practices/Install-File-Server-Resource-Manager.md). Do not substitute an empty core member for the prepared enterprise file server.

**Safe sequence:** snapshot `F1-before-storage`; identify disks before initializing; use the GUI or source commands to bring only the disposable disk online, initialize it with the selected partition style, create a volume, and label it. Install the file-server/FSRM roles only when the selected lab requires them. Create test shares and quotas with disposable data. Never format the OS or AD volumes.

```powershell
Get-Disk -CimSession VN1-SRV20
Get-Partition -CimSession VN1-SRV20
Get-Volume -CimSession VN1-SRV20
Get-SmbShare -CimSession VN1-SRV20
Get-WindowsFeature -ComputerName VN1-SRV20 -Name FS-FileServer,FS-Resource-Manager
```

**Expected state:** the intended disk/volume and share exist, permissions are tested with a disposable account, and FSRM rules target only test data. **Rollback/cleanup:** remove test shares/quotas, detach disposable disks only after unmounting them, and retain no data needed by later labs. Formatting and disk initialization are destructive and cannot be undone by a snapshot once external data has changed.

### F2. Storage Spaces and tiering — Expanded/Dedicated

**Objective:** learn pools, virtual disks, resiliency, and storage tiers.

**Prerequisites/topology:** the selected procedure's server and exact disposable disk count/sizes. [Implementing and managing Storage Spaces and Storage Tiering](../Labs/Implementing-and-managing-Storage-Spaces-and-Storage-Tiering.md) uses enterprise `VN1-SRV10`, not the illustrative core `VN1-SRV20` below. Storage Spaces Direct is a separate multi-node topology; two generic disks are not its complete prerequisite.

**Safe sequence:** snapshot `F2-before-pool`; confirm disk identity and emptiness; create a pool/virtual disk only through the source procedure; record resiliency and tier choices; test a disposable volume. Do not include the OS disk, AD database, or a disk containing required data.

```powershell
Get-PhysicalDisk -CimSession VN1-SRV20
Get-StoragePool -CimSession VN1-SRV20
Get-VirtualDisk -CimSession VN1-SRV20
Get-Volume -CimSession VN1-SRV20
```

Storage Spaces and S2D are not backups. Pool removal, disk retirement, and tier changes can destroy data. S2D is **Dedicated**: it needs a supported multi-node cluster, multiple disks per node, networking, and quorum; a three-VM low-memory simulation is not evidence of production readiness. Clean up by removing the disposable pool/volumes through supported procedures, not by deleting VHDX files first.

### F3. iSCSI and MPIO — Expanded/Dedicated

**Objective:** provide and consume block storage over iSCSI and understand multipath failover.

**Prerequisites/topology:** an iSCSI target VM and an initiator VM, separate VMnet11 storage paths where the source lab requires them, and at least two independent virtual NIC/path designs for MPIO. Use [Implementing and managing iSCSI and MPIO](../Labs/Implementing-and-managing-iSCSI-and-multipath-io.md).

**Safe sequence:** snapshot target and initiator; use unique IQNs and disposable LUNs; connect the initiator through the documented target portal; enable MPIO only after confirming the supported path design; format and mount only the new LUN. Never expose the target to the physical LAN.

```powershell
Get-IscsiTargetPortal
Get-IscsiSession
Get-MSDSMAutomaticClaimSettings
Get-Disk
Get-Volume
```

Expected state is a connected disposable LUN and, for MPIO, the intended number of healthy paths. Do not disconnect an in-use LUN or delete a target while mounted. Remove sessions, reservations, LUNs, and target VHDX files in the documented order during cleanup.

### F4. DFS and Azure File Sync — Expanded/Optional

**Objective:** compare namespace/file replication with cloud-backed synchronization.

**Prerequisites/topology:** the exact servers, identities, shares, and DFS roles declared by [Distributed File System and Azure File Sync](../Labs/Distributed-File-System-and-Azure-File-Sync.md), including enterprise `VN1-SRV10` and `VN1-SRV6`. The `VN1-SRV20`/`VN1-SRV21` check below illustrates a separate core pair, not a substitution for that lab. Azure File Sync additionally needs an existing Azure subscription, storage account, endpoint permissions, persistent approved outbound access while syncing, and cost review.

**Safe sequence:** create only disposable namespace roots and test files; document the authoritative copy before enabling replication. For Azure File Sync, use a dedicated resource group and budget controls, connect VMnet8 only for the approved operation, and remove the cloud endpoint after testing.

```powershell
Get-SmbShare -CimSession VN1-SRV20,VN1-SRV21
Get-DfsnRoot
Get-DfsnFolder
Get-DfsrMembership
```

DFS-R and cloud sync are asynchronous; do not treat an old snapshot as a consistent replica. Validate convergence and conflict handling before cleanup. Azure storage, transactions, and bandwidth are cost-gated under the £10 safety limit.

### F5. Hyper-V, nested virtualization, WSL, containers, and SSH — Standard/Optional/Dedicated

**Objective:** manage Hyper-V, nested guests, Linux tooling, Windows containers, and secure shell where supported.

**Prerequisites/topology:** Hyper-V requires a Server/Windows edition and hardware virtualization; nested Hyper-V requires VMware nested virtualization enabled for the specific VM, extra CPU/RAM, and lower performance. Procedures that create a small Linux guest also require a learner-supplied `TinyCorePure64.vhdx`; follow the acquisition, verification, and placement requirements in the [Resources inventory](../../Resources/README.md) before starting them. Use [Managing Hyper-V](../Labs/Managing-Hyper-V.md), [Configure nested virtualization](../Practices/Configure-nested-virtualization.md), [Windows containers](../Labs/Windows-containers.md), [Windows Subsystem for Linux](../Labs/Windows-Subsystem-for-Linux.md), and [Secure Shell](../Labs/Secure-Shell.md).

**Safe sequence:** take `F5-before-hyperv`; power off the guest before changing VMware virtualization settings; enable nested virtualization only for the selected VM; create nested switches/guests on isolated networks; never bridge nested lab traffic by default. Treat WSL/container images as disposable and review downloaded images. Configure SSH with reviewed keys kept outside Git.

```powershell
Get-ComputerInfo | Select-Object HyperVisorPresent,WindowsProductName
Get-WindowsFeature -ComputerName VN1-SRV20 -Name Hyper-V,Hyper-V-PowerShell
Get-VM -ComputerName VN1-SRV20
Get-VMSwitch -ComputerName VN1-SRV20
wsl --status
Get-Service -Name sshd -ErrorAction SilentlyContinue
```

Nested virtualization can be unsupported or slow depending on VMware/Windows versions; it is not required for ordinary Windows Server administration. Remove nested VMs, container images, WSL distributions, and SSH test keys during cleanup. Do not place secrets in images or command history.

### F6. Failover clustering, Storage Replica, and S2D — Dedicated

**Objective:** learn quorum, clustered roles, replicated storage, and hyper-converged design.

**Prerequisites/topology:** at least two or three disposable member servers, a stable AD/DNS foundation, dedicated VMnet11 management/storage paths, extra disks, and a witness location where the source lab requires it. Use [Installing and configuring a fail-over cluster](../Labs/Installing-and-configuring-a-fail-over-cluster.md), [Storage Replica and stretched cluster](../Labs/Storage-Replica-and-stretched-cluster.md), and [Configuring and managing S2D](../Labs/Configuring-and-managing-Storage-Spaces-Direct-and-hyper-converged-virtualization.md).

**Safe sequence:** snapshot every node and data disk as `F6-before-cluster`; validate names, DNS, time, firewall, identical patch level, and disk eligibility; run the source validation wizard; define quorum/witness deliberately; create only disposable clustered roles; test one planned failure at a time.

```powershell
Get-Cluster -Domain ad.lab.test
Get-ClusterNode
Get-ClusterQuorum
Get-ClusterGroup
Get-ClusterSharedVolume
# Run Test-Cluster separately in the selected lab's validation phase;
# it is not a read-only inventory check and can disrupt storage/roles.
Get-SRGroup -ComputerName VN1-SRV20 -ErrorAction SilentlyContinue
```

A cluster without an appropriate quorum/witness can lose availability or split-brain. Storage Replica is destructive to target data during initial sync; S2D consumes all selected disks. Never use VMware snapshots as a cluster backup, never revert one node while peers run, and never test failure by deleting a VHDX. Remove clustered roles, demote/clean members as appropriate, and destroy the disposable cluster only after all data has been copied or intentionally discarded.

### F7. RDS, WSUS, and deployment services — Expanded/Dedicated

**Objective:** stage session hosts, update management, and deployment services.

**Prerequisites/topology:** RDS typically needs a connection broker/web/access/session-host design and client VMs; HA needs multiple nodes and a supported database/load-balancer design. WSUS needs a dedicated server, update storage, and outbound bandwidth. WDS/MDT needs deployment media, a DHCP/PXE network decision, and extra storage. Use [Deploy RDS](../Labs/Deploy-Remote-Desktop-Services.md), [RDS external access](../Labs/Configure-external-access-to-Remote-Desktop-Services.md), [RDS high availability](../Labs/Configure-high-availability-for-Remote-Desktop-Services.md), [Managing WSUS](../Labs/Managing-Windows-Server-Update-Services.md), [Windows Deployment Services](../Labs/Windows-Deployment-Services.md), and [Microsoft Deployment Toolkit](../Labs/Microsoft-Deployment-Toolkit.md).

**Safe sequence:** take `F7-before-service`; use an isolated test client and no public RDP endpoint; install only the roles named by the lab; approve/download only the update products and languages needed; use a non-production deployment share and media. Do not point every lab VM at WSUS until its policy is understood.

```powershell
Get-WindowsFeature -ComputerName VN1-SRV20
Get-Service -ComputerName VN1-SRV20 -Name WsusService,W3SVC,TermService -ErrorAction SilentlyContinue
Get-WinEvent -ComputerName VN1-SRV20 -LogName System -MaxEvents 20
Test-NetConnection VN1-SRV20 -Port 3389
```

WSUS consumes disk and bandwidth; RDS and public access can create licensing/security exposure; PXE/WDS can conflict with DHCP. Keep these topics expanded or dedicated, use current product licensing, and remove update metadata, deployment shares, certificates, and firewall exceptions during cleanup.

## F verification gate

Milestone F is complete only for the selected topic when its required VMs/disks/resources exist, the source lab’s verification commands pass, the named checkpoint is recorded, and cleanup/rollback has been rehearsed or documented. Validate the curriculum manifest and run preflight again with the selected item's `-CurriculumPath`. Do not call a topic complete merely because a role installed successfully.
