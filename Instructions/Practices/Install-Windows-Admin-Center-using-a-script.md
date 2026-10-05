# Practice: Install Windows Admin Center using a script

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV2 (VMware display: VN1-SRV2; accepted display aliases: WIN-VN1-SRV2; existing); VN1-SRV4 (VMware display: VN1-SRV4; accepted display aliases: WIN-VN1-SRV4; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Official Microsoft Windows Admin Center download/extension endpoints.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The Microsoft-signed WAC package is installed on VN1-SRV4 and CL1 reaches the intended HTTPS gateway.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV2
* VN1-SRV4

## Task

Install Windows Admin Center on VN1-SRV4 using the official installer. The source helper script is intentionally not included in the learner edition.

## Instructions

Perform these steps on VN1-SRV4.

1. Logon as **ad\Administrator**.
1. From the official Microsoft download page, download the current Windows Admin Center installer to a learner-controlled temporary folder such as `C:\WindowsServerLab\Resources\Downloads`.
1. Verify the download and its publisher, then run the installer interactively on VN1-SRV4.
1. Select a management port and certificate option appropriate for this isolated lab. Do not place the installer, certificates, passwords, or generated onboarding material in Git.
1. From CL1, verify that the gateway opens and that VN1-SRV4 is reachable. Remove the installer when the practice is complete if it is no longer needed.
