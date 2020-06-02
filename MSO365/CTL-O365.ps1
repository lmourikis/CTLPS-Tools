function CTLBuild-Message {
    [cmdletbinding()]
    Param (
        [string]$Message,
        [string]$Fullname,   # This will replace _FULLNAME_
        [string]$Username,   # This will replace _USERNAME_
        [string]$Password    # This will replace _PASSWORD_
    ) # End of Parameters

    Begin {}

    Process {
        [string]$msg = $Message

        $msg = $msg -creplace "_FULLNAME_", "$Fullname"
        $msg = $msg -creplace "_USERNAME_", "$Username"
        $msg = $msg -creplace "_PASSWORD_", "$Password"
    } # End of Process

    End {
        Return $msg
    }
}


function CTLIsValid-Email { 
    Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
    [AllowNull()]
    [AllowEmptyString()]
    [string]$EmailAddress,
    [Parameter(Mandatory=$false)]
    [switch]
    [bool]$CheckMxRecord
    )

    try {
        $null = [mailaddress]$EmailAddress
    } catch {
        return $false
    }

    if ($CheckMxRecord -eq $true) {
        Resolve-DnsName -Name $([mailaddress]$EmailAddress).Host -Type MX -ErrorAction SilentlyContinue 2>&1 > $null
        if ($? -ne $false) { return $true } else { return $false }
    }

    return $true
}

function CTLReset-MsolUserPass {
# Reset user's password and send email. The user is forced to change her/his password.
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$UserPrincipalName,
        [Parameter(Mandatory=$false)]
        [string]$Password,
        [Parameter(Mandatory=$true)]
        [string]$MessageSubject,
        [Parameter(Mandatory=$true)]
        [string]$MessageBody,
        [Parameter(Mandatory=$true)]
        [string]$FromAddress,
        [Parameter(Mandatory=$true)]
        [System.Object]$SMTPCreds
    ) # End of Parameters

    Begin {
    } # End of Begin


    Process {
        # Validating data

        # Checking UPN
        $user = Get-MsolUser -UserPrincipalName $UserPrincipalName -ErrorAction SilentlyContinue | select * 
        if ($null -eq $user) {
            break
        }

        # Checking alternate email address
        $AltEmailAddress = $user.AlternateEmailAddresses
        if ($AltEmailAddress.Length -lt 1) {
            Write-Host "User $($UserPrincipalName) has no defined AlternateEmailAddresses. Will now exit..."
            break
        }

        # Checking SMTP credentials
        if ($null -eq $SMTPCreds) {
            Write-Host "SMTP Credentials not defined. Will now exit..."
            break
        }

        # End of data validations

        # Resetting user's password
        if ($Password.Length -gt 4 ) {
            $setPassword = $Password
            Set-MsolUserPassword -UserPrincipalName $UserPrincipalName -ForceChangePassword $true -NewPassword "$($Password)" > $null
        } else {
            $setPassword = Set-MsolUserPassword -UserPrincipalName $UserPrincipalName -ForceChangePassword $true
        }
        
        # Building message
        $message = CTLBuild-Message -Message $($MessageBody) -Username $UserPrincipalName -Fullname "$($user.DisplayName)" -Password "$($setPassword)"
        # Sending email notification
        Send-MailMessage -To $AltEmailAddress -From $FromAddress -Subject "$($MessageSubject)" `
            -Port 587 -SmtpServer smtp.office365.com -UseSsl -Credential $SMTPCreds `
            -Encoding "UTF8" `
            -Body "$($message)"
    } # End of Process

    End {
        
    }
}

