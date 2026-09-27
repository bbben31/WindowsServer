# Base images and templates

Use clean templates to reduce repeated installation work. This guide does not provide product keys, credentials, or domain-provisioning automation.

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

Do not generalize or clone domain controllers, certificate authorities, AD FS/RMS servers, machines with unique security identities, or machines containing lab secrets. Sysprep can invalidate or remove state that a procedure requires; use it only for a disposable, supported base image and follow the current Microsoft guidance. A snapshot is not a backup.

Before using a template, verify `winver`, `Get-ComputerInfo`, `Get-NetAdapter`, and VMware Tools status. After cloning, rename the VM, assign its intended VMnet and address, run preflight, and snapshot the new role-specific machine.
