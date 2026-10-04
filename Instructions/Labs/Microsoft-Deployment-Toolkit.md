# Lab: Microsoft Deployment Toolkit

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-the-Microsoft-Deployment-Toolkit.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV20 (VMware display: VN1-SRV20; accepted display aliases: WIN-VN1-SRV20; created); VN1-SRV21 (VMware display: VN1-SRV21; accepted display aliases: WIN-VN1-SRV21; created); VN1-SRV8 (VMware display: VN1-SRV8; accepted display aliases: WIN-VN1-SRV8; existing).  Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Official Microsoft product download endpoints and installer dependencies.

**Risk, cost and optional status:** high; local-only; optional=true. local-only Historical optional compatibility exercise; use only isolated disposable legacy media from official sources. Skip installation if official media/support prerequisites cannot be met.

**Success verification:** The isolated legacy task sequence deploys only the disposable Server 2022 target; otherwise record a conceptual skip.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision every VM, extra disk, cluster member, certificate, and client named by this lab; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.

> **Legacy compatibility gate:** Microsoft has [retired MDT](https://learn.microsoft.com/en-us/troubleshoot/mem/configmgr/mdt/mdt-retirement). Preserve this lab for task-sequence and deployment-share concepts only. Run it, if at all, in an isolated disposable Server 2022 snapshot with the exact legacy ADK/WinPE combination; it is not a supported Windows 11 or Windows Server 2025 deployment path.




## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV20 (created during this exercise)
* VN1-SRV21 (created during this exercise)
* VN1-SRV8

## Setup

1. In VMware Workstation, open the settings for **CL1**, select **CD/DVD**, choose **Use ISO image file**, and select `C:\WindowsServerLab\ISOs\2022_x64_EN_Eval.iso`. Connect the drive only for the import steps that require it.
1. On **CL1**, sign in as **ad\administrator**.
1. On **VN1-SRV8**, sign in as **ad\administrator**.

## Introduction

Adatum wants to automate some steps when deploying new servers. This historical scenario demonstrates how MDT deployment shares and task sequences worked before the product was retired.

## Exercices

1. [Configure a Windows Server installation in Microsoft Deployment Toolkit](#exercise-1-configure-a-windows-server-installation-in-microsoft-deployment-toolkit)
1. [Install a Windows Server using the Microsoft Deployment Toolkit](#exercise-2-install-a-windows-server-using-the-microsoft-deployment-toolkit)
1. [Integrate MDT with WDS](#exercise-3-integrate-mdt-with-wds)

## Exercise 1: Configure a Windows Server installation in Microsoft Deployment Toolkit

1. [Prepare a file share](#task-1-prepare-a-file-share) for Microsoft Deployment Toolkit on VN1-SRV8
1. [Configure a deployment share](#task-2-configure-a-deployment-share) and configure localization settings both for the Windows PE phase, and the final operating system
1. [Import the operating system](#task-3-import-the-operating-system) Windows Server 2022
1. [Create a task sequence](#task-4-create-a-task-sequence) to install Windows Server 2022 Datacenter

### Task 1: Prepare a file share

Perform this task on CL1.

1. Open **Server Manager**.
1. In Server Manager, click **File and Storage Services**, **Shares**.
1. Under SHARES, click **Tasks**, **New Share...**
1. In New Share Wizard, on page Select Profile, ensure **SMB Share - Quick** is selected, and click **Next >**.
1. On page Share Location, under **Server**, click **VN1-SRV8**. Under **Share location**, click **R:**. Click **Next >**.
1. On page Share Name, beside **Share name**, type **MDT** and click **Next >**.
1. On page Configure share settings, click **Next >**.

    You may change the settings on this page, if you want.

1. On page Permissions, click **Customize permissions...**
1. In Advanced Security Settings for MDT, on tab Permissions, click **Disable inheritance**
1. In Block inheritance, click **Convert inherited permissions into explicit permissions on this object**.
1. In **Advanced Security Settings for MDT**, on tab **Permissions**, under **Permission entries**, click the entry **Users (VN1-SRV8\Users) | Allow | Special** and click **Remove**.
1. Click the tab **Share**.
1. On the tab Share, click **Add**.
1. In Permission Entry for MDT, click **Select a principal**.
1. In Select User, Computer, Service Account, or Group, click **Locations...**.
1. In Locations, click **VN1-SRV8.ad.lab.test** and click **OK**.
1. In **Select User, Computer, Service Account, or Group**, under **Enter the object name to select**, type **Users** and click **OK**.
1. In **Permission Entry for MDT**, ensure that beside **Type** **Allow** is selected, and below **Permissions**, **Read** is activated only. Click **OK**.
1. In **Advanced Security Settings for MDT**, on tab **Share**, click **Add**.
1. In Permission Entry for MDT, click **Select a principal**.
1. In Select User, Computer, Service Account, or Group, under **Enter the object name to select**, type **Administrators** and click **OK**.
1. In **Permission Entry for MDT**, ensure that beside **Type** **Allow** is selected. Activate the checkbox beside **Full Control** and click **OK**.
1. In **Advanced Security Settings for MDT**, on tab **Share**, under **Permission entries**, click then entry **Everyone** and click **Remove**. Click **OK**.
1. In **New Share Wizard**, on page **Permissions**, click **Next >**.
1. On page Confirmation, click **Create**.
1. On page Results, click **Close**.

### Task 2: Configure a deployment share

Perform this task on CL1.

1. Open **Deployment Workbench**.
1. In DeploymentWorkbench, in the context-menu of **Deployment Shares**, click **New Deployment Share**.
1. In New Deployment Share Wizard, on page Path, under **Deployment share path**, type **\\\\VN1-SRV8\\MDT** and click **Next**.
1. On page Descriptive Name, click **Next**.
1. On page Options, deactivate all checkboxes and click **Next**.
1. On page Summary, click **Next**.

    Wait for the progress. This should take a few seconds only.

1. On page Confirmation, click **Finish**.
1. In **DeploymentWorkbench**, expand **Deployment Shares**.
1. In the context-menu of **MDT Deployment Share (\\\\VN1-SRV8\\MDT)**, click **Properties**.
1. In MDT Deployment Share (\\\\VN1-SRV8\\MDT) Properties, on tab General, under **Platforms Supported**, deactivate the checkbox **x86**. Click the tab **Rules**.
1. On the tab Rules, at the end, add the following lines and click **Apply**.

    ````ini
    KeyboardLocalePE=0407:00000407
    SkipLocaleSelection=YES
    SkiptimeZone=YES
    UserLocale=de-AT
    KeyboardLocale=0407:00000407
    TimeZoneName=W. Europe Standard Time
    ````

    *Note*: The code above configures a German keyboard, an Austria locale, and the CET time zone. You may want to customize these values for your locale. For **KeyboardLocalePE** and **KeyboardLocale**, find the keyboard identifiers under <https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-language-pack-default-values>. If the code on that page is ````0x00000807````, then use ````0807:00000807```` in the rules. For UserLocale, you can find out your current locale by executing the following PowerShell command.

    ````powershell
    Get-WinSystemLocale
    ````

    To find out your current time zone, use this PowerShell command

    ````powershell
    Get-TimeZone
    ````

1. Click **Edit Bootstrap.ini**.
1. In Bootstrap - Editor, at the end, add the following line.

    ````ini
    KeyboardLocalePE=0407:00000407
    ````

    *Note*: Ensure, you use the same code as in rules above.

1. Close ***Bootstrap - Editor** and save the file.
1. In **MDT Deployment Share (\\\\VN1-SRV8\\MDT) Properties**, click **OK**.
1. In **DeploymentWorkbench**, in the context-menu of **MDT Deployment Share (\\\\VN1-SRV8\\MDT)**, click **Update Deployment Share**.
1. In Update Deployment Share Wizard, on page **Options**, click **Next**.
1. On page Summary, click **Next**.

    Wait for the progress. This will take about two minutes.

1. On page Confirmation, click **Finish**.

### Task 3: Import the operating system

Perform this task on CL1.

1. Open **Deployment Workbench**.
1. In DeploymentWorkbench, expand **Deployment Shares**, **MDT Deployment Share (\\\\VN1-SRV8\\mdt)**.
1. In the context-menu of **Operating Systems**, click **Import Operating System**.
1. In the Import Operating System Wizard, on page OS Type, ensure **Full set of source files** is selected, and click **Next**.
1. On page Source, under **Source directory**, click **Browse...**
1. In Browse for Folder, click **DVD Drive (D:) SSS_X64FREE_EN-US-DV9** and click **OK**.
1. In the **Import Operating System Wizard**, on page **Source**, click **Next**.
1. On page Destination, click **Next**.
1. On page Summary, click **Next**.

    The import will take about a minute. Wait for it.

1. On page Confirmation, click **Finish**.

### Task 4: Create a task sequence

Perform this task on CL1.

1. Open **Deployment Workbench**.
1. In DeploymentWorkbench, expand **Deployment Shares**, **MDT Deployment Share (\\\\VN1-SRV8\\mdt)**.
1. In the context-menu of **Task Sequences**, click **New Task Sequence**.
1. In the New Task Sequence Wizard, on page General Settings, under **Task sequence ID**, type **WS2022Datacenter**. Under **Task sequence name**, type, **Install Windows Server 2022 Datacenter**. Under Task sequence comments, type **without desktop experience**. Click **Next**.
1. On page Select Template, under **The following task sequence templates are available. Select the one you would like to use as a starting point**, click **Standard Server Task Sequence**. Click **Next**.
1. On page Select OS, click **Windows Server 2022 SERVERDATACENTERCORE in Windows Server 2022 SERVERSTANDARDCORE x64 install.wim** and click **Next**.
1. On page Specify a Product Key, ensure **Do not specify a product key at this time** is selected, and click **Next**.
1. On page OS Settings, under **Full Name**, type your name. Under **Organization**, type your organization. Click **Next**.
1. On page Admin Password, click **Use the specified local Administrator password**. In **Administrator Password** and **Please confirm Administrator Password**, type a secure password and click **Next**.
1. On page Summary, click **Next**.
1. On page Confirmation, click **Finish**.

## Exercise 2: Install a Windows Server using the Microsoft Deployment Toolkit

1. [Prepare a new virtual machine](#task-1-prepare-a-new-virtual-machine) by copying LiteTouchPE_x64.iso from the deployment share to the host and creating a new virtual machine with the name WIN-VN1-SRV20
1. [Run the Microsoft Deployment Kit Wizard](#task-2-run-the-microsoft-deployment-kit-wizard) on WIN-VN1-SRV20 to install Windows Server 2022 Datacenter and join it to the domain
1. [Review logs](#task-3-review-logs) created bey the Microsoft Deployment Tookit on VN1-SRV20
1. [Edit the task sequence (optional)](#task-4-edit-the-task-sequence-optional) to automatically lock the computer during deployment
1. [Verify the deployment (optional)](#task-5-verify-the-deployment-with-automatic-lock-optional) with automatic lock

### Task 1: Prepare a new virtual machine

Perform the VMware configuration on the host and the authenticated file copy on CL1.

1. On the host, create `C:\WindowsServerLab\ISOs` if it does not exist. In the powered-off **CL1** VM settings, temporarily add that folder under **Options > Shared Folders** with the name `LabISOs`, then start CL1.
1. On **CL1**, copy the Lite Touch ISO from the deployment share into the temporary VMware shared folder.

    ````powershell
    Copy-Item `
        -Path '\\VN1-SRV8\mdt\Boot\LiteTouchPE_x64.iso' `
        -Destination '\\vmware-host\Shared Folders\LabISOs\LiteTouchPE_x64.iso'
    ````

1. On the host, verify that the file exists and record its SHA-256 in private lab notes.

    ````powershell
    Get-FileHash `
        -Path C:\WindowsServerLab\ISOs\LiteTouchPE_x64.iso `
        -Algorithm SHA256
    ````

1. Shut down CL1 and disable or remove the temporary `LabISOs` VMware shared folder before continuing.

1. In VMware Workstation, create **WIN-VN1-SRV20** with 2 vCPUs, 4 GB RAM, UEFI firmware, a blank 127 GB thin-provisioned disk, and the VMware custom network mapped to this exercise's enterprise `VNet1` segment. The VMware display name is `WIN-VN1-SRV20`; the operating system will receive the hostname `VN1-SRV20` during deployment.
1. Keep local-disk boot ahead of network boot for the ISO-based deployment. Take a powered-off snapshot named `MDT-blank-target` before attaching the Lite Touch ISO; the optional redeployment and WDS exercises reuse this clean state.

### Task 2: Run the Microsoft Deployment Kit Wizard

Perform this task on the host.

1. In VMware Workstation, open **WIN-VN1-SRV20** settings. Select **CD/DVD**, choose **Use ISO image file**, open `C:\WindowsServerLab\ISOs\LiteTouchPE_x64.iso`, and enable **Connect at power on**.
1. Open the VMware console and power on **WIN-VN1-SRV20**.
1. As soon as the message Press any key to boot from CD or DVD appears, press any key.

    You have a few seconds time only to press the key. If you fail to press the key on time, restart the virtual machine.

1. In Microsoft Deployment Toolkit, click **Run the Deployment Wizard to install a new Operating System**.

    The keyboard layout should be the configured layout from Bootstrap.ini.

1. In User Credentials, beside **User Name**, type **Administrator**. Beside **Domain**, type **AD**. Beside Password, type the password of **AD\Administrator**. Click **OK**.
1. In Windows Deployment Wizard, on page Task Sequence, click **Install Windows Server 2022 Datacenter** and click **Next**.
1. On page Computer Details, beside **Computer name**, type **VN1-SRV20**. Click **Join a domain**. Beside **Domain to join**, type **ad.lab.test**. Click **Next**.

    The credentials for the domain join should be filled in already.

    *Note*: Because we configured localization settings in CustomSettings.ini, the wizard will not ask for them.

1. On page Ready, click **Begin**.

    Observe the steps the Lite Touch Installation takes to install Windows Server 2022. This will take a few minutes.

1. Keep the VMware console open while Lite Touch Installation performs its final steps.

1. In the message box Successful Deployment, click **OK**.

    You are automatically signed in as local administrator.

1. Continue through the VMware console. After deployment is complete, install VMware Tools if the clean compatibility snapshot does not already provide the required drivers.

### Task 3: Review logs

Perform this task on VN1-SRV20.

1. Sign in using the local administrator password.
1. In SConfig, enter **15**.
1. Navigate to **C:\\Windows\\Temp\\DeploymentLogs**.

    ````powershell
    Set-Location -Path C:\\Windows\\Temp\\DeploymentLogs
    ````

1. Review the file **Wizard.log** in Notepad.

    ````powershell
    notepad.exe Wizard.log
    ````

    > The file contains all the steps, the Windows Deployment Wizard has taken, including your selections.

1. Close Notepad.

1. Review the file **LiteTouch.log** in Notepad.

    ````powershell
    notepad.exe LiteTouch.log
    ````

    > The file contains all the steps, the Lite Touch Installation has taken to deploy Windows Server.

1. Close Notepad.

    > This file consolidates all steps taken to deploy Windows Server, including the Windows PE initialization, the Windows Deployment Wizard, and the Lite Touch Installation.

### Task 4: Edit the task sequence (optional)

Perform this task on CL1.

1. Open **Deployment Workbench**.
1. In DeploymentWorkbench, expand **Deployment Shares**, **MDT Deployment Share (\\\\VN1-SRV8\\mdt)**.
1. In DeploymentWorkbench, click **Task Sequences**.
1. Under Task Sequences, double-click **Install Windows Server 2022 Datacenter**.
1. In Install Windows Server 2022 Datacenter Properties, under **State Restore**, click **Gather local only**
1. With Gater local only selected, click **Add**, **General**, **Run Command Line**.
1. With Run Command Line selected, on tab Properties, beside **Name**, type **Lock computer**. Under **Command line**, type **rundll32.exe user32.dll,LockWorkStation**.

    *Important*: The term LockWorkStation is case-sensitive.

1. With Run Command Line or Lock Computer selected, click **Up**.

    The task should be the first task in the group State Restore.

1. Click **OK**.

### Task 5: Verify the deployment with automatic lock (optional)

Perform this task on the host computer.

1. Shut down **WIN-VN1-SRV20** in VMware Workstation and revert it to the powered-off `MDT-blank-target` snapshot. Confirm the blank 127 GB disk is present; do not delete VMDK files manually.

1. Perform [Task 2: Run the Microsoft Deployment Kit Wizard](#task-2-run-the-microsoft-deployment-kit-wizard) again.

    During the deployment, the computer should remain locked now.

If time permits, you could try to create and verify an additional task sequence to install Windows Server with desktop experience. You do not need to verify that task sequence, as you can use it in the next exercise.

## Exercise 3: Integrate MDT with WDS

1. [Add the Microsoft Deployment Toolkit Lite Touch boot image](#task-1-add-the-microsoft-deployment-toolkit-lite-touch-boot-image)
2. [Run Microsoft Deployment Wizard from the network](#task-2-run-microsoft-deployment-wizard-from-the-network)

### Task 1: Add the Microsoft Deployment Toolkit Lite Touch boot image

Perform this task on VN1-SRV8.

1. Open **Windows Deployment Services**.
1. In Windows Deployment Services, expand **Servers**, **VN1-SRV8.ad.lab.test**, and click **Boot Images**.
1. In the context-menu of **Boot Images**, click **Add Boot Image...**.
1. In Add Image Wizard, on page Image File, click **Browse...**
1. In Select Windows Image File, open **R:\\Shares\\MDT\\Boot\\LiteTouchPE_x64.wim**.
1. In **Add Image Wizard**, on page **Image File**, click **Next >**.
1. On page Image Metadata, click **Next >**.
1. On page Summary, click **Next >**.
1. On page Task Progress, click **Finish**.

### Task 2: Run Microsoft Deployment Wizard from the network

Perform these steps on the host computer.

1. In VMware Workstation, shut down **WIN-VN1-SRV20** and revert it to `MDT-blank-target`.
1. Open the VM settings, disconnect `LiteTouchPE_x64.iso`, and place network/PXE boot ahead of the blank local disk for this exercise only. Confirm the network adapter is attached to the isolated enterprise `VNet1` VMware segment served by WDS.
1. Open the VMware console and power on **WIN-VN1-SRV20**.
1. After a few seconds, you should see a screen with this information (the **Client IP** may vary):

    ````txt
    WDS Boot Manager version 0800
    Client IP: 10.1.1.6
    Server IP: 10.1.1.64
    Server Name: VN1-SRV8.ad.lab.test

    Press ENTER for network boot service.
    ````

1. Press ENTER.

    You have a few seconds time only to press ENTER. If you fail to press the key on time, restart the virtual machine.

1. In Windows Boot Manager, use the arrow keys to select **Lite Touch Windows PE (x64)** and press ENTER.
1. In Microsoft Deployment Toolkit, click **Run the Deployment Wizard to install a new Operating System**.
1. In User Credentials, beside **User Name**, type **Administrator**. Beside **Domain**, type **AD**. Beside Password, type the password of **AD\Administrator**. Click **OK**.
1. In Windows Deployment Wizard, on page Task Sequence, click **Install Windows Server 2022 Datacenter** and click **Next**.

    If you have added an additional task sequence, you may choose that one.

1. On page Computer Details, beside **Computer name**, type **VN1-SRV21**. Click **Join a domain**. Beside **Domain to join**, type **ad.lab.test**. Click **Next**.

    The credentials for the domain join should be filled in already.

1. On page Ready, click **Begin**.

You do not have to wait for the installation to complete.
