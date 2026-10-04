# Practice: Explore Windows Terminal

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-Windows-Terminal.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Microsoft Store and its package distribution endpoints.

**Risk, cost and optional status:** low; local-only; optional=true. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** Terminal reports its updated version and the requested shell tabs, shortcuts and settings work.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1

## Task

On CL1, update Windows Terminal to the latest version. In Windows Terminal, query the current PowerShell version. In Windows Terminal, in a Command Prompt tab, list the contents of the user profile folder. List the contents of C:\Windows\System32 including sub directories. Explore the shortcuts from the course slide. Explore Windows Terminal settings.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. Open **Microsoft Store**.
1. In Microsoft Store, click **Library** (it may display as **Bibliothek**).
1. In Library, find **Windows Terminal** and click **Update** next to it.
1. From the context-menu of **Start** (you can press WIN + X), launch **Terminal**.
1. In Terminal, on the tab **Administrator: Windows PowerShell**, execute

    ````powershell
    $PSVersionTable
    ````

1. Click **+** to open a new tab with the default command line interpreter.
1. Click the down arrow and click **Command Prompt** (it may display as **Eingabeaufforderung**).
1. Explore the context-menu of a tab. You may change the color or rename a tab, if you want.
1. List the contents of the current directory.

    ````shell
    dir
    ````

1. Show the help for the dir command.

    ````shell
    dir /?
    ````

1. Change to **C:\Windows\System32**.

    ````shell
    cd c:\Windows\System32
    ````

1. List the contents of the current directory including subdirectories

    ````shell
    dir /s
    ````

1. Use the up/down keys to scroll through the command history.
1. Press Alt + Shift + +. The tab splits vertically. To the right, a Windows PowerShell prompt should appear.
1. Press Alt + Shift + -. The right section split horizontally. At the bottom, a Windows PowerShell prompt should appear.
1. Press Alt + Left. The cursor should move to the left section.
1. Press Alt + Shift + D. A new section with the CMD.EXE prompt should appear.
1. Press Alt + Shift + Left/Right. The vertical divider should move.
1. Press Alt + Right. The cursor should move to the top-right section.
1. Press Alt + Down. The cursor should move to the bottom-right section.
1. Press Alt + Shift + Up/Down. The right horizontal divider should move.
1. Press Ctrl + Shift + W to close the bottom-right section.
1. Press Ctrl + Shift + P and explore the command palette.
1. Click the down arrow and **Settings** (may display as **Einstellungen**) and explore the available settings.
