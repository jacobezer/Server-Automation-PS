#Jacobezer
Import-Module ActiveDirectory

#password validation(change values based on custom policies or preference)
#uncomment specialchar if you want a special character required and add "-and $specialchar" to the if statement
function Validate-Password {
    param (
        [SecureString]$Password
    )
    
    $passwordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
    $minlength = 8
    $uppercase = $passwordPlain -match "[A-Z]"
    $lowercase = $passwordPlain -match "[a-z]"
    $hasnumber = $passwordPlain -match "\d"
    #$specialchar = $passwordPlain -match "[^a-zA-Z0-9]"

    if ($passwordPlain.Length -ge $minlength -and $uppercase -and $lowercase -and $hasnumber) {
        return $true
    } else {
        return $false
    }
}

#get and validate password
function Get-SecurePassword {
    param (
        [string]$prompt
    )

    do {
        $password = Read-Host -Prompt "$prompt" -AsSecureString
        $confirmPassword = Read-Host -Prompt "Confirm Password" -AsSecureString

        $passwordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
        $confirmPasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmPassword))

        if ($passwordPlain -eq $confirmPasswordPlain) {
            if (Validate-Password -Password $password) {
                Write-Host "Password Valid" -ForegroundColor Green
                return $password
            } else {
                Write-Host "Password Rejected Not Complex Enough" -ForegroundColor Red
            }
        } else {
            Write-Host "Passwords Do Not Match" -ForegroundColor Red
        }
    } while ($passwordPlain -ne $confirmPasswordPlain -or -not (Validate-Password -Password $password))
}

function Confirm-user {
    param (
        [string]$username,
        [string]$fullName,
        [string]$description,
        [string]$UPname
    )

    Write-Host "Confirm user '$username' with the following information:" -ForegroundColor Yellow
    Write-Host "Username: $username" -ForegroundColor Yellow
    Write-Host "Full Name: $fullName" -ForegroundColor Yellow
    Write-Host "Description: $description" -ForegroundColor Yellow
    Write-Host "UPN/Domain: $UPname" -ForegroundColor Yellow

    $confirmation = Read-Host -Prompt "Do you want to proceed? (Yes/No)"
    
    if ($confirmation -eq 'Yes' -or $confirmation -eq 'Y') {
        return $true
    } else {
        return $false
    }
}

do {
    #script
    #for multiple domains you can uncomment both lines below and comment $UPname to specify domain for each user
    $username = Read-Host -Prompt "Enter Username"
    $fullName = Read-Host -Prompt "Enter Full Name"
    $description = Read-Host -Prompt "Description"
    $password = Get-SecurePassword -prompt "Enter A Secure Password"
    #$domain = Read-Host -Prompt "Enter Domain Name"
    #$UPname = "$username@$Domain"
    $UPname = "$username@insert-domain" #change domain name
    $confirmed = Confirm-user -username $username -fullName $fullName -description $description -UPname $UPname

    if ($confirmed) {
        try {
            #create user (add optional parameters if needed)
            New-ADUser -SamAccountName $username `
                       -Name $fullName `
                       -Description $description `
                       -AccountPassword $password `
                       -UserPrincipalName $UPname `
                       -Enabled $true `
                       -ChangePasswordAtLogon $true #change to false if not needed

            Write-Host "User $username Created" -ForegroundColor Green
        } catch {
            Write-Host "Error Creating User: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "User Cancelled" -ForegroundColor Red
    }
 } while (-not $confirmed)