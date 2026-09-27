# Practice: Update the Active Directory schema

## Required VMs

* VN1-SRV1
* CL1

## Task

On CL1, update the Active Directory schema to the current version.

## Instructions

Perform these steps on the host.

1. This is an advanced, dedicated operation. Take a full backup/snapshot of the forest and do not use a snapshot as the only rollback mechanism after schema changes.
1. In VMware Workstation, open the CL1 VM settings, attach the verified Windows Server 2025 Evaluation ISO from `C:\WindowsServerLab\ISOs\<WINDOWS_SERVER_2025_EVALUATION_ISO>` to the virtual CD/DVD drive, and mount it in the guest.

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. Open **Terminal**.
1. Prepare the forest for the latest version of Windows Server.

    ````powershell
    D:\support\adprep\adprep.exe /forestprep
    ````

1. Enter **c** to continue.
1. Prepare the domain for the latest version of Windows Server.

    ````powershell
    D:\support\adprep\adprep.exe /domainprep /gpprep
    ````

Perform these steps on the host.

1. In the menu of **"WIN-CL1" on "..." - Connection to virtual computer**, click **Media**, **DVD Drive**, **Eject "2025_x64_EN_Eval.iso"**.

