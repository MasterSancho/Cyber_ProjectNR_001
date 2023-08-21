#!/bin/bash


# read -p "Enter Domain or IP of Target: " target_ip_or_domain
# echo "You chose target: $target_ip_or_domain"


# SERVER_IP="192.168.36.137"
# SSH_PORT="33333"
# SSH_USER="kali"


# function print_target_info {
#     echo "Information for target: $target_ip_or_domain"

#     if whois $target_ip_or_domain >> whois_output.txt; then
#         echo "Whois data saved to whois_output.txt"
#     else
#         echo "Error occurred with whois."
#     fi

#     if sudo nmap -p- $target_ip_or_domain > nmap_output.txt; then
#         echo "Nmap data saved to nmap_output.txt"
#     else
#         echo "Error occurred with nmap."
#     fi
# }

function check_and_install_tools_on_local_machine {
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

function installation_nipe_on_local_machine {
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
            echo "Nipe directory doesn't exist after cloning. Something went wrong."
            return 1
        fi

        if which cpanm &> /dev/null; then
            cpanm --installdeps . &> /dev/null
        else
            echo "cpanm is not installed. Please install cpanm first."
            return 1
        fi

        if [ -f "nipe.pl" ]; then
            sudo perl nipe.pl install &> /dev/null
            echo "Nipe has been installed successfully and is now ready!"
        else
            echo "nipe.pl doesn't exist. Cannot run installation."
            return 1
        fi
    fi
}


function start_nipe_on_local_machine {
    if [ ! -d "nipe" ]; then
        echo "Nipe directory doesn't exist. Unable to perform operations on nipe."
        return 1
    fi

    # Change to nipe directory once
    cd nipe

    echo "Starting nipe..."
    sudo perl nipe.pl start

    sudo perl nipe.pl restart

    status_output_on_local_machine=$(sudo perl nipe.pl status)
    echo "----- Nipe Status Of Local Machine Output -----"

    nipe_status_on_local_machine=$(echo "$status_output_on_local_machine" | grep "\[+\] Status:" | awk '{print $3}')
    nipe_ip_on_local_machine=$(echo "$status_output_on_local_machine" | grep "\[+\] Ip:" | awk '{print $3}')

    echo "Anonimus Status: $nipe_status_on_local_machine"
    echo "Spoofed IP: $nipe_ip_on_local_machine"

    # Change back to the original directory
    cd ..

    if [ "$nipe_ip_on_local_machine" ]; then
        country_info_on_local_machine=$(geoiplookup "$nipe_ip_on_local_machine" | awk -F ": " '{print $2}')
        echo "Spoofed geolocation: $country_info_on_local_machine"
    else
        echo "Unable to determine Nipe IP country info."
    fi

    echo "------------------------------"
}




# function check_and_install_tools {
#     # Check for nmap
#     if which nmap &> /dev/null; then
#         echo "nmap is ready."
#     else
#         echo "nmap is not installed. Installing nmap..."
#         sudo apt-get install -y nmap
#     fi

#     # Check for whois
#     if which whois &> /dev/null; then
#         echo "whois is ready."
#     else
#         echo "whois is not installed. Installing whois..."
#         sudo apt-get install -y whois
#     fi

#     # Check for geoiplookup
#     if which geoiplookup &> /dev/null; then
#         echo "geoiplookup is ready."
#     else
#         echo "geoiplookup is not installed. Installing geoip-bin..."
#         sudo apt-get install -y geoip-bin
#     fi
# }

# function installation_nipe {
#     if [ ! -d "nipe" ]; then
#         git clone https://github.com/htrgouvea/nipe
#     else
#         echo "Nipe directory already exists. Skipping clone."
#     fi

#     if [ -d "nipe" ]; then
#         cd nipe
#         cpan install Try::Tiny Config::Simple JSON
#     else
#         echo "Nipe directory doesn't exist. Please clone it first."
#         return 1
#     fi

#     if which cpanm &> /dev/null; then
#         cpanm --installdeps .
#     else
#         echo "cpanm is not installed. Please install cpanm first."
#         return 1
#     fi

#     if [ -f "nipe.pl" ]; then
#         sudo perl nipe.pl install
#     else
#         echo "nipe.pl doesn't exist. Cannot run installation."
#         return 1
#     fi
# }

# function start_nipe {
#     if [ -d "nipe" ]; then
#         echo "Starting nipe..."
#         (cd nipe && sudo perl nipe.pl start)

#         echo "Restarting nipe..."
#         (cd nipe && sudo perl nipe.pl restart)

#         echo "Checking nipe status..."
#         status_output=$(cd nipe && sudo perl nipe.pl status)
#         echo "----- Nipe Status Output -----"
#         echo "$status_output"
#         echo "------------------------------"

#         nipe_status=$(echo "$status_output" | grep "\[+\] Status:" | awk '{print $3}')
#         nipe_ip=$(echo "$status_output" | grep "\[+\] Ip:" | awk '{print $3}')

#         echo "Nipe Status: $nipe_status"
#         echo "Nipe IP: $nipe_ip"
#     else
#         echo "Nipe directory doesn't exist. Unable to perform operations on nipe."
#     fi

#     country_info=$(geoiplookup "$nipe_ip" | awk -F ": " '{print $2}')
#     echo "Country Info: $country_info"
#     echo "Uptime: $(uptime -p)"
# }

check_and_install_tools_on_local_machine
installation_nipe_on_local_machine
start_nipe_on_local_machine


# REMOTE_FUNCTIONS=(
#     check_and_install_tools
#     installation_nipe
#     start_nipe
#     print_target_info
# )

# for func in "${REMOTE_FUNCTIONS[@]}"; do
#     ssh -p "$SSH_PORT" "$SSH_USER"@"$SERVER_IP" "$(declare -f "$func"); $func  $target_ip_or_domain"
# done

# scp -P "$SSH_PORT" "$SSH_USER"@"$SERVER_IP":~/dig_output.txt ./
# scp -P "$SSH_PORT" "$SSH_USER"@"$SERVER_IP":~/nmap_output.txt ./

# echo "Files transferred to local machine."