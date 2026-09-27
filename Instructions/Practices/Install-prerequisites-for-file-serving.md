# Practice: Install prerequisites for file serving

## Required VMs

* VN1-SRV1
* VN1-SRV2
* VN1-SRV4
* VN1-SRV10
* VN1-SRV5
* CL1

## Task

Prepare the file-serving environment manually for subsequent practices and labs. The source automation helper is intentionally not included in the learner edition.

> Note: If you receive an error message, that Windows Admin Center cannot be installed, you can safely ignore it.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. On **VN1-SRV10**, confirm that `D:` is the intended data volume. Create these downstream folders:
   * `D:\Shares\IT`
   * `D:\Shares\Users`
   * `D:\Shares\Finance`
1. Create shares named **IT**, **Users**, and **Finance** using Server Manager or the documented file-serving practice. Use placeholder domain groups such as `ad\IT-Users`, `ad\Users-Users`, and `ad\Finance-Users` only after you have created or verified the corresponding groups manually. Apply least-privilege share and NTFS permissions; do not copy permissions from an unreviewed script.
1. From CL1, verify the concrete shares with `Test-Path \\VN1-SRV10\IT`, `Test-Path \\VN1-SRV10\Users`, `Test-Path \\VN1-SRV10\Finance`, and `Get-SmbShare -CimSession VN1-SRV10`.
1. Record the manual choices privately; do not create accounts, permissions, or shares from an unreviewed script.
