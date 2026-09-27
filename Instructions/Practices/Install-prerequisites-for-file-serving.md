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
1. On the selected member server, confirm the data volume and create only the folders required by the next practice.
1. Create the share and NTFS permissions through Server Manager or the documented file-serving practice, using placeholders for paths and groups.
1. From CL1, verify the share with `Test-Path \\<SERVER>\<SHARE>` and `Get-SmbShare -CimSession <SERVER>`.
1. Record the manual choices privately; do not create accounts, permissions, or shares from an unreviewed script.
