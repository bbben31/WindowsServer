# Compatibility and requirements matrix

Use the supported baseline unless an exercise explicitly tests an older operating system. Verify current product documentation for cloud services and optional components.

| Area | Server 2025 / Windows 11 | Server 2022 / Windows 11 | Windows 11 host | Local VMware | Azure |
| --- | --- | --- | --- | --- | --- |
| Baseline | Default evaluation server/client baseline | Substitution where a lab requires it | Host OS baseline | Workstation Pro 17, staged VMs | Existing Azure for Students subscription |
| AD DS/DNS | Supported lab baseline | Usually suitable; verify lab requirement | Client/host only | VMnet10 | Not a replacement for local AD |
| Hyper-V/nested virtualization | Requires nested virtualization and extra capacity | Verify the selected exercise | Host firmware/VMware prerequisite | Extra RAM/CPU and storage | Not equivalent to nested VMware |
| WDS install-media deployment | Windows Server 2025 deployment through install-media `boot.wim` is blocked | Retained only as a deprecated, isolated Server 2022 compatibility exercise | Management client only | Dedicated PXE VMnet; never bridge to a physical LAN | Not required |
| Microsoft Deployment Toolkit | Retired and unsupported; not part of the baseline | Optional historical exercise using an isolated Server 2022 target only | Do not use for the Windows 11 baseline | Dedicated PXE VMnet | Not required |
| AD RMS and WSUS | Retained for enterprise concepts, but neither is actively developed | Use only in disposable lab roles | Management client only | Isolated/local | Modern replacements are outside the default £10 scope |
| Azure Arc/Monitor/Automation | Guest support depends on current service docs | Verify the selected service | Host/client support is lab-specific | Outbound VMnet8 only when required | UK South; core scope by default |
| Cost | Local electricity/storage | Local electricity/storage | Host resource use | No Azure charge | £10 hard monthly safety limit |

## VM profiles

| Profile | Suggested use | VMs powered on | Notes |
| --- | --- | --- | --- |
| Low | Stages A-E and single-server practices | 3-4 | `VN1-SRV1`, `VN1-SRV20`, `CL1`, optional second DC; add a separate `VN1-SRV4` only for its WAC role. Advanced labs are not suitable for this profile. |
| Standard | Selected storage, management, and multi-server labs | 5-8 | Add machines named by the lab; do not assume cluster support. |
| Expanded | Clusters, RDS HA, S2D, nested Hyper-V, and multi-service labs | 9+ | Extra disks, RAM, and storage are required; verify each lab manifest entry. |

Windows Server 2022, Azure VM SKUs, and service-specific support remain lab-specific. Source steps that still say Windows 10 are historical UI descriptions: use the Windows 11 client baseline and adapt the navigation, or isolate an older client only when the exercise specifically tests legacy behavior and the operating system remains properly licensed and protected.

For deployment services, follow Microsoft's current [WDS boot-image support matrix](https://learn.microsoft.com/en-us/windows/deployment/wds-boot-support) and [MDT retirement notice](https://learn.microsoft.com/en-us/troubleshoot/mem/configmgr/mdt/mdt-retirement). Do not weaken PXE or unattended-deployment security controls to reproduce a retired workflow.
