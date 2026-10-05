# Practice: Install Windows Server with Desktop Experience manually

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Base-Images-and-Templates.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** VN1-SRV20 (VMware display: VN1-SRV20; accepted display aliases: WIN-VN1-SRV20; created in the designated task; not a preflight prerequisite). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** VMware VM creation/settings permission and guest Local Administrator for OS installation; no AD administration until domain-join steps.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The created VMware VN1-SRV20 boots Desktop Experience and its evaluation version is recorded.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* Created during exercise: VN1-SRV20


## Task

Create VN1-SRV20 manually in VMware Workstation Pro 17 and install Windows Server Datacenter Evaluation with Desktop Experience. The source VM-creation helper is intentionally not included.

## Instructions

Perform these steps on the host.

1. In VMware Workstation, create a VM named `VN1-SRV20`, use UEFI, attach the verified ISO from `C:\WindowsServerLab\ISOs\<WINDOWS_SERVER_2025_EVALUATION_ISO>`, and connect its NIC to VMnet20.
1. Start the VM and open its VMware console.
1. On the message Press any key to boot from CD or DVD, press any key within a few seconds. If fail to do so, and the VM tries to start PXE over IPv4, on the menu, click **Action**, **Reset...**.
1. In Windows Server Setup, on page Select language settings, configure **Time and currency format**  as you wish and click **Next**.
1. On page Select keyboard settings, configure the **Keyboard or input method** as you wich and click **Next**.
1. On page Select setup option, ensure **Install Windows Server** is selected, click **I agree everything will be deleted including files, apps, and settings** and click **Next**.
1. On page Select image, click **Windows Server 2025 Datacenter Evaluation (Desktop Experience)** and click **Next**.
1. On page Applicable notices and license terms, click **Accept**.
1. On page Select location to install Windows Server, explore the options and click **Next**.
1. On page Ready to install, click **Install**.

Do not wait for the installation to finish.
