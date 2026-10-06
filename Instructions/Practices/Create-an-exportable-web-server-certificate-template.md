# Practice: Create an exportable web server certificate template

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. VN1-SRV2 is a domain-joined member with its final hostname/static lab address. Create the disposable enterprise root CA only if absent; preserve any existing intended CA and verify public-root trust before enrollment. The local Server Manager/certsrv GUI preparation uses an explicitly selected VN1-SRV2 Desktop Experience member/CA lineage; do not convert an installed Core server in place.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV2 (VMware display: VN1-SRV2; accepted display aliases: WIN-VN1-SRV2; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Authorized disposable Enterprise Administrator and root-domain Domain Administrator for initial enterprise CA configuration; delegated CA/template administration and named computer Read/Enroll rights afterward. Local Administrator for guest setup; protect private-key exports.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The enterprise CA issues WebServerexportable and CL1 has the specified enrollment permission.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV2

## Setup: prepare the disposable enterprise CA

Use this CA only in the isolated learner forest. Do not configure a new CA over an existing CA or import production keys. Record the active domain controller/DNS address and the selected core or enterprise profile; VN1-SRV2 must be a domain-joined member server with its final hostname and a recorded static lab address before CA installation.

The local Server Manager/certsrv GUI below requires the **Windows Server Desktop Experience** CA-member baseline on VN1-SRV2. Verify this installation type before starting; the generic Server Core member image does not supply that local workflow. If the current guest is Core, prepare the coordinated disposable Desktop Experience CA baseline before these steps, preserving its recorded hostname/address and directory lineage. Do not attempt an in-place Core-to-Desktop conversion or overwrite an existing CA/private key. A remote-management/unattended Core workflow is a separate alternative only when fully documented for the selected version.

1. On **VN1-SRV2**, sign in with the disposable lab account authorized as both Enterprise Administrator and root-domain Domain Administrator. Verify the domain, hostname, DNS resolution and secure channel first. If **Certification Authority** already shows the intended enterprise CA and `Get-Service CertSvc` is running, record its CA name and skip installation; do not create a second root.
1. In **Server Manager > Manage > Add Roles and Features**, choose **Role-based or feature-based installation** and **VN1-SRV2**. Add **Active Directory Certificate Services** and its management tools. Select only the **Certification Authority** role service, install it, and wait for completion.
1. Select **Configure Active Directory Certificate Services on the destination server**. Confirm the authorized lab credentials. Select **Certification Authority**, **Enterprise CA**, **Root CA**, and **Create a new private key**. Use **RSA#Microsoft Software Key Storage Provider**, **2048** bits or stronger, and **SHA256**. Name the CA **Adatum-Lab-Root-CA**, set a disposable-lab validity period such as **2 years**, retain the recorded database/log locations, and select **Configure**. Record the actual CA name if the intended CA already existed. This follows [Microsoft's enterprise CA installation procedure](https://learn.microsoft.com/en-us/windows-server/networking/core-network-guide/cncg/server-certs/install-the-certification-authority).
1. Open **Certification Authority**. Verify the recorded CA is running and has **Certificate Templates**. On CL1, run `gpupdate /force`, then use **Certificates (Local Computer) > Trusted Root Certification Authorities > Certificates** to verify the CA's public root certificate has arrived through AD. If it has not, wait/check domain policy and CA publication rather than accepting untrusted certificates. For workgroup clients used later, export only the public root certificate and import it into their trusted-root store after checking its recorded thumbprint.
1. Take the coordinated AD/CA recovery point required by the selected lab before issuing certificates. Keep any later PFX exports and passwords private and delete exercise exports when no dependent exercise needs them. Retain the CA until its dependent RMS/RDS/AD FS/WAC tasks finish.

## Task

Duplicate the Web Server certificate template with the display name **Web Server exportable** and template name **WebServerexportable**. Make the private key exportable, grant the CL1 computer account Enroll permission, and issue the template on the enterprise root certification authority.

## Instructions

Perform these steps on VN1-SRV2.

1. Sign in as **AD\Administrator**.
1. Open **Certification Authority**.
1. In certsrv - \[Certification Authority (Local)\], expand the recorded **Adatum-Lab-Root-CA** (or the verified existing enterprise CA name) and click **Certificate Templates**. A standalone WORKGROUP CA cannot issue AD certificate templates.
1. In the context-menu of **Certificate Templates**, click **Manage**.
1. In Certificate Templates Console, in the context-menu of **Web Server**, click **Duplicate Template**.
1. In Properties of New Template, the tab **General**.
1. On the tab General, under **Template display name**, type **Web Server exportable**. Ensure that the **Template name** is **WebServerexportable**. Click the tab **Request Handling**.
1. On the tab Request Handling, click to activate **Allow private key to be exported**. Click the tab **Security**.
1. On the tab Security, click **Add...**.
1. In Select Users, Computers, Service Accounts, or Groups, click **Object Types...**.
1. In Object Types, click to activate **Computers** and click **OK**.
1. In Select Users, Computers, Service Accounts, or Groups, under **Enter the object names to select**, type **CL1** click **Check Names**.

    The CL1 should be underlined now.

1. Click **OK**.
1. In Properties of New Template, click **CL1$** and, under Permissions for CL1$, in the column **Allow**, activate **Read** and **Enroll**. Keep enrollment limited to the named lab computer; do not grant all users exportable-key enrollment. Click **OK**.
1. Close **Certificate Template Console**.
1. In certsrv - \[Certification Authority (Local)\], in the context-menu of **Certificate Templates**, click **New**, **Certificate Template to Issue**.
1. In Enable Certificate Templates, click **Web Server exportable** and click **OK**.
1. Verify **Web Server exportable** is listed under the CA's **Certificate Templates**. On CL1, open **Certificates (Local Computer)**, choose **Personal > Certificates > All Tasks > Request New Certificate**, and confirm the template is available through the AD enrollment policy. Cancel this check without creating a certificate; request the precise subject/SANs in the dependent lab.
