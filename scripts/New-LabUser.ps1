param(
    [Parameter(Mandatory=$true)]
    [string]$FirstName,

    [Parameter(Mandatory=$true)]
    [string]$LastName,

    [Parameter(Mandatory=$true)]
    [string]$Department
)

$Username = "$($FirstName.ToLower()).$($LastName.ToLower())"

$OU = "OU=$Department,OU=Users,OU=Copenhagen,DC=corp,DC=lucalab,DC=test"

$Password = Read-Host "Enter temporary password" -AsSecureString

New-ADUser `
    -Name "$FirstName $LastName" `
    -GivenName $FirstName `
    -Surname $LastName `
    -SamAccountName $Username `
    -UserPrincipalName "$Username@corp.lucalab.test" `
    -Path $OU `
    -AccountPassword $Password `
    -Enabled $true `
    -ChangePasswordAtLogon $true

Write-Host "Created user: $Username"