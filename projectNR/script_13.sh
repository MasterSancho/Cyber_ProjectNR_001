#!/bin/bash


read -p "Enter Domain or IP of Target: " target
# echo "You chose target: $target"


SERVER_IP="192.168.36.137"
SSH_PORT="33333"
SSH_USER="kali"


# function check_and_install_tools_on_local_machine {
#     # Check and install nmap
#     if which nmap &> /dev/null; then
#         echo "nmap is ready."
#     else
#         echo "nmap is not installed. Installing nmap..."
#         if ! sudo apt-get install -y nmap &> /dev/null; then
#             echo "Error installing nmap."
#         else
#             echo "nmap is ready."
#         fi
#     fi

#     # Check and install whois
#     if which whois &> /dev/null; then
#         echo "whois is ready."
#     else
#         echo "whois is not installed. Installing whois..."
#         if ! sudo apt-get install -y whois &> /dev/null; then
#             echo "Error installing whois."
#         else
#             echo "whois is ready."
#         fi
#     fi

#     # Check and install geoiplookup
#     if which geoiplookup &> /dev/null; then
#         echo "geoiplookup is ready."
#     else
#         echo "geoiplookup is not installed. Installing geoip-bin..."
#         if ! sudo apt-get install -y geoip-bin &> /dev/null; then
#             echo "Error installing geoip-bin."
#         else
#             echo "geoiplookup is ready."
#         fi
#     fi
# }

# function installation_nipe_on_local_machine {
#     if [ -f "nipe/nipe.pl" ]; then
#         echo "Nipe is ready."
#     else
#         echo "Nipe not found in the current folder..."
#         echo "Starting installation of Nipe..."

#         git clone https://github.com/htrgouvea/nipe &> /dev/null

#         if [ -d "nipe" ]; then
#             cd nipe
#             cpan install Try::Tiny Config::Simple JSON &> /dev/null
#         else
#             echo "Nipe directory doesn't exist after cloning. Something went wrong."
#             return 1
#         fi

#         if which cpanm &> /dev/null; then
#             cpanm --installdeps . &> /dev/null
#         else
#             echo "cpanm is not installed. Please install cpanm first."
#             return 1
#         fi

#         if [ -f "nipe.pl" ]; then
#             sudo perl nipe.pl install &> /dev/null
#             echo "Nipe has been installed successfully and is now ready!"
#         else
#             echo "nipe.pl doesn't exist. Cannot run installation."
#             return 1
#         fi
#     fi
# }


# function start_nipe_on_local_machine {
#     if [ ! -d "nipe" ]; then
#         echo "Nipe directory doesn't exist. Unable to perform operations on nipe."
#         return 1
#     fi

#     # Change to nipe directory once
#     cd nipe

#     echo "Starting nipe..."
#     sudo perl nipe.pl start

#     sudo perl nipe.pl restart

#     status_output_on_local_machine=$(sudo perl nipe.pl status)
#     echo "----- Nipe Status Of Local Machine Output -----"

#     nipe_status_on_local_machine=$(echo "$status_output_on_local_machine" | grep "\[+\] Status:" | awk '{print $3}')
#     nipe_ip_on_local_machine=$(echo "$status_output_on_local_machine" | grep "\[+\] Ip:" | awk '{print $3}')

#     echo "Anonimus Status: $nipe_status_on_local_machine"
#     echo "Spoofed IP: $nipe_ip_on_local_machine"

#     # Change back to the original directory
#     cd ..

#     if [ "$nipe_ip_on_local_machine" ]; then
#         country_info_on_local_machine=$(geoiplookup "$nipe_ip_on_local_machine" | awk -F ": " '{print $2}')
#         echo "Spoofed geolocation: $country_info_on_local_machine"
#     else
#         echo "Unable to determine Nipe IP country info."
#     fi

#     echo "------------------------------"
# }



function check_and_install_tools_on_server {
    # Check and install nmap
    if which nmap &> /dev/null; then
        echo "nmap is ready."
    else
        echo "nmap is not installed. Installing nmap..."
        if ! sudo apt-get install -y nmap &> /dev/null; then
            echo "Error installing nmap."
        else
            echo "nmap is ready."
        fi
    fi

    # Check and install whois
    if which whois &> /dev/null; then
        echo "whois is ready."
    else
        echo "whois is not installed. Installing whois..."
        if ! sudo apt-get install -y whois &> /dev/null; then
            echo "Error installing whois."
        else
            echo "whois is ready."
        fi
    fi

    # Check and install geoiplookup
    if which geoiplookup &> /dev/null; then
        echo "geoiplookup is ready."
    else
        echo "geoiplookup is not installed. Installing geoip-bin..."
        if ! sudo apt-get install -y geoip-bin &> /dev/null; then
            echo "Error installing geoip-bin."
        else
            echo "geoiplookup is ready."
        fi
    fi
}

