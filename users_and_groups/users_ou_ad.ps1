# PowerShell script that creates and manages Active Directory user accounts, including setting passwords and group memberships

# Define variables for domain authentication
$domain = "contoso.com"
$username = "domain\administrator"
$password = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

# Import ActiveDirectory module using domain credentials
try {
    Import-Module ActiveDirectory -Credential $credential -ErrorAction Stop
} catch {
    Write-Error "Unable to import ActiveDirectory module: $_"
    exit 1
}

# Define variables for user properties
$firstname = "John"
$lastname = "Doe"
$samaccountname = "jdoe"
$password = "P@ssword123!"
$email = "jdoe@contoso.com"
$group = "Sales"
$city = "Seattle"
$state = "Washington"
$country = "USA"
$title = "Sales Manager"
$department = "Sales"
$company = "Contoso"
$ou = "OU=NewUsers,DC=contoso,DC=com"

# Check if the user account already exists
try {
    $user = Get-ADUser -Filter {SamAccountName -eq $samaccountname} -Credential $credential -ErrorAction Stop
    Write-Host "User account already exists"
    
    # Check if the user is already in the target OU
    if ($user.DistinguishedName -notlike "*$ou") {
        # Move the user to the target OU
        Move-ADObject -Identity $user.DistinguishedName -TargetPath $ou -Credential $credential
        Write-Host "User account moved to $ou"
    }
} catch {
    # Create the user account in the target OU
    try {
        $newuser = New-ADUser -Name "$firstname $lastname" -GivenName $firstname -Surname $lastname -SamAccountName $samaccountname -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -Enabled $true -EmailAddress $email -City $city -State $state -Country $country -Title $title -Department $department -Company $company -Path $ou -Credential $credential -ErrorAction Stop

        # Add the user to the specified group
        Add-ADGroupMember -Identity $group -Members $samaccountname -Credential $credential

        # Output the details of the new user account
        Write-Host "User account created successfully:"
        Get-ADUser -Filter {SamAccountName -eq $samaccountname} -Properties * -Credential $credential
    } catch {
        Write-Error "Unable to create user account: $_"
        exit 1
    }
}