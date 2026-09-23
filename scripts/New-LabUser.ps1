[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$FirstName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$LastName,

    [Parameter(Mandatory)]
    [ValidateSet("Finance", "HR", "Sales", "IT")]
    [string]$Department
)

Import-Module ActiveDirectory

$FirstName = $FirstName.Trim()
$LastName  = $LastName.Trim()

$Username = "$($FirstName.ToLower()).$($LastName.ToLower())"
$UPN      = "$Username@corp.lucalab.test"
$OU       = "OU=$Department,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test"
$Group    = "GG-$Department"

Write-Host ""
Write-Host "Preparing employee account"
Write-Host "--------------------------"
Write-Host "Name:       $FirstName $LastName"
Write-Host "Username:   $Username"
Write-Host "Department: $Department"
Write-Host "OU:         $OU"
Write-Host "Group:      $Group"
Write-Host ""

if (Get-ADUser -Filter "SamAccountName -eq '$Username'") {
    Write-Error "User '$Username' already exists."
    return
}

try {
    Get-ADOrganizationalUnit -Identity $OU -ErrorAction Stop | Out-Null
}
catch {
    Write-Error "Target OU does not exist: $OU"
    return
}

try {
    Get-ADGroup -Identity $Group -ErrorAction Stop | Out-Null
}
catch {
    Write-Error "Department group does not exist: $Group"
    return
}

$Password = Read-Host "Enter temporary password" -AsSecureString

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
        -ErrorAction Stop

    Write-Host "[OK] Created user $Username"
}
catch {
    Write-Error "AD user creation failed: $($_.Exception.Message)"
    return
}

Write-Host "Adding user to $Group..."

try {
    Add-ADGroupMember `
        -Identity $Group `
        -Members $User `
        -ErrorAction Stop

    Write-Host "[OK] Added $Username to $Group"
}
catch {
    Write-Error "Group assignment failed: $($_.Exception.Message)"
    Write-Warning "The AD user was created, but onboarding is incomplete. Review the account before retrying."
    return
}

Write-Host ""
Write-Host "Employee account created successfully."
Write-Host "Username:   $Username"
Write-Host "UPN:        $UPN"
Write-Host "Department: $Department"
Write-Host "Group:      $Group"
