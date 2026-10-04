# Practice: Install Windows Terminal

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN2-SRV1 (VMware display: VN2-SRV1; accepted display aliases: WIN-VN2-SRV1; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Microsoft Store and its package distribution endpoints.

**Risk, cost and optional status:** low; local-only; optional=false. local-only Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Windows Terminal launches on the named guest and its installed package version is recorded.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

* VN1-SRV1
* VN2-SRV1

## Introduction

Install Windows Terminal on VN2-SRV1.

## Instructions

Perform these steps on VN2-SRV1.

1. Logon as **ad\Administrator**.
1. In Microsoft Edge, navigate to https://github.com/microsoft/terminal/releases.
1. Find the latest version.
1. Download the files **Microsoft.Windows.Terminal.\*.msixbundle** and **Microsoft.WindowsTerminal.\*_PreInstallKit**.
1. Run **Windows PowerShell** as Administrator.
1. Change to the **Downloads** folder.

    ````powershell
    Set-Location $env:USERPROFILE\Downloads
    ````

1. Expand the zip file **Microsoft.WindowsTerminal_Win10_\*PreinstallKit.zip**

    ````powershell
    Expand-Archive `
        .\Microsoft.WindowsTerminal_*.msixbundle_Windows10_PreinstallKit.zip
    ````

1. Change to the folder of the extracted preinstall kit.

    ````powershell
    Set-Location `
        .\Microsoft.WindowsTerminal_*.msixbundle_Windows10_PreinstallKit
    ````

1. Install the preinstall kit.

    ````powershell
    Add-AppxPackage Microsoft.UI.Xaml.*_x64__*.appx
    ````

1. Change to the folder of the downloaded Windows Terminal.

    ````powershell
    Set-Location ..
    ````

1. Install Windows Terminal

    ````powershell
    Add-AppxPackage Microsoft.WindowsTerminal_*.msixbundle
    ````
