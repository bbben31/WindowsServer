# Practice: Use a Group Managed Service Account

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. On an active DC, reuse an effective KDS key; allow at least 10 hours and verify replication for a new key in a multi-controller forest. Do not backdate to bypass enterprise replication.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); PM-SRV2 (VMware display: PM-SRV2; accepted display aliases: WIN-PM-SRV2; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; conditional until retired; supply the guest or explicitly confirm retirement with -RetiredVmName); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary VMnet8 NAT on CL1 only for Windows Update RSAT capability installation; preserve the AD NIC/DNS and disconnect after setup.

**Permissions:** Delegated AD/GPO rights for the named OU, account and policy changes; lab Domain Administrator only where the procedure requires it. Local Administrator for guest setup.

**Outbound access:** Windows Update downloads Windows 11 RSAT Features on Demand on CL1 during the documented setup/fallback. Before installing capabilities, attach a temporary second VMware NIC to VMnet8 NAT; retain the AD NIC and its AD DNS, disable DNS registration on the NAT NIC, and record adapters/routes/DNS. Disconnect VMnet8 immediately after installation. If the required tools are already installed, the download step needs no outbound access. Endpoints: *.windowsupdate.com (Windows Update service/content); *.update.microsoft.com (Microsoft Update service); *.delivery.mp.microsoft.com (Windows Update delivery); https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-security (current service endpoint guidance).

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** The gMSA is installed on the authorized PM-SRV2 host and Test-ADServiceAccount returns True. NotepadService shows the configured ad\MyService$ identity; observe its deliberately transient process/start timeout without claiming a healthy service, then delete only that demonstration service.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Disconnect the temporary VMnet8 NIC after capability installation and restore recorded adapters/routes/DNS; retain installed RSAT until dependent exercises finish. Delete only the disposable NotepadService demonstration; retain the gMSA until dependent services finish.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* PM-SRV2
* VN1-SRV5
* Conditional until retired: VN1-SRV1

> **Conditional controller lifecycle:** Supply VN1-SRV1 while it remains the active original controller. After its documented retirement, confirm that VN1-SRV5 serves the original DNS address and the required directory roles, then pass `-RetiredVmName VN1-SRV1` to preflight; never restart a retired controller. Retirement requires the completed address/role handover, not merely completing controller promotion or switching off a guest. Steps concerning the retired server apply only to recorded historical state or removal of its stale directory objects.

## Setup

If you skipped the practice [Install Remote Server Administration Tools](Install-Remote-Server-Administration-Tools.md), on **CL1**, in **Terminal**, execute ````C:\WindowsServerLab\Resources\Solutions\Install-RemoteServerAdministrationTools.ps1````.

## Task

Create a Group Managed Service Account, install it on PM-SRV2 and use it to create a service.

## Instructions

First perform the KDS readiness check in an elevated **Windows PowerShell 5.1** console on the live writable domain controller (**VN1-SRV5** after the documented handover, or **VN1-SRV1** only while it is still active). Never restart a retired controller for this check. KDS management is a domain-controller operation, not a CL1 command.

1. Sign in as **Administrator@ad.lab.test**.
1. Run **Terminal**.
1. Check for an existing KDS root key. Reuse a ready key; do not create another key merely to rerun this practice.

    ````powershell
    Get-KdsRootKey
    ````

    If no key exists, follow [Generating the KDS root key](../General/Generating-the-KDS-root-key.md). In the multi-controller enterprise lab, wait at least 10 hours and verify replication before continuing. Backdating is only for an isolated single-DC test forest, not this multi-controller topology. See [Microsoft's KDS timing requirements](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-managed-service-accounts/group-managed-service-accounts/create-the-key-distribution-services-kds-root-key).

Return to **CL1**, signed in as **Administrator@ad.lab.test**, and open an authorized administrative terminal with the Active Directory module.

1. Create a new Group Managed Service Account with the name **MyService**, the DNS host name **myservice.ad.lab.test**, and allow PM-SRV2 to retrieve the managed password.

    ````powershell
    New-ADServiceAccount `
        -Name MyService `
        -DNSHostName myservice.ad.lab.test `
        -PrincipalsAllowedToRetrieveManagedPassword PM-SRV2$
    ````

Perform these steps on PM-SRV2.

1. Sign in as **Administrator@ad.lab.test**.
1. In SConfig, enter **15**.
1. Install the PowerShell module for Active Directory.

    ````powershell
    Install-WindowsFeature -Name RSAT-AD-PowerShell
    ````

1. Install the Group Managed Service Account **MyService**.

    ````powershell
    Install-ADServiceAccount -Identity MyService
    Test-ADServiceAccount -Identity MyService
    ````

    `Test-ADServiceAccount` must return `True` before continuing.

1. Register a disposable **NotepadService** with **C:\windows\System32\notepad.exe** to demonstrate its configured account. Notepad is not a service-compatible application; this deliberately transient demonstration does not establish a healthy running service.

    ````powershell
    $name = 'NotepadService'
    New-Service `
        -Name $name `
        -BinaryPathName C:\windows\System32\notepad.exe
    ````

1. Get the new service using CIM (supported in Windows PowerShell 5.1 and PowerShell 7).

    ````powershell
    $service = Get-CimInstance -ClassName Win32_Service -Filter "Name = '$name'"
    ````

1. Change the start account for the service to **ad\MyService$**

    ````powershell
    $change = Invoke-CimMethod -InputObject $service -MethodName Change -Arguments @{ StartName = 'ad\MyService$'; StartPassword = '' }
    if ($change.ReturnValue -ne 0) { throw "Service account change failed: $($change.ReturnValue)" }
    ````

1. Verify the change.

    ````powershell
    $service = Get-CimInstance -ClassName Win32_Service -Filter "Name = '$name'"
    $service.StartName
    ````

    > The return value should bei ad\MyService$.

1. Open **Task Manager**.

    ````powershell
    taskmgr.exe
    ````

1. In Task Manager, click **More details**.
1. Click the tab Details. Move Task Manager side by side with the console window.
1. In console windows, start the service.

    ````powershell
    Start-Service -Name $name
    ````

    Expect a service-start timeout because Notepad does not implement the service protocol. Observe Task Manager during the attempt; do not repeatedly restart it or treat that timeout as a healthy-service result. The durable checks are `Test-ADServiceAccount` returning `True` and the configured `StartName` above.

1. Switch to **Task Manager**.

    > During the start attempt, a transient notepad.exe process may appear under MyService$. Record the observed result, not a claim that NotepadService is running normally.

1. Remove the disposable demonstration service. Confirm its name before deletion; leave the gMSA available for later exercises or remove it only when no dependent service needs it.

    ````powershell
    sc.exe delete NotepadService
    ````

1. Sign out.

    ````powershell
    logoff
    ````
