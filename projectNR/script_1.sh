#!/bin/bash

# Replace with your server's IP address
SERVER_IP="192.168.36.137"
SSH_PORT="33333"
SSH_USER="kali"

# Commands to run on the remote server
REMOTE_COMMANDS=(
    "echo 'Hello from remote server!'"
    "ls -l /etc"
    "df -h"
    "mkdir /home/kali/Desktop/project/new_folder"
)

# Loop through and execute commands
for command in "${REMOTE_COMMANDS[@]}"; do
    ssh -p "$SSH_PORT" "$SSH_USER"@"$SERVER_IP" "$command"
done
