# Practice: Manage the status of a virtual machine

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Create-and-install-a-virtual-machine.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Enable VMware processor virtualization extensions on powered-off outer hosts; run Hyper-V commands only inside the declared nested lab layer.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV1 (VMware display: PM-SRV1; accepted display aliases: WIN-PM-SRV1; existing); PM-SRV20 (Hyper-V name: PM-SRV20; accepted display aliases: WIN-PM-SRV20; existing-inner); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the explicitly declared nested Hyper-V hosts and inner guests; cluster administrator for cluster changes. VMware settings permission on the outer host.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The inner guest moves through the requested running/paused/saved/off states and resumes with the expected state.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Optional nested-Hyper-V exercise:** Hyper-V Manager steps apply only to a dedicated nested Hyper-V guest; VMware Workstation controls the default lab VMs.

## Required VMs

* CL1
* PM-SRV1
* PM-SRV20
* VN1-SRV1

## Task

Save the virtual machine PM-SRV20.

> What happens to the memory occupied by the virtual machine?

Start the virtual machine PM-SRV20.

> What is the state of the virtual machine after the restart?

Pause the virtual machine PM-SRV20.

> What happens to the virtual machine when paused?

> Does the virtual machine consume CPU resources?

> Does the virtual machine occupy memory on the host?

Shut down the virtual machine PM-SRV20 from Hyper-V.

> Can you shut down the virtual machine from Hyper-V Manager gracefully?

Turn off the virtual machine PM-SRV20.

> Does the virtual machine shut down gracefully?

Reset the virtual machine PM-SRV20.

> Does the virtual machine shut down gracefully?

## Instructions

Perform this task on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Hyper-V Manager**.
1. In Hyper-V Manager, click **PM-SRV1**.
1. Under virtual machines, in the context-menu of **PM-SRV20**, click **Save**. Wait until **State** shows **Saved**.

    > The memory occupied by the virtual machine is released.

1. In the context-menu of **PM-SRV20**, click **Connect...**.
1. In PM-SRV20 on PM-SRV1 - Virtual Machine Connection, on the menu, click **Action**, **Start**.
1. In Connect to PM-SRV20, click **Connect**.
1. At the Password prompt, enter the password of the local Administrator.

    > The state of the virtual machine should be the same as when you saved the virtual machine.

1. Switch to **Hyper-V Manager**.
1. Under Virtual Machines, in the context-menu of **PM-SRV20**, click **Pause**. Wait until **State** shows **Paused**.
1. Switch to **PM-SRV20 on PM-SRV1 - Virtual Machine Connection**

    > The PM-SRV20 on PM-SRV1 - Virtual Machine Connection will be darkened. You cannot interact with the guest operating system anymore.
    
    > The virtual machine does not consume CPU resources anymore
    
    > The memory is still occupied.

1. On the menu, click **Action**, **Resume**.
1. In **Connect to PM-SRV20**, click **Connect**.

    > You can interact with the guest operating system again.

1. On the menu, click **View**. If there is a checkmark beside **Enhanced Session** click it to deactivate the Enhanced Session Mode.
1. On the menu, click **Action**, **Shut Down...**.
1. In the message box Shut Down Machine, click **Shut Down**.

    Alternatively, you can initiate the shut down from the context-menu of the virtual machine in Hyper-V Manager.

    > You can observe the virtual machine to shut down gracefully.

1. On the menu, click **Action**, **Start**.
1. Close **Connect to PM-SRV20** (do not enter Enhanced Session Mode).
1. On the menu, click **View**. If there is a checkmark beside **Enhanced Session** click it to deactivate the Enhanced Session Mode.
1. On the menu, click **Action**, **Turn Off...**.
1. In the message box Turn Off Machine, click **Turn Off**.

    Alternatively, you can turn off the virtual machine from the context-menu in Hyper-V Manager.

    > The virtual machine is turned off immediately without a graceful shut down.

1. On the menu, click **Action**, **Start**.
1. Close **Connect to PM-SRV20** (do not enter Enhanced Session Mode).
1. On the menu, click **View**. If there is a checkmark beside **Enhanced Session** click it to deactivate the Enhanced Session Mode.
1. On the menu, click **Action**, **Reset...**.
1. In the message box Reset Machine, click **Reset**.

    Alternatively, you can reset the virtual machine from the context-menu in Hyper-V Manager.

    > The virtual machine is reset immediately without a graceful shut down.
