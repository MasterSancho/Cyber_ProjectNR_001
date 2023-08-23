#!/bin/bash

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


# input target
read -p "Enter Domain or IP of Target: " target

# variables for connecting to remote server
SERVER_IP="192.168.36.137"
SSH_PORT="33333"
SSH_USER="kali"


function check_and_install_tools_on_local_machine {
    echo -e "${YELLOW}-----> Tools Status On Local Machine <-----${NC}"

    # Check and install nmap
    if which nmap &> /dev/null; then
        echo -e "${GREEN}nmap is ready${NC}"
    else
        # Install nmap if not installed
        echo -e "${YELLOW}nmap is not installed. Installing nmap...${NC}"
        if ! sudo apt-get install -y nmap &> /dev/null; then
            echo -e "${RED}Error installing nmap!${NC}"
        else
            echo -e "${GREEN}nmap is ready${NC}"
        fi
    fi

    # Check and install whois
    if which whois &> /dev/null; then
        echo -e "${GREEN}whois is ready${NC}"
    else
        # Install whois if not installed
        echo -e "${YELLOW}whois is not installed. Installing whois...${NC}"
        if ! sudo apt-get install -y whois &> /dev/null; then
            echo -e "${RED}Error installing whois!${NC}"
        else
            echo -e "${GREEN}whois is ready${NC}"
        fi
    fi

    # Check and install geoiplookup
    if which geoiplookup &> /dev/null; then
        echo -e "${GREEN}geoiplookup is ready${NC}"
    else
        # Install geoip-bin if geoiplookup not installed
        echo -e "${YELLOW}geoiplookup is not installed. Installing geoip-bin...${NC}"
        if ! sudo apt-get install -y geoip-bin &> /dev/null; then
            echo -e "${RED}Error installing geoip-bin!${NC}"
        else
            echo -e "${GREEN}geoiplookup is ready${NC}"
        fi
    fi
}

function installation_nipe_on_local_machine {
    # Check if nipe.pl exists
    if [ -f "nipe/nipe.pl" ]; then
        echo -e "${GREEN}nipe is ready${NC}"
    else
        echo "Nipe not found in the current folder..."
        echo "Starting installation of Nipe..."

        # Clone the Nipe tool from GitHub
        git clone https://github.com/htrgouvea/nipe &> /dev/null

        # Check if the nipe folder exists after cloning
        if [ -d "nipe" ]; then

            cd nipe

            # Install Perl modules
            cpan install Try::Tiny Config::Simple JSON &> /dev/null
        else
            echo -e "${RED}Nipe folder doesn't exist after cloning. Something went wrong!${NC}"
            return 1
        fi

        # Check if cpanm is installed
        if which cpanm &> /dev/null; then
            # Install the dependencies
            cpanm --installdeps . &> /dev/null
        else
            echo -e "${RED}cpanm is not installed. Please install cpanm first${NC}"
            return 1
        fi

        # Check if nipe.pl file exists then install nipe
        if [ -f "nipe.pl" ]; then
            sudo perl nipe.pl install &> /dev/null
            echo -e "${GREEN}nipe is ready${NC}"
        else
            echo -e "${RED}nipe.pl doesn't exist. Cannot run installation${NC}"
            return 1
        fi

        cd ..
    fi

    sleep 2
}

function start_nipe_on_local_machine {
    echo -e "${YELLOW}-----> Nipe Status On Local Machine <-----${NC}"

    cd nipe

    # Start Nipe
    sudo perl nipe.pl start

    # Restart Nipe
    sudo perl nipe.pl restart

    # Check the status of Nipe
    status_output_on_local_machine=$(sudo perl nipe.pl status)

    # Extract Nipe's status and IP from the status output
    nipe_status_on_local_machine=$(echo "$status_output_on_local_machine" | grep "\[+\] Status:" | awk '{print $3}')
    nipe_ip_on_local_machine=$(echo "$status_output_on_local_machine" | grep "\[+\] Ip:" | awk '{print $3}')

    # Check and print nipe status
    if [[ "$nipe_status_on_local_machine" == "true" ]]; then
        echo -e "${GREEN}Anonimus Local Status: $nipe_status_on_local_machine${NC}"
    else
        echo -e "${RED}Error: Nipe not working!${NC}"
        exit 1
    fi

    # Print spoofed IP
    echo -e "${GREEN}Spoofed IP: $nipe_ip_on_local_machine${NC}"

    cd ..

    # If Nipe IP exists, find and display geolocation
    if [ "$nipe_ip_on_local_machine" ]; then
        country_info_on_local_machine=$(geoiplookup "$nipe_ip_on_local_machine" | awk -F ": " '{print $2}')
        echo -e "${GREEN}Spoofed Geolocation: $country_info_on_local_machine${NC}"
    else
        echo -e "${RED}Erorr with country geolocation!${NC}"
    fi

    sleep 2
}


