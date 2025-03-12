# Active Directory'yi Rastgele Kullanıcılar, Bilgisayarlar, Gruplar ve OUs ile Dolduran PowerShell Betiği

param (
    [int]$UserCount = 1000,
    [int]$GroupCount = 50,
    [int]$ComputerCount = 200
)

# Organizasyon Birimlerini (OU) Oluşturma
$OUs = @("HR", "IT", "Sales", "Finance", "Security", "Marketing")
foreach ($ou in $OUs) {
    New-ADOrganizationalUnit -Name $ou -Path "DC=example,DC=com" -ErrorAction SilentlyContinue
}

# Rastgele Kullanıcılar Oluşturma
for ($i = 1; $i -le $UserCount; $i++) {
    $FirstName = (Get-Random -InputObject @("John", "Jane", "Mike", "Emily", "Chris", "Anna"))
    $LastName = (Get-Random -InputObject @("Smith", "Doe", "Johnson", "Brown", "Davis"))
    $Username = "$FirstName.$LastName$i"
    $Password = ConvertTo-SecureString "P@ssword123" -AsPlainText -Force
    $OU = Get-Random -InputObject $OUs

    New-ADUser -Name "$FirstName $LastName" -SamAccountName $Username -UserPrincipalName "$Username@example.com" `
        -Path "OU=$OU,DC=example,DC=com" -AccountPassword $Password -Enabled $true -PasswordNeverExpires $true -ErrorAction SilentlyContinue
}

# Rastgele Bilgisayarlar Oluşturma
for ($i = 1; $i -le $ComputerCount; $i++) {
    $ComputerName = "PC$i"
    $OU = Get-Random -InputObject $OUs
    New-ADComputer -Name $ComputerName -Path "OU=$OU,DC=example,DC=com" -Enabled $true -ErrorAction SilentlyContinue
}

# Rastgele Gruplar Oluşturma
for ($i = 1; $i -le $GroupCount; $i++) {
    $GroupName = "Group$i"
    New-ADGroup -Name $GroupName -GroupScope Global -Path "DC=example,DC=com" -ErrorAction SilentlyContinue
}

# Kullanıcıları Rastgele Gruplara Atama
$Users = Get-ADUser -Filter * | Select-Object -ExpandProperty SamAccountName
$Groups = Get-ADGroup -Filter * | Select-Object -ExpandProperty Name

foreach ($user in $Users) {
    $RandomGroup = Get-Random -InputObject $Groups
    Add-ADGroupMember -Identity $RandomGroup -Members $user -ErrorAction SilentlyContinue
}

Write-Host "Active Directory ortamı başarıyla oluşturuldu!"
