# Practice: Configure nested virtualization

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Provision a dedicated VMware guest as an intermediate Hyper-V host with two inner WIN-PM-SRV1/WIN-PM-SRV2 VMs. These commands run inside that host, never on the outer Windows VMware host. Enable VMware processor virtualization extensions on powered-off outer hosts; run Hyper-V commands only inside the declared nested lab layer. HV-MGMT is the dedicated outer VMware Windows guest hosting the two inner PM VMs; enable its VMware virtualization extensions and install Hyper-V before this optional practice.

**Machines and network profile:** PM-SRV1 (Hyper-V name: WIN-PM-SRV1; accepted display aliases: WIN-PM-SRV1; existing-inner); PM-SRV2 (Hyper-V name: WIN-PM-SRV2; accepted display aliases: WIN-PM-SRV2; existing-inner); HV-MGMT (VMware display: HV-MGMT; existing). Dedicated isolated VMware custom VMnet for HV-MGMT and the inner PM hosts; map their inner Hyper-V switches explicitly. This separate optional topology does not replace the direct VMware PM hosts used elsewhere.

**Permissions:** Local Administrator on the explicitly declared nested Hyper-V hosts and inner guests; cluster administrator for cluster changes. VMware settings permission on the outer host.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=true. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** The explicitly named inner Hyper-V VMs show fixed 4 GB memory, exposed extensions and MAC spoofing; inner virtualization starts.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Optional nested-Hyper-V exercise:** The Hyper-V commands below target a nested Hyper-V guest, not the Windows 11 VMware host. Do not run them against VMware Workstation VMs.

## Required VMs

* HV-MGMT
* PM-SRV1 (inner Hyper-V guest/role)
* PM-SRV2 (inner Hyper-V guest/role)

## Task

For WIN-PM-SRV1 and WIN-PM-SRV2 disable dynamic memory, set the memory to 4 GB, activate MAC address spoofing on the network adapters and expose virtualization extensions to the virtual machines.

## Instructions

Perform these steps inside the declared nested Hyper-V host.

1. Open **Hyper-V Manager**.
1. In Hyper-V Manager, click the name of your computer.
1. Under Virtual Machines, in the context-menu of **WIN-PM-SRV1**, click **Shut down...**.
1. In the context-menu of **WIN-PM-SRV1**, click **Settings...**
1. In Settings for WIN-PM-SRV1, in the left pane, click **Memory**.
1. Under Memory, in **RAM**, type **4096**. Deactivate **Enable Dynamic Memory**.
1. In the left pane, expand the first **Network Adapter** and click **Advanced Features**.
1. Under Advanced Features, **MAC address**, activate **Enable MAC address spoofing**.
1. In the left pane, expand the second **Network Adapter** and click **Advanced Features**.
1. Under Advanced Features, **MAC address**, activate **Enable MAC address spoofing** and click **OK**.
1. Run **Windows PowerShell** or **Terminal** with Administrator rights.
1. In Windows PowerShell or Terminal, for **WIN-PM-SRV1** expose the virtualization extensions to the virtual machine.

    ````powershell
    Set-VMProcessor -VMName 'WIN-PM-SRV1' -ExposeVirtualizationExtensions $true
    ````

1. Switch to **Hyper-V Manager**.
1. In the context-menu of **WIN-PM-SRV1**, click **Start**.

Repeat this task from step 3 for **WIN-PM-SRV2**.
