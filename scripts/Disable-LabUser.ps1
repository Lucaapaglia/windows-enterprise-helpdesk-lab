[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Username
)

Import-Module ActiveDirectory

$DisabledOU = "OU=Disabled Users,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test"

try {
    $User = Get-ADUser `
        -Identity $Username `
        -Properties Enabled,MemberOf,DistinguishedName `
        -ErrorAction Stop
}
catch {
    Write-Error "User '$Username' was not found."
    return
}

Write-Host ""
Write-Host "Preparing employee offboarding"
Write-Host "------------------------------"
Write-Host "User:    $($User.SamAccountName)"
Write-Host "Enabled: $($User.Enabled)"
Write-Host ""

try {
    Get-ADOrganizationalUnit `
        -Identity $DisabledOU `
        -ErrorAction Stop |
    Out-Null
}
catch {
    Write-Error "Disabled Users OU does not exist."
    return
}

Write-Host "Disabling account..."

try {
    Disable-ADAccount `
        -Identity $User `
        -ErrorAction Stop

    Write-Host "[OK] Account disabled"
}
catch {
    Write-Error "Failed to disable account: $($_.Exception.Message)"
    return
}

Write-Host "Removing non-default group memberships..."

foreach ($GroupDN in $User.MemberOf) {
    try {
        Remove-ADGroupMember `
            -Identity $GroupDN `
            -Members $User `
            -Confirm:$false `
            -ErrorAction Stop

        $GroupName = (Get-ADGroup $GroupDN).Name
        Write-Host "[OK] Removed from $GroupName"
    }
    catch {
        Write-Warning "Could not remove membership from $GroupDN"
    }
}

Write-Host "Moving account to Disabled Users OU..."

try {
    Move-ADObject `
        -Identity $User.DistinguishedName `
        -TargetPath $DisabledOU `
        -ErrorAction Stop

    Write-Host "[OK] Account moved"
}
catch {
    Write-Error "Failed to move account: $($_.Exception.Message)"
    return
}

Set-ADUser `
    -Identity $Username `
    -Description "Offboarded $(Get-Date -Format 'yyyy-MM-dd')"

Write-Host ""
Write-Host "Employee offboarding completed."
Write-Host "User: $Username"
