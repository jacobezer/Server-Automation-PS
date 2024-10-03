#jacobezer
#creates local users

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

function Confirm-user {
    param (
        [string]$username,
        [string]$fullName,
        [string]$description
    ) 

    Write-Host "Confirm user '$username' with the following information"
    Write-Host "Username: $username" -ForegroundColor Yellow
    Write-Host "Full Name: $fullname" -ForegroundColor Yellow
    Write-Host "Description: $description" -ForegroundColor Yellow

    $confirmation = Read-Host -Prompt "Do you want to proceed? (Yes/No)"

    if ($confirmation -eq 'Yes' -or $confirmation -eq 'Y') {
        return $true
    } else {
        return $false
    }
}

do {
    #script
    $username = Read-Host -Prompt "Enter Username"
    $fullName = Read-Host -Prompt "Enter Full Name"
    $description = Read-Host -Prompt "Description"
    $password = Get-SecurePassword -prompt "Enter A Secure Password"
    $confirmed = Confirm-user -username $username -fullName $fullName -description $description
    
    if ($confirmed ) {
        try {
            New-LocalUser -Name $username `
                          -FullName $fullName `
                          -Description $description `
                          -Password $password `
    
            Write-Host "User $username Created" -ForegroundColor Green
        } catch {
            Write-Host "Error Creating User: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "User Cancelled" -ForegroundColor Red
    }
} while (-not $confirmed)