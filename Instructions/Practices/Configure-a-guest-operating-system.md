# Practice: Configure a guest operating system

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. PM-SRV20 is a preexisting VMware Server Core guest with a VMnet10 AD-management NIC at 10.10.10.160/24 and a VMnet20 workload NIC at 10.10.20.160/24. AD DNS 10.10.10.10 must be reachable on the management NIC before joining.

**Machines and network profile:** VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV20 (VMware display: PM-SRV20; accepted display aliases: WIN-PM-SRV20; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

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

## Task

Provision PM-SRV20 as a VMware Server Core guest with two recorded NICs. Before domain join, configure its VMnet10 management NIC as `10.10.10.160/24` with AD DNS `10.10.10.10` and no default gateway, and verify DNS resolution to `ad.lab.test`. The procedure below configures the separate VMnet20 workload NIC; identify it by the MAC address in VMware settings instead of assuming SConfig adapter number 1. Disable DNS registration on the workload NIC to keep the management address authoritative.

In the virtual machine PM-SRV20, set the administrator password, set the IP address to 10.10.20.160/24, leave the default gateway blank on isolated VMnet20, and set the DNS client server to 10.10.10.10. Join the virtual machine to the domain ad.lab.test and rename the guest operating system computer.

## Instructions

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. In VMware Workstation, open the **PM-SRV20** console. Hyper-V Manager and Hyper-V Virtual Machine Connection are not used by the default learner host.
1. At the prompt **The user's password must be changed before signing in**, select **OK** and press ENTER.
1. Beside **New password** and **Confirm password**, enter a secure password and take a note.
1. At **Your password has been changed**, press ENTER.
1. In SConfig, enter **8**.
1. In Network settings, select the **VMnet20 workload adapter** identified by its recorded MAC address.
1. In Network adapter settings, enter **1**.
1. At the prompt Select (D)HCP or (S)tatic IP address (Blank=Cancel), enter **S**.
1. At the prompt **Enter static IP address (Blank=Cancel)**, type **10.10.20.160** directly in the VMware console and press ENTER. VMware clipboard integration is not required.
1. At the prompt **Enter subnet mask (Blank=255.255.255.0)**, press ENTER.
1. At the prompt **Enter default gateway (Blank=Cancel)**, press ENTER and leave it blank. Isolated VMnet20 has no default gateway; attach VMnet8 temporarily only when controlled outbound access is required.
1. Under a number of success messages, press ENTER.
1. In SConfig, enter **8**.
1. In Network settings, select the same **VMnet20 workload adapter**.
1. In Network adapter settings, enter **2**.
1. At the prompt **Enter new preferred DNS server (Blank=Cancel)**, enter **10.10.10.10**.
1. At the prompt **Enter alternate DNS server**, press ENTER.
1. Under **Sucessfully assigned DNS server(s)**, press ENTER.
1. In SConfig, enter **1**.
1. At the prompt **Join (D)omain or (W)orkgroup? (Blank=Cancel)**, enter **D**.
1. At the prompt **Name of domain to join (Blank=Cancel)**, enter **ad.lab.test**.
1. At the prompt **Specify an authorized domain\user (Blank=Cancel)**, enter **ad\Administrator**.
1. At the prompt **Password for ad\Administrator**, enter the password of **ad\Administrator**.
1. At the prompt **Do you want to change the computer name before restarting? (Y)es or (N)o**, enter **Y**.
1. At the prompt **Enter new computer name (Blank=Canel)**, enter **PM-SRV20**.
1. At the prompt **Password for ad\Administrator**, enter the password of **ad\Administrator**.
1. At the prompt **Restart now? (Y)es or (N)o**, enter **Y**.
