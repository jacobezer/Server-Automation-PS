#jacobezer
#for active directory users refer to createADuser.ps1 

#password validation
function Validate-Password {
    param (
        [SecureString]$Password
    )
    
    $passwordplain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
    $minlength = 8
    $uppercase = $passwordPlain -match "[A-Z]"
    $lowercase = $passwordPlain -match "[a-z]"
    $hasnumber = $passwordPlain -match "\d"

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
                Write-Host "Password Is Not Complex Enough" -ForegroundColor Red
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

try {
    $user = New-LocalUser -Name $username `
                          -FullName $fullName `
                          -Description $description `
                          -Password $password `
    
    Write-Host "User $username Created" -ForegroundColor Green
} catch {
    Write-Host "Error Creating User: $_" -ForegroundColor Red
}
