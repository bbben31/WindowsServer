# Lab: Monitor performance

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Practices/Install-app-compatibility-feature-on-demand.md. Provision only existing prerequisite machines and their required roles, disks, certificates and test data before starting; create phase-created machines in the designated tasks. Preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller. On Server Core VN1-SRV10, apply the App Compatibility practice to VN1-SRV10 with matching optional-feature media before local Resource Monitor/Performance Monitor steps; restart and verify resmon.exe and perfmon.exe launch. Completing the practice only on its original VN1-SRV5 target does not prepare VN1-SRV10.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing). Core foundation: VMnet10 10.10.10.0/24 (AD), VMnet11 10.10.20.0/24 (workloads), VMnet12 10.10.30.0/24 (clients); use only the NICs required by this procedure.

**Permissions:** Local Administrator on the named disposable guests for role, service, storage, registry and remote-management changes; authorized lab account for remote access.

**Outbound access:** Isolated lab; no online download is required by the selected procedure.

**Risk, cost and optional status:** high; local-only; optional=false. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Recorded counters identify the controlled workload/resource pressure; stop the workload and confirm recovery to baseline.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; restore recorded adapters/DNS/settings.

<!-- END GENERATED COMPLETION CONTRACT -->

> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision only existing prerequisite machines, disks, cluster roles and certificates before starting; create machines marked Created during exercise in their designated tasks. Follow alternatives and conditional-retirement requirements instead of starting every named VM; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Required VMs

* CL1
* VN1-SRV1
* VN1-SRV10

## Setup

The local Resource Monitor/Performance Monitor tasks require graphical tools on **VN1-SRV10**. On its Server Core baseline, install **ServerCore.AppCompatibility~~~~0.0.1.0** from matching Server Languages/Optional Features media, following [the AppCompatibility practice](../Practices/Install-app-compatibility-feature-on-demand.md) but targeting VN1-SRV10, then restart and verify `resmon.exe` and `perfmon.exe` launch. Do not assume the untouched Core image includes these tools. Record the staged ISO path instead of relying on a filename from a different release.

On **VN1-SRV10**, sign in as **ad\Administrator**.

On **CL1**, sign in as **ad\Administrator**.

## Introduction

Users complain about the performance of one of your servers. You analyze the performance of that server, identify the problem. After you make upgrades to tackle the performance problem, you analyze the performance again. To avoid problems in the future, you test a performance alert that will gather performance data automatically.

## Exercises

