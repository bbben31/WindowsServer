# Lab: Delegated managed service accounts

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. Use an updated Windows Server 2025 service host and authenticating DC with compatible AD tools and a ready, replicated KDS key. Manually grant PSService logon/write/read rights and establish a working user-backed service before migration.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing); VN1-SRV9 (VMware display: VN1-SRV9; accepted display aliases: WIN-VN1-SRV9; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Delegated AD/GPO rights for the named OU, account and policy changes; lab Domain Administrator only where the procedure requires it. Local Administrator for guest setup.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: nssm.cc official distribution; stop if provenance/hash cannot be verified.

**Risk, cost and optional status:** high; local-only; optional=true. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution. Execution requires the supported updated Windows Server 2025 dMSA platform.

**Success verification:** Before and after dMSA migration, PSService remains configured with the recorded superseded account, runs successfully and writes a fresh successful SYSVOL policy list, not an ERROR entry. Verify the dMSA properties and relevant Kerberos/service events; an account object alone does not establish service migration success.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision only existing prerequisite machines, disks, cluster roles and certificates before starting; create machines marked Created during exercise in their designated tasks. Follow alternatives and conditional-retirement requirements instead of starting every named VM; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Required VMs

* CL1
* VN1-SRV5
* VN1-SRV9

## Setup

1. Copy the repository `Resources` directory to `C:\WindowsServerLab\Resources` on **VN1-SRV9**. Obtain `nssm.exe` only from the [official NSSM project](https://nssm.cc/), verify its published SHA-256 value, inspect the download, and place the reviewed binary in that directory.
1. On **VN1-SRV5**, sign in as **ad\\Administrator**.
1. On **CL1**, sign in as **ad\\Administrator**.
1. On **VN1-SRV9**, sign in as **ad\\Administrator**.
1. Verify **VN1-SRV9** and its authenticating domain controller run the supported **Windows Server 2025** dMSA platform with current security updates. Use the AD management tools capable of creating/migrating dMSAs. Record the controller used and verify replication before migration. [Microsoft's dMSA setup guidance](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/delegated-managed-service-accounts/delegated-managed-service-accounts-set-up-dmsa) defines these platform and KDS prerequisites.
1. On **CL1**, use **Active Directory Users and Computers** to create/verify **OU=Service accounts** directly under ad.lab.test. Manually create an enabled user named **PowerShell Service**, sAMAccountName **PSService**, UPN **PSService@ad.lab.test**. Enter and privately retain a unique lab password; clear **User must change password at next logon**. Do not grant administrator membership or commit the password. If the account already belongs to another exercise, use the appropriate clean coordinated snapshot rather than reset it without review.

1. On **VN1-SRV9**, open an elevated **Terminal** and run `C:\WindowsServerLab\Resources\Solutions\Install-Service.ps1`.
1. Create/verify **C:\Logs**. Grant **ad\PSService** NTFS **Modify** on that log folder and **Read & execute** on `C:\WindowsServerLab\Resources\service.ps1` and `nssm.exe`; retain administrator/SYSTEM access. Explicitly grant only this account **Log on as a service** using Local Security Policy (or an authorized GPO scoped only to VN1-SRV9). Verify effective policy does not replace the grant. Do not solve file-access or logon failures with administrator membership.
1. On **VN1-SRV9**, open **Services**, open **PSService**, select the **Log On** tab, choose **This account**, and configure `ad\PSService` with the private password created above. Apply the change and restart the service.
1. Confirm **PSService** is Running as **ad\PSService** and `C:\Logs\Policies.log` receives a fresh **successful SYSVOL policy listing**, not merely a timestamp or ERROR entry. If it fails, review service logon, effective policy, NTFS permissions and AD DNS before proceeding.

## Introduction

To evaluate delegated managed service accounts, you want to migrate the service account of a sample service to a dMSA.

## Exercise: Validate delegated managed service accounts

1. [Inspect the service](#task-1-inspect-the-service) PSService on VN1-SRV9 and the file `C:\WindowsServerLab\Resources\service.ps1`

    > Which account uses the service to log on?
    > What does the service do?

1. [Generate the KDS root key](#task-2-generate-the-kds-root-key)
1. [Create a delegated managed service account](#task-3-create-a-delegated-managed-service-account) with the name dMSA_PSService in the organizational unit Service accounts for VN1-SRV9
1. [Add the registry value DelegatedMSAEnabled](#task-4-add-the-registry-value-delegatedmsaenabled) to the key HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters on VN1-SRV9
1. [Migrate the service account to the dMSA](#task-5-migrate-the-service-account-to-the-dmsa)

### Task 1: Inspect the service

Perform this task on VN1-SRV9.

1. Open **Services**
1. In Services, double-click the service **PSService**. Verify the **Startup type** is **Automatic** and the **Service status** is **Running**.

    On the tab General, you see as Path to executable C:\WindowsServerLab\Resources\nssm.exe.

    > nssm.exe is a tool to run any program as service. In our case, it runs the PowerShell script C:\WindowsServerLab\Resources\service.ps1. See <https://nssm.cc/> for more information about NSSM.

1. Click the tab **Log On**.

    > The service logs on as PSService@ad.lab.test, which is a user account used as service account.

1. Click **Cancel**.
1. Open **File Explorer**.
1. In File Explorer, navigate to **C:\WindowsServerLab\Resources**.
1. In the context-menu of **service.ps1** click **Edit**.

    If you installed Visual Studio Code before, alternatively you can open the file with this app.

    > Every 30 seconds, the script write all GPO objects found in SYSVOL to C:\Logs\Policies.log.

1. In File Explorer, navigate to **C:\Logs**.
1. Open **Policies.log** and inspect its content.

### Task 2: Generate the KDS root key

Perform this task in an elevated Windows PowerShell session on an **active domain controller**, not the Windows 11 CL1 client. Return to CL1 for Task 3.

1. Open **Terminal**.
1. In Terminal, verify if the KDS root key exists.

    ````powershell
    Get-KdsRootKey
    ````

1. If there is no KDS root key, generate it.

    ````powershell
    Add-KdsRootKey -EffectiveImmediately
    ````

1. In a multi-controller forest, wait at least 10 hours and verify healthy replication before using the new key. Only an isolated **single-DC** test forest may instead backdate its one new key using `Add-KdsRootKey -EffectiveTime (Get-Date).AddHours(-10)`. Do not create a second key merely to bypass the wait. Verify the KDS root key again.

    ````powershell
    Get-KdsRootKey
    ````

### Task 3: Create a delegated managed service account

Perform this task on CL1.

1. Open **Terminal**.
1. In Terminal, create a delegated managed service account with the name dMSA_PSService in the organizational unit Service accounts for VN1-SRV9

    ```powershell
    New-ADServiceAccount -Path 'ou=Service accounts, DC=ad,DC=lab,DC=test' -Name dMSA_PSService -DNSHostName vn1-srv9.ad.lab.test -CreateDelegatedServiceAccount -KerberosEncryptionType AES256
    ````

### Task 4: Add the registry value DelegatedMSAEnabled

Perform this task on CL1.

1. Open **Terminal**.
1. In Terminal, add the registry value **DelegatedMSAEnabled** to the key to the key **HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters** on **VN1-SRV9**.

    ````powershell
    Invoke-Command -Computername VN1-SRV9 -ScriptBlock {
        $path = `
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters'
        New-Item $path -Force
        Set-ItemProperty `
            -Path $path -Name 'DelegatedMSAEnabled' -Value 1 -Type 'DWORD'

    }
    ````

### Task 5: Migrate the service account to the dMSA

Perform this task on CL1.

1. Open **Terminal**.
1. In Terminal, start the migration from the account **PowerShell Service** to **dMSA_PSService**.

    ````powershell
    $identity = `
        'cn=dMSA_PSService, ou=Service accounts, DC=ad,DC=lab,DC=test'
    $supersededAccount = `
        'cn=Powershell Service, ou=Service accounts, DC=ad,DC=lab,DC=test'

    Start-ADServiceAccountMigration `
        -Identity $identity -SupersededAccount $supersededAccount
    ````

1. Verify the properties **msDS-DelegatedMSAState** and **msDS-ManagedAccountPrecededByLink** of the dMSA.

    ````powershell
    Get-ADServiceAccount `
        -Identity $identity `
        -Properties msDS-DelegatedMSAState, msDS-ManagedAccountPrecededByLink
    ````

    msDS-DelegatedMSAState should be 1. msDS-ManagedAccountPrecededByLink should contain the DN of the superseded account.

1. Verify the properties **msDS-SupersededServiceAccountState** and **msDS-SupersededManagedAccountLink** of the old service account.

    ````powershell
    Get-ADUser `
        -Identity $supersededAccount `
        -Properties `
            msDS-SupersededServiceAccountState, `
            msDS-SupersededManagedAccountLink
    ````

    msDS-SupersededServiceAccountState should be 1. msDS-SupersededManagedAccountLink should contain the DN of the dMSA.

1. Restart the service **PSService** on **VN1-SRV9**.

    ````powershell
    Invoke-Command -ComputerName VN1-SRV9 -ScriptBlock {
        Restart-Service PSService
    }
    ````

1. Complete the account migration from the account **PowerShell Service** to **dMSA_PSService**.

    ````powershell
    Complete-ADServiceAccountMigration `
        -Identity $identity -SupersededAccount $supersededAccount
    ````

1. Verify the property **msDS-DelegatedMSAState** of the dMSA.

    ````powershell
    Get-ADServiceAccount -Identity $identity -Properties msDS-DelegatedMSAState
    ````

    msDS-DelegatedMSAState should be 2.

1. Verify the property **msDS-SupersededServiceAccountState** of the old service account.

    ````powershell
    Get-ADUser `
        -Identity $supersededAccount `
        -Properties msDS-SupersededServiceAccountState
    ````

1. Disable the old service account.

    ````powershell
    Disable-ADAccount -Identity $supersededAccount
    ````

1. Restart the service **PSService** on **VN1-SRV9** again.

    ````powershell
    Invoke-Command -ComputerName VN1-SRV9 -ScriptBlock {
        Restart-Service PSService
    }
    ````

    This is not necessary, but want to check, if the service still starts.

1. Reset the password of the old service account.

    ````powershell
    Set-ADAccountPassword -Identity $supersededAccount -Reset
    ````

1. At the prompts **Password** and **Repeat Password**, enter a new secure password that is different from any default passwords.

Verify the service is still configured to log on with the superseded service account. Confirm it remains Running and Policies.log receives a fresh successful SYSVOL listing after the final restart/password-change tests. Check Kerberos Operational/service events for authentication failures; dMSA object properties alone do not demonstrate a working migrated service. Retain the original AD account for supported rollback; do not delete it.
