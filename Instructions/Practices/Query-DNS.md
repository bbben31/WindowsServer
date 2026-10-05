# Practice: Query DNS

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-the-DNS-server-role.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN2-SRV1 (VMware display: VN2-SRV1; accepted display aliases: WIN-VN2-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Standard lab user for local read-only queries and user-owned files; no local elevation. If the explicitly documented system-help prerequisite is selected under Windows PowerShell 5.1, use a separate authorized elevated session.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Approved DNS forwarders on UDP/TCP 53; public name resolution only.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Resolve-DnsName returns the expected authoritative lab records; classify public-query failures separately from internal DNS.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN2-SRV1

## Task

Resolve the name **microsoft.com**. Repeat the command several times.

> Why are you receiving more than one IP address?

> What happens to the order of the IP addresses?

> Why did the TTL values decrease?

Resolve the name **microsoft.com** using the local DNS client cache.

> Can you resolve the name using the local DNS client cache?

Resolve the name **etc.at** using the local DNS client cache.

> Can you resolve the name using the local DNS client cache?

Resolve the name **etc.at** without using the local cache, then resolve the name **etc.at** using the local DNS client cache again.

> Can you resolve the name using the local DNS client cache now?

Resolve the MX record for **microsoft.com**. Query the SRV record for **_sip._tls.microsoft.com**. Resolve the SOA record for **microsoft.com**. Query for the name servers of **microsoft.com**.

Clear the DNS client cache and the DNS server cache of **VN1-SRV1**. Then, query for the name **office.com**. Clear the DNS client cache and the DNS server cache of **VN2-SRV1**. Resolve the name **office.com** using **VN2-SRV1** as DNS server without changing the dns client settings.

> Why did you receive an answer?

> Why did response from VN2-SRV1 take significantly longer than from VN1-SRV1?

Resolve the name **ad.lab.test** using **VN2-SRV1** as DNS server without changing the DNS client settings.

> Why do you get the error message **DNS name does not exist**?

Display the contents of the DNS client cache.

## Instructions

Perform this task on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Windows Terminal**
1. Resolve the name **microsoft.com**.

    ````powershell
    Resolve-DnsName -Name microsoft.com
    ````

    > You receive more than one IP address, because there are multiple A records for microsoft.com with different IP addresses. This can serve security or load balancing purposes.

    Repeat the command several times.

    > The IP addresses are reordered with each query. This is called DNS round robin and servers load balancing purposes.

    > The TTL values decrease, because the response is served from a cache. The TTL indicates the seconds, the record is allowed to be kept in the cache.

1. Resolve the name **microsoft.com** using the local DNS client cache.

    ````powershell
    Resolve-DnsName -Name microsoft.com -CacheOnly
    ````

    > Most likely, you will receive a response, because the entry is present in the cache.

1. Resolve the name **etc.at** using the local DNS client cache.

    ````powershell
    Resolve-DnsName -Name etc.at -CacheOnly
    ````

    > Most likely, you will receive an error message, because the record is not present in the cache.

1. Resolve the name **etc.at** without using the local cache.

    ````powershell
    Resolve-DnsName -Name etc.at -DnsOnly
    ````

1. Resolve the name **etc.at** using the local DNS client cache again.

    ````powershell
    Resolve-DnsName -Name etc.at -CacheOnly
    ````

    > Most likely, you will receive an error message, because the record still is not present in the cache.

1. Resolve the MX record for **microsoft.com**.

    ````powershell
    Resolve-DnsName -Name microsoft.com -Type MX
    ````

1. Query the SRV record for **_sip._tls.microsoft.com**.

    ````powershell
    Resolve-DnsName -Name _sip._tls.microsoft.com -Type SRV
    ````

1. Resolve the SOA record for **microsoft.com**. Make sure, all properties are in the output on the screen.

    ````powershell
    Resolve-DnsName -Name microsoft.com -Type SOA | Format-List *
    ````

1. Query for the name servers of **microsoft.com**.

    ````powershell
    Resolve-DnsName -Name microsoft.com -Type NS
    ````

1. Clear the DNS client cache and the DNS server cache of **VN1-SRV1**. Then, query for the name **office.com**.

    ````powershell
    Clear-DnsClientCache
    Clear-DnsServerCache -ComputerName vn1-srv1.ad.lab.test -Force
    Resolve-DnsName -Name office.com
    ````

1. Clear the DNS client cache and the DNS server cache of **VN2-SRV1**. Resolve the name **office.com** using **VN2-SRV1** as DNS server without changing the DNS client settings.

    ````powershell
    Clear-DnsClientCache
    Clear-DnsServerCache -ComputerName VN2-SRV1.ad.lab.test -Force
    Resolve-DnsName -Name office.com -Server VN2-SRV1.ad.lab.test
    ````

    > VN2-SRV1 uses the DNS root servers to resolve the query.

    > VN1-SRV1 uses a DNS forwarder with a large cache, which boosts the DNS query performance on small networks.

    If you did not notice the difference, you may repeat the commands of the last two steps, but include the ````Resolve-DnsName```` cmdlet in the ````Measure-Command```` cmdlet, e.g.,

    ````powershell
    Clear-DnsClientCache
    Clear-DnsServerCache -ComputerName vn1-srv1.ad.lab.test -Force
    Measure-Command { Resolve-DnsName -Name office.com }
    Clear-DnsClientCache
    Clear-DnsServerCache -ComputerName VN2-SRV1.ad.lab.test -Force
    Measure-Command {
        Resolve-DnsName -Name office.com -Server VN2-SRV1.ad.lab.test
    }
    ````

1. Resolve the name **ad.lab.test**.

    ````powershell
    Resolve-DnsName -Name ad.lab.test
    ````

    > You should get the IP address 10.10.10.10 as response.

1. Resolve the name **ad.lab.test** using **VN2-SRV1** as DNS server without changing the DNS client settings.

    ````powershell
    Resolve-DnsName -Name ad.lab.test -Server VN2-SRV1.ad.lab.test
    ````

    > Why do you get the error message **DNS name does not exist**?

1. Display the contents of the DNS client cache.

    ````powershell
    Get-DnsClientCache
    ````
