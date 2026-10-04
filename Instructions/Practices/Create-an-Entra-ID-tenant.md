# Practice: Create an Entra ID tenant

<!-- BEGIN GENERATED COMPLETION CONTRACT -->
## Self-learner completion contract

Generated from `metadata/curriculum-source.json`; edit that entry and regenerate rather than editing this section.

**Prerequisites (in order):** Instructions/General/Learner-Setup.md. Use an existing authorized tenant/subscription as a conceptual reference; do not create resources.

**Machines and network profile:** No dedicated guest; use the host/browser or existing tenant context specified by this reference. Host-browser Internet access for the Azure portal and Microsoft sign-in; no guest-network changes or tenant/subscription mutation.

**Permissions:** Authorized read-only access to the existing subscription or tenant through the host browser; no local elevation or resource creation.

**Outbound access:** Use the host browser Internet connection to inspect the existing Azure subscription or Entra tenant through the Azure portal and Microsoft sign-in. No guest VM, temporary guest NIC or VMnet8 change is required. Endpoints: https://portal.azure.com (Azure portal); https://login.microsoftonline.com (Microsoft organizational sign-in); https://login.live.com (Microsoft account sign-in, when applicable).

**Risk, cost and optional status:** low; conceptual; optional=false. No deployment or new resource charges. Core learner profile unless the procedure declares an additional enterprise role or compatibility gate.

**Success verification:** Record the existing tenant context privately; no tenant, user or directory role is created.

**Rollback and cleanup:** Sign out and close the portal browser; retain only private conceptual notes. No deployment, directory mutation or guest-network change was made.

<!-- END GENERATED COMPLETION CONTRACT -->


## Required VMs

None; use the existing reference context.


## Task

This source activity is retained as a conceptual reference only. Use the existing Microsoft Entra tenant; never create a tenant, Global Administrator, user, or password for this learner edition.

## Instructions

1. Open the portal and switch to the existing tenant only if needed.
1. Verify the current signed-in identity and least-privilege role for the selected lab.
1. Use `<AZURE_TENANT_ID>` as a placeholder in notes. Do not copy tenant identifiers, credentials, tokens, or invitation URLs into Git.
1. If a lab needs an identity, use an existing approved identity or the product's documented, reversible flow with the minimum scope.
1. Confirm that no tenant, user, password, or directory-role assignment was created by this conceptual practice.