function installation_nipe_on_server {
    if [ -f "nipe/nipe.pl" ]; then
        echo "Nipe is ready."
    else
        echo "Nipe not found in the current folder..."
        echo "Starting installation of Nipe..."

        git clone https://github.com/htrgouvea/nipe &> /dev/null

        if [ -d "nipe" ]; then
            cd nipe
            cpan install Try::Tiny Config::Simple JSON &> /dev/null
        else
            echo "Nipe directory doesn't exist after cloning!"
            echo "Something went wrong!"
            return 1
        fi

        if which cpanm &> /dev/null; then
            cpanm --installdeps . &> /dev/null
        else
            echo "cpanm is not installed!"
            echo "Please install cpanm first!"
            return 1
        fi

        if [ -f "nipe.pl" ]; then
            sudo perl nipe.pl install &> /dev/null
            echo "Nipe is ready!"
        else
            echo "nipe.pl doesn't exist!"
            echo "Cannot run installation!"
            return 1
        fi
    fi
}

function start_nipe_on_server {
    # Change to nipe directory
    cd nipe

    echo "Starting nipe..."
    sudo perl nipe.pl start

    sudo perl nipe.pl restart

    status_output_of_nipe_on_server=$(sudo perl nipe.pl status)
    echo "----- Nipe Status Of Server Machine Output -----"

    nipe_status_on_server=$(echo "$status_output_of_nipe_on_server" | grep "\[+\] Status:" | awk '{print $3}')
    nipe_ip_on_server=$(echo "$status_output_of_nipe_on_server" | grep "\[+\] Ip:" | awk '{print $3}')

    echo "Uptime Server: $(uptime -p)"
    echo "Anonimus Server Status: $nipe_status_on_server"
    echo "Spoofed Server IP: $nipe_ip_on_server"

    # Back to script directory
    cd ..

    if [ "$nipe_ip_on_server" ]; then
        country_info_on_server=$(geoiplookup "$nipe_ip_on_server" | awk -F ": " '{print $2}')
        echo "Spoofed Server geolocation: $country_info_on_server"
    else
        echo "Unable to determine Nipe IP country info."
    fi

    echo "------------------------------"
}

function target_info {
    target=$1
    echo "Your target: $target"

    if whois $target >> whois_target_info.txt; then
        echo "Whois data saved to whois_target_info.txt"
    else
        echo "Error occurred with whois."
    fi

    if sudo nmap -sS -Pn $target > nmap_target_info.txt; then
        echo "Nmap data saved to nmap_target_info.txt"
    else
        echo "Error occurred with nmap."
    fi
}

# check_and_install_tools_on_local_machine
# installation_nipe_on_local_machine
# start_nipe_on_local_machine


REMOTE_FUNCTIONS=(
    check_and_install_tools_on_server
    installation_nipe_on_server
    start_nipe_on_server
    target_info
)

for func in "${REMOTE_FUNCTIONS[@]}"; do
        ssh -p "$SSH_PORT" "$SSH_USER"@"$SERVER_IP" "$(declare -f "$func"); $func \"$target\""
done

# for func in "${REMOTE_FUNCTIONS[@]}"; do
#     if [ "$func" = "target_info" ]; then
#         ssh -p "$SSH_PORT" "$SSH_USER"@"$SERVER_IP" "$(declare -f "$func"); $func \"$target\""
#     else
#         ssh -p "$SSH_PORT" "$SSH_USER"@"$SERVER_IP" "$(declare -f "$func"); $func"
#     fi
# done

# scp -P "$SSH_PORT" "$SSH_USER"@"$SERVER_IP":~/whois_target_info.txt ./
# scp -P "$SSH_PORT" "$SSH_USER"@"$SERVER_IP":~/nmap_target_info.txt ./

if scp -P "$SSH_PORT" "$SSH_USER"@"$SERVER_IP":~/whois_target_info.txt ./ > /dev/null 2>&1; then
    echo "Whois data transferred to local machine."
else
    echo "Error occurred while transferring whois data."
fi

if scp -P "$SSH_PORT" "$SSH_USER"@"$SERVER_IP":~/nmap_target_info.txt ./ > /dev/null 2>&1; then
    echo "Nmap data transferred to local machine."
else
    echo "Error occurred while transferring nmap data."
fi


# echo "Files transferred to local machine."