# Practice: Configure e-mail notifications in FSRM

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-File-Server-Resource-Manager.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** FSRM notification configuration contains the requested sender, recipients and mail.lab.test; email delivery is conceptual without SMTP.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10

Note: In the lab environment no real SMTP server is installed. Therefore, e-mail notification will not work. This practice demonstrates the configuration and avoids warning messages in later practices and labs.

## Task

Configure the e-mail notification settings of FSRM to use mail.lab.test as SMTP server. The from address should be fsrm@lab.test and the default administrator recipients should be fsm@lab.test.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Open **File Server Resource Manager**.
1. In File Server Resource Manager, in the left pane, in the context menu of **File Server Resource Manager**, click **Connect to Another Computer...**
1. In Connect to Another Computer, click **Another computer**, type **VN1-SRV10**, and click **OK**.
1. In the context-menu of **File Server Resource Manager**, click **Configure Options...**
1. In File Server Resource Manager Options, on tab Email Notifications, enter the values below and click **OK**.

    | Label                            | Value               |
    |----------------------------------|---------------------|
    | SMTP server name or IP address   | **mail.lab.test** |
    | Default administrator recipients | **fsrm@lab.test**  |
    | Default "From" e-mail address    | **fsrm@lab.test** |

    > In a real-world environment, you would click **Send Test E-mail** to verify the settings. In the lab environment, this would fail. Therefore, do not click the button.
