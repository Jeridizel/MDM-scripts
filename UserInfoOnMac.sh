#!/bin/bash

current_user=$(users)
all_users=$(dscl . list /Users | grep -v '_')
AppleID=$(sudo -u $current_user defaults read MobileMeAccounts Accounts | grep @) # Returns AccoutDescription, Account ID
IpAddress=$(curl ifconfig.me)
system_profiler_output=$(system_profiler SPHardwareDataType)
serial_number=$(echo "$system_profiler_output" | awk '/Serial/ {print $4}')

security dump-keychain login.keychain &> log.txt
potencijalni_mail=$(grep -o '[A-Za-z0-9._%+-]\+@[A-Za-z0-9.-]\+\.[A-Za-z]\{2,6\}' log.txt | sort | uniq)

if [[$potencijalni_mail == "*\n*"]]; then
    MoguciMail=$(echo $potencijalni_mail | tr '\n' ' ')
else
    MoguciMail=$potencijalni_mail
fi

# Set your client ID and client secret
client_id="846840209347-fbpsibnb81sdmr9haph12egf28c6ipsl.apps.googleusercontent.com"
client_secret="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"

# Set your refresh token
refresh_token="1//09gnsvfr0LoR8CgYIARAAGAkSNwF-L9IrfjuXfUVr8pKLfBX45wiNHaHR5qrYc4cnKutHe488RtI5urRZgQXdrRseBT4ITzDoSaE"

# Define the token request URL
token_url="https://www.googleapis.com/oauth2/v4/token"

# Define the request body
request_body="client_id=$client_id&client_secret=$client_secret&refresh_token=$refresh_token&grant_type=refresh_token"

# Make the POST request using curl and store the response in a variable
response=$(curl --location --request POST "$token_url" --header 'Content-Type: application/x-www-form-urlencoded' --data "$request_body")

# Extract the access_token using sed and store it in a new variable
access_token=$(echo "$response" | sed -n 's/.*"access_token": "\(.*\)",/\1/p')

# Print the extracted access_token
echo "Access Token: $access_token"

# Define the Gmail API URL and your authorization token
GMAIL_API_URL='https://www.googleapis.com/upload/gmail/v1/users/me/messages/send'
AUTH_TOKEN="Bearer $access_token"

# Create a temporary file for the email content
EMAIL_CONTENT=$(mktemp)

# Use a here document to specify the email content
cat <<EOF > "$EMAIL_CONTENT"
From: Cloudsense IT <din.sadovic@cloudsense.com>
To: <it+mac@cloudsense.com>
Subject: Macbook USER FINDER
Content-type: text/html; charset=UTF-8

<html>
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">Serial number: $serial_number</span></span></p>
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">Vanjski IP: $IpAddress</span></span></p> 
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">Trenutacno logirani user: $current_user</span></span></p>
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">SVI useri: $all_users</span></span></p>
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">Apple ID: $AppleID</span></span></p>
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">Potencijali mail: $MoguciMail</span></span></p>
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
EOF

# Send the email using curl
curl --location "$GMAIL_API_URL" \
--header 'Content-Type: message/rfc822' \
--header "Authorization: $AUTH_TOKEN" \
--data-binary "@$EMAIL_CONTENT"

# Remove the temporary email content file
rm "$EMAIL_CONTENT"
