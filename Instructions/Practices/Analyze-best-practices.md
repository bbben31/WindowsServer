# Practice: Analyze best practices

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-Remote-Server-Administration-Tools.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing).  Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** BPA scans complete for the three named models; record findings and distinguish expected lab warnings.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* CL1
* VN1-SRV1

## Task

Run the Best Practices Analyzer on VN1-SRV1 for Domain Services, File Services, and DNS Server, and review the results.

## Instructions

For this practice, it is recommended to perform both experiences, Desktop and PowerShell.

### Desktop experience

Perform these steps on CL1.

1. On **CL1**, sign in as **ad\Administrator**.
1. Open **Server Manager**.
1. In Server Manager, click **All Servers**.
1. Under Server Manager > All Servers, click **VN1-SRV1**.
1. Under **BEST PRACTICES ANALYZER** (you might have to scroll down), click **Tasks**, **Start BPA Scan**.
1. In Select Servers, activate the checkbox beside **VN1-SRV1.ad.lab.test** and click **Start Scan**.

    Review some of the findings of Best Practices Analyzer.

### PowerShell

Perform these steps on CL1.

1. On **CL1**, sign in as **ad\Administrator**.
1. Open **Terminal**.
1. Create a remote PowerShell session to **VN1-SRV1** and store it in a variable.

    ````powershell
    $pSSession = New-PSSession -ComputerName VN1-SRV1
    ````

1. On VN1-SRV1, query the available BPA models.

    ````powershell
    Invoke-Command -Session $pSSession -ScriptBlock { Get-BpaModel }
    ````

1. Create an array of BPA models to scan.

    ````powershell
    $models = 'DirectoryServices', 'DNSServer', 'FileServices' |
        foreach-object { "Microsoft/Windows/$PSItem" }
    ````

1. Run the BPA for the selected models.

    ````powershell
    Invoke-Command -Session $pSSession -ScriptBlock { 
        $using:models | ForEach-Object { Invoke-BpaModel -Id $PSItem }
    }
    ````

1. Query the BPA results for the selected models and store them in a variable.

    ````powershell
    $bPAresult = Invoke-Command -Session $pSSession -ScriptBlock { $using:models | ForEach-Object { Get-BpaResult -Id $PSItem }}
    ````

1. View the BPA results in a grid.

    ````powershell
    $bPAresult | Out-GridView
    ````

1. Save the BPA results to a HTML file.

    ````powershell
    $bPAresult | ConvertTo-Html | Out-File ~\Desktop\BPAResults.html
    ````

1. From the desktop, open the file **BPAResults.html** and review it.
1. Switch back to **Terminal**.
1. Save the BPA results to a CSV file.

    ````powershell
    $bPAresult | Export-Csv -Path ~\Desktop\BPAResults.csv
    ````

1. From the desktop, open the file **BPAResults.csv** and review it.
