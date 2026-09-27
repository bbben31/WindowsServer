# Practice: Install Windows Server manually

## Task

Create VN1-SRV21 manually in VMware Workstation Pro 17 and install Windows Server Datacenter Evaluation. The source VM-creation helper is intentionally not included.

## Instructions

Perform these steps on the host.

1. In VMware Workstation, choose **Create a New Virtual Machine**, use UEFI, assign a unique name `VN1-SRV21`, and attach the verified ISO from `C:\WindowsServerLab\ISOs\<WINDOWS_SERVER_2025_EVALUATION_ISO>`.
1. Attach the NIC to the documented VMware VMnet20 server network, then start the VM and open its VMware console.
1. On the message Press any key to boot from CD or DVD, press a key within a few seconds. If PXE starts, use VMware **Power > Restart** and confirm the virtual CD/DVD is first in the boot order.
1. In Windows Server Setup, on page Select language settings, configure **Time and currency format**  as you wish and click **Next**.
1. On page Select keyboard settings, configure the **Keyboard or input method** as you wich and click **Next**.
1. On page Select setup option, ensure **Install Windows Server** is selected, click **I agree everything will be deleted including files, apps, and settings** and click **Next**.
1. On page Select image, click **Windows Server 2025 Datacenter Evaluation** and click **Next**.
1. On page Applicable notices and license terms, click **Accept**.
1. On page Select location to install Windows Server, explore the options and click **Next**.
1. On page Ready to install, click **Install**.

Do not wait for the installation to finish.
