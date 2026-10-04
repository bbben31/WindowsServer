# Lab: Configure external access to Remote Desktop Services

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md; Instructions/General/Environment-Profiles.md; Instructions/General/Member-Servers-and-Clients.md; Instructions/Labs/Deploy-Remote-Desktop-Services.md. Provision the declared roles, disks, certificates and test data before the first task; preserve the selected profile and recorded VMnet mapping. Take a coordinated pre-lab recovery point for every guest changed by this exercise; do not independently rewind a domain controller.  Record a dedicated Perimeter 10.1.200.0/24 VMware NAT segment and a separate VMnet8 external-client segment. TCP 443 on the host must be unused; restrict the temporary host listener/firewall to the external test client.

**Machines and network profile:** CL1 (VMware display: CL1; accepted display aliases: WIN-CL1; existing); CL2 (VMware display: CL2; accepted display aliases: WIN-CL2; existing); PM-SRV3 (VMware display: PM-SRV3; accepted display aliases: WIN-PM-SRV3; existing); VN1-SRV1 (VMware display: VN1-SRV1; accepted display aliases: WIN-VN1-SRV1; existing); VN1-SRV10 (VMware display: VN1-SRV10; accepted display aliases: WIN-VN1-SRV10; existing); VN1-SRV8 (VMware display: VN1-SRV8; accepted display aliases: WIN-VN1-SRV8; existing); VN1-SRV9 (VMware display: VN1-SRV9; accepted display aliases: WIN-VN1-SRV9; existing); VN2-SRV1 (VMware display: VN2-SRV1; accepted display aliases: WIN-VN2-SRV1; existing).  Enterprise expansion: named source VNet1/VNet2/VNet3 and 10.1.x.0/24 segments use distinct isolated VMware custom VMnets. Record the per-exercise mapping; disable VMware DHCP on Windows DHCP segments. Temporary outbound VMnet8 NAT during the declared online or media-staging steps only; disconnect afterward.

**Permissions:** Enterprise CA/template administration and enrollment rights for the named certificate tasks; Local Administrator for server/guest setup. Protect private-key exports.

**Outbound access:** Temporary VMware NAT VMnet8; preserve AD DNS on the lab NIC, disable NAT NIC DNS registration, remove outbound connectivity afterward. Endpoints: Official Microsoft product download endpoints and installer dependencies.

**Risk, cost and optional status:** high; local-only; optional=true. local-only Enterprise expansion profile; retain the named multi-server roles and isolate all source networks in VMware. Verify current support for optional products before execution.

**Success verification:** The intended gateway/web URL and trusted certificate allow the authorized test session from the isolated external segment.

**Rollback and cleanup:** Restore the coordinated pre-lab recovery points of affected disposable guests and remove only exercise-created data/configuration. Retain prerequisite roles until dependent exercises finish; remove temporary VMnet8 access and restore recorded adapters/DNS/settings. Remove the exercise VMware TCP 443 forward and restricted host firewall allowance; restore the Perimeter VMnet to its original isolated state and restore CL2 networking.

<!-- END GENERATED COMPLETION CONTRACT -->


> **Learner topology note:** Complete [Learner setup](../General/Learner-Setup.md) and the practices linked below first. Provision every VM, extra disk, cluster member, certificate, and client named by this lab; the foundation machines alone may not be enough. Use your own documented addresses and the ad.lab.test domain. Do not use classroom provisioning scripts or credentials.




## Required VMs

* CL1
* CL2
* PM-SRV3
* VN1-SRV1
* VN1-SRV10
* VN1-SRV8
* VN1-SRV9
* VN2-SRV1

## Setup

1. On **CL1**, sign in as **ad\\Administrator**.
1. On **CL2**, sing in as **.\Administrator**.

You must have completed the lab [Deploy Remote Desktop Services](Deploy-Remote-Desktop-Services.md).

## Introduction

Because your users work from home office, you want to make your Remote Desktop Services Deployment available for external access. For this purpose, you want to deploy and verify the RD Gateway.

## Exercises

