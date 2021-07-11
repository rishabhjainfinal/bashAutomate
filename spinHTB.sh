#!/bin/bash
echo "Running file $0";

# command example bash_script.sh {ip of the server | domain name  }

# check ip is valid
valid_ip(){
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# this function will make folder and subfolders if not exist
createFolderTree(){
    if [ ! -e "$1" ]; 
    then
        echo "at ==> $( pwd ) creating folder ==> '$1' "
        mkdir "$1";
        cd "$1";
        createFolder "nmap";
    else
        echo "$1 folder already exist";
        cd "$1";
        createFolder "nmap";
    fi
}

# create folder if not exits 
createFolder(){
    name="$1"
    if [ ! -e "$name" ]; then
        mkdir "$name";
        echo "at ==> $( pwd ) creating folder '$name'";
    fi
}

# this will start some common scans and save the results in seperate files 
startScans(){
    # start a nmap initial fast
    sudo nmap -sC -sV $ip -oA nmap/initial -v -F
    
    # start searchsploit from the nmap results 
    searchsploit --nmap -t nmap/initial.xml > searchsploitInitialResults &

    # start gobuster  
    echo "Running gobuster and saving results "
    gobuster dir -u http://$ip/ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt | tee gobusterResult

    # start nikito
    echo "Running nikto and saving results "
    nikto -host $ip | tee niktoResults
    


    # list all the open ports after completion of nmap comma seperated
    cat nmap/initial.xml | grep -E portid=\"[0-9]*\" -o | cut -d "=" -f 2 | grep -E "[0-9]*" -o | awk -vORS=, '{ print $0 }' | sed 's/,$/\n/'
    # list all open ports with services
    cat nmap/initial.xml.nmap | grep open

    # start a nmap all ports 
    sudo nmap -sC -sV $ip -p- -oA nmap/initial -v
    
    
    # then use that ports to run nmap cve scripts and get cves and sort and unique them 
}



# in a variable then create the folder
if valid_ip "$1" ; then 
    ip="$1"
    createFolderTree "$ip"
    echo "Running whois "
    whois $ip > 'whoisResutls'
    # all the required scans and save then in their specific results files 
    startScans
else
    echo "    No valid ip found
    run again with ip "
fi



# sub domains and 
# sub domains and 
# sub domains and 
