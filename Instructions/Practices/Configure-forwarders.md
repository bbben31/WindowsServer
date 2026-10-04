# Practice: Configure forwarders

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-the-DNS-server-role.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV1 (VMware display: PM-SRV1; accepted display aliases: WIN-PM-SRV1; existing); PM-SRV2 (VMware display: PM-SRV2; accepted display aliases: WIN-PM-SRV2; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN2-SRV1 (VMware display: VN2-SRV1; accepted display aliases: WIN-VN2-SRV1; existing).  Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** DNS Administrators/delegated zone rights on the named DNS servers; Local Administrator for role installation and guest setup.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Approved DNS forwarders on UDP/TCP 53; public name resolution only.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** Resolve-DnsName resolves ad.lab.test via the conditional forwarder; public queries succeed only with declared outbound access.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* PM-SRV1
* PM-SRV2
* VN1-SRV1
* VN2-SRV1

## Task

On VN2-SRV1, PM-SRV1, and PM-SRV2, add the DNS servers 8.8.8.8 and 8.8.4.4 as forwarders and add vn1-srv1.ad.lab.test as conditional forwarder for ad.lab.test.

> Does the query performance for internet names improve after you added the forwarders?

> Can you resolve ad.lab.test from the DNS servers?

## Instructions

Perform this task on CL1.

1. Sign in as **ad\Administrator**.
1. Open **DNS**.

    If the dialog **Connect to DNS Server** appears, click **The following computer**, type **vn2-srv1.ad.lab.test** below and click **OK**.

1. In DNS Manager, click **vn2-srv1.ad.lab.test**.
1. In the right pane, double-click **Forwarders**.
1. In vn2-srv1.ad.lab.test Properties, on tab Forwarders, click **Edit...**
1. In Edit Forwards, in **\<Click here to add an IP Address or DNS name\>**, enter **8.8.8.8**.
1. In **\<Click here to add an IP Address or DNS name\>**, enter **8.8.4.4**.
1. Click **OK**.
1. In **vn2-srv1.ad.lab.test Properties**, on tab **Forwarders**, click **OK**.
1. In **DNS Manager**, expand **vn2-srv1.ad.lab.test** and click **Conditional Forwarders**.
1. In the context-menu of **Conditional Forwarders**, click **New Conditional Forwarder...**
1. In New Conditional Forwarder, under **DNS Domain**, type **ad.lab.test**.
1. Under IP addresses of the master servers, click **\<Click here to add an IP Address or DNS name\>** and enter **vn1-srv1.ad.lab.test**.
1. Click the faulty entry **No such host is known.** and click **Delete**.

    You can safely ignore the remaining error under **Validated**. It appears, because we have not added a reverse lookup zone yet. Moreover, we have not configured a valid IPv6 address for the DNS server.

1. Click **OK**.
1. Open **Terminal**.
1. Clear the DNS client cache and the DNS server cache of **vn2-srv1.ad.lab.test**.

    ````powershell
    $server = 'vn2-srv1.ad.lab.test'
    Clear-DnsClientCache
    Clear-DnsServerCache -ComputerName $server -Force
    ````

1. Resolve the name **microsoft.com** on the server **vn2-srv1.ad.lab.test**.

    ````powershell
    Resolve-DnsName -Name microsoft.com -Server $server
    ````

    > The response should appear very fast.

1. Resolve the name **ad.lab.test** on the server **vn2-srv1.ad.lab.test**.

    ````powershell
    Resolve-DnsName -Name ad.lab.test -Server $server
    ````

    > The query should be resolved.

Repeat the task for **pm-srv1.ad.lab.test** and **pm-srv2.ad.lab.test**. To add additional servers to DNS Manager, in the context menu of **DNS**, click **Connect to DNS Server...** and follow the instructions from step 2.
