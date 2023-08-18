#!/bin/bash


SERVER_IP="192.168.36.137"
SSH_PORT="33333"
SSH_USER="kali"

function where_am_i {
    pwd
}

function installation_nipe {
    if [ ! -d "nipe" ]; then
        git clone https://github.com/htrgouvea/nipe
    else
        echo "Nipe directory already exists. Skipping clone."
    fi

    if [ -d "nipe" ]; then
        cd nipe
        cpan install Try::Tiny Config::Simple JSON
    else
        echo "Nipe directory doesn't exist. Please clone it first."
        return 1
    fi

    if command -v cpanm &> /dev/null; then
        cpanm --installdeps .
    else
        echo "cpanm is not installed. Please install cpanm first."
        return 1
    fi

    if [ -f "nipe.pl" ]; then
        sudo perl nipe.pl install
    else
        echo "nipe.pl doesn't exist. Cannot run installation."
        return 1
    fi
}

function start_nipe {
    if [ -d "nipe" ]; then
        echo "Starting nipe..."
        (cd nipe && sudo perl nipe.pl start)

        echo "Restarting nipe..."
        (cd nipe && sudo perl nipe.pl restart)

        echo "Checking nipe status..."
        (cd nipe && sudo perl nipe.pl status)
    else
        echo "Nipe directory doesn't exist. Unable to perform operations on nipe."
    fi
}

REMOTE_FUNCTIONS=(
installation_nipe
start_nipe
)


for func in "${REMOTE_FUNCTIONS[@]}"; do
    ssh -p "$SSH_PORT" "$SSH_USER"@"$SERVER_IP" "$(declare -f "$func"); $func"
done
