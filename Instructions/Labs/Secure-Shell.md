# Lab: Secure Shell

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Microsoft Windows Update/WSUS and feature-on-demand endpoints.

**Risk, cost and optional status:** high; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The intended SSH client authenticates to the lab server and its command reports the correct hostname; remove the temporary key/session.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings. Retain the disposable SSH test key only while the dependent guest-management practice still requires it; remove both public/private test keys after that dependent work, not before.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision only existing prerequisite machines, disks, cluster roles and certificates before starting; create machines marked Created during exercise in their designated tasks. Follow alternatives and conditional-retirement requirements instead of starting every named VM; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV5

## Setup

1. On **CL1**, sign in as **ad\Administrator**.
1. On **VN1-SRV5**, sign in as **ad\Administrator**.
1. In SConfig, enter **15**.

## Introduction

For secure remote command line administration, Adatum wants to deploy the proven SSH protocol. For added security, Adatum wants to use key-based authentication.

## Exercises

1. [Installing and verifying OpenSSH server](#exercise-1-installing-and-verifying-openssh-server)
1. [Configuring key-based authentication](#exercise-2-configuring-key-based-authentication)

## Exercise 1: Installing and verifying OpenSSH server

1. [Enable the OpenSSH server](#task-1-enable-the-openssh-server) on VN1-SRV5.
1. [Using SSH with a password connect to server](#task-2-using-ssh-with-a-password-connect-to-server) VN1-SRV5

### Task 1: Enable the OpenSSH server

Perform this task on VN1-SRV5.

1. Check the status of the OpenSSH SSH Server service.

    ````powershell
    $name = 'sshd'
    Get-Service -Name $name
    ````

    The service should be stopped.

1. Start the OpenSSH SSH Server service.

    ````powershell
    Start-Service -Name $name
    ````

1. Configure the firewall rule.

   ````powershell
   Set-NetFirewallRule -Name OpenSSH-Server-In-TCP -Enabled True -Profile Domain
   ````
   
1. Configure the **sshd** service to start automatically.

    ````powershell
    Set-Service -Name $name -StartupType 'Automatic'
    ````

### Task 2: Using SSH with a password connect to server

Perform this task on CL1.

1. Open **Terminal**.
1. Connect to VN1-SRV5 using ssh.exe.

    ````powershell
    ssh vn1-srv5.ad.lab.test -l 'Administrator@ad.lab.test'
    ````

1. At the prompt Are you sure you want to continue connecting, enter **yes**.
1. At the prompt administrator@ad.lab.test@vn1-srv5.ad.lab.test's password, enter the password for **Administrator@ad.lab.test**.

    You are now connected to a cmd.exe session on VN1-SRV5.

1. Confirm the hostname.

    ````shell
    hostname
    ````

    This should return VN1-SRV5.

1. Start PowerShell.

    ````shell
    powershell
    ````

1. Get computer info.

    ````powershell
    Get-ComputerInfo
    ````

1. Exit from PowerShell.

    ````powershell
    exit
    ````

1. Exit from cmd.exe.

    ````shell
    exit
    ````

## Exercise 2: Configuring key-based authentication

1. [Generate user key](#task-1-generate-user-key)
1. [Deploy the public key](#task-2-deploy-the-public-key) to VN1-SRV5
1. [Verify connectivity with the key file](#task-3-verify-connectivity-with-the-key-file)
1. [Store the private key in the Windows security context](#task-4-store-the-private-key-in-the-windows-security-context) on CL1
1. [Verify the connectivity with ssh-agent](#task-5-verify-the-connectivity-with-ssh-agent)

*Important*: In this lab, do not delete the private key file yet! You will need it in a later lab.


### Task 1: Generate user key

Perform this task on CL1.

1. Open **Terminal**.
1. Generate key files using the **Ed25519** algorithm.

    ````powershell
    ssh-keygen.exe -t ed25519 -f '.ssh\Administrator@ad.lab.test'
    ````

1. At the prompt Enter passphrase and Enter same passphrase again, enter a secure passphrase of your choice. Make sure you write down the passphrase in a secure location.

### Task 2: Deploy the public key

Perform this task on CL1.

1. Open **Terminal**
1. Use sftp to connect to **VN1-SRV5**.

    ````powershell
    sftp.exe Administrator@ad.lab.test@vn1-srv5.ad.lab.test
    ````

1. At the prompt Administrator@ad.lab.test@vn1-srv5.ad.lab.test's password, enter the password of **Administrator@ad.lab.test**.

1. Using sftp, from CL1, copy **.ssh/Administrator@ad.lab.test.pub** to **c:/programdata/ssh/administrators_authorized_keys** on VN1-SRV5.

    ````shell
    put .ssh/Administrator@ad.lab.test.pub c:/programdata/ssh/administrators_authorized_keys
    ````

1. Quit sftp.

    ````shell
    bye
    ````

1. Connect to VN1-SRV5 using ssh.exe.

    ````powershell
    ssh vn1-srv5.ad.lab.test -l 'Administrator@ad.lab.test'
    ````

1. At the prompt administrator@ad.lab.test@vn1-srv5.ad.lab.test's password, enter the password for **Administrator@ad.lab.test**.

1. Grant **Administrators** and **SYSTEM** full control over **C:\\ProgramData\\ssh\\administrators_authorized_keys**.

    ````shell
    icacls.exe c:\ProgramData\ssh\administrators_authorized_keys /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
    ````

1. Exit from the ssh session.

    ````shell
    exit
    ````

### Task 3: Verify connectivity with the key file

Perform this task on CL1.

1. Open **Terminal**.
1. Connect to **vn1-srv5.ad.lab.test** using the private key file **~\.ssh\Administrator@ad.lab.test**.

    ````powershell
    ssh.exe vn1-srv5.ad.lab.test -i ".ssh\Administrator@ad.lab.test"
    ````

1. At the prompt Enter passphrase for ~\\.ssh\\Administrator@ad.lab.test, type the passphrase you created an took note of in a previous task.
1. Confirm the user name you are connected with.

    ````shell
    whoami
    ````

    The output should be ad\Administrator.

1. Exit from the ssh session.

    ````shell
    exit
    ````

### Task 4: Store the private key in the Windows security context

Perform this task on CL1.

1. Open **Terminal**.
1. Configure the service ssh-agent to start automatically and start it.

    ````powershell
    $name = 'ssh-agent'
    Set-Service -Name $name -StartupType Automatic
    Start-Service -Name $name
    ````

1. Load your key files into ssh-agent.

    ````powershell
    ssh-add.exe ".ssh\Administrator@ad.lab.test"
    ````

1. At the prompt Enter passphrase for .ssh\\Administrator@ad.lab.test, type the passphrase you created an took note of in a previous task.

### Task 5: Verify the connectivity with ssh-agent

Perform this task on CL1.

1. Open **Terminal**.
1. Connect to **vn1-srv5.ad.lab.test**.

    ````powershell
    ssh.exe vn1-srv5.ad.lab.test
    ````

    There should be no password prompt.

1. Confirm the user name you are connected with.

    ````shell
    whoami
    ````

    The output should be ad\Administrator.

1. Exit from the ssh session.

    ````shell
    exit
    ````

In a real-world scenario, it is strongly recommended that you back up your private key to a secure location, then delete it from the local system, after adding it to ssh-agent. The private key cannot be retrieved from the agent providing a strong algorithm has been used, such as Ed25519 in this example. If you lose access to the private key, you will have to create a new key pair and update the public key on all systems you interact with.
