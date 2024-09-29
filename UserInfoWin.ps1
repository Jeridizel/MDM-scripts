function PublicIp {
    $Ip = (Invoke-WebRequest ifconfig.me/ip).Content
    return $Ip
} 

function Get-AllUsers {
    $users = Get-ChildItem C:\Users -Force | select Name
    return $users.Name
}

function Get-LaptopDetails {
    $computerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $bios = Get-WmiObject -Class Win32_BIOS

    $details = [PSCustomObject]@{
        Model = $computerSystem.Model
        SerialNumber = $bios.SerialNumber
    }
    return $details
}

function Get-LogedUsers {
    $loggedInUsers = Get-WmiObject -Class Win32_ComputerSystem | ForEach-Object {
        $_.UserName
    }

    return $loggedInUsers
}

function StatusDomene {
    $output = dsregcmd /status
    $lines = $output -split "`n"
    $extractedLines = $lines[5..10]
    $result = $extractedLines -join "`n"
    return $result
}

function LastContactedDomain {
    $output = net statistics workstation
    $lastContactLine = $output | Select-String -Pattern "Statistics since"

    if ($lastContactLine) {
        return $lastContactLine.Line
    } else {
         return $lastContact = "Could not determine the last contact with domain."
    }
}

function Get-LaptopInfo {
    $users = Get-AllUsers
    $filteredUsers = $users | Where-Object { $_ -notin @("All Users", "Default", "Default User") }

    $laptopDetails = Get-LaptopDetails
    $loggedInUsers = Get-LogedUsers
    $domena = StatusDomene
    $Ip = PublicIp
    $admins = Get-LocalGroupMember -Group 'Administrators' | Select-Object Name | foreach { $_.Name }

    $info = [PSCustomObject]@{
        Users            = $filteredUsers -join ", "
        Model            = $laptopDetails.Model
        SerialNumber     = $laptopDetails.SerialNumber
        Vanjski_IP       = $Ip
        LogedUsers       = $loggedInUsers
        Domena_Status    = $domena
        Administators    = $admins
        Zadnji_kontakt_sa_domenom = LastContactedDomain
    }
    return $info
}

$laptopInfo = Get-LaptopInfo
$laptopInfoFormatted = $laptopInfo | Format-List | Out-String -Width 4096

# Set your client ID and client secret
$client_id = "846840209347-fbpsibnb81sdmr9haph12egf28c6ipsl.apps.googleusercontent.com"
$client_secret = "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"
$refresh_token = "1//09gnsvfr0LoR8CgYIARAAGAkSNwF-L9IrfjuXfUVr8pKLfBX45wiNHaHR5qrYc4cnKutHe488RtI5urRZgQXdrRseBT4ITzDoSaE"

# Define the token request URL
$token_url = "https://www.googleapis.com/oauth2/v4/token"

# Define the request body
$request_body = @{
    client_id = $client_id
    client_secret = $client_secret
    refresh_token = $refresh_token
    grant_type = "refresh_token"
}

# Make the POST request using Invoke-RestMethod and store the response in a variable
$response = Invoke-RestMethod -Method Post -Uri $token_url -ContentType "application/x-www-form-urlencoded" -Body $request_body

# Extract the access_token from the response
$access_token = $response.access_token

# Print the extracted access_token
Write-Output "Access Token: $access_token"

# Define the Gmail API URL and your authorization token
$GMAIL_API_URL = 'https://www.googleapis.com/upload/gmail/v1/users/me/messages/send'
$AUTH_TOKEN = "Bearer $access_token"

$emailContent = @"
From: Cloudsense IT <din.sadovic@cloudsense.com>
To: <it+win@cloudsense.com>
Subject: Windows USER FINDER
Content-type: text/html; charset=UTF-8

<html>
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">Laptop Information:</span></span></p>
<pre>$laptopInfoFormatted</pre>
<div style="color: #4a26ab; font-family: arial, helvetica, sans-serif; font-size: 14px;">
    <br>
    <strong>Din Sadovic</strong>
</div>
<div style="color: #484848; font-family: arial, helvetica, sans-serif; font-size: 12px;">
    <strong>IT Technician</strong>
</div>
<div style="font-size: 12px; color: #484848; font-family: arial, helvetica, sans-serif;">
    <br>
</div>
<div style="font-size: 12px; color: #484848; font-family: arial, helvetica, sans-serif;">
    +385994720225   <br>
    din.sadovic@cloudsense.com
</div>
<div style="font-size: 12px; color: #484848; font-family: arial, helvetica, sans-serif;">
    <br>
    <a href="https://www.cloudsense.com/?utm_medium=email&utm_campaign=SignatureLogo" target="_blank" style="font-size: 12px; font-family: arial, helvetica, sans-serif;">
        <img src="https://www.cloudsense.com/hubfs/Signature/CloudSenselogo.png" alt="CloudSense" height="37" width="106" style="border-style: none;">
    </a>
</div>
<div style="font-family: arial, helvetica, sans-serif; color: #33333d; font-size: 10px;">
    <br>
    Registered office: Radnicka cesta 80, 15th floor, 10000 Zagreb, Croatia
</div>
<div style="font-family: arial, helvetica, sans-serif; color: #33333d;">
    <br>
    <a href="https://insight.cloudsense.com/signature/?utm_medium=email&utm_campaign=SignatureCampaign" target="_blank">
    <img src="https://www.cloudsense.com/hubfs/Signature/Campaign.png?q=2" width="380" height="120" alt="Commerce and Subscriber Management"
        style="color:#4a26ab;font-family: helvetica; border-style: none;"></a>
    <br><br>
</div>
</html>
"@

Invoke-RestMethod -Uri $GMAIL_API_URL -Method Post -Headers @{
    'Authorization' = $AUTH_TOKEN
    'Content-Type' = 'message/rfc822'
} -Body ([System.Text.Encoding]::UTF8.GetBytes($emailContent))