function check_and_install_tools_on_server {
    echo -e "${YELLOW}-----> Tools Status On Server Machine <-----${NC}"

    # Check and install nmap
    if which nmap &> /dev/null; then
        echo -e "${GREEN}nmap is ready${NC}"
    else
        # Install 'nmap' if not installed
        echo "nmap is not installed. Installing nmap..."
        if ! sudo apt-get install -y nmap &> /dev/null; then
            echo -e "${RED}Error installing nmap!${NC}"
        else
            echo -e "${GREEN}nmap is ready${NC}"
        fi
    fi

    # Check and install whois
    if which whois &> /dev/null; then
        echo -e "${GREEN}whois is ready${NC}"
    else
        # Install 'whois' if not installed
        echo "whois is not installed. Installing whois..."
        if ! sudo apt-get install -y whois &> /dev/null; then
            echo -e "${RED}Error installing whois${NC}"
        else
            echo -e "${GREEN}whois is ready${NC}"
        fi
    fi

    # Check and install geoiplookup
    if which geoiplookup &> /dev/null; then
        echo -e "${GREEN}geoiplookup is ready${NC}"
    else
        # Install 'geoip-bin' if geoiplookup not installed
        echo "geoiplookup is not installed. Installing geoip-bin..."
        if ! sudo apt-get install -y geoip-bin &> /dev/null; then
            echo -e "${RED}Error installing geoip-bin!${NC}"
        else
            echo -e "${GREEN}geoiplookup is ready${NC}"
        fi
    fi
}

function installation_nipe_on_server {
    # Check if nipe.pl exists
    if [ -f "nipe/nipe.pl" ]; then
        echo -e "${GREEN}nipe is ready.${NC}"
    else
        echo "${RED}Nipe not found in the current folder...${NC}"
        echo "Starting installation of Nipe..."

        # Clone the Nipe tool from GitHub
        git clone https://github.com/htrgouvea/nipe &> /dev/null

        # Check if the Nipe folder exists after cloning
        if [ -d "nipe" ]; then
            cd nipe
            # Install Perl modules for Nipe
            cpan install Try::Tiny Config::Simple JSON &> /dev/null
        else
            echo -e "${RED}Nipe folder doesn't exist after cloning!${NC}"
            echo -e "${RED}Something went wrong!${NC}"
            return 1
        fi

        # Check if cpanm is installed
        if which cpanm &> /dev/null; then
            # Install dependencies
            cpanm --installdeps . &> /dev/null
        else
            echo -e "${RED}cpanm is not installed!${NC}"
            echo -e "${RED}Please install cpanm first!${NC}"
            return 1
        fi

        # Check if nipe.pl exists, then install Nipe
        if [ -f "nipe.pl" ]; then
            sudo perl nipe.pl install &> /dev/null
            echo -e "${GREEN}nipe is ready!${NC}"
        else
            echo -e "${RED}nipe.pl doesn't exist!${NC}"
            echo -e "${RED}Cannot run installation!${NC}"
            return 1
        fi
    fi

    sleep 2
}

