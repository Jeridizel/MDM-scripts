#!/bin/sh

# Run the script and save the result
fmmToken=$(/usr/sbin/nvram -x -p | /usr/bin/grep fmm-mobileme-token-FMM)

if [ -z "$fmmToken" ]; then
    result="Find my Mac NIJE UKLJUCEN"
    #apply tag "disabled fmf" u miradore na device

    # Retrieving the Mac serial number and store the result in a variable
    system_profiler_output=$(system_profiler SPHardwareDataType)

    # Extracts the serial number and store it in a variable
    serial_number=$(echo "$system_profiler_output" | awk '/Serial/ {print $4}')

    # Send the request, extract email, and store the response in a variable
    RESULT=$(curl -s "https://cloudsense1.online.miradore.com/API/Device?auth=5_4nsX-KI\$p20vR1$&select=ID&filters=InvDevice.SerialNumber%20eq%20$serial_number" | xmllint --format - | xpath -e /Content/Items/Device\[last\(\)\]/ID | sed -n 's/.*<ID>\(.*\)<\/ID>.*/\1/p')

    ID="$RESULT"
    TAG="disabled-fmm"

    # Specify the full URL for the PUT request
    PUT_URL="https://cloudsense1.online.miradore.com/API/Device/$ID/Tag/$TAG?auth=5_4nsX-KI%24p20vR1%24"

    # Specify the API key in the header
    API_KEY="5_4nsX-KI\$p20vR1$"

    # Make the PUT request using curl with a Content-Length header
    curl --location --request PUT "$PUT_URL" \
    --header "X-API-Key: $API_KEY" \
    --header "Content-Length: 0"  # Add a Content-Length header with a value of 0

    #erases all content from crontab
    launchctl unload /Library/LaunchDaemons/com.proba.plist
    rm /Library/LaunchDaemons/com.proba.plist
    rm /Library/Application\ Support/Miradore/OnlineClient/skripta.sh

else
    result="Find my Mac je UKLJUCEN"
    # dobi serial number devica -> pretrazi ga u miradoreu i dobi mail i first name -> posalji google mail

    # Use system_profiler to retrieve the Mac serial number and store the result in a variable
    system_profiler_output=$(system_profiler SPHardwareDataType)

    # Extracts the serial number and store it in a variable
    serial_number=$(echo "$system_profiler_output" | awk '/Serial/ {print $4}')

    # Check if the serial number is empty
    if [ -z "$serial_number" ]; then
        echo "Serial number not found."
    else
        echo "$serial_number"
        # Send the request, extract email, and store the response in a variable
        RESULT=$(curl -s "https://cloudsense1.online.miradore.com/API/Device?auth=5_4nsX-KI\$p20vR1$&select=InvDevice.Model,InvDevice.SerialNumber,User.Email,User.LastName,User.FirstName,Organization.FullName&filters=InvDevice.SerialNumber%20eq%20$serial_number" | xmllint --format - | xpath -e /Content/Items/Device\[last\(\)\]/User/Email | sed -n 's/.*<Email>\(.*\)<\/Email>.*/\1/p')

        # Print the email variable
        # echo "$RESULT"
        first_name="${RESULT%%.*}"
        first_name="$(tr '[:lower:]' '[:upper:]' <<< ${first_name:0:1})${first_name:1}"

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
To: <$RESULT>
Subject: Please turn off your Find my MAC
Content-type: text/html; charset=UTF-8

<html>
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">Dear $first_name,</span></span></p>
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">We&#39;ve found out that you have the &quot;Find my Mac&quot; option enabled on your CloudSense Macbook, and would kindly ask you to <strong>disable</strong> it!</span></span></p>
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">Here is how to do it:&nbsp;</span></span><a href="https://support.apple.com/en-gb/guide/icloud/mmdc23b125f6/icloud">https://support.apple.com/en-gb/guide/icloud/mmdc23b125f6/icloud</a></p>
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">If you need any help let me know. </span></span></p>
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">Your IT Team, </span></span></p>
<p><span style="font-family:Arial,Helvetica,sans-serif"><span style="font-size:14px">Thanks</span></span></p>
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
    fi
fi
