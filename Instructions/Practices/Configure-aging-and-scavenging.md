# Practice: Configure aging and scavenging

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-the-DNS-server-role.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** DNS Administrators/delegated zone rights on the named DNS servers; Local Administrator for role installation and guest setup.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** DNS zone aging and server scavenging intervals match seven days; explain when stale records become eligible.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1

## Task

Enable aging and scavenging for all Active Directory integrated zones and enable automatic scavenging of stale records at an interval of 7 days.

> When will a stale record be removed at the earliest and the latest?

## Instructions

Perform this task on CL1.

1. Sign in as **ad\Administrator**.
1. Open **DNS**.
1. If the dialog **Connect to DNS Server** does not appear, in DNS Manager, in the context-menu of **DNS**, click **Connect to DNS server...**.
1. In Connect to DNS Server, click **The following computer**, type **vn1-srv1.ad.lab.test** below and click **OK**.
1. In **DNS-Manager**, click **vn1-srv1.ad.lab.test**.
1. In the context-menu of **vn1-srv1.ad.lab.test**, click **Set Aging/Scavenging for All Zones...**

    Note: It can take a few seconds until the context-menu appears.

1. In Server Aging/Scavenging Properties, activate **Scavenge stale resource records** and click **OK**.

    Note that the No-refresh interval and the Refresh interval are set to 7 days.

    > A stale record will be removed after 14 days at the earliest and 21 days at the latest.

1. In Server Aging/Scavenging Confirmation, activate **Apply these settings to the existing Active Directory-integrated zones** and click **OK**.

1. In **DNS Manager**, expand **vn1-srv1.ad.lab.test**, **Forward Lookup Zones** and click **ad.lab.test**.
1. In the context-menu of **ad.lab.test**, click **Properties**.

    Note, that in ad.lab.test Properties, on tab General, Dynamic updates are set to Secure only.

1. Click **Aging...**

    Note that Scavenge stale resource records is activated.

1. Click **Cancel**.
1. In **ad.lab.test Properties**, click **Cancel**.
1. In **DNS-Manager**, in the context-menu of **vn1-srv1.ad.lab.test**, click **Properties**.
1. In **vn1-srv1.ad.lab.test Properties**, click the tab **Advanced**.
1. On tab Advanced, activate **Enable automatic scavenging of stale records** and click **OK**.
