# Practice: Work without and with Enhanced Session Mode

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Create-and-install-a-virtual-machine.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Enable VMware processor virtualization extensions on powered-off outer hosts; run Hyper-V commands only inside the declared nested lab layer.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV1 (VMware display: PM-SRV1; accepted display aliases: WIN-PM-SRV1; existing); PM-SRV20 (Hyper-V name: PM-SRV20; accepted display aliases: WIN-PM-SRV20; existing-inner); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the explicitly declared nested Hyper-V hosts and inner guests; cluster administrator for cluster changes. VMware settings permission on the outer host.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The dedicated inner Hyper-V connection demonstrates both session modes and their intended redirection settings.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Optional nested-Hyper-V exercise:** Enhanced Session Mode is a Hyper-V feature. This procedure requires a dedicated nested Hyper-V guest and is not part of the default VMware path.

## Required VMs

* CL1
* PM-SRV1
* PM-SRV20
* VN1-SRV1

## Task

In PM-SRV20, explore the clipboard features without and with Enhanced Session Mode.

> Can you copy text from the virtual machine into some other application on the same virtual machine?

> Can you paste clipboard text from the virtual machine to the host in standard session mode?

> Can you paste clipboard text from the virtual machine to the host in Enhanced Session Mode?

> Can you paste clipboard text from the client computer directly into the virtual machine in Enhanced Session Mode?

## Instructions

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Hyper-V Manager**.
1. In Hyper-V Manager, click **PM-SRV1**.
1. In the context-menu of **PM-SRV20**, click **Connect...**.
1. In PM-SRV20 on PM-SRV1 - Virtual Machine Connection, on the menu click **Action**, **Ctrl+Alt+Delete**.
1. At the prompt **Enter credentials for Administrator or hit ESC to switch users/sign-in methods**, enter the local Administrator password.
1. In SConfig, use the mouse to select the **Computer name** (**PM-SRV20**) and press CTRL + C.
1. Enter **15**.
1. Press CTRL + V.

    > You can copy and paste within the virtual machine.

1. Press ESC.
1. On CL1, open **Notepad**.
1. In Notepad, press CTRl + V.

    > Nothing happens or some other text gets pasted. The virtual machine does not share a clipboard with the client computer.

1. Close **PM-SRV20 on PM-SRV1 - Virtual Machine Connection**.
1. Switch to **Hyper-V Manager**.
1. In Hyper-V Manager, click **PM-SRV1**.
1. In the context-menu of **PM-SRV1**, click **Hyper-V Settings**.
1. In Hyper-V Settings for PM-SRV1, in the left pane, click **Enhanced Session Mode Policy**.
1. Under Enhanced Session Mode Policy, activate **Allow enhanced session mode**.
1. In the left pane, click **Enhanced Session Mode**.
1. Under Enhanced Session Mode, ensure **Use enhanced session mode** is activated.
1. Click **OK**.
1. In **Hyper-V Manager**, under **Virtual Machines**,  double-click **PM-SRV20**.
1. In Connect to VM-SRV20, select a resolution that fits your purposes (1366 by 768 pixels are fine) and click **Connect**.
1. In PM-SRV20 on PM-SRV1 - Virtual Machine Connection, at the Password prompt, enter the password of the local Administrator.
1. Exit to SConfig.

    ````powershell
    Exit
    ````

1. In SConfig, use the mouse to select the **Computer name** (**PM-SRV20**) again and press CTRL + C.
1. On CL1, switch to **Notepad**.
1. Press CTRL + V.

    > The computer name is pasted. The clipboard between the virtual machine and the client computer is shared in Enhanced session mode.

1. In Notepad, type **Get-NetIPConfiguration**, select the text and press CTRL + C.
1. Switch to **PM-SRV20 on PM-SRV1 - Virtual Machine Connection**.
1. In SConfig, enter **15**.
1. At the prompt, press CTRL + V.

    > You can paste the text from the the client computer into the virtual machine.

1. Press ENTER.

    The current IP configuration will be returned.

Leave the virtual machine in its current state for the next exercise.