1. [Monitor performance under low memory conditions](#exercise-1-monitor-performance-under-low-memory-conditions)
2. [Monitor performance after a memory upgrade](#exercise-2-monitor-performance-after-a-memory-upgrade)
3. [Use a performance alert](#exercise-3-use-a-performance-alert)

## Exercise 1: Monitor performance under low memory conditions

1. [Configure a data collector set with baseline performance counters](#task-1-configure-a-data-collector-set-with-baseline-performance-counters) on VN1-SRV10
1. [Configure VN1-SRV10 with 1 GB of memory](#task-2-configure-vn1-srv10-with-1-gb-of-memory)
1. [Start the data collector set](#task-3-start-the-data-collector-set)
1. [Simulate load](#task-4-simulate-load) by copying an ISO file from `C:\WindowsServerLab\Resources` on VN1-SRV10 to CL1.
1. [Analyze the performance data](#task-5-analyze-the-performance-data)

### Task 1: Configure a data collector set with baseline performance counters

Perform these steps on VN1-SRV10.

1. Open **Performance Monitor**.
1. In Performance Monitor, expand **Data Collector Sets**.
1. In the context menu of **User Defined**, click **New**, **Data Collector Sets**.
1. In Create new Data Collector Sets, on the page **How would you like to create this new data collector set?**, in **Name**, type **Baseline**.
1. Click **Create manually** and click **Next**.
1. On page **What type of data do you want to include?**, click **Create data logs**, activate the checkbox **Performance counter**, and click **Next**.
1. On page **Which performance counters would you like to log?`**, click **Add...**.
1. Under **Available counters**, click **Processor**.
1. Under **Instances of selected object**, click **\<All instances\>** and click **Add >>**.
1. Repeat the previous 2 steps to add counters for **PhysicalDisk** and **Network Adapter**.
1. Under **Available counters**, click **Memory** and click **Add >>**.
1. Click **OK**.
1. On page **Which performance counters would you like to log?`**, under **Sample interval**, type **1**.
1. Click **Next**.
1. On page **Where would you like the data to be saved?**, click **Next**.
1. On page **Create the data collector set?**, click **Finish**.

### Task 2: Configure VN1-SRV10 with 1 GB of memory

Perform these steps on the host.

1. Shut down VN1-SRV10. In VMware Workstation, record its current memory, set it to **1 GB**, and start the VM.

Wait for the complete start of VN1-SRV10.

### Task 3: Start the data collector set

Perform these steps on VN1-SRV10.

1. Sign in as **ad\\Administrator**.
1. Open **Performance Monitor**.
1. In Performance Monitor, expand **Data Collector Sets** and click **User Defined**.
1. In the context menu of **Baseline**, click **Start**.

### Task 4: Simulate load

Perform these steps on CL1.

1. Open **Terminal**.
1. Measure the time it takes to copy **\\\\VN1-SRV10\\c$\\WindowsServerLab\\Resources\\26100.1.240331-1435.ge_release_amd64fre_SERVER_LOF_PACKAGES_OEM.iso** to **C:\\**.

   ````powershell
   Get-Date
   Measure-Command { 
      Copy-Item `
         -Path `
            '\\VN1-SRV10\c$\WindowsServerLab\Resources\26100.1.240331-1435.ge_release_amd64fre_SERVER_LOF_PACKAGES_OEM.iso' `
         -Destination 'c:\' `
         -Force 
      }
   Get-Date
   ````

   Take a note of the start and end time and the timespan it takes.

### Task 5: Analyze the performance data

Perform this task on CL1.

1. Open **Performance Monitor**.
1. In the context menu of **Performance Monitor**, click **Properties**.
1. In Performance Monitor Properties, click the tab **Source**.
1. On the tab Source, click **Log files**.
1. Click **Add...**
1. In Select log file, in **File name**, enter **\\\\VN1-SRV10\\c$\\PerfLogs\\Admin\\Baseline**.
1. Open the folder with the highest number.
1. Open **DataCollector01**.
1. In **Performance Monitor Properties**, on tab **Source**, under **Total range**, drag the sliders to the start and end times of the copy process.
1. In **Performance Monitor Properties**, click the tab **Data**.
1. On the tab Data, click **Add...**.
1. In Add Counters, under **Available counters**, expand **Memory**, click **Available MBytes** and click **Add >>**.
1. Repeat the previous step for
   * Memory: Cache Bytes
   * Memory: Committed Bytes
   * Memory: Pages/sec
   * Network Adapter: Bytes Received/sec
   * Network Adapter: Bytes Sent/sec
   * Network Adapter: Current Bandwidth
   * PhysicalDisk: % Disk Time \<All Instances\>
   * PhysicalDisk: Current Disk Queue Length \<All Instances\>
   * Processor: % Processor Time \<All Instances\>

1. Click **OK**.
1. In **Performance Monitor Properties**, click **OK**.
1. In the right pane, uncheck all checkboxes in the column **Show**.
1. Now gradually check the checkboxes in the column **Show** for various counters.

   > Can you identify the bottlenecks during the copy process? Especially look at Cache Bytes, Committed Bytes and Pages/sec.

## Exercise 2: Monitor performance after a memory upgrade

1. [Configure VN1-SRV10 with 4 GB of memory](#task-1-configure-VN1-SRV10-with-4-gb-of-memory)
1. [Analyze the impact of the memory upgrade](#task-2-analyze-the-impact-of-the-memory-upgrade)

   > Can you spot the main difference?

1. [Stop the data collector set](#task-3-stop-the-data-collector-set)

### Task 1: Configure VN1-SRV10 with 4 GB of memory

Perform these steps on the host.

1. Shut down VN1-SRV10. In VMware Workstation, restore its memory to **4 GB**, and start the VM.

Wait for the complete start of VN1-SRV10.

### Task 2: Analyze the impact of the memory upgrade

Repeat tasks 3 - 5 from the previous exercise.

### Task 3: Stop the data collector set

Perform these steps on VN1-SRV10.

1. In **Performance Monitor**, in the context menu of **Baseline**, click **Stop**.

## Exercise 3: Use a performance alert

1. [Configure a performance alert](#task-1-configure-a-performance-alert) on % Processor Time over 80 to log an event and start the Baseline data collector set.
1. [Simulate CPU load](#task-2-simulate-cpu-load) with bounded PowerShell background jobs
1. [Verify the performance alert](#task-3-verify-the-performance-alert) and stop all data collector sets.

### Task 1: Configure a performance alert

Perform these steps on VN1-SRV10.

1. In **Performance Monitor**, in the context menu of **User Defined**, click **New**, **Data Collector Set**.
1. In Create new Data Collector Sets, on the page **How would you like to create this new data collector set?**, in **Name**, type **CPU time alert**.
1. Click **Create manually** and click **Next**.
1. On page **What type of data do you want to include?**, click **Performance Counter Alert** and click **Next**.
1. On page **Which performance counters would you like to monitor?`**, click **Add...**.
1. Under **Available counters**, expand **Processor** and click **% Processor Time**.
1. Under **Instances of selected object**, click **\<All instances\>** and click **Add >>**.
1. Click **OK**.
1. On page **Which performance counters would you like to monitor?`**, under **Performance counters**, click **\\Processor(0)\\% Processor Time**. Under **Alert when**, ensure **Above** is selected and in **Limit**, type 80.
1. Repeat the previous step for all instances of % Processor Time.
1. Click **Next**.
1. On page **Create the data collector set?** click **Finish**.
1. In **Performance Monitor**, click **CPU time alert**.
1. In CPU time alert, in the context menu of **DataCollector001**, click **Properties**.
1. In Datacollector01 Properties, click the tab **Alert Action**.
1. On tab Alert Action, activate the checkbox **Log an entry in the application event log**.
1. Under **Start a data collector set**, click **Baseline** and click **OK**.
1. In the context menu of **CPU time alert**, click **Start**.

### Task 2: Simulate CPU load

Perform these steps on VN1-SRV10.

1. Run **Windows PowerShell** as Administrator.
1. Start one bounded CPU workload per logical processor. The jobs stop after 60 seconds and are then removed.

   ````powershell
   $jobs = foreach ($processor in 1..([Environment]::ProcessorCount)) {
       Start-Job -ScriptBlock {
           $end = (Get-Date).AddSeconds(60)
           while ((Get-Date) -lt $end) {
               [Math]::Sqrt((Get-Random)) | Out-Null
           }
       }
   }
   try {
       $jobs | Wait-Job | Out-Null
   }
   finally {
       $jobs | Stop-Job
       $jobs | Remove-Job -Force
   }
   ````

   After about a minute, the process will stop automatically.

### Task 3: Verify the performance alert

Perform these steps on VN1-SRV10.

1. Open **Event Viewer**.
1. Expand **Applications and Services Logs**, **Microsoft**, **Windows**, **Diagnosis-PLA**, and click **Operational**.

   > You should see various entries from the alert with the event ID **2031**.

1. In **Performance Monitor**, verify the data collector set **Baseline** is running.
1. In the context menu of **Baseline**, click **Stop**.
1. In **Performance Monitor**, in the context menu of CPU time alert, click **Stop**.
