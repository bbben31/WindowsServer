# Practice: Add a DHCP scope

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-the-DHCP-server-role.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV6 (VMware display: VN1-SRV6; accepted display aliases: WIN-VN1-SRV6; existing).  Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments.

**Permissions:** DHCP Administrators/delegated scope rights on the named servers; authorized AD DHCP-authorization rights for authorization steps. Local Administrator for guest networking/role setup.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware. Verify current support for optional products before execution.

**Success verification:** DHCP console shows VNet1 range 10.1.1.2-254, two-hour lease and router 10.1.1.1.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


> **Environment profile:** This practice is part of the enterprise expansion and uses source `VNet1` (`10.1.1.0/24`) on its dedicated VMware custom VMnet. Do not apply this scope to core client `VMnet30`.

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV6

## Task

On VN1-SRV6, add a scope with the range 10.1.1.2 to 10.1.1.254 with a lease duration of 2 hours. Configure the router option to 10.1.1.1.

> Why would you prefer a short lease duration?

> Why do you not configure DNS options?

## Instructions

Perform this task on CL1.

1. Open **DHCP**.
1. In DHCP, in the context-menu of **DHCP**, click **Add Server...**
1. In Add Server, under **This server**, type **VN1-SRV6** and click **OK**.
1. In **DHCP**, expand  **vn1-srv6.ad.lab.test**, and click **IPv4**.
1. In the context-menu of **IPv4**, click **New Scope...**
1. In the New Scope Wizard, on page Welcome to the New Scope Wizard, click **Next >**.
1. On page Scope Name, in **Name**, type **VNet1** and click **Next >**.
1. On page IP Address Range, in **Start IP address**, type **10.1.1.2**. In **End IP address**, type **10.1.1.254**. In **Length**, type **24**. Click **Next >**

    In **Length**, you can also click the up arrow button to increase it to 24. Alternatively, in **Subnet mask**, you could type **255.255.255.0**.

1. On page Add Exclusions and Delay, click **Next >**.
1. On page Lease Duration, in **Days**, type **0**, in **Hours**, type **2**, and click **Next >**.

    > A short lease duration allow for quicker reconfiguration and uses the IP address range more efficiently. To mitigate server failures, we will configure fault-tolerance later.

1. On page Configure DHCP options, ensure **Yes, I want to configure these options now** is selected, and click **Next >**.
1. On page Router (Default Gateway), under **IP address**, type **10.1.1.1**, click **Add** and click **Next >**.
1. On page Domain Name and DNS Servers, set **Parent domain** to **ad.lab.test** and ensure **10.1.1.8** is the DNS server. Remove any public, NAT, or unrelated DNS server, then click **Next >**.

    > These options are configured server-wide already.

1. On page WINS Servers, click **Next >**.
1. On page Activate Scope, click **No, I will activate this scope later** and click **Next >**.
1. On Completing the New Scope Wizard, click **Finish**.
