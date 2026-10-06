# Practice: Registry editing using PowerShell

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** low; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Inspect registry subkeys and values, perform the intended disposable set/remove demonstration, then restore and verify the recorded prior routing-value type/value/presence.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings. Restore the original routing-value type/value/presence, rather than unconditionally deleting a value that existed before the exercise.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* CL1
* VN1-SRV1

## Task

On disposable CL1, list the keys and values of the registry key `HKLM:\system\CurrentControlSet\services\Tcpip\Parameters`. Record the original IPEnableRouter value/type/presence, set it to 1, remove it for the demonstration, then restore its original state. This is registry practice, not permission to bridge or route the lab through the physical host.

## Instructions

Perform these steps on CL1.

1. Logon as **ad\Administrator**.
1. From the context-menu of **Start** (you can press WIN + X), launch **Terminal** as Administrator.
1. Store the registry key path **HKLM:\system\CurrentControlSet\services\Tcpip\Parameters** in a variable.

    ````powershell
    $path = 'HKLM:\system\CurrentControlSet\services\Tcpip\Parameters'
    ````

1. List the contents of the registry key.

    ````powershell
    Get-ChildItem $path
    Get-ItemProperty $path
    ````

1. Record the original value, type and presence before changing **IPEnableRouter**.

    ````powershell
    $name = 'IPEnableRouter'
    $key = Get-Item -LiteralPath $path
    $originalPresent = $key.GetValueNames() -contains $name
    if ($originalPresent) {
        $originalValue = $key.GetValue($name)
        $originalKind = $key.GetValueKind($name)
    }
    ````

1. Within the key set **IPEnableRouter** to 1.

    ````powershell
    Set-ItemProperty -Path $path -Name $name -Value 1
    ````

1. Verify the changed value.

    ````powershell
    Get-ItemProperty -Path $path -Name $name
    ````

1. Remove the value.

    ````powershell
    Remove-ItemProperty -Path $path -Name $name
    ````

1. Verify the value was removed.

    ````powershell
    Get-ItemProperty -Path $path -Name $name
    ````

    An error message should be returned.

1. Restore the recorded baseline immediately. If the value was originally absent, leave it absent; otherwise recreate its original type/value and verify it. Do not reboot CL1 with an unintended routing change.

    ````powershell
    if ($originalPresent) {
        New-ItemProperty -Path $path -Name $name -PropertyType $originalKind -Value $originalValue | Out-Null
        Get-ItemProperty -Path $path -Name $name
    }
    ````
