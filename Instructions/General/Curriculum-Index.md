# Curriculum index and dependency map

Complete `Instructions/General/Learner-Setup.md` first. Within each section, practices establish skills and the labs combine them. A lab may require extra VMs, storage disks, certificates, or Azure resources; use its prerequisite/topology notes and do not assume the foundation topology is sufficient.

## Manifest and preflight

Use the machine-readable [curriculum manifest](../../metadata/curriculum-manifest.json) to filter all 89 practices and 50 labs by Azure requirement, topology, risk, cost, permissions, dependencies, and cleanup. Run the read-only [learner preflight checker](../../tools/Preflight-LearnerLab.ps1) before a lab, then resolve warnings, snapshot the relevant VMs, perform the lab, verify the result, and clean up.

Example:

```powershell
.\tools\Preflight-LearnerLab.ps1 `
  -ServerIsoPath '<PATH_TO_WINDOWS_SERVER_2025_EVALUATION_ISO>' `
  -ClientIsoPath '<PATH_TO_WINDOWS_11_ISO>' `
  -VmName VN1-SRV1,VN1-SRV4,CL1 `
  -ExpectedDnsServer 10.10.10.10 `
  -ExpectedSubnet 10.10.10.0/24 `
  -AzureSubscriptionId '<AZURE_SUBSCRIPTION_ID>' `
  -AzureRegion 'UK South' `
  -AzureResourceGroup '<AZURE_RESOURCE_GROUP>' `
  -ReportPath '.\preflight-report.json'
