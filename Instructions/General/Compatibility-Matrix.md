# Compatibility and requirements matrix

Use `TBD` where a source procedure or current product documentation is authoritative; do not infer compatibility from this matrix alone.

| Area | Server 2025 / Windows 10 | Server 2022 / Windows 10 | Windows 11 | Local VMware | Azure |
| --- | --- | --- | --- | --- | --- |
| Baseline | Default evaluation server/client baseline | Substitution where a lab requires it | Host OS baseline | Workstation Pro 17, staged VMs | Existing Azure for Students subscription |
| AD DS/DNS | Supported lab baseline | Usually suitable; verify lab requirement | Client/host only | VMnet10 | Not a replacement for local AD |
| Hyper-V/nested virtualization | Requires nested virtualization and extra capacity | TBD per lab | Host firmware/VMware prerequisite | Extra RAM/CPU and storage | Not equivalent to nested VMware |
| Azure Arc/Monitor/Automation | Guest support depends on current service docs | TBD per service | Host/client support is lab-specific | Outbound VMnet8 only when required | UK South; core scope by default |
| Cost | Local electricity/storage | Local electricity/storage | Host resource use | No Azure charge | £10 hard monthly safety limit |

## VM profiles

| Profile | Suggested use | VMs powered on | Notes |
| --- | --- | --- | --- |
| Low | Stages A-E and single-server practices | 3-4 | `VN1-SRV1`, `VN1-SRV4`, `CL1`, optional second DC; advanced labs are TBD/not suitable. |
| Standard | Selected storage, management, and multi-server labs | 5-8 | Add machines named by the lab; do not assume cluster support. |
| Expanded | Clusters, RDS HA, S2D, nested Hyper-V, and multi-service labs | 9+ | Extra disks, RAM, and storage are required; verify each lab manifest entry. |

Windows Server 2022, Windows 11 guests, Azure VM SKUs, and service-specific support remain lab-specific. Check the manifest's `compatibility` and `requiredVmsOrTopology` fields and current vendor documentation before proceeding.
