#!/bin/bash

# Replace with your server's IP address
SERVER_IP="192.168.36.137"
SSH_PORT="33333"
SSH_USER="kali"

# Define functions for remote commands
function where_am_i {
    pwd
}

function git_clone_nipe {
    if [ ! -d "nipe" ]; then
        git clone https://github.com/htrgouvea/nipe
    else
        echo "Nipe directory already exists. Skipping clone."
    fi
}

function config_nipe {
    if [ -d "nipe" ]; then
        (cd nipe && cpan install Try::Tiny Config::Simple JSON)
    else
        echo "Nipe directory doesn't exist. Please clone it first."
    fi
}

function install_deps {
    if [ -d "nipe" ]; then
        (cd nipe && cpanm --installdeps .)
    else
        echo "Nipe directory doesn't exist. Please clone it first."
    fi
}

function install_nipe {
    if [ -d "nipe" ]; then
        (cd nipe && sudo perl nipe.pl install)
    else
        echo "Nipe directory doesn't exist. Can't run installation."
    fi
}

function start_nipe {
    if [ -d "nipe" ]; then
        (cd nipe && sudo perl nipe.pl start)
    else
        echo "Nipe directory doesn't exist. Can't start nipe."
    fi
}

function restart_nipe {
    if [ -d "nipe" ]; then
        (cd nipe && sudo perl nipe.pl restart)
    else
        echo "Nipe directory doesn't exist. Can't restart nipe."
    fi
}

function status_nipe {
    if [ -d "nipe" ]; then
        (cd nipe && sudo perl nipe.pl status)
    else
        echo "Nipe directory doesn't exist. Can't check nipe status."
    fi
}

# Array of functions to execute remotely
REMOTE_FUNCTIONS=(
where_am_i
git_clone_nipe
config_nipe
#    install_deps
install_nipe
start_nipe
restart_nipe
status_nipe
)

# Loop through and execute functions
for func in "${REMOTE_FUNCTIONS[@]}"; do
   ssh -p "$SSH_PORT" "$SSH_USER"@"$SERVER_IP" "$(declare -f "$func"); $func"
done
