#!/usr/bin/env bash

## Check if run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

## Ask for username
read -p "Enter the username to create: " username

## Check if user already exists
if id "$username" &>/dev/null; then
    echo "User '$username' already exists!"
    exit 1
fi

## Create the user with home directory
useradd -m -s /bin/bash "$username"

## Set password
passwd "$username"

## Add to sudo group (optional)
read -p "Add user to sudo group? (y/n): " add_sudo
if [[ "$add_sudo" == "y" ]]; then
    usermod -aG sudo "$username"
    echo "User '$username' added to sudo group."
fi

echo "User '$username' has been created successfully."
