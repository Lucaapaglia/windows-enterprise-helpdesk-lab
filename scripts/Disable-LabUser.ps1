[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Username,

    [Parameter()]
    [PSCredential]$Credential,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Server
)

Import-Module ActiveDirectory

$DisabledOU = "OU=Disabled Users,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test"

$ADParams = @{}

if ($PSBoundParameters.ContainsKey("Credential")) {
    $ADParams["Credential"] = $Credential
}

if ($PSBoundParameters.ContainsKey("Server")) {
    $ADParams["Server"] = $Server
}

try {
    $User = Get-ADUser `
        -Identity $Username `
        -Properties Enabled,MemberOf,DistinguishedName,Description `
        @ADParams `
        -ErrorAction Stop
}
catch {
    Write-Error "User '$Username' was not found or could not be queried."
    return
}

try {
    $CurrentGroups = Get-ADPrincipalGroupMembership `
        -Identity $Username `
        @ADParams `
        -ErrorAction Stop

    $CurrentGroupNames = $CurrentGroups.Name
}
catch {
    Write-Error "Unable to inspect current group memberships: $($_.Exception.Message)"
    return
}

$ProtectedGroups = @(
    "Domain Admins",
    "Enterprise Admins",
    "Schema Admins",
    "Administrators"
)

$ProtectedMembership = $CurrentGroupNames |
    Where-Object { $_ -in $ProtectedGroups }

if ($ProtectedMembership) {
    Write-Error "Refusing to offboard '$Username'. Protected membership detected: $($ProtectedMembership -join ', ')"
    return
}

try {
    Get-ADOrganizationalUnit `
        -Identity $DisabledOU `
        @ADParams `
        -ErrorAction Stop |
    Out-Null
}
catch {
    Write-Error "Disabled Users OU does not exist or cannot be accessed."
    return
}

Write-Host ""
Write-Host "Preparing employee offboarding"
Write-Host "------------------------------"
Write-Host "User:    $($User.SamAccountName)"
Write-Host "Enabled: $($User.Enabled)"
Write-Host "Current OU:"
Write-Host $User.DistinguishedName
Write-Host ""

if ($User.MemberOf.Count -gt 0) {
    Write-Host "Explicit group memberships to remove:"

    foreach ($GroupDN in $User.MemberOf) {
        try {
            $GroupName = (Get-ADGroup `
                -Identity $GroupDN `
                @ADParams `
                -ErrorAction Stop).Name

            Write-Host " - $GroupName"
        }
        catch {
            Write-Host " - $GroupDN"
        }
    }
}
else {
    Write-Host "No explicit group memberships to remove."
}

Write-Host ""

if ($WhatIfPreference) {
    $null = $PSCmdlet.ShouldProcess(
        $Username,
        "Disable Active Directory account"
    )

    foreach ($GroupDN in $User.MemberOf) {
        $null = $PSCmdlet.ShouldProcess(
            "$Username -> $GroupDN",
            "Remove group membership"
        )
    }

    $null = $PSCmdlet.ShouldProcess(
        $Username,
        "Move account to Disabled Users OU"
    )

    $null = $PSCmdlet.ShouldProcess(
        $Username,
        "Set offboarding description"
    )

    return
}

if ($PSCmdlet.ShouldProcess(
    $Username,
    "Disable Active Directory account"
)) {
    try {
        Disable-ADAccount `
            -Identity $Username `
            @ADParams `
            -ErrorAction Stop

        Write-Host "[OK] Account disabled"
    }
    catch {
        Write-Error "Failed to disable account: $($_.Exception.Message)"
        return
    }
}

foreach ($GroupDN in $User.MemberOf) {

    try {
        $GroupName = (Get-ADGroup `
            -Identity $GroupDN `
            @ADParams `
            -ErrorAction Stop).Name
    }
    catch {
        $GroupName = $GroupDN
    }

    if ($PSCmdlet.ShouldProcess(
        "$Username -> $GroupName",
        "Remove group membership"
    )) {
        try {
            Remove-ADGroupMember `
                -Identity $GroupDN `
                -Members $Username `
                -Confirm:$false `
                @ADParams `
                -ErrorAction Stop

            Write-Host "[OK] Removed from $GroupName"
        }
        catch {
            Write-Warning "Failed to remove $Username from $GroupName"
        }
    }
}

if ($PSCmdlet.ShouldProcess(
    $Username,
    "Move account to Disabled Users OU"
)) {
    try {
        $CurrentUser = Get-ADUser `
            -Identity $Username `
            @ADParams `
            -ErrorAction Stop

        Move-ADObject `
            -Identity $CurrentUser.DistinguishedName `
            -TargetPath $DisabledOU `
            @ADParams `
            -ErrorAction Stop

        Write-Host "[OK] Account moved to Disabled Users"
    }
    catch {
        Write-Error "Failed to move account: $($_.Exception.Message)"
        return
    }
}

$OffboardingDescription = "Offboarded $(Get-Date -Format 'yyyy-MM-dd')"

if ($PSCmdlet.ShouldProcess(
    $Username,
    "Set description to '$OffboardingDescription'"
)) {
    try {
        Set-ADUser `
            -Identity $Username `
            -Description $OffboardingDescription `
            @ADParams `
            -ErrorAction Stop

        Write-Host "[OK] Offboarding description updated"
    }
    catch {
        Write-Warning "Failed to update Description: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "Verifying final state..."

try {
    $FinalUser = Get-ADUser `
        -Identity $Username `
        -Properties Enabled,Description `
        @ADParams `
        -ErrorAction Stop

    $FinalGroups = Get-ADPrincipalGroupMembership `
        -Identity $Username `
        @ADParams `
        -ErrorAction Stop |
        Select-Object -ExpandProperty Name

    Write-Host ""
    Write-Host "Employee offboarding completed."
    Write-Host "Username:    $Username"
    Write-Host "Enabled:     $($FinalUser.Enabled)"
    Write-Host "Description: $($FinalUser.Description)"
    Write-Host "OU:          $($FinalUser.DistinguishedName)"
    Write-Host "Groups:      $($FinalGroups -join ', ')"
}
catch {
    Write-Warning "Changes completed, but final verification failed: $($_.Exception.Message)"
}
