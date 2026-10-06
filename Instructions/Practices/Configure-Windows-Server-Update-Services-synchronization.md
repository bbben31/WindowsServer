# Practice: Configure Windows Server Update Services synchronization

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Synchronize-Windows-Server-Update-Services-languages-products-and-categories.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV5 (VMware display: VN1-SRV5; accepted display aliases: WIN-VN1-SRV5; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Microsoft Windows Update/WSUS and feature-on-demand endpoints.

**Risk, cost and optional status:** low; local-only; optional=true. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** Verify the recorded lab product scope, explicit disabling of Drivers, selected languages/classifications and daily schedule. The first full selected-update synchronization completes successfully; record its last result and measured duration before disconnecting staging NAT.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV5

## Setup (for desktop experience only)

On CL1, the Windows Server Update Services Configuration Wizard:VN1-SRV5 should still be running. If not, perform these steps:

1. On **CL1**, sign in as **ad\Administrator**.
1. Open **Windows Server Update Services**.
1. In Update Services, in the context-menu of **Update Services**, click **Connect to Server...**
1. In Connect to Server, beside **Server name**, type **VN1-SRV5** and click **Connect**.

    The Windows Server Update Services Configuration Wizard:VN1-SRV5 opens. If not, follow these steps:

    1. In Update Services, expand **Update Services**, **VN1-SRV5** and click **Options**.
    1. In Options, click **WSUS Server Configuration Wizard**.
1. In Windows Server Update Services Configuration Wizard:VN1-SRV5, on page Before You Begin, click **Next >**.
1. On page Microsoft Update Improvement Program, click **Next >**.

    Optionally, you might deactivate **Yes, I would like to join the Microsoft Update Improvement Program** before clicking **Next >**.

1. On page Choose Upstream Server, ensure **Synchronize from Microsoft Update** is selected and click **Next >**.
1. On page Specify Proxy Server, ensure, **Use a proxy server when synchronizing** is deactivated and click **Next >**.
1. Click **Start Connecting**.

## Task

Continue configuration of VN1-SRV5 from practice [Synchronize Windows Server Update Services languages, products, and categories](Synchronize-Windows-Server-Update-Services-languages-products-and-categories.md) and configure it to synchronize all languages, products, and categories except Drivers once a day during off-peak hours. Initiate the initial synchronization of the server.

*Note*: In real world, you should leave Drivers activated. For this lab, Drivers is deactivated for performance reasons, because all computers are virtual machines.

## Instructions

### Desktop experience

Perform these steps on CL1.

1. On page Connect to Upstream Server, click **Next >**.
1. On page Choose Languages, ensure **Download updates in all languages, including new languages** is selected and click **Next >**.
1. On page Choose Products, activate the checkbox **All Products** and click **Next >**.

    For the disposable lab, deactivate **All Products** and select **Windows 11** only unless you deliberately recorded a wider product scope and its storage/time impact. Synchronization duration depends on connectivity, catalog size and host resources; measure it rather than relying on classroom timings.

1. On page Choose Classifications, activate the checkbox **All Classifications** and deactivate the checkbox **Drivers**. Click **Next >**.
1. On page Configure Sync Schedule, click **Synchronize automatically**. Beside **First synchronization**, enter a time during off-peak hours, e.g. 18:00:00. Beside **Synchronizations per day**, ensure **1** is filled in. Click **Next >**.
1. On page Finished, activate **Begin initial synchronization** and click **Next >**.

    This is the first full synchronization for the selected languages/products/classifications, distinct from the prerequisite catalog-connection step. Keep the declared temporary outbound access until it finishes. If the next practice cannot edit settings during synchronization, wait for this run to complete before continuing.

1. On page What's Next, click **Finish**.
1. In **Update Services > VN1-SRV5 > Synchronizations**, refresh until this run completes successfully. Record its start/end times, selected products/classifications and result; troubleshoot failed synchronization before claiming completion. Disconnect temporary NAT when no further declared download is needed.

### PowerShell

Perform these steps on CL1.

1. On **CL1**, sign in as **ad\Administrator**.
1. Open **Terminal**.
1. Connect to Update Services.

    ````powershell
    $wsusServer = Get-WsusServer -Name vn1-srv5 -PortNumber 8530
    ````

1. Enable all languages.

    ````powershell
    $configuration = $wsusServer.GetConfiguration()
    $configuration.AllUpdateLanguagesEnabled = $true
    $configuration.Save()
    ````

1. Enable all products.

    ````powershell
    Get-WsusProduct -UpdateServer $wsusServer | Set-WsusProduct
    ````

    For the disposable lab, select only the products actually being tested below. Record the chosen scope; duration is measured, not guaranteed. Broader product coverage remains available when its storage and time impact is explicitly accepted.

    ````powershell
    $title = @(
        'Windows 11'
    )

    $wsusProduct = Get-WsusProduct -UpdateServer $wsusServer
    $wsusProduct | Set-WsusProduct -Disable
    
    $wsusProduct |
    Where-Object { $PSItem.Product.Title -in $title } |
    Set-WsusProduct
    ````

1. Enable all classifications except for drivers.

    ````powershell
    <#
        You might have to replace 'Drivers' with a similar word in your local
        language, such as 'Treiber'. If you are unsure, run

        Get-WsusClassification -UpdateServer $wsusServer
        
        first and look out for the correct title.
    #>
    $classifications = Get-WsusClassification -UpdateServer $wsusServer
    $driverTitle = 'Drivers' # Replace with the verified localized title if necessary.
    $drivers = $classifications |
        Where-Object { $PSItem.Classification.Title -eq $driverTitle }
    if (!$drivers) { throw 'Verify the localized Drivers classification title before continuing.' }
    $drivers | Set-WsusClassification -Disable
    $classifications |
    Where-Object { $PSItem.Classification.Title -ne $driverTitle } |
    Set-WsusClassification
    ````

1. Configure the synchronization for off-peak hours once a day, e.g., at 18:00:00.

    ````powershell
    $subscription = $wsusServer.GetSubscription()
    $subscription.SynchronizeAutomatically = $true
    $subscription.SynchronizeAutomaticallyTimeOfDay = `
        (New-TimeSpan -Hours 18 -Minutes 0 -Seconds 0)
    $subscription.NumberOfSynchronizationsPerDay = 1
    $subscription.Save()
    ````

1. Start the initial full synchronization and inspect its status. If a run is already active, wait for it instead of starting a duplicate.

    ````powershell
    if ($subscription.GetSynchronizationStatus() -eq 'NotProcessing') {
        $subscription.StartSynchronization()
    }
    $subscription.GetSynchronizationStatus()
    $subscription.GetSynchronizationProgress()
    ````

1. Repeat the status/progress checks until **NotProcessing**, then inspect `$subscription.GetLastSynchronizationInfo()` and require a successful result. Record start/end times and resolve errors before moving to the next practice. Keep temporary NAT only for this declared synchronization/download period, then disconnect it.
