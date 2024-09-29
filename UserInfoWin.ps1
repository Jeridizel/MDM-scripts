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
$client_id = "ENTER_YOUR_CLIENT_ID_HERE"
$client_secret = "ENTER_YOUR_CLIENT_SECRET_HERE"
$refresh_token = "ENTER_YOUR_REFRESH_TOKEN_HERE"

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
From: Your Name <your.email@example.com>
To: <recipient@example.com>
Subject: Windows USER FINDER
Content-type: text/html; charset=UTF-8

<html>
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">Laptop Information:</span></span></p>
<pre>$laptopInfoFormatted</pre>
<div style="color: #4a26ab; font-family: arial, helvetica, sans-serif; font-size: 14px;">
    <br>
    <strong>Your Name</strong>
</div>
<div style="color: #484848; font-family: arial, helvetica, sans-serif; font-size: 12px;">
    <strong>Your Position</strong>
</div>
<div style="font-size: 12px; color: #484848; font-family: arial, helvetica, sans-serif;">
    <br>
</div>
<div style="font-size: 12px; color: #484848; font-family: arial, helvetica, sans-serif;">
    +ENTER_YOUR_PHONE_NUMBER   <br>
    your.email@example.com
</div>
<div style="font-size: 12px; color: #484848; font-family: arial, helvetica, sans-serif;">
    <br>
    <a href="https://yourcompany.com" target="_blank" style="font-size: 12px; font-family: arial, helvetica, sans-serif;">
        <img src="https://yourcompany.com/logo.png" alt="Your Company Logo" height="37" width="106" style="border-style: none;">
    </a>
</div>
<div style="font-family: arial, helvetica, sans-serif; color: #33333d; font-size: 10px;">
    <br>
    Registered office: ENTER_YOUR_ADDRESS
</div>
<div style="font-family: arial, helvetica, sans-serif; color: #33333d;">
    <br>
    <a href="https://yourcompany.com/campaign" target="_blank">
    <img src="https://yourcompany.com/campaign.png" width="380" height="120" alt="Your Campaign"
        style="color:#4a26ab;font-family: helvetica; border-style: none;"></a>
    <br><br>
</div>
</html>
"@

Invoke-RestMethod -Uri $GMAIL_API_URL -Method Post -Headers @{
    'Authorization' = $AUTH_TOKEN
    'Content-Type' = 'message/rfc822'
} -Body ([System.Text.Encoding]::UTF8.GetBytes($emailContent))
