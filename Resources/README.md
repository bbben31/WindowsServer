# Learner lab resources

Copy this `Resources` directory into each applicable guest as `C:\WindowsServerLab\Resources`. Keep the repository copy as the source of truth.

Only reviewed, self-contained learner helpers belong here. Each helper must be idempotent where practical, accept secrets interactively rather than embedding them, stop on errors, and support `-WhatIf` when it changes system state.

If a curriculum document names a helper that is not present here, treat the document as invalid and complete its linked prerequisite instead. Do not download a similarly named script from an unverified source.

Run `Solutions\Initialize-SampleDocuments.ps1` inside VN1-SRV10 to create disposable classification text, old/recent expiration files, an offline-guide folder, a 64 MB IT quota fixture and 120 MB `Travel Packages`. The IT dataset exceeds 50 MB but fits within 75 MB; Travel Packages intentionally exceeds 100 MB. The helper preserves existing text/IT files; use a clean disposable test tree when resetting. Prepare the actual XLSX/PPTX files manually in licensed desktop Office on CL2 using [Prepare valid Office fixtures](../Instructions/Practices/Install-prerequisites-for-file-serving.md#prepare-valid-office-fixtures); the helper does not install Office or manufacture fake Office documents.

Large or third-party assets are intentionally not committed:

| Asset | Learner action |
| --- | --- |
| Windows Server evaluation and Languages/Optional Features ISOs | Download from Microsoft, record the SHA-256 privately, and store under `C:\WindowsServerLab\ISOs` or the path named by the procedure. |
| `TinyCorePure64.vhdx` | Obtain Tiny Core Linux from its official project, verify the download, create a Generation 1-compatible VHDX, and place it in `C:\WindowsServerLab\Resources` only for the Hyper-V and cluster labs. |
| `nssm.exe` | Obtain it from the official NSSM project, verify its published SHA-256 value, and place the reviewed binary in `C:\WindowsServerLab\Resources` only for the delegated-service-account lab. |
| Product installers such as Windows Admin Center, FSLogix, ADK, and MDT | Use the current official vendor link in the relevant procedure; verify publisher signature and hash before execution. |
