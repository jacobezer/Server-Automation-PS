#Jacobezer
Import-Module ActiveDirectory
#specify domain name on line 61 (make sure it is correct it does not validate)





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
                Write-Host "Password Rejected" -ForegroundColor Red
            }
        } else {
            Write-Host "Passwords Do Not Match" -ForegroundColor Red
        }
    } while ($passwordPlain -ne $confirmPasswordPlain -or -not (Validate-Password -Password $password))
}

#script
$username = Read-Host -Prompt "Enter Username"
$fullName = Read-Host -Prompt "Enter Full Name"
$description = Read-Host -Prompt "Description"
$password = Get-SecurePassword -prompt "Enter A Secure Password"
$UPname = "$username@domain" #change based on domain name and make sure it is correct

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
