#!/bin/bash


read -p "Enter Domain or IP of Target: " target_ip_or_domain
echo "You chose target: $target_ip_or_domain"


SERVER_IP="192.168.36.137"
SSH_PORT="33333"
SSH_USER="kali"


function print_target_info {
    echo "Information for target: $target_ip_or_domain"

    # whois $target_ip_or_domain >> whois_output.txt
    dig $target_ip_or_domain MX >> dig_output.txt
    # host -t mx $target_ip_or_domain >> host_output.txt
    # nslookup $target_ip_or_domain >> nslookup_output.txt

    sudo nmap -Pn $target_ip_or_domain >> nmap_output.txt
    # sudo zmap $target_ip_or_domain >> zmap_output.txt
    # sudo masscan -p1-65535 $target_ip_or_domain --rate=100 >> masscan_output.txt
    # sudo unicornscan -mT -a $target_ip_or_domain >> unicornscan_output.txt
    # sudo nikto -h $target_ip_or_domain >> nikto_output.txt

    echo "Whois data saved to info_output.txt"
    echo "Nmap data saved to ports_output.txt"
}

function check_and_install_tools_on_local_machine {
    tools_on_local_machine=("nmap" "whois" "geoiplookup" "dig" "host" "nslookup" "zmap" "masscan" "unicornscan" "nikto")

    for tool_on_local_machine in "${tools_on_local_machine[@]}"; do
        if which $tool_on_local_machine &> /dev/null; then
            echo "$tool_on_local_machine is ready."
        else
            echo "$tool_on_local_machine is not installed. Installing $tool_on_local_machine..."
            sudo apt-get update
            sudo apt-get install -y $tool_on_local_machine
        fi
    done
}

function installation_nipe_on_local_machine {
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

function start_nipe_on_local_machine {
    cd ..
    (pwd)

    if [ -d "nipe" ]; then
        echo "Starting nipe..."
        (cd nipe && sudo perl nipe.pl start)

        echo "Restarting nipe..."
        (cd nipe && sudo perl nipe.pl restart)

        echo "Checking nipe status..."
        status_output_on_local_machine=$(cd nipe && sudo perl nipe.pl status)
        echo "----- Nipe Status Of Local Machine Output -----"
        echo "$status_output_on_local_machine"
        echo "------------------------------"

        nipe_status_on_local_machine=$(echo "$status_output_on_local_machine" | grep "\[+\] Status:" | awk '{print $3}')
        nipe_ip_on_local_machine=$(echo "$status_output_on_local_machine" | grep "\[+\] Ip:" | awk '{print $3}')

        echo "Nipe Status: $nipe_status_on_local_machine"
        echo "Nipe IP: $nipe_ip_on_local_machine"
    else
        echo "Nipe directory doesn't exist. Unable to perform operations on nipe."
    fi

    country_info_on_local_machine=$(geoiplookup "$nipe_ip_on_local_machine" | awk -F ": " '{print $2}')
    echo "Country Info: $country_info_on_local_machine"

    echo "------------------------------"
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

check_and_install_tools_on_local_machine
installation_nipe_on_local_machine
start_nipe_on_local_machine

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