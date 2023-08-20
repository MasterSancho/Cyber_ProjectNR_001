#!/bin/bash


read -p "Enter Domain or IP of Target: " target_ip_or_domain
echo "You chose target: $target_ip_or_domain"


SERVER_IP="192.168.36.137"
SSH_PORT="33333"
SSH_USER="kali"


function print_target_info {
    echo "Information for target: $1"

    sudo whois $1 >> info_output.txt
    sudo dig $1 >> info_output.txt
    sudo host $1 >> info_output.txt
    sudo nslookup $1 >> info_output.txt

    sudo nmap -Pn $1 >> ports_output.txt
    sudo zmap $1 >> ports_output.txt
    sudo masscan $1 >> ports_output.txt
    sudo unicornscan $1 >> ports_output.txt
    sudo nikto -h $1 >> ports_output.txt

    echo "Whois data saved to whois_output.txt"
    echo "Nmap data saved to nmap_output.txt"
}


function check_and_install_tools {
    tools=("nmap" "whois" "geoiplookup" "dig" "host" "nslookup" "zmap" "masscan" "unicornscan" "nikto")

    for tool in "${tools[@]}"; do
        if which $tool &> /dev/null; then
            echo "$tool is ready."
        else
            echo "$tool is not installed. Installing $tool..."
            sudo apt-get update
            sudo apt-get install -y $tool
        fi
    done
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

    if which cpanm &> /dev/null; then
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
        status_output=$(cd nipe && sudo perl nipe.pl status)
        echo "----- Nipe Status Output -----"
        echo "$status_output"
        echo "------------------------------"

        nipe_status=$(echo "$status_output" | grep "\[+\] Status:" | awk '{print $3}')
        nipe_ip=$(echo "$status_output" | grep "\[+\] Ip:" | awk '{print $3}')

        echo "Nipe Status: $nipe_status"
        echo "Nipe IP: $nipe_ip"
    else
        echo "Nipe directory doesn't exist. Unable to perform operations on nipe."
    fi

    country_info=$(geoiplookup "$nipe_ip" | awk -F ": " '{print $2}')
    echo "Country Info: $country_info"
    echo "Uptime: $(uptime -p)"
}

REMOTE_FUNCTIONS=(
    check_and_install_tools
    installation_nipe
    start_nipe
    print_target_info
)

for func in "${REMOTE_FUNCTIONS[@]}"; do
    ssh -p "$SSH_PORT" "$SSH_USER"@"$SERVER_IP" "$(declare -f "$func"); $func  $target_ip_or_domain"
done

scp -P "$SSH_PORT" "$SSH_USER"@"$SERVER_IP":~/info_output.txt ./
scp -P "$SSH_PORT" "$SSH_USER"@"$SERVER_IP":~/ports_output.txt ./

echo "Files transferred to local machine."