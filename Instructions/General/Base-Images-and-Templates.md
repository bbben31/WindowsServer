# Milestone B: Base images and templates

Use clean templates to reduce repeated installation work. This is the operational runbook for **Milestone B** on Windows 11 with VMware Workstation Pro 17. It does not provide product keys, credentials, or domain-provisioning automation.

## Prerequisites, sizing, and rollback

Complete [Milestone A networking](VMware-Segmented-Networking.md), verify `VMnet10`, `VMnet20`, `VMnet30`, and optional `VMnet8`, and run the [read-only preflight checker](../../tools/Preflight-LearnerLab.ps1) with both ISO paths. Download the Windows Server 2025 Evaluation ISO and Windows 10 ISO only from official Microsoft sources. Keep their SHA-256 values and download dates in private notes; never commit media, keys, tokens, or personal identifiers.

On the 32 GB host, start conservatively:

| Template | vCPU | RAM | Disk | NIC | Startup plan |
| --- | ---: | ---: | ---: | --- | --- |
| `TEMPLATE-SRV2025` Server Core | 2 | 4 GB | 60 GB thin | VMnet10; VMnet8 only for updates | Run alone during installation |
| `TEMPLATE-SRV2025-DE` Desktop Experience | 2 | 6 GB | 80 GB thin | VMnet10; VMnet8 only for updates | Use instead of Core, not alongside it |
| `TEMPLATE-WIN10` | 2 | 4 GB | 64 GB thin | VMnet30; VMnet8 only for updates | Run with one Server template |

Do not power on every template and lab VM together. A practical initial startup is one Server template plus the Windows 10 template; shut down the template before cloning the next role. Leave at least 8 GB for the Windows 11 host and VMware overhead. Storage-heavy or nested labs need a separate expanded profile from the compatibility matrix.

Before changing a template, create `B-before-template-build`. If installation or updates fail, power off the VM and revert to that snapshot. After each clean template reaches the expected state, take `B-server2025-clean` or `B-windows10-clean`. A VMware snapshot is a rollback point, not a backup.

## Create the Server 2025 VM in VMware

1. In Workstation, select **File > New Virtual Machine**, choose **Typical**, and select the Windows Server 2025 Evaluation ISO. If Easy Install does not recognize the media, choose **I will install the operating system later** and attach the ISO under **VM > Settings > CD/DVD**.
2. Set the temporary name `TEMPLATE-SRV2025` and store it under a dedicated path such as `D:\VMs\WindowsServerLab\Templates`.
3. Choose a 2-vCPU processor, 4 GB RAM, a 60 GB thin-provisioned SCSI disk, and one network adapter set to **Custom: VMnet10**. Do not attach VMnet8 until updates are needed.
4. In **VM > Settings > Options > Advanced**, use UEFI firmware. Enable Secure Boot when the selected Windows edition and lab procedure support it. Use a virtual TPM only when Windows or a selected lab requires it; record the choice because it can affect cloning and encryption.
5. Start the VM, select the required Server 2025 edition (Core or Desktop Experience), and complete setup with a local administrator account whose password is stored only in a password manager. Do not put the password in this repository or command history.

## Create the Windows 10 VM

1. Create a second VM from the Windows 10 ISO named `TEMPLATE-WIN10`, stored under the same templates directory.
2. Use 2 vCPUs, 4 GB RAM, a 64 GB thin-provisioned disk, UEFI firmware, and one adapter on **Custom: VMnet30**.
3. Enable Secure Boot when supported by the selected Windows 10 configuration. Add a virtual TPM only if required by the edition or a later lab; do not copy a TPM-backed identity into another clone.
4. Complete setup with a local administrator account and no personal Microsoft account, domain join, tokens, or private certificates. Keep its password outside Git.

## Prepare each clean template

1. From **VM > Install VMware Tools**, install VMware Tools and restart. Verify that the VMware Tools service is running; do not download an untrusted installer.
2. Connect VMnet8 only for approved updates and downloads. Keep the VMnet10/VMnet30 lab NIC as the intended primary NIC. Disconnect VMnet8 when updates finish.
3. Apply Windows updates, restart until no pending restart remains, and confirm the correct time zone. Do not activate with a personal or committed key; follow the evaluation license terms and record the evaluation start date privately.
4. Set a temporary workgroup name and temporary hostname only. Do not join `ad.lab.test`. Remove personal files, browser profiles, downloaded secrets, installers containing credentials, and test accounts other than the local administrator.
5. Confirm the network profile and firewall are appropriate for an isolated workgroup. Do not assign an AD DNS server, static domain address, or production gateway to the template.
6. Shut down cleanly and create `B-server2025-clean` or `B-windows10-clean`.

## Server 2025 Evaluation template

1. Create a new VMware VM from the Windows Server 2025 Evaluation ISO. Use a temporary name such as `TEMPLATE-SRV2025`.
2. Attach one NIC to VMnet10. Connect VMnet8 only while obtaining updates or approved installers.
3. Install the required edition and interface, install VMware Tools from the Workstation menu, apply current updates, and restart until no pending restart remains.
4. Confirm time, storage, device state, firewall profile, and network profile. Leave the machine workgroup-joined and without personal data.
5. Take `B-server2025-clean` after shutdown. Record the ISO version and snapshot date outside the repository.

## Windows 10 client template

1. Create a new VMware VM from the Windows 10 ISO named `TEMPLATE-WIN10`.
2. Attach the NIC to VMnet30 for client testing; use VMnet8 only for controlled updates.
3. Install VMware Tools and updates. Do not join `ad.lab.test`, enroll the device, add personal accounts, or store tokens in the template.
4. Take `B-windows10-clean` after shutdown and record the media version outside Git.

## Naming, networking, and cloning cautions

Templates use temporary names and workgroup identity. Assign final names and static addresses only after cloning, before joining the domain. Confirm adapter placement with `Get-NetIPConfiguration` and follow [segmented networking](VMware-Segmented-Networking.md).

For a repeatable base, use a **full clone** when you need an independent, portable VM or expect to change disks extensively. A **linked clone** saves space and starts quickly but depends on the parent snapshot; use it only while the parent remains unchanged and available. Either clone type must receive a unique final hostname, machine identity, NIC configuration, and local test data before joining the domain.

Sysprep/generalization is optional and must be used only on a disposable, supported workgroup template after reviewing the current Microsoft guidance. Do not generalize or clone domain controllers, certificate authorities, AD FS/RMS servers, machines with unique security identities, machines with a virtual TPM identity, or machines containing lab secrets. **Never clone an already-promoted AD identity.** Create `VN1-SRV1` from a clean template and promote it once; create `VN1-SRV5` through the documented additional-domain-controller procedure, not by cloning `VN1-SRV1`.

## Read-only verification and expected state

Run these checks inside each template before shutdown:

```powershell
winver
Get-ComputerInfo | Select-Object WindowsProductName,WindowsVersion,OsBuildNumber,WindowsRegisteredOwner
Get-NetAdapter
Get-NetIPConfiguration
Get-NetConnectionProfile
Get-NetFirewallProfile
Get-Service -Name VMTools -ErrorAction SilentlyContinue
Get-CimInstance Win32_ComputerSystem | Select-Object Name,Domain,PartOfDomain,HypervisorPresent
```

Expected conditions are the correct Windows version/build, one intended lab NIC, no domain membership, no unexpected default gateway on the isolated NIC, a suitable firewall profile, and a running VMware Tools service where installed. `PartOfDomain` must be `False` for both templates.

After a full or linked clone, rename the VM and guest, assign its intended VMnet and address, verify `Get-NetIPConfiguration`, run preflight with the final VM name, and take a role-specific snapshot before joining `ad.lab.test`. The unique clone steps are deliberately not automated.

## Cleanup

Disconnect VMnet8 after updates, shut down templates when not cloning, and remove only disposable failed clones. Keep the two clean checkpoints and the private media/license notes. Never delete a parent snapshot while linked clones depend on it.
