#!/bin/sh

# Provjera statusa "Find my Mac"
fmmToken=$(/usr/sbin/nvram -x -p | /usr/bin/grep fmm-mobileme-token-FMM)

if [ -z "$fmmToken" ]; then
    result="Find my Mac NIJE UKLJUCEN"
    
    # Dohvaćanje serijskog broja Maca
    system_profiler_output=$(system_profiler SPHardwareDataType)
    serial_number=$(echo "$system_profiler_output" | awk '/Serial/ {print $4}')

    # API zahtjev za Miradore na temelju serijskog broja
    RESULT=$(curl -s "https://<your-miradore-url>/API/Device?auth=<your-api-auth>&select=ID&filters=InvDevice.SerialNumber%20eq%20$serial_number" | xmllint --format - | xpath -e /Content/Items/Device\[last\(\)\]/ID | sed -n 's/.*<ID>\(.*\)<\/ID>.*/\1/p')

    ID="$RESULT"
    TAG="disabled-fmm"

    # PUT zahtjev za dodavanje taga "disabled-fmm"
    PUT_URL="https://<your-miradore-url>/API/Device/$ID/Tag/$TAG?auth=<your-api-auth>"
    
    curl --location --request PUT "$PUT_URL" \
    --header "X-API-Key: <your-api-key>" \
    --header "Content-Length: 0"

    # Uklanjanje cron zadataka i datoteka
    launchctl unload /Library/LaunchDaemons/com.proba.plist
    rm /Library/LaunchDaemons/com.proba.plist
    rm /Library/Application\ Support/Miradore/OnlineClient/skripta.sh
else
    result="Find my Mac je UKLJUCEN"
    
    # Ponovno dohvati serijski broj
    system_profiler_output=$(system_profiler SPHardwareDataType)
    serial_number=$(echo "$system_profiler_output" | awk '/Serial/ {print $4}')

    if [ -n "$serial_number" ]; then
        echo "$serial_number"
        
        # API zahtjev za informacije o korisniku
        RESULT=$(curl -s "https://<your-miradore-url>/API/Device?auth=<your-api-auth>&select=User.Email,User.FirstName&filters=InvDevice.SerialNumber%20eq%20$serial_number" | xmllint --format - | xpath -e /Content/Items/Device\[last\(\)\]/User/Email | sed -n 's/.*<Email>\(.*\)<\/Email>.*/\1/p')

        # Pretvori email u ime za pozdrav
        first_name="${RESULT%%.*}"
        first_name="$(tr '[:lower:]' '[:upper:]' <<< ${first_name:0:1})${first_name:1}"
        
        # Postavi API informacije kao varijable izvan koda (npr. .env datoteka)
        client_id="<your-client-id>"
        client_secret="<your-client-secret>"
        refresh_token="<your-refresh-token>"

        token_url="https://www.googleapis.com/oauth2/v4/token"
        request_body="client_id=$client_id&client_secret=$client_secret&refresh_token=$refresh_token&grant_type=refresh_token"

        # Dohvati novi access_token
        response=$(curl --location --request POST "$token_url" --header 'Content-Type: application/x-www-form-urlencoded' --data "$request_body")
        access_token=$(echo "$response" | sed -n 's/.*"access_token": "\(.*\)",/\1/p')

        # URL Gmail API-ja
        GMAIL_API_URL='https://www.googleapis.com/upload/gmail/v1/users/me/messages/send'
        AUTH_TOKEN="Bearer $access_token"

        # Privremena datoteka za email sadržaj
        EMAIL_CONTENT=$(mktemp)

        # Kreiraj email sadržaj
        cat <<EOF > "$EMAIL_CONTENT"
From: IT <Your gmail here>
To: <$RESULT>
Subject: Please turn off your Find my MAC
Content-type: text/html; charset=UTF-8

<html>
<p>Dear $first_name,</p>
<p>We've found that you have the "Find my Mac" option enabled on your MacBook, and we kindly ask you to disable it. You can find instructions here:</p>
<a href="https://support.apple.com/en-gb/guide/icloud/mmdc23b125f6/icloud">Disable Find my Mac</a>
<p>If you need any help, let us know. Your IT Team.</p>
<p>Thanks!</p>
</html>
EOF

        # Pošalji email
        curl --location "$GMAIL_API_URL" \
        --header 'Content-Type: message/rfc822' \
        --header "Authorization: $AUTH_TOKEN" \
        --data-binary "@$EMAIL_CONTENT"

        # Obriši privremenu datoteku
        rm "$EMAIL_CONTENT"
    fi
fi
