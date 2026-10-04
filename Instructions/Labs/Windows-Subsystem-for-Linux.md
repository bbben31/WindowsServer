# Lab: Windows Subsystem for Linux

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV9 (VMware display: VN1-SRV9; accepted display aliases: WIN-VN1-SRV9; existing). At least 1 of [VN1-SRV1, VN1-SRV5]: Use the active AD DNS/controller from the documented deployment lineage; do not restart a retired DC. Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Official WSL distribution/download and Linux package-repository endpoints.

**Risk, cost and optional status:** high; local-only; optional=true. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** wsl --list --verbose shows the installed distribution/version; Linux networking/file tests pass and final uninstall leaves no exercise distribution.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision every VM, extra disk, cluster member, certificate, and client named by this lab; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Required VMs

* VN1-SRV1
* VN1-SRV5
* VN1-SRV9

## Introduction

Your developers maintain a server application that consists of components running under Windows and Linux. For easier development, you want to provide them with a machine that can run all components on a single system. Therefore, you want to evaluate Windows Subsystem for Linux.

First, you will install WSL with a distribution. Then, you want to find out how networking works and how to access files in the Linux distribution from Windows.

At the end of your evaluation, you want to uninstall the Linux distribution and WSL.

## Exercises

1. [Install Windows Subsystem for Linux](#exercise-1-install-windows-subsystem-for-linux)
1. [Work with Windows Subsystem for Linux](#exercise-2-work-with-windows-subsystem-for-linux)
1. [Uninstall Windows Subsystem for Linux](#exercise-3-uninstall-windows-subsystem-for-linux)

## Exercise 1: Install Windows Subsystem for Linux

1. [Configure nested virtualization](#task-1-configure-nested-virtualization) for VN1-SRV9
1. [Install Windows Subsystem for Linux](#task-2-install-windows-subsystem-for-linux) without a distribution
1. [Install and configure a distribution](#task-3-install-and-configure-a-distribution)

### Task 1: Configure nested virtualization

Perform this task on the VMware Workstation host.

1. Shut down **VN1-SRV9** inside Windows and wait until VMware shows it powered off.
1. Open **VM > Settings > Processors**. Enable **Virtualize Intel VT-x/EPT or AMD-V/RVI**. Set at least **3 GB** of fixed memory under **Memory**.
1. Keep the lab NIC on its declared isolated VMnet. Add a temporary **NAT (VMnet8)** adapter for WSL/package downloads; preserve AD DNS on the domain NIC and do not register the NAT address in AD DNS.
1. Start VN1-SRV9. Run `systeminfo.exe` in the guest and verify virtualization is available before installing WSL 2. If the VM cannot expose virtualization extensions, stop this optional lab and record the host limitation.

The setting belongs to VMware; the Microsoft Hyper-V parent-host command is not applicable here. See [Microsoft WSL VM prerequisites](https://learn.microsoft.com/en-us/windows/wsl/faq) and [Broadcom nested virtualization restrictions](https://knowledge.broadcom.com/external/article?articleNumber=313547). Host Hyper-V/VBS may prevent VMware nesting. Do not disable host security controls as an automatic lab step.
### Task 2: Install Windows Subsystem for Linux

Perform this task on VN1-SRV9.

1. Sign in as **ad\Administrator**.
1. Open **Terminal**.
1. Install Windows Subsystem for Linux without a distribution.

    ````powershell
    wsl --install --no-distribution
    ````

1. Restart the computer.

    ````powershell
    Restart-Computer
    ````

### Task 3: Install and configure a distribution

Perform this task on VN1-SRV9.

1. Sign in as **ad\Administrator**.
1. Open **Terminal**.
1. List the available distributions.

    ````powershell
    wsl --list --online
    ````

1. Install the latest version of Ubuntu. If you are more familiar with another distribution, feel free to install your favorite distribution.

    ````powershell
    wsl --install --distribution Ubuntu
    ````

    Wait for the download and installation to complete. This will take a few minutes.

1. List installed Linux distributions.

    ````powershell
    wsl --list --verbose
    ````

1. Launch Ubuntu.

    ````powershell
    wsl --distribution Ubuntu
    ````

1. At the prompt Create a default Unix user account, type a name for your account, e.g. your first name, and take a note.
1. At the prompts New password and Retype new password, type a secure password and take a note.

If time allows, you can install additional distributions. This will take less time than the first one.

1. Log out of Linux.

    ````bash
    logout
    ````

1. Close **Terminal**.

## Exercise 2: Work with Windows Subsystem for Linux

1. [Find out the IP addresses](#task-1-find-out-the-ip-addresses) of the Linux distribution from Windows and of the Windows Host from Linux
1. [Access files in Linux](#task-2-access-files-in-linux) home directory from Windows
1. [Update the Linux distribution](#task-3-update-the-linux-distribution)
1. [Install a graphical Linux application](#task-4-install-a-graphical-linux-application), e.g. quadrapassel
1. [Shutdown the Linux distribution](#task-5-shut-down-the-linux-distribution)

### Task 1: Find out the IP addresses

Perform this task on VN1-SRV9.

1. Open **Terminal**.
1. In Terminal, run the command ```hostname -I``` in the Linux distribution.

    ````powershell
    wsl --distribution Ubuntu hostname -I
    ````

    The displayed IP address is the IP address of the Linux distribution.

1. In Terminal, click the down chevron and click **Ubuntu**.
1. On the tab Ubuntu, find out the IP address of the Windows host.

    ````bash
    ip route show | grep -i default | awk '{ print $3}'
    ````

    The displayed IP address is the IP address of the Windows host.

### Task 2: Access files in Linux

Perform this task on VN1-SRV9.

1. Open **Terminal**.
1. In Terminal, click the down chevron and click **Ubuntu**.
1. In Ubuntu, change to the home directory.

    ````bash
    cd ~
    ````

1. Create a file in your home directory

    ````bash
    touch testfile.txt
    ````

1. Open **File Explorer**.
1. In File Explorer, expand **Linux**, **Ubuntu**, **home** and click the directory of your user.
1. In the context-menu of **testfile.txt**, click **Edit**.
1. In Notepad, type some text and, on the menu, click **File**, **Save**.
1. Close **Notepad**.
1. In **Terminal**, on the tab Ubuntu, display the content of **testfile.txt**.

    ````bash
    cat testfile.txt
    ````

### Task 3: Update the Linux distribution

Perform this task on VN1-SRV9.

1. Open **Terminal**.
1. In Terminal, click the down chevron and click **Ubuntu**.
1. In Ubuntu, fetch the latest package information from the repositories.

    ````bash
    sudo apt-get update
    ````

1. At the prompt \[sudo\] password, enter your password for the Linux distribution.
1. Upgrade all packages.

    ````bash
    sudo apt-get upgrade
    ````

1. Confirm any prompts.

This may take a few minutes.

### Task 4: Install a graphical Linux application

Perform this task on VN1-SRV9.

1. Open **Terminal**.
1. In Terminal, click the down chevron and click **Ubuntu**.
1. Install quadrapassel, which is a clone of the Tetris game.

    ````bash
    sudo apt-get install quadrapassel
    ````

1. If a prompt \[sudo\] password appears, enter your password for the Linux distribution.
1. At the prompt Do you want to continue?, enter **y**.
1. In the Windows start menu, find the app **Quadrapassel (Ubuntu)**, open it and have some fun!

### Task 5: Shut down the Linux distribution

Perform this task on VN1-SRV9.

1. Open **Terminal**.
1. List running distributions.

    ````powershell
    wsl --list --running
    ````

1. If at least one distribution was listed in the previous step, shut it down.

    ````powershell
    wsl --shutdown
    ````

1. Verify that the distribution was shut down.

    ````powershell
    wsl --list --running
    ````

    There are not running distributions.

## Exercise 3: Uninstall Windows Subsystem for Linux

1. [Uninstall a distribution](#task-1-uninstall-a-distribution)
1. [Uninstall WSL](#task-2-uninstall-wsl)

### Task 1: Uninstall a distribution

Perform this task on VN1-SRV9.

1. Open **Terminal**.
1. In Terminal list the installed distributions.

    ````powershell
    wsl --list
    ````

1. Uninstall the Linux distribution

    ````powershell
    wsl --unregister Ubuntu
    ````

1. In Terminal list the installed distributions again.

    ````powershell
    wsl --list
    ````

    The distribution you uninstalled should not be listed anymore.

### Task 2: Uninstall WSL

Perform this task on VN1-SRV9.

1. Open **Terminal**.
1. Uninstall wsl.

    ````powershell
    wsl --uninstall
    ````





After uninstalling the distribution and WSL, shut down the guest, disconnect/remove its temporary VMnet8 adapter, and restore the recorded VMware CPU/memory settings or pre-lab snapshot. Verify domain DNS still resolves.
