[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$FirstName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$LastName,

    [Parameter(Mandatory)]
    [ValidateSet("Finance", "HR", "Sales", "IT")]
    [string]$Department,

    [Parameter()]
    [PSCredential]$Credential,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Server
)

Import-Module ActiveDirectory

$FirstName = $FirstName.Trim()
$LastName  = $LastName.Trim()

$Username = "$($FirstName.ToLower()).$($LastName.ToLower())"
$UPN      = "$Username@corp.lucalab.test"

$OU    = "OU=$Department,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test"
$Group = "GG-$Department"

$ADParams = @{}

if ($PSBoundParameters.ContainsKey("Credential")) {
    $ADParams["Credential"] = $Credential
}

if ($PSBoundParameters.ContainsKey("Server")) {
    $ADParams["Server"] = $Server
}

Write-Host ""
Write-Host "Preparing employee account"
Write-Host "--------------------------"
Write-Host "Name:       $FirstName $LastName"
Write-Host "Username:   $Username"
Write-Host "UPN:        $UPN"
Write-Host "Department: $Department"
Write-Host "OU:         $OU"
Write-Host "Group:      $Group"
Write-Host ""

try {
    $ExistingUser = Get-ADUser `
        -Filter "SamAccountName -eq '$Username'" `
        @ADParams `
        -ErrorAction Stop
}
catch {
    Write-Error "Unable to query Active Directory: $($_.Exception.Message)"
    return
}

if ($ExistingUser) {
    Write-Error "User '$Username' already exists."
    return
}

try {
    Get-ADOrganizationalUnit `
        -Identity $OU `
        @ADParams `
        -ErrorAction Stop |
    Out-Null
}
catch {
    Write-Error "Target OU does not exist or cannot be accessed: $OU"
    return
}

try {
    Get-ADGroup `
        -Identity $Group `
        @ADParams `
        -ErrorAction Stop |
    Out-Null
}
catch {
    Write-Error "Department group '$Group' does not exist or cannot be accessed."
    return
}

if ($WhatIfPreference) {
    $null = $PSCmdlet.ShouldProcess(
        "$Username in $OU",
        "Create Active Directory user"
    )

    $null = $PSCmdlet.ShouldProcess(
        "$Username -> $Group",
        "Add user to department group"
    )

    return
}

$Password = Read-Host "Enter temporary password" -AsSecureString

if (-not $PSCmdlet.ShouldProcess(
    "$Username in $OU",
    "Create Active Directory user"
)) {
    return
}

Write-Host "Creating AD user..."

try {
    $User = New-ADUser `
        -Name "$FirstName $LastName" `
        -DisplayName "$FirstName $LastName" `
        -GivenName $FirstName `
        -Surname $LastName `
        -SamAccountName $Username `
        -UserPrincipalName $UPN `
        -Department $Department `
        -Path $OU `
        -AccountPassword $Password `
        -Enabled $true `
        -ChangePasswordAtLogon $true `
        -PassThru `
        @ADParams `
        -ErrorAction Stop

    Write-Host "[OK] Created user $Username"
}
catch {
    Write-Error "AD user creation failed: $($_.Exception.Message)"
    return
}

if (-not $PSCmdlet.ShouldProcess(
    "$Username -> $Group",
    "Add user to department group"
)) {
    Write-Warning "User was created, but department group assignment was skipped."
    return
}

Write-Host "Adding user to $Group..."

try {
    Add-ADGroupMember `
        -Identity $Group `
        -Members $User `
        @ADParams `
        -ErrorAction Stop

    Write-Host "[OK] Added $Username to $Group"
}
catch {
    Write-Error "Group assignment failed: $($_.Exception.Message)"
    Write-Warning "The AD account exists, but onboarding is incomplete."
    return
}

Write-Host ""
Write-Host "Verifying account..."

try {
    $VerifiedUser = Get-ADUser `
        -Identity $Username `
        -Properties Department,Enabled `
        @ADParams `
        -ErrorAction Stop

    $Memberships = Get-ADPrincipalGroupMembership `
        -Identity $Username `
        @ADParams `
        -ErrorAction Stop |
        Select-Object -ExpandProperty Name

    Write-Host ""
    Write-Host "Employee onboarding completed."
    Write-Host "Username:   $($VerifiedUser.SamAccountName)"
    Write-Host "Enabled:    $($VerifiedUser.Enabled)"
    Write-Host "Department: $($VerifiedUser.Department)"
    Write-Host "OU:         $($VerifiedUser.DistinguishedName)"
    Write-Host "Groups:     $($Memberships -join ', ')"
}
catch {
    Write-Warning "Account was created but final verification failed: $($_.Exception.Message)"
}
