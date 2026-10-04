# Curriculum metadata

`curriculum-source.json` is the reviewed per-path source for all 89 practices and 50 labs. `curriculum-manifest.json` and each marked self-learner completion contract are generated artifacts.

Edit the source entry deliberately: prerequisites are ordered requirements, not a list of every Markdown link. Preserve procedural content outside the contract markers. After changing topology, also update Required VMs and the affected tasks; validation rejects disagreements.

Each entry declares:

- `dependencies` and `prerequisiteState`: ordered prerequisite paths and the actual role/media/data state needed before execution.
- `vmTopology`: guest hostname, planned VMware display name and aliases, or inner `hyperVName`; `layer` distinguishes outer VMware from inner Hyper-V. `phase` is `existing`, `existing-inner`, `created`, or `conditional`. Created machines appear in topology but are not expected at preflight. Conditional first DCs follow the documented retirement lineage.
- `alternativeVmGroups`: explicit one-of requirements, used only when the procedure permits either active DC. `referencedVms` requires a reason for every example-only/excluded name; it must never hide a real task target.
- `networkProfile` and `networks`: the selected core, enterprise, or alternate-forest profile and isolated segment mapping. VMware custom VMnet numbers are host-specific and must be recorded before execution.
- `permissions`: authorized guest/AD/service/cloud rights for the selected steps, with temporary elevation scoped to those steps.
- `outbound`: an explicit requirement, mode, method and endpoint purpose. Mode is `none`, `guest-vmnet8`, or `host-browser`. Guest downloads use temporary VMnet8 with AD DNS preserved and disconnect cleanup. Host-browser-only conceptual access uses the host Internet connection and sign-out/browser cleanup without guest-network changes.
- `azure`: required services/scope/region guidance; optional integration is selected through a separate Azure-required practice.
- `riskCost`: `risk` is `low`, `medium`, or `high`; `costClass` is `local-only`, `conceptual`, `optional-azure`, or `cost-gated`. Cost text supplies actionable guidance. Boolean optional/Azure/outbound flags are JSON booleans.
- `verification`, `cleanup`, and `compatibility`: observable results, rollback/removal boundaries, and support/optional limitations.

Run from the repository root in both Windows PowerShell 5.1 and current PowerShell:

```powershell
.\tools\Update-CurriculumManifest.ps1
.\tools\Validate-Curriculum.ps1
.\tools\Test-CurriculumRegression.ps1
git diff --exit-code -- metadata/curriculum-manifest.json Instructions
```

Commit intended generated changes before using the final drift command as a clean-tree assertion. `Update-CurriculumManifest.ps1 -Check` and the validator reject stale contracts/manifest without writing them. Regeneration uses canonical formatting and UTF-8 without BOM to produce identical bytes in both engines. CI runs the complete checks under both shells.

Preflight requires an explicit `-CurriculumPath` selecting exactly one entry. Missing or invalid selection returns an error and exit code 1 without prompting. The preflight is read-only: no authentication, AD resource query, Azure login or resource mutation. It reports declared requirements, user-supplied prerequisite/VM evidence, optional host/DNS/ICMP probes, and skipped placeholders. These checks do not prove installed roles, service health, cloud permissions or prices.
