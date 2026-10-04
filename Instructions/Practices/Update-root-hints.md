# Practice: Update root hints

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-the-DNS-server-role.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN2-SRV1 (VMware display: VN2-SRV1; accepted display aliases: WIN-VN2-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** DNS Administrators/delegated zone rights on the named DNS servers; Local Administrator for role installation and guest setup.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Approved DNS forwarders on UDP/TCP 53; public name resolution only.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** DNS root hints reflect the documented change; internal AD DNS remains authoritative.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN2-SRV1

## Task

On VN2-SRV1, delete all root hints. Verify the effect of a DNS server without forwarders or root hints. Restore the current root hints from another DNS server

> Can you resolve DNS names from the internet after you removed all DNS root hints?

## Instructions

### Desktop experience

Perform this task on CL1.

1. Sign in as **ad\Administrator**.
1. Open **DNS**.
1. In Connect to DNS Server, click **The following computer**, type **VN2-SRV1.ad.lab.test** below and click **OK**.
1. In DNS Manager, click **VN2-SRV1.ad.lab.test**.
1. In the right pane, double-click **Root Hints**.
1. In VN2-SRV1.ad.lab.test Properties, on tab Root Hints, click **Remove** multiple times until the list under **Name servers** is empty. Then, click **OK**.
1. In the message box You are about to remove the last root hint. If the DNS server is not authoritative for the root zone and is not configured for exclusive forwarding, the DNS server may not be able to resolve queries for names not stored on the local DNS server. Do you want to continue?, click **Yes**.
1. In **DNS Manager**, in the context-menu of **VN2-SRV1.ad.lab.test**, click **Clear Cache**.

    Note: It may take a few seconds until the context menu appears.

1. Open **Terminal**.
1. Resolve the name **microsoft.com** using the server **VN2-SRV1.ad.lab.test**.

    ````powershell
    Resolve-DnsName -Name microsoft.com -Server VN2-SRV1.ad.lab.test
    ````

    > You will receive an error message, because the server cannot resolve names from the internet anymore.

1. Switch to **DNS Manager**.
1. In the right pane, double-click **Root Hints**.
1. In VN2-SRV1.ad.lab.test Properties, on tab Root Hints, click **Copy from Server**.
1. In Server to Copy From, under **IP address or DNS name**, type **8.8.8.8** and click **OK**.
1. In **VN2-SRV1.ad.lab.test Properties**, on tab **Root Hints**, under **Name servers**, click the first name server with an **IP Address** of **Unknown** (most likely **a.root-servers.net**) and click **Edit...**
1. In Edit Name Server Record, click **Resolve** and click **OK**.

    The name server should have an IP address now.

    Repeat the last 2 steps for all name servers without IP addresses.

1. In **VN2-SRV1.ad.lab.test Properties**, on tab **Root Hints**, click **OK**.
1. Switch to **Terminal**.
1. Resolve the name **microsoft.com** using the server **VN2-SRV1.ad.lab.test** again.

    ````powershell
    Resolve-DnsName -Name microsoft.com -Server VN2-SRV1.ad.lab.test
    ````

    > The query should resolve again.

#### PowerShell

Perform this task on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Terminal**.
1. Remove all root hints on **vn2-srv1.ad.lab.test**

    ````powershell
    $computerName = 'vn2-srv1.ad.lab.test'
    Get-DnsServerRootHint -ComputerName $computerName | Remove-DnsServerRootHint -ComputerName $computerName
    ````

1. Clear the DNS server cache on **vn2-srv1.ad.lab.test**.

    ````powershell
    Clear-DnsServerCache -ComputerName $computerName -Force
    ````

1. Resolve the name **microsoft.com** using the server **VN2-SRV1.ad.lab.test**.

    ````powershell
    Resolve-DnsName -Name microsoft.com -Server VN2-SRV1.ad.lab.test
    ````

    > You will receive an error message, because the server cannot resolve names from the internet anymore.

1. On **vn2-srv1.ad.lab.test**, import the root hints again from **10.10.10.10**.

    ````powershell
    Import-DnsServerRootHint -NameServer 10.10.10.10 -ComputerName $computerName
    ````

1. Resolve the name **microsoft.com** using the server **VN2-SRV1.ad.lab.test** again.

    ````powershell
    Resolve-DnsName -Name microsoft.com -Server VN2-SRV1.ad.lab.test
    ````

    > The query should resolve again.