function start_nipe_on_server {
    echo -e "${YELLOW}-----> Nipe Status On Server Machine <-----${NC}"

    cd nipe

    # Start Nipe
    sudo perl nipe.pl start

    # Restart Nipe
    sudo perl nipe.pl restart

    # Store nipe status in a variable
    status_of_nipe_on_server=$(sudo perl nipe.pl status)

    # Extract the actual status and IP address from Nipe's status output
    nipe_status_on_server=$(echo "$status_of_nipe_on_server" | grep "\[+\] Status:" | awk '{print $3}')
    nipe_ip_on_server=$(echo "$status_of_nipe_on_server" | grep "\[+\] Ip:" | awk '{print $3}')

    # Display the server uptime
    echo -e "${GREEN}Uptime Server: $(uptime -p)${NC}"

    # Check and print nipe status
    if [[ "$nipe_status_on_server" == "true" ]]; then
        echo -e "${GREEN}Anonimus Local Status: $nipe_status_on_local_machine${NC}"
    else
        echo -e "${RED}Error: Nipe not working!${NC}"
        exit 1
    fi

    # Print spoofed IP
    echo -e "${GREEN}Spoofed Server IP: $nipe_ip_on_server${NC}"

    cd ..

    # If a spoofed IP is present, determine its geographical location
    if [ "$nipe_ip_on_server" ]; then
        country_info_on_server=$(geoiplookup "$nipe_ip_on_server" | awk -F ": " '{print $2}')
        echo -e "${GREEN}Spoofed Server Geolocation: $country_info_on_server${NC}"
    else
        echo -e "${RED}Error with country geolocation!${NC}"
    fi

    sleep 2
}

function target_info {
    # Target variable
    target=$1
    # Print target
    echo -e "${YELLOW}-----> Your target: $target <-----${NC}"
    echo "${GREEN}whois & nmap in process...${NC}"

    # Get the whois information of the target and store in a file
    if whois $target > whois_target_info.txt &> /dev/null; then
        echo -e "${GREEN}whois data ready${NC}"
    else
        echo -e "${RED}Error with whois!${NC}"
    fi

    # Scan the target using nmap and store the result in a file
    if sudo nmap -sS $target > nmap_target_info.txt &> /dev/null; then
        echo -e "${GREEN}nmap data ready${NC}"
    else
        echo -e "${RED}Error with nmap!${NC}"
    fi
}

# Run the functions on local machine
check_and_install_tools_on_local_machine
installation_nipe_on_local_machine
start_nipe_on_local_machine

# Variable of array of functions to run on the remote server
REMOTE_FUNCTIONS=(
    check_and_install_tools_on_server
    installation_nipe_on_server
    start_nipe_on_server
    target_info
)

# Loop with array variable to run the functions on the remote server
for func in "${REMOTE_FUNCTIONS[@]}"; do
        ssh -p "$SSH_PORT" "$SSH_USER"@"$SERVER_IP" "$(declare -f "$func");RED='$RED';GREEN='$GREEN';YELLOW='$YELLOW';NC='$NC'; $func \"$target\""
done

# Transfer the whois information file from the server to local machine
if scp -P "$SSH_PORT" "$SSH_USER"@"$SERVER_IP":~/whois_target_info.txt ./nr_log/ > /dev/null 2>&1; then
    echo -e "${GREEN} whois data transferred to nr_log on local machine ${NC}"
else
    echo -e "${RED} Error with transferring whois data ${NC}"
fi

# Transfer the nmap scan result file from the server to local machine
if scp -P "$SSH_PORT" "$SSH_USER"@"$SERVER_IP":~/nmap_target_info.txt ./nr_log/ > /dev/null 2>&1; then
    echo -e "${GREEN} nmap data transferred to nr_log on local machine ${NC}"
else
    echo -e "${RED} Error with transferring nmap data ${NC}"
fi

# Delete the whois data file from the server
if ssh -p "$SSH_PORT" "$SSH_USER"@"$SERVER_IP" "rm ~/whois_target_info.txt" > /dev/null 2>&1; then
    echo -e "${GREEN} whois data deleted from server ${NC}"
else
    echo -e "${RED} Error with deleting whois data file from server ${NC}"
fi

# Delete the nmap data file from the server
if ssh -p "$SSH_PORT" "$SSH_USER"@"$SERVER_IP" "rm ~/nmap_target_info.txt" > /dev/null 2>&1; then
    echo -e "${GREEN} nmap data deleted from server ${NC}"
else
    echo -e "${RED} Error with deleting nmap data file from server ${NC}"
fi