```

The checker is read-only and never logs in, creates, deletes, or changes resources. It returns exit code `0` when no errors are found, and `1` for errors (or warnings when `-FailOnWarning` is used). Missing optional tools are warnings or skipped checks.

## Staged workflow

Follow the [staged lab roadmap](Staged-Lab-Roadmap.md) from host/network foundation through optional topics. Use the [base-image guide](Base-Images-and-Templates.md) before cloning guests and the [compatibility matrix](Compatibility-Matrix.md) to choose a low, standard, or expanded VM profile.

Start with the [Milestone A VMware network runbook](VMware-Segmented-Networking.md) before creating the first guest.

Then complete the [Milestone B base-image runbook](Base-Images-and-Templates.md) before cloning role-specific servers or clients.

Next follow the [Milestone C AD DS/DNS foundation runbook](AD-DNS-Foundation.md) before joining member servers or clients.

Continue in order with [Milestone D member servers and clients](Member-Servers-and-Clients.md), then [Milestone E core Windows administration](Core-Windows-Administration.md). The runbooks link to the source-aligned practices and labs without replacing them.

For advanced topics, use the [Milestone F advanced infrastructure guide](Advanced-Infrastructure.md) before selecting storage, Hyper-V, clustering, RDS, WSUS, deployment, Linux/container, or Azure File Sync material.

For cloud and hybrid topics, continue with the [Milestone G Azure and hybrid services guide](Azure-Hybrid-Services.md); it replaces instructor-selected identifiers with placeholders and keeps Azure provisioning cost-gated.

Finish with the [Milestone H optional and cost-gated guide](Optional-Cost-Gated-Topics.md), which provides the go/no-go workflow and final curriculum completion checklist.

## General

- [Adding-a-registry-value](../General/Adding-a-registry-value.md)
- [Adding-servers-to-Server-Manager](../General/Adding-servers-to-Server-Manager.md)
- [Adding-servers-to-Windows-Admin-Center](../General/Adding-servers-to-Windows-Admin-Center.md)
- [Changing-TCP-IP-settings-on-Windows-11](../General/Changing-TCP-IP-settings-on-Windows-11.md)
- [Changing-TCP-IP-settings-on-Windows-Server](../General/Changing-TCP-IP-settings-on-Windows-Server.md)
- [Configuring-Active-Directory-Domain-Services-as-an-additional-domain-controller](../General/Configuring-Active-Directory-Domain-Services-as-an-additional-domain-controller.md)
- [Configuring-Active-Directory-Domain-Services-as-a-new-forest](../General/Configuring-Active-Directory-Domain-Services-as-a-new-forest.md)
- [Configuring-forwarders](../General/Configuring-forwarders.md)
- [Configuring-the-network-profile-type](../General/Configuring-the-network-profile-type.md)
- [Connecting-the-DNS-console-to-a-server](../General/Connecting-the-DNS-console-to-a-server.md)
- [Creating-a-delegated-managed-service-account](../General/Creating-a-delegated-managed-service-account.md)
- [Demoting-a-domain-controller](../General/Demoting-a-domain-controller.md)
- [Enabling-or-disabling-network-adapters](../General/Enabling-or-disabling-network-adapters.md)
- [Enabling-the-Database-32k-pages-option](../General/Enabling-the-Database-32k-pages-option.md)
- [Generating-the-KDS-root-key](../General/Generating-the-KDS-root-key.md)
- [Installing-extensions-in-Windows-Admin-Center](../General/Installing-extensions-in-Windows-Admin-Center.md)
- [Installing-optional-features-on-Windows-11](../General/Installing-optional-features-on-Windows-11.md)
- [Installing-roles-and-features-on-Windows-Server](../General/Installing-roles-and-features-on-Windows-Server.md)
- [Joining-Windows-11-to-a-local-Active-Directory-domain](../General/Joining-Windows-11-to-a-local-Active-Directory-domain.md)
- [Learner-Setup](../General/Learner-Setup.md)
- [Managing-resource-records](../General/Managing-resource-records.md)
- [Managing-services](../General/Managing-services.md)
- [Managing-shares](../General/Managing-shares.md)
- [Managing-the-DNS-client-cache](../General/Managing-the-DNS-client-cache.md)
- [Migrating-a-service-account-to-a-dMSA](../General/Migrating-a-service-account-to-a-dMSA.md)
- [Raising-the-domain-functional-level](../General/Raising-the-domain-functional-level.md)
- [Raising-the-forest-functional-level](../General/Raising-the-forest-functional-level.md)
- [Removing-an-orphaned-domain-controller-from-Active-Directory](../General/Removing-an-orphaned-domain-controller-from-Active-Directory.md)
- [Removing-roles-and-features-on-Windows-Server](../General/Removing-roles-and-features-on-Windows-Server.md)
- [Restarting-a-server](../General/Restarting-a-server.md)
- [Running-Best-Practices-Analyzer-and-managing-scan-results](../General/Running-Best-Practices-Analyzer-and-managing-scan-results.md)
- [Transferring-flexible-single-master-operation-roles](../General/Transferring-flexible-single-master-operation-roles.md)
- [Verifying-a-32k-page-capable-database](../General/Verifying-a-32k-page-capable-database.md)

## Practices

- [Add-a-DHCP-scope](../Practices/Add-a-DHCP-scope.md)
- [Add-DHCP-reservations](../Practices/Add-DHCP-reservations.md)
- [Add-server-to-Azure-Arc](../Practices/Add-server-to-Azure-Arc.md)
- [Analyze-best-practices](../Practices/Analyze-best-practices.md)
- [Authorize-DHCP-server-and-activate-scope](../Practices/Authorize-DHCP-server-and-activate-scope.md)
- [Configure-access-denied-assistance](../Practices/Configure-access-denied-assistance.md)
- [Configure-a-classification-schedule](../Practices/Configure-a-classification-schedule.md)
- [Configure-a-fine-grained-password-policy](../Practices/Configure-a-fine-grained-password-policy.md)
- [Configure-aging-and-scavenging](../Practices/Configure-aging-and-scavenging.md)
- [Configure-a-guest-operating-system](../Practices/Configure-a-guest-operating-system.md)
- [Configure-basic-Hyper-V-settings](../Practices/Configure-basic-Hyper-V-settings.md)
- [Configure-DHCP-server-options](../Practices/Configure-DHCP-server-options.md)
- [Configure-e-mail-notifications-in-FSRM](../Practices/Configure-e-mail-notifications-in-FSRM.md)
- [Configure-forwarders](../Practices/Configure-forwarders.md)
- [Configure-Kerberos-contrained-delegation](../Practices/Configure-Kerberos-contrained-delegation.md)
- [Configure-nested-virtualization](../Practices/Configure-nested-virtualization.md)
- [Configure-password-and-account-lockout-policies](../Practices/Configure-password-and-account-lockout-policies.md)
- [Configure-storage-report-options](../Practices/Configure-storage-report-options.md)
- [Configure-Windows-Admin-Center](../Practices/Configure-Windows-Admin-Center.md)
- [Configure-Windows-Server-Update-Services-synchronization](../Practices/Configure-Windows-Server-Update-Services-synchronization.md)
- [Create-a-custom-Microsoft-Management-Console](../Practices/Create-a-custom-Microsoft-Management-Console.md)
- [Create-a-Log-Analytics-Workspace](../Practices/Create-a-Log-Analytics-Workspace.md)
- [Create-an-Automation-account](../Practices/Create-an-Automation-account.md)
- [Create-an-Azure-Subscription](../Practices/Create-an-Azure-Subscription.md)
- [Create-and-install-a-virtual-machine](../Practices/Create-and-install-a-virtual-machine.md)
- [Create-an-Entra-ID-tenant](../Practices/Create-an-Entra-ID-tenant.md)
- [Create-an-exportable-web-server-certificate-template](../Practices/Create-an-exportable-web-server-certificate-template.md)
- [Create-a-security-baseline-using-OSConfig](../Practices/Create-a-security-baseline-using-OSConfig.md)
- [Create-Windows-Server-Update-Services-automatic-approval-rules](../Practices/Create-Windows-Server-Update-Services-automatic-approval-rules.md)
- [Create-Windows-Server-Update-Services-computer-groups](../Practices/Create-Windows-Server-Update-Services-computer-groups.md)
- [Delegate-password-reset-permissions](../Practices/Delegate-password-reset-permissions.md)
- [Display-license-information](../Practices/Display-license-information.md)
- [Enable-the-Active-Directory-Recycle-Bin](../Practices/Enable-the-Active-Directory-Recycle-Bin.md)
- [Explore-intra-site-replication](../Practices/Explore-intra-site-replication.md)
- [Explore-PowerShell-return-types](../Practices/Explore-PowerShell-return-types.md)
- [Explore-Server-Manager](../Practices/Explore-Server-Manager.md)
- [Explore-Windows-Terminal](../Practices/Explore-Windows-Terminal.md)
- [Explore-winget](../Practices/Explore-winget.md)
- [Find-PowerShell-commands-and-manage-modules](../Practices/Find-PowerShell-commands-and-manage-modules.md)
- [Getting-started-with-System-Insights](../Practices/Getting-started-with-System-Insights.md)
- [Harden-SMB](../Practices/Harden-SMB.md)
- [Install-app-compatibility-feature-on-demand](../Practices/Install-app-compatibility-feature-on-demand.md)
- [Install-File-Server-Resource-Manager](../Practices/Install-File-Server-Resource-Manager.md)
- [Install-group-policy-management](../Practices/Install-group-policy-management.md)
- [Install-prerequisites-for-file-serving](../Practices/Install-prerequisites-for-file-serving.md)
- [Install-Remote-Server-Administration-Tools](../Practices/Install-Remote-Server-Administration-Tools.md)
- [Install-roles-using-Server-Manager](../Practices/Install-roles-using-Server-Manager.md)
- [Install-roles-using-Windows-Admin-Center](../Practices/Install-roles-using-Windows-Admin-Center.md)
- [Install-the-DHCP-server-role](../Practices/Install-the-DHCP-server-role.md)
- [Install-the-DNS-server-role](../Practices/Install-the-DNS-server-role.md)
- [Install-the-Hyper-V-management-tools](../Practices/Install-the-Hyper-V-management-tools.md)
- [Install-the-Hyper-V-role](../Practices/Install-the-Hyper-V-role.md)
- [Install-the-Microsoft-Deployment-Toolkit](../Practices/Install-the-Microsoft-Deployment-Toolkit.md)
- [Install-the-Microsoft-Office-Filter-Pack](../Practices/Install-the-Microsoft-Office-Filter-Pack.md)
- [Install-the-Remote-Server-Administration-DHCP-Server-Tools](../Practices/Install-the-Remote-Server-Administration-DHCP-Server-Tools.md)
- [Install-the-Remote-Server-Administration-DNS-Server-Tools](../Practices/Install-the-Remote-Server-Administration-DNS-Server-Tools.md)
- [Install-the-Remote-Server-Administration-Windows-Update-Services-Tools](../Practices/Install-the-Remote-Server-Administration-Windows-Update-Services-Tools.md)
- [Install-Windows-Admin-Center-using-a-script](../Practices/Install-Windows-Admin-Center-using-a-script.md)
- [Install-Windows-Server-manually](../Practices/Install-Windows-Server-manually.md)
- [Install-Windows-Server-Update-Services-role](../Practices/Install-Windows-Server-Update-Services-role.md)
- [Install-Windows-Server-with-Desktop-Experience-manually](../Practices/Install-Windows-Server-with-Desktop-Experience-manually.md)
- [Install-Windows-Terminal](../Practices/Install-Windows-Terminal.md)
- [Manage-dynamic-disks](../Practices/Manage-dynamic-disks.md)
- [Manage-features-using-PowerShell](../Practices/Manage-features-using-PowerShell.md)
- [Manage-local-groups](../Practices/Manage-local-groups.md)
- [Manage-local-users](../Practices/Manage-local-users.md)
- [Manage-PowerShell-output](../Practices/Manage-PowerShell-output.md)
- [Manage-services-using-PowerShell](../Practices/Manage-services-using-PowerShell.md)
- [Manage-services-using-Windows-Admin-Center](../Practices/Manage-services-using-Windows-Admin-Center.md)
- [Manage-the-guest-operating-system-from-the-host](../Practices/Manage-the-guest-operating-system-from-the-host.md)
- [Manage-the-status-of-a-virtual-machine](../Practices/Manage-the-status-of-a-virtual-machine.md)
- [NIC-teaming](../Practices/NIC-teaming.md)
- [PowerShell-remoting](../Practices/PowerShell-remoting.md)
- [Query-DNS](../Practices/Query-DNS.md)
- [Register-Windows-Admin-Center-with-Azure](../Practices/Register-Windows-Admin-Center-with-Azure.md)
- [Registry-editing-using-PowerShell](../Practices/Registry-editing-using-PowerShell.md)
- [Request-and-export-certificates-for-the-connection-broker-and-RD-web](../Practices/Request-and-export-certificates-for-the-connection-broker-and-RD-web.md)
- [Restrict-the-Administrators-group-for-clients](../Practices/Restrict-the-Administrators-group-for-clients.md)
- [Synchronize-Windows-Server-Update-Services-languages-products-and-categories](../Practices/Synchronize-Windows-Server-Update-Services-languages-products-and-categories.md)
- [Update-root-hints](../Practices/Update-root-hints.md)
- [Update-the-active-directory-schema](../Practices/Update-the-active-directory-schema.md)
- [Use-a-group-managed-service-account](../Practices/Use-a-group-managed-service-account.md)
- [Verify-DHCP-functionality](../Practices/Verify-DHCP-functionality.md)
- [Verify-the-sysvol-replication-mode](../Practices/Verify-the-sysvol-replication-mode.md)
- [View-events-using-PowerShell](../Practices/View-events-using-PowerShell.md)
- [View-events-using-Windows-Admin-Center](../Practices/View-events-using-Windows-Admin-Center.md)
- [Work-without-and-with-Enhanced-Session-Mode](../Practices/Work-without-and-with-Enhanced-Session-Mode.md)
- [Work-with-PowerShell-arrays](../Practices/Work-with-PowerShell-arrays.md)
- [Work-with-PowerShell-variables](../Practices/Work-with-PowerShell-variables.md)

## Labs

- [Active-Directory-Rights-Management-Service](../Labs/Active-Directory-Rights-Management-Service.md)
- [Audit-file-server-events](../Labs/Audit-file-server-events.md)
- [BranchCache](../Labs/BranchCache.md)
- [Configure-external-access-to-Remote-Desktop-Services](../Labs/Configure-external-access-to-Remote-Desktop-Services.md)
- [Configure-high-availability-for-Remote-Desktop-Services](../Labs/Configure-high-availability-for-Remote-Desktop-Services.md)
- [Configuring-and-managing-Storage-Spaces-Direct-and-hyper-converged-virtualization](../Labs/Configuring-and-managing-Storage-Spaces-Direct-and-hyper-converged-virtualization.md)
- [Data-Deduplication](../Labs/Data-Deduplication.md)
- [Delegated-managed-service-accounts](../Labs/Delegated-managed-service-accounts.md)
- [Deploying-a-hybrid-cloud-model](../Labs/Deploying-a-hybrid-cloud-model.md)
- [Deploying-and-managing-read-only-domain-controllers](../Labs/Deploying-and-managing-read-only-domain-controllers.md)
- [Deploying-domain-controllers](../Labs/Deploying-domain-controllers.md)
- [Deploy-Remote-Desktop-Services](../Labs/Deploy-Remote-Desktop-Services.md)
- [Distributed-File-System-and-Azure-File-Sync](../Labs/Distributed-File-System-and-Azure-File-Sync.md)
- [Dynamic-Access-Control](../Labs/Dynamic-Access-Control.md)
- [Explore-Windows-Admin-Center](../Labs/Explore-Windows-Admin-Center.md)
- [File-server-resource-management](../Labs/File-server-resource-management.md)
- [Finalizing-Active-Directory-upgrade](../Labs/Finalizing-Active-Directory-upgrade.md)
- [FSLogix](../Labs/FSLogix.md)
- [Group-Policies-Management](../Labs/Group-Policies-Management.md)
- [Implementing-Active-Directory-Federation-Services](../Labs/Implementing-Active-Directory-Federation-Services.md)
- [Implementing-and-managing-iSCSI-and-multipath-io](../Labs/Implementing-and-managing-iSCSI-and-multipath-io.md)
- [Implementing-and-managing-Storage-Spaces-and-Storage-Tiering](../Labs/Implementing-and-managing-Storage-Spaces-and-Storage-Tiering.md)
- [Implementing-DHCP-fault-tolerance](../Labs/Implementing-DHCP-fault-tolerance.md)
- [Implementing-DNS-Security](../Labs/Implementing-DNS-Security.md)
- [Implementing-IP-address-management](../Labs/Implementing-IP-address-management.md)
- [Installing-and-configuring-a-fail-over-cluster](../Labs/Installing-and-configuring-a-fail-over-cluster.md)
- [Manage-domain-users-groups-and-computers](../Labs/Manage-domain-users-groups-and-computers.md)
- [Manage-file-sharing](../Labs/Manage-file-sharing.md)
- [Manage-local-storage](../Labs/Manage-local-storage.md)
- [Manage-servers-remotely-using-Microsoft-Management-Console](../Labs/Manage-servers-remotely-using-Microsoft-Management-Console.md)
- [Managing-DNS](../Labs/Managing-DNS.md)
- [Managing-hybrid-servers-using-Azure-Arc](../Labs/Managing-hybrid-servers-using-Azure-Arc.md)
- [Managing-Hyper-V](../Labs/Managing-Hyper-V.md)
- [Managing-local-administrator-passwords](../Labs/Managing-local-administrator-passwords.md)
- [Managing-sites-and-replication](../Labs/Managing-sites-and-replication.md)
- [Managing-Windows-Server-Update-Services](../Labs/Managing-Windows-Server-Update-Services.md)
- [Microsoft-Deployment-Toolkit](../Labs/Microsoft-Deployment-Toolkit.md)
- [Migrate-Active-Directory](../Labs/Migrate-Active-Directory.md)
- [Monitor-Performance](../Labs/Monitor-Performance.md)
- [Multi-domain-environments](../Labs/Multi-domain-environments.md)
- [Post-installation-configuration](../Labs/Post-installation-configuration.md)
- [Providing-the-Remote-Desktop-Web-Client](../Labs/Providing-the-Remote-Desktop-Web-Client.md)
- [Secure-Shell](../Labs/Secure-Shell.md)
- [Storage-migration](../Labs/Storage-migration.md)
- [Storage-QoS](../Labs/Storage-QoS.md)
- [Storage-Replica-and-stretched-cluster](../Labs/Storage-Replica-and-stretched-cluster.md)
- [Windows-Admin-Center](../Labs/Windows-Admin-Center.md)
- [Windows-containers](../Labs/Windows-containers.md)
- [Windows-Deployment-Services](../Labs/Windows-Deployment-Services.md)
- [Windows-Subsystem-for-Linux](../Labs/Windows-Subsystem-for-Linux.md)

## Suggested progression

1. General setup, Windows installation, networking, local users, Server Manager, and PowerShell practices.
2. AD DS, DNS, DHCP, Group Policy, file services, storage, and Windows Admin Center practices.
3. Core labs: post-installation configuration, domain controllers, domain users, DNS, file sharing, local storage, management, and performance.
4. Advanced local labs: clustering, RDS, AD FS/RMS, Storage Replica/S2D, deployment services, containers, and migration.
5. Azure and hybrid labs: Azure Arc, Azure File Sync, hybrid cloud, and any service-specific exercises.

The links below are generated from the repository tree so every imported practice and lab remains discoverable.
