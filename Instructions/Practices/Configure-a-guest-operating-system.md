# Practice: Configure a guest operating system

## Required VMs

* VN1-SRV1
* PM-SRV1
* CL1

## Task

In the virtual machine PM-SRV20, set the administrator password, set the IP address to 10.10.20.160/24, leave the default gateway blank on isolated VMnet20, and set the DNS client server to 10.10.10.10. Join the virtual machine to the domain ad.lab.test and rename the guest operating system computer.

## Instructions

Perform these steps on CL1.

1. Sign in as **ad\Administrator**.
1. In VMware Workstation, open the **PM-SRV20** console. Hyper-V Manager and Hyper-V Virtual Machine Connection are not used by the default learner host.
1. At the prompt **The user's password must be changed before signing in**, select **OK** and press ENTER.
1. Beside **New password** and **Confirm password**, enter a secure password and take a note.
1. At **Your password has been changed**, press ENTER.
1. In SConfig, enter **8**.
1. In Network settings, enter **1**.
1. In Network adapter settings, enter **1**.
1. At the prompt Select (D)HCP or (S)tatic IP address (Blank=Cancel), enter **S**.
1. At the prompt **Enter static IP address (Blank=Cancel)**, type **10.10.20.160** directly in the VMware console and press ENTER. VMware clipboard integration is not required.
1. At the prompt **Enter subnet mask (Blank=255.255.255.0)**, press ENTER.
1. At the prompt **Enter default gateway (Blank=Cancel)**, press ENTER and leave it blank. Isolated VMnet20 has no default gateway; attach VMnet8 temporarily only when controlled outbound access is required.
1. Under a number of success messages, press ENTER.
1. In SConfig, enter **8**.
1. In Network settings, enter **1**.
1. In Network adapter settings, enter **2**.
1. At the prompt **Enter new preferred DNS server (Blank=Cancel)**, enter **10.10.10.10**.
1. At the prompt **Enter alternate DNS server**, press ENTER.
1. Under **Sucessfully assigned DNS server(s)**, press ENTER.
1. In SConfig, enter **1**.
1. At the prompt **Join (D)omain or (W)orkgroup? (Blank=Cancel)**, enter **D**.
1. At the prompt **Name of domain to join (Blank=Cancel)**, enter **ad.lab.test**.
1. At the prompt **Specify an authorized domain\user (Blank=Cancel)**, enter **ad\Administrator**.
1. At the prompt **Password for ad\Administrator**, enter the password of **ad\Administrator**.
1. At the prompt **Do you want to change the computer name before restarting? (Y)es or (N)o**, enter **Y**.
1. At the prompt **Enter new computer name (Blank=Canel)**, enter **PM-SRV20**.
1. At the prompt **Password for ad\Administrator**, enter the password of **ad\Administrator**.
1. At the prompt **Restart now? (Y)es or (N)o**, enter **Y**.
