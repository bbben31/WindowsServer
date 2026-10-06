# Practice: Explore Winget

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV9 (VMware display: VN1-SRV9; accepted display aliases: WIN-VN1-SRV9; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Microsoft Store; winget source/CDN; Official Git and Visual Studio Code package sources.

**Risk, cost and optional status:** low; local-only; optional=true. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate. Verify current support for optional products before execution.

**Success verification:** winget list/export reflect the installed packages; update/uninstall results match the procedure and exported JSON is readable.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

## Required VMs

* VN1-SRV1
* VN1-SRV9

## Task

You want to develop a server application on VN1-SRV9. For this purpose, install the store version of PowerShell, the latest version of Git and version 1.96.3 of Microsoft Visual Studio Code on the server. Verify the install, by listing all installed packages. Export all installed packages to a JSON file for later use on another computer.

Later, you decide to update Visual Studio Code to the latest version. Moreover, you want to update all other packages on the server.

Finally, you want to inspect the log files of winget.

## Instructions

Perform these steps on VN1-SRV9.

1. Sign in as **.\Administrator**.
1. Run **Terminal** as Administrator.
1. Update the sources for winget and list.

    ````powershell
    winget source update
    ````

1. List the package sources of winget.

    ````powershell
    winget source list
    ````

1. Find the package for PowerShell.

    ````powershell
    winget search --name 'powershell' --accept-source-agreements
    ````

1. Copy the **Id** of **PowerShell** with the **msstore** as **Source** to the clipboard.
1. Install PowerShell from the msstore source.

    ````powershell
    winget install --id 9MZ1SNWT0N5D --accept-source-agreements --accept-package-agreements
    ````

    *Important*: The parameter for --id should be the the ID you copied in the previous step.

    > The version from the store will be updated automatically in the future.

1. Find the package for Git.

    ````powershell
    winget search --name 'Git' --exact --accept-source-agreements
    ````

    *Important:* When using the --exact parameter, the name is case-sensitive.

1. Get information about the Git package.

    ````powershell
    winget show --id Git.Git
    ````

1. Install Git from the winget source.

    ````powershell
    winget install --id Git.Git --accept-source-agreements --accept-package-agreements
    ````

1. Find the package for Visual Studio Code.

    ````powershell
    winget search --name 'Visual Studio Code' --accept-source-agreements
    ````

1. List available versions of Visual Studio Code.

    ````powershell
    winget show --id Microsoft.VisualStudioCode --versions
    ````

1. Install version 1.96.3 of Visual Studio Code from the winget source.

    ````powershell
    winget install --id Microsoft.VisualStudioCode --version 1.96.3 --accept-source-agreements --accept-package-agreements
    ````

1. List all installed packages.

    ````powershell
    winget list
    ````

1. Export the list of packages to a JSON file.

    ````powershell
    winget export c:\packages.json
    ````

    You might inspect the exported file. You could install all the packages on another computer by running ````winget import packages.json --accept-package-agreements --accept-source-agreements````.

1. List packages with available updates.

    ````powershell
    winget upgrade
    ````

    > Among others, Microsoft Visual Studio Code (User) should be listed, because we did not install the latest version.

1. Update Visual Studio Code.

    ````powershell
    winget upgrade --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements
    ````

1. Update all packages.

    ````powershell
    winget upgrade --all --accept-source-agreements --accept-package-agreements
    ````

1. View the location of log files.

    ````powershell
    winget --info
    ````

    To view the full path, you might have to extend the width of the Terminal window.

1. Open **File Explorer** and navigate to the path of the log files.
1. Open one of the log files in **Visual Studo Code** and inspect it.

If time allows, restart **Terminal** and verify, that **PowerShell** as well as **Git Bash** are available as command line interpreters.
