# Windows containers

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV13 (VMware display: VN1-SRV13; accepted display aliases: WIN-VN1-SRV13; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet20 10.10.20.0/24 (workloads), VMnet30 10.10.30.0/24 (clients); use only the NICs required by this procedure. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: raw.githubusercontent.com/microsoft/Windows-Containers pinned installer; mcr.microsoft.com and registry CDN; github.com/MicrosoftDocs/Virtualization-Documentation; Official winget/Git/Visual Studio Code sources and VS Code extension marketplace.

**Risk, cost and optional status:** high; local-only; optional=true. Optional nested Windows-container exercise. Verify VMware nesting and Microsoft host/image compatibility. Preserve the historical SDK 6 sample only in disposable compatibility work; skip sample-app building if its SDK/runtime/framework cannot be validated, and retain the basic container exercise.

**Success verification:** The pinned installer hash matches, Nano Server image runs, and the built sample image produces the intended output.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision only existing prerequisite machines, disks, cluster roles and certificates before starting; create machines marked Created during exercise in their designated tasks. Follow alternatives and conditional-retirement requirements instead of starting every named VM; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.








## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV13

## Introduction

## Exercises

1. [Run the first container](#exercise-1-run-the-first-container)
1. [Containerize a sample app](#exercise-2-containerize-a-sample-app)

## Exercise 1: Run the first container

1. [Configure nested virtualization](#task-1-configure-nested-virtualization) for the VM VN1-SRV13. This is an expanded VMware exercise and is not part of the default profile.
1. [Download and install Docker CE](#task-2-download-and-install-docker-ce) on VN1-SRV13
1. [Pull the Nano server base image](#task-3-pull-the-nano-server-base-image)
1. [Run the Nano server image in a container](#task-4-run-the-nano-server-image-in-a-container) with the user ContainerAdministrator and create a simple text file in it
1. [Create a new container image](#task-5-create-a-new-container-image) from the container you created with the name helloworld and run a new container from the image, emitting the content of the text file you created

### Task 1: Configure nested virtualization

Perform this task on the host.

1. Open **Windows PowerShell (Admin)**.
1. Power off **VN1-SRV13** and open **VM > Settings > Processors** in VMware Workstation. Enable **Virtualize Intel VT-x/EPT or AMD-V/RVI** and, if Docker requires it, **Virtualize IOMMU**. Set fixed memory of **4 GB** and keep the NIC on the documented VMware VMnet. Do not run Hyper-V host cmdlets against a VMware VM.
1. Start the VM and verify nested virtualization from inside Windows with `systeminfo.exe`; if the hypervisor requirements are not available, stop this optional exercise.

### Task 2: Download and install Docker CE

Perform this task on VN1-SRV13.

1. Sign in as **Administrator**.
1. In SConfig, enter **15**.
1. Download and install Docker CE from Github.

    ````powershell
    Set-Location C:\WindowsServerLab\Resources\Downloads
    $uri = 'https://raw.githubusercontent.com/microsoft/Windows-Containers/9fd4c4d85597ce75834f4e1cd21695c34642de3d/helpful_tools/Install-DockerCE/install-docker-ce.ps1'
    $expectedHash = '09DED921D046EE98723ED533E6E517691C744A916769C181AA1C4A2DC784E63E'
    Invoke-WebRequest -Uri $uri -OutFile install-docker-ce.ps1 -UseBasicParsing
    $actualHash = (Get-FileHash .\install-docker-ce.ps1 -Algorithm SHA256).Hash
    if ($actualHash -ne $expectedHash) {
        throw "Installer hash mismatch. Expected $expectedHash; received $actualHash."
    }
    Get-Content .\install-docker-ce.ps1
    # Continue only after reviewing the pinned script.
    .\install-docker-ce.ps1 -HyperV
    ````

    Wait for the instalation to finish. This will take less than a minute. The computer will during the installation.

1. After the computer finished starting, sign in as **Administrator**.

    The PowerShell script should start automatically. After a few seconds, the script should complete.

1. Close the windows with the script.

### Task 3: Pull the Nano server base image

Perform this task on CL1.

1. Open **Terminal**.
1. In Terminal, enter a remote PowerShell session to VN1-SRV13.

    ````powershell
    Enter-PSSession VN1-SRV13
    `````

1. Download and install the base image for Nano server.

    ````powershell
    docker image pull mcr.microsoft.com/windows/nanoserver:ltsc2022
    ````

1. Query your local docker image repository.

    ````powershell
    docker image ls
    `````

    You should see the image of microsoft/nanoserver.

1. Exit the remote PowerShell session

    ````powershell
    Exit-PSSession
    ````

### Task 4: Run the Nano server image in a container

Perform this task on VN1-SRV13.

1. In SConfig, enter **15**.
1. Start a container with an interactive session from the nanoserver image.

    ````powershell
    docker container run --interactive --tty --user ContainerAdministrator mcr.microsoft.com/windows/nanoserver:ltsc2022 cmd.exe
    ````

    This command starts a new container using the Nano server image. The -i or --interactive option tells Docker to keep STDIN open even if not attached. The -t or --tty option tells Docker to allocate a pseudo-TTY. Within the container, cmd.exe is executed.

    You are now in a `cmd.exe` session inside the container.

1. In the container, create a simple text file **Hello.txt** in **C:\\Users\\ContainerUser** and exit from the container.

    ````shell
    echo "Hello World!" > Hello.txt
    exit
    `````

### Task 5: Create a new container image

Perform this task on VN1-SRV13.

1. In SConfig, enter **15**.
1. Get the container ID for the container you just existed.

    ````powershell
    docker container ls --all
    ````

    Take a note of the CONTAINER ID of your container.

1. Create a new **heloworld** image that includes the changes in the first container you ran. Replace the first parameter with the container ID noted in the previous step.

    ````powershell
    docker container commit bb91a76b8023 helloworld
    ````

1. List the image in your local repository.

    ````powershell
    docker image ls
    ````

    You should see the helloworld image in addition to the Nano server image.

1. Run the new container, type the content of **C:\\Users\\ContainerUser\\Hello.txt** and remove the container.

    ````powershell
    docker container run --rm helloworld cmd.exe /s /c type Hello.txt
    ````

    You should see the content of Hello.txt.

## Exercise 2: Containerize a sample app

1. [Install Git](#task-1-install-git) on CL1
1. [Install Visual Studio Code](#task-2-install-visual-studio-code) on CL1 and add the Docker extension
1. [Clone the app repository](#task-3-clone-the-app-repository) <https://github.com/MicrosoftDocs/Virtualization-Documentation.git>
1. [Build and run the app](#task-4-build-and-run-the-app): To build the app, you must change the base image for the build environment to mcr.microsoft.com/dotnet/sdk:6.0.406-nanoserver-ltsc2022. Run the container in Hyper-V isolation mode and map port 80 of the container to port 5000 on the host.

### Task 1: Install Git

Perform this task on CL1.

1. Run **Terminal**.
1. In Terminal, install **Git** using winget.

    ````powershell
    winget install Git.Git --accept-source-agreements
    ````

    Wait for the installation to complete. This takes less than a minute.

### Task 2: Install Visual Studio Code

Perform this task on CL1.

1. Open **Terminal**.
1. In Terminal, install **Visual Studio Code** using winget.

    ````powershell
    winget install Microsoft.VisualStudioCode --accept-source-agreements
    ````

    Wait for the installation to complete. This takes less than a minute.

1. Open **Visual Studio Code**.
1. In Visual Studio Code, close the tab **Walkthrough: Setup VS Code**.
1. On the left-hand side click the icon *Extensions*.
1. In EXTENSIONS, in **Search Extensions in Marketplace**, type **Docker** and click Docker.

    Make sure, the extension looks similar to [figure 1].

1. In the extension screen of Docker, click **Install**.

### Task 3: Clone the app repository

Perform this task on CL1.

1. Open **Visual Studio Code**.
1. In Visual Studio Code, on the menu, click **View**, **Command Palette...** or press CTRL + SHIFT + P.
1. In the command palette, search for and click **Git: Clone**.
1. In Provide repository URL or pick a repository source, enter **https://github.com/MicrosoftDocs/Virtualization-Documentation.git**.
1. In Choose a folder to clone https://github.com/MicrosoftDocs/Virtualization-Documentation.git into, navigate to **C:\\WindowsServerLab\\Resources** and click **Select as Repository Destination**.

    Wait for the cloning to finish. This takes a few seconds.

1. In Would you like to open the cloned repository, click **Open**.
1. In Do you trust the authors of the files in the folder, click **Yes, I trust the authors**

### Task 4: Build and run the app

Perform this task on CL1.

1. Open **Visual Studio Code**.
1. In Visual Studio Code, if the repository **VIRTUALIZATION-DOCUMENTATION** is not open:

    1. On the menu, click **File**, **Open Folder...**
    1. In Open Folder, navigate to **C:\\WindowsServerLab\Resources\Virtualization-Documentation** and click **Select Folder**.
    1. In Do you trust the authors of the files in the folder, click **Yes, I trust the authors**

1. In Explorer view, click **windows-container-samples**, **asp-net-getting-started** and **dockerfile**.
1. Change the first line to base the container on the following image.

    ````text
    FROM mcr.microsoft.com/dotnet/sdk:6.0.406-nanoserver-ltsc2022 AS build-env
    ````

    Take a look at the file content. You can find a line-by-line explanation under <https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/building-sample-app#write-the-dockerfile>

    *Compatibility gate*: Consult [Microsoft's Windows container compatibility matrix](https://learn.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility) for the actual host and image versions. Its Server 2025 table permits Server 2022 images in process or Hyper-V isolation; do not describe Server 2022 as newer than Server 2025. The pinned SDK 6 sample is historical. Inspect the project's target framework and every Dockerfile stage before building; if the old SDK/runtime or sample cannot be obtained and validated, skip this optional sample-app portion and retain exercise 1. Record the actual builder's supported isolation mode rather than claiming all builders forbid Hyper-V isolation.

1. On the menu click **File**, **Save**.
1. On the menu, click **View**, **Terminal**.
1. In the TERMINAL pane, create a new remote PowerShell session to VN1-SRV13 and store it in a variable.

    ````powershell
    $pSSession = New-PSSession VN1-SRV13
    ````

1. Copy the source files of the sample application to VN1-SRV13.

    ````powershell
    Copy-Item `
        -Path `
            C:\WindowsServerLab\Resources\Virtualization-Documentation\windows-container-samples\asp-net-getting-started\ `
        -ToSession $psSession `
        -Destination C:\WindowsServerLab\Resources\ `
        -Container `
        -Recurse
    ````

1. Enter the session to VN1-SRV13.

    ````powershell
    Enter-PSSession $psSession
    `````

1. Navigate to the directory of the sample application with the dockerfile.

    ````powershell
    Set-Location C:\WindowsServerLab\Resources\asp-net-getting-started\
    `````

1. Build the container from the dockerfile.

    ````powershell
    docker buildx build -t my-asp-app .
    ````

    If the command fails with an unknow switch error, try the alias command instead:

    ````powershell
    docker build -t my-asp-app .
    ````

    Wait for the build to complete. This takes a few minutes or two.

1. Run the container detached in hyper-v isolation mode, map port **5000** on the host to port **80** in the container and give the container the convenient name **myapp**.

    ````powershell
    docker container run -d -p 5000:80 --isolation hyperv --name myapp my-asp-app
    ````

    *Note:* This step deliberately demonstrates Hyper-V isolation. It is a teaching choice; consult the compatibility matrix before claiming that image/host versions require it.

1. Open **Microsoft Edge**.
1. In Microsoft Edge, navigate to <http://VN1-SRV13:5000>.

    You should see a sample web site.

[figure 1]: /images/Docker-VSCode-extension.png
