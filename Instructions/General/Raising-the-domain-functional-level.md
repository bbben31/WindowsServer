# Raising the domain functional level

Before raising to Windows Server 2025, verify every DC in the target domain runs Server 2025, replication/DNS are healthy, required older DCs are retired, and supported backups/recovery are available. Use the selected exercise's disposable compatibility lineage rather than the only foundation forest.

## Desktop experience

1. Open **Active Directory Administrative Center**.
1. In Active Directory Administrative Center, in the context-menu of the domain, click **Raise the domain functional level...**

1. In Raise domain function level, click **OK**.

1. In the message box This change affects the entire domain. After you raise the domain functional level, it is possible that you may not be able to reverse it., click **OK**.

1. In the message box Raise Domain Functional Level, click **OK**.

## PowerShell

1. Open a terminal.
1. Set the domain mode to Windows Server 2025.

    ````powershell
    # Between the quotes, insert the FQDN name of the domain
    $identity = ''
    Set-ADDomainMode -Identity $identity -DomainMode Windows2025Domain
    ````

    If you receive **A referral was returned from the server**, verify the target domain, DNS, credentials, and the appropriate DC before retrying. Connect to a verified DC in the target domain explicitly instead of blindly restarting it:

    ````powershell
    $server = '' # FQDN of the verified DC in the target domain
    Get-ADDomain -Identity $identity -Server $server
    Set-ADDomainMode -Identity $identity -Server $server -DomainMode Windows2025Domain
    ````

1. At the prompt **Performing the operation "Set" on target ...**, enter **y**.

