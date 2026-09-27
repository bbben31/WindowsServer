# Practice: Install Windows Admin Center using a script

## Required VMs

* VN1-SRV1
* VN1-SRV2
* VN1-SRV4

## Task

Install Windows Admin Center on VN1-SRV4 using the official installer. The source helper script is intentionally not included in the learner edition.

## Instructions

Perform these steps on VN1-SRV4.

1. Logon as **ad\Administrator**.
1. From the official Microsoft download page, download the current Windows Admin Center installer to a learner-controlled temporary folder such as `C:\WindowsServerLab\Resources\Downloads`.
1. Verify the download and its publisher, then run the installer interactively on VN1-SRV4.
1. Select a management port and certificate option appropriate for this isolated lab. Do not place the installer, certificates, passwords, or generated onboarding material in Git.
1. From CL1, verify that the gateway opens and that VN1-SRV4 is reachable. Remove the installer when the practice is complete if it is no longer needed.

