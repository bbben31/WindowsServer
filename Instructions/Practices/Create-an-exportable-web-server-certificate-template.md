# Practice: Create an exportable web server certificate template

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV2 (VMware display: VN1-SRV2; accepted display aliases: WIN-VN1-SRV2; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Enterprise CA/template administration and enrollment rights for the named certificate tasks; Local Administrator for server/guest setup. Protect private-key exports.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The enterprise CA issues WebServerexportable and CL1 has the specified enrollment permission.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV2

## Task

Duplicate the Web Server certificate template with the display name **Web Server exportable** and template name **WebServerexportable**. Make the private key exportable, grant the CL1 computer account Enroll permission, and issue the template on the enterprise root certification authority.

## Instructions

Perform these steps on VN1-SRV2.

1. Sign in as **AD\Administrator**.
1. Open **Certification Authority**.
1. In certsrv - \[Certification Authority (Local)\], expand **WORKGROUP-...-CA** and click on **Certificate Templates**.
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
1. In Properties of New Template, click **CL1$** and, under Permissions for CL1$, in the column **Allow**, click to activate **Enroll**. Click **OK**.
1. Close **Certificate Template Console**.
1. In certsrv - \[Certification Authority (Local)\], in the context-menu of **Certificate Templates**, click **New**, **Certificate Template to Issue**.
1. In Enable Certificate Templates, click **Web Server exportable** and click **OK**.
