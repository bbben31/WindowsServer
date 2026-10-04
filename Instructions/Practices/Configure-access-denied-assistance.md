# Practice: Configure Access-Denied-Assistance

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-File-Server-Resource-Manager.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** FSRM access-denied settings match the requested message; document that actual email requires a separate SMTP service.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10

## Task

Configure Access-Denied assistance and enable requests by e-mail.

## Instructions

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. Open **File Server Resource Manager**.
1. In File Server Resource Manager, in the left pane, in the context menu of **File Server Resource Manager**, click **Connect to Another Computer...**
1. In Connect to Another Computer, click **Another computer**, type **VN1-SRV10**, and click **OK**.
1. In the context-menu of **File Server Resource Manager**, click **Configure Options...**
1. In File Server Resource Manager Options, click the tab **Access-Denied Assistance**.
1. On the tab Access-Denied Assistance, activate the checkbox **Enable access-deneid assistance**.
1. Click the button **Configure email requests...**
1. In Access-Denied Assistance, activate the checkbox **Enable users to request assistance** and click **OK**.
1. In **File Server Resource Manager Options**, click **OK**.
