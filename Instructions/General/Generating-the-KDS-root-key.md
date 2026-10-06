# Generating the KDS root key

1. Open a terminal.
1. In Terminal, verify if the KDS root key exists.

    ````powershell
    Get-KdsRootKey
    ````

1. If there is no KDS root key, generate it.

    ````powershell
    Add-KdsRootKey -EffectiveImmediately
    ````

    Wait at least 10 hours for safe replication before using the key in a multi-DC forest. Only in an isolated single-DC test forest may you instead use `Add-KdsRootKey -EffectiveTime (Get-Date).AddHours(-10)` to avoid that wait. Do not create a second key or backdate a key in the multi-controller enterprise lab merely to bypass the replication delay.

1. Verify the KDS root key again.

    ````powershell
    Get-KdsRootKey
    ````

## References

[Create a Key Distribution Service (KDS) root key](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-managed-service-accounts/group-managed-service-accounts/create-the-key-distribution-services-kds-root-key)