1. [Deploy an RD Gateway](#exercise-1-deploy-an-rd-gateway)
2. [Verify the RD Gateway](#exercise-2-verify-the-rd-gateway)

## Exercise 1: Deploy an RD Gateway

1. [Install the Remote Server Administration DNS Server Tools](#task-1-install-the-remote-server-administration-dns-server-tools) on CL1
1. [Create a DNS zone with a record](#task-2-create-a-dns-zone-with-a-record) with the name lab.test and the record remote pointing to 10.1.200.24
1. [Add an RD gateway server](#task-3-add-an-rd-gateway-server) on PM-SRV3
1. [Configure RD Gateway](#task-4-configure-rd-gateway) by adding the RD Web certificate

### Task 1: Install the Remote Server Administration DNS Server Tools

#### Desktop experience

Perform these steps on CL1.

1. Open **Settings**.
1. In Settings, click **System**.
1. In System, click **Optional features**.
1. In Optional features, click the button **View features**.
1. In View features, if necessary, click **See available features**.
1. In Add an optional feature, in the text field **Find an available optional feature**, type **RSAT**. Activate the check box beside **RSAT: DNS Server Tools**. Click **Add (1)**.
1. If required, restart the computer.

Wait for the installation to complete.

#### PowerShell

Perform these steps on CL1.

1. In the context menu of **Start**, click **Terminal (Admin)**.
1. Add the windows capabilities **RSAT: Server DNS Server tools**.

    ````powershell
    Get-WindowsCapability -Online -Name 'Rsat.Dns.Tools*' |
    Add-WindowsCapability -Online
    ````

Wait for the installation to complete.

### Task 2: Create a DNS zone with a record

Perform these steps on CL1.

1. Open **DNS**.
1. In Connect to DNS-Server, click **The following computer** and, below, type VN1-SRV1.ad.lab.test. Click **OK**.
1. In DNS Manager, expand **VN1-SRV1.ad.lab.test**, **Forward Lookup Zones**, and click **Forward Lookup Zones**.
1. In the context-menu of **Forward Lookup Zones**, click **New Zone..**
1. In the New Zone Wizard, click **Next >**.
1. On page Zone Type, ensure, **Primary zone** is selected. Click to deactivate **Store the zone in Active Directory**. Click **Next >**.
1. On page Zone Name, type **lab.test** and click **Next >**.
1. On page Zone file, ensure, **Create a new file with this file name** is selected and **lab.test.dns** is typed in. Click **Next >**.
1. On page Dynamic update, ensure **Do not allow dynamic updates** is selected and click **Next >**.
1. On page Completing the New Zone Wizard, verify you selections and click **Finish**.
1. In DNS Manager, click **lab.test**.
1. In the context-menu of **lab.test**, click **New Host (A or AAAA)...**
1. In New Host, under **Name (uses parent domain if blank)**, type **remote**. Ensure, that under **Fully qualified domain name (FQDN)**, **remote.lab.test** appears. Under **IP address**, type **10.1.200.24**. Click **Add Host**.
1. In The host record remote.lab.test was successfully created, click **OK**.
1. In New Host, click **Done**.

### Task 3: Add an RD gateway server

Perform these steps on CL1.

1. Open **Server Manager**.
1. In Server Manager, click **Remote Desktop Services**.
1. In Remote Desktop Services > Overview, under DEPLOYMENT SERVERS, click **TASKS**, **Add RD Gateway Servers**.

    Alternatively, under DEPLOYMENT OVERVIEW, click the green plus sign above RD Gateway.

1. In Add RD Gateway Servers, click **PM-SRV3.ad.lab.test** and click the arrow button rbetween the columns. Click **Next >**.
1. On page Name the self-signed SSL certificate, type **remote.lab.test** and click **Next >**.
1. On page Confirmation, click **Add**.

    Wait for the installation to complete.

1. On page Results, click **Close**.

### Task 4: Configure RD Gateway

Perform these steps on CL1.

1. Open **Server Manager**.
1. In Server Manager, click **Remote Desktop Services**.
1. In Remote Desktop Services > Overview, under DEPLOYMENT OVERVIEW, click **TASKS**, **Edit Deployment Properties**.
1. In Deployment Properties, click the page **Certificates**.
1. On page Certificates, click **RD Gateway** and click **Select existing certificate...**.
1. In Select Existing Certificate, click **Choose a different certificate** and click **Browse...**.
1. In Open, open the file **c:\\certs\\rdweb.pfx**
1. In Select Existing Certificate, under **Password**, type the password you assigned to the PFX file. Click to enable **Allow the certificate to be added to the Trusted Root Certification Authorities certificate store on the destination computer** and click **OK**.
1. In Deployment Properties, click **Apply**.

    Wait for the changes to be applied. For the Role Service RD Gateway, the Level column should be Trusted now.

1. Click the page **RD Gateway**.
1. On page RD Gateway, ensure **Use these RD Gateway server settings** is selected. Ensure, under **Server name**, **remote.lab.test** is typed in. Ensure, **Logon method** is **Password Authentication**. Ensure, both checkboxes are activated.
1. In Deployment Properties, click **OK**.

## Exercise 2: Verify the RD Gateway

1. [Connect to Remote Desktop Services using RD Web](#task-1-connect-to-remote-desktop-services-using-rd-web) from CL1.
1. [Create an external network switch](#task-2-create-an-external-network-switch) on the host computer
1. [Add a static NetNat mapping](#task-3-add-a-static-netnat-mapping) on the host computer forwarding port 443 to 10.1.200.24 and find out the external IP address of the Perimeter network.
1. [Connect WIN-CL2 to the external network switch](#task-4-connect-win-cl2-to-the-external-network-switch)
1. [Configure the network on the client](#task-5-configure-the-network-on-the-client) CL2: Set the network adapter to use DHCP for all configurations and add remote.lab.test with the external IP address of the Perimeter network
1. [Connect to Remote Desktop Services from the external network](#task-6-connect-to-remote-desktop-services-from-the-external-network) on CL2

### Task 1: Connect to Remote Desktop Services using RD Web

Perform these steps on CL1.

1. Open **File Explorer**.
1. In File Explorer, navigate to **Downloads**.
1. Delete the file **cpub-Standard_desktop-Standard_desktop-CmsRdsh**, if it is present.

1. Open **Microsoft Edge**.
1. In Microsoft Edge, navigate to <https://remote.lab.test/RDWeb>.
1. On page Work Resources, sign in as **AD\Ada**.
1. On page Work Resources, under RemoteApp and Desktops, click **Standard desktop**.
1. Under Downloads, click **Keep**.
1. Under cpub-Standard_desktop-Standard_desktop-CMSRdsh.rdp, click **Open file**.
1. In Remote Desktop connection security warning, ensure, beside **Gateway server**, **remote.lab.test** is shown. Click **Connect**.
1. In Windows Security, click **More choices** and **Use a different account**. Sign in as **AD\Ada**.

    Wait for the connection to complete.

1. In the connection bar, click the icon *Connection information* ([figure 1]).
1. In Remote Desktop Connection, click **Show details**.

    Beside Gateway name, Not in use is displayed. This is because Remote Desktop Connection determined that the session host is on the same network.

1. Click **OK**.
1. Close the Remote Desktop Connection.

### Task 2: Create an external network switch

Perform these steps in VMware Workstation on the host.

1. Record the current custom VMnet mapped to **Perimeter (10.1.200.0/24)** and all attached guests. In **Edit > Virtual Network Editor > Change Settings**, configure that dedicated VMnet as **NAT** for this exercise. Keep its existing subnet; record the actual NAT gateway. Disable VMware DHCP on the Perimeter segment to preserve the guests' static addresses.
1. Use **VMnet8** as the external test-client segment. Record the host's VMnet8 adapter address and CL2's lease. This models an external client through a lab NAT boundary; it does not publish a service on the Internet or bridge a physical adapter.

### Task 3: Add a static NetNat mapping

1. In the Perimeter custom VMnet's **NAT Settings > Port Forwarding > Add**, map an unused host **TCP 443** port to **10.1.200.24 TCP 443** (PM-SRV3, the RD Gateway/Web server). Verify no host service already owns port 443; if it does, stop this optional portion rather than displacing it.
1. Restrict any temporary host firewall allowance to the VMnet8 adapter and the recorded CL2 address. Do not open the physical LAN interface. Record the exact forwarding/firewall settings for removal.
1. Record the host's VMnet8 adapter address as the external endpoint for the next task. The original Windows `Perimeter` NetNat object is not used on the VMware host.

### Task 4: Connect WIN-CL2 to the external network switch

1. Shut down CL2. In VMware **VM > Settings > Network Adapter**, select **NAT (VMnet8)** for its test NIC, and disconnect other NICs that bypass this boundary.
1. Start CL2 and verify its VMnet8 lease and access to the recorded host endpoint. Preserve the original NIC settings for cleanup.
### Task 5: Configure the network on the client

Perform these steps on CL2.

1. Open **Terminal** as Administrator.
1. Configure the network adapter to use DHCP for all settings.

    ````powershell
    Get-NetAdapter | Set-NetIPInterface -Dhcp Enabled
    Get-NetAdapter | Set-DnsClientServerAddress -ResetServerAddresses
    ````

1. Open the hosts file.

    ````powershell
    notepad.exe C:\windows\System32\drivers\etc\hosts
    ````

1. In the hosts file, add a new line at the end with theh following text. Replace **\<external IP address\>** with the IP address you noted in the previous task.

    ````text
    <external IP address>   remote.lab.test
    ````

1. Save and close the hosts file.

### Task 6: Connect to Remote Desktop Services from the external network

Perform these steps on CL2.

1. Open **Microsoft Edge**.
1. In Microsoft Edge, navigate to <https://remote.lab.test/RDWeb>
1. On page Work Resources, sign in with **AD\Ada**.
1. On page Work Resources, under RemoteApp and Desktops, click **Standard desktop**.
1. Under Downloads, click **Keep**.
1. Under cpub-Standard_desktop-Standard_desktop-CMSRdsh.rdp, click **Open file**.
1. In Remote Desktop connection security warning, ensure, beside **Gateway server**, **remote.lab.test** is shown. Click **Connect**.
1. In Windows Security, sign in as **AD\Ada**.
1. In the message with Certificate errors, click Yes.

    *Note:* The error occurs, because the certificate revocation list (CRL) is not available to CL2. In a real-world scenario, you should make the CRL of your enterprise root CA available on the public Internet.

    Wait for the connection to complete.

1. In the connection bar, click the icon *Connection information* ([figure 1]).
1. In Remote Desktop Connection, click **Show details**.

    Beside Gateway name, remote.lab.test is shown.

1. Click **OK**.
1. Close the Remote Desktop Connection.

[figure 1]: /images/Remote-Desktop-Connection-Bar.png

## Network cleanup

Remove only this exercise's VMware TCP 443 forwarding entry and restricted host firewall allowance. Restore the Perimeter VMnet's recorded host-only settings and CL2's original network connections/DNS. Verify the RD Gateway is no longer reachable through the temporary external endpoint.
