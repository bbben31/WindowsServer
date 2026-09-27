# Instructor content mapping

The source repository includes prerequisite guidance mixed with automation for classroom provisioning. This learner edition keeps the useful operational knowledge while removing actions that are unsafe or unnecessary for one learner.

| Source material | Learner disposition | Safe learner adaptation |
| --- | --- | --- |
| Prerequisite sequence and dependency checks | **Retained and adapted** | Follow [Learner setup](Learner-Setup.md), then use the curriculum index and each lab's prerequisites. |
| Resource-group planning, budgets, cost controls, region/SKU checks | **Retained and adapted** | Use an existing subscription, a dedicated lab resource group, budget alerts, quota/provider checks, and explicit cleanup. |
| Per-lab Azure permissions and operational checklists | **Retained and adapted** | Start with Owner or User Access Administrator only for setup; use least-privilege roles per lab, validate dependencies before deployment, and remove assignments afterward. |
| Conceptual Azure setup and hybrid-service prerequisites | **Retained and adapted** | Azure Arc, File Sync, hybrid identity, VM, monitoring, and related labs remain available with placeholders and current Microsoft documentation. |
| VMware/Windows host and snapshot guidance | **Retained and adapted** | Target Windows 11, VMware Workstation Pro 17, i7-14700KF, 32 GB RAM, 2 TB free storage, and staged multi-VM operation. |
| Bulk student user creation | **Intentionally excluded** | Create only a small number of disposable personal test identities manually when a lab requires them. |
| Password or MFA reset automation | **Intentionally excluded** | Use normal authorized account-recovery procedures outside this repository; never automate credential resets in lab scripts. |
| Guest invitations and invitation URL handling | **Intentionally excluded** | Do not invite external users for this curriculum or commit invitation URLs. |
| Global Administrator grants | **Intentionally excluded** | Use the existing authorized account and documented least-privilege roles; elevate only through the product's approved workflow when unavoidable. |
| Tenant creation or tenant deletion | **Intentionally excluded** | Use the existing Entra tenant and never delete it as part of a lab reset. |
| Instructor scripts that create tenants, students, or credentials | **Removed** | Perform the surrounding documented task manually or use a reviewed, disposable learner-local helper that does not handle secrets. |

No source credentials, invitation links, tenant identifiers, subscription identifiers, student data, or instructor provisioning scripts are included.
