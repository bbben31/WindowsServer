# Practice: Configure a guest operating system

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. PM-SRV20 is a preexisting VMware Server Core guest with a VMnet10 AD-management NIC at 10.10.10.160/24 and a VMnet11 workload NIC at 10.10.20.160/24. AD DNS 10.10.10.10 must be reachable on the management NIC before joining.

**Machines and network profile:** VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV20 (VMware display: PM-SRV20; accepted display aliases: WIN-PM-SRV20; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** PM-SRV20 reports its intended hostname/address and Test-ComputerSecureChannel succeeds after domain join.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. If temporary VMnet8 access was attached, disconnect it and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* VN1-SRV1
* CL1
* PM-SRV20

> **Scenario boundary:** This practice configures the outer VMware guest PM-SRV20. The separately scoped nested Hyper-V creation practice reuses that hostname for an inner guest. Keep these scenarios isolated; do not run or domain-join both copies on the same lab network.

## Task

Provision PM-SRV20 as a VMware Server Core guest with two recorded NICs. Before domain join, configure its VMnet10 management NIC as `10.10.10.160/24` with AD DNS `10.10.10.10` and no default gateway, and verify DNS resolution to `ad.lab.test`. The procedure below configures the separate VMnet11 workload NIC; identify it by the MAC address in VMware settings instead of assuming SConfig adapter number 1. Disable DNS registration on the workload NIC to keep the management address authoritative.

In the virtual machine PM-SRV20, set the administrator password, set the IP address to 10.10.20.160/24, leave the default gateway blank on isolated VMnet11, and set the DNS client server to 10.10.10.10. Join the virtual machine to the domain ad.lab.test and rename the guest operating system computer.

## Instructions

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. In VMware Workstation, open the **PM-SRV20** console. Hyper-V Manager and Hyper-V Virtual Machine Connection are not used by the default learner host.
1. At the prompt **The user's password must be changed before signing in**, select **OK** and press ENTER.
1. Beside **New password** and **Confirm password**, enter a secure password and take a note.
1. At **Your password has been changed**, press ENTER.
1. In SConfig, enter **8**.
1. In Network settings, select the **VMnet11 workload adapter** identified by its recorded MAC address.
1. In Network adapter settings, enter **1**.
1. At the prompt Select (D)HCP or (S)tatic IP address (Blank=Cancel), enter **S**.
1. At the prompt **Enter static IP address (Blank=Cancel)**, type **10.10.20.160** directly in the VMware console and press ENTER. VMware clipboard integration is not required.
1. At the prompt **Enter subnet mask (Blank=255.255.255.0)**, press ENTER.
1. At the prompt **Enter default gateway (Blank=Cancel)**, press ENTER and leave it blank. Isolated VMnet11 has no default gateway; attach VMnet8 temporarily only when controlled outbound access is required.
1. Under a number of success messages, press ENTER.
1. In SConfig, enter **8**.
1. In Network settings, select the same **VMnet11 workload adapter**.
1. In Network adapter settings, enter **2**.
1. At the prompt **Enter new preferred DNS server (Blank=Cancel)**, enter **10.10.10.10**.
1. At the prompt **Enter alternate DNS server**, press ENTER.
1. Under **Sucessfully assigned DNS server(s)**, press ENTER.
1. Return to the main SConfig menu and choose **15** to open PowerShell. Use `Get-NetAdapter` to identify the recorded workload adapter by MAC address, then run `Set-DnsClient -InterfaceAlias '<RECORDED_WORKLOAD_ALIAS>' -RegisterThisConnectionsAddress $false` after substituting its actual alias. Verify the separate management NIC already has `10.10.10.160/24`, DNS `10.10.10.10` and no default gateway; if absent, configure those values through SConfig for the management NIC before joining. Require `Resolve-DnsName ad.lab.test -Server 10.10.10.10` to succeed. Run `SConfig` to return to the menu.
1. In SConfig, enter **1**.
1. At the prompt **Join (D)omain or (W)orkgroup? (Blank=Cancel)**, enter **D**.
1. At the prompt **Name of domain to join (Blank=Cancel)**, enter **ad.lab.test**.
1. At the prompt **Specify an authorized domain\user (Blank=Cancel)**, enter **ad\Administrator**.
1. At the prompt **Password for ad\Administrator**, enter the password of **ad\Administrator**.
1. At the prompt **Do you want to change the computer name before restarting? (Y)es or (N)o**, enter **Y**.
1. At the prompt **Enter new computer name (Blank=Canel)**, enter **PM-SRV20**.
1. At the prompt **Password for ad\Administrator**, enter the password of **ad\Administrator**.
1. At the prompt **Restart now? (Y)es or (N)o**, enter **Y**.
1. After restart, sign in with the authorized domain account, choose SConfig **15**, and verify `hostname`, `Get-NetIPConfiguration`, `Get-DnsClient` and `Test-ComputerSecureChannel`. Require hostname **PM-SRV20**, the recorded two-NIC addresses, disabled workload DNS registration and a successful secure channel. This verification is for the outer VMware guest, not the identically named inner Hyper-V guest.
