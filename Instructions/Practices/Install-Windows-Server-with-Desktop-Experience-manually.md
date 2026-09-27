# Practice: Install Windows Server with Desktop Experience manually

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
