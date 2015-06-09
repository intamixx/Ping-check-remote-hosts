#!/bin/bash

# Checks hosts on ipv4 and ipv6 to report any remote hosts down

IFS=!

# *** Edit ipv4 and ipv6 remote hosts here ***
ping4_hosts=( "107.162.17.37" "107.162.17.41" "107.162.17.45" "107.162.17.49" )
ping6_hosts=( "2604:e180:100:2:1:1:7:1" "2604:e180:100:2:1:1:8:1" "2604:e180:100:2:2:1:7:1" "2604:e180:100:2:2:1:8:1" )

programs=( "echo" "hostname" "logger" "ps" "ping" "ping6" "id" "grep" "pidof" "mktemp" "rm" "awk" "kill" "pkill" "dig" )
ipv4_hostdown=( )
ipv6_hostdown=( )
debug=0
hostname=`hostname | cut -d. -f1`
# we send notification emails here
ADDR="abc@domain.com"
user="intamixx"

function usage()
{
        cat <<END
$0 (C) Copyright 2014 Intamixx Remote Host Checker

Usage: $0 [options]

-s Summary Mode
-d Debug Mode

END
}

if [[ -z "$1" ]]; then
        # Run in summary mode by default
        debug=0
fi

trap '[[ $debug -eq 1 ]] && echo -e "\e[0mExiting $$...";exit' SIGINT SIGTERM EXIT

while getopts "sd" OPT; do
        case "$OPT" in
        s)
                debug=0
                ;;
        d)
                debug=1
                ;;
        h)
                usage
                exit 0
                ;;
        ?)
                usage
                exit 1
        esac
done
shift $((OPTIND - 1))

# Check if required progs are on system
        for prog in "${programs[@]}"
                do
                        if type "$prog" >/dev/null 2>&1; then
                                [[ $debug -eq 1 ]] && echo -n "";
                        else
                                [[ $debug -eq 1 ]] && echo "Executable $prog missing"; exit 1; fi
                done

[[ $debug -eq 1 ]] && echo "----------------------------------" && echo " $hostname - GRE Tunnel Checker       " && echo "----------------------------------"

i=0
for ip in "${ping4_hosts[@]}"; do
        [[ $debug -eq 1 ]] && echo -n "Checking $ip ... "
    ping -c 4 -t 20 ${ip} > /dev/null 2> /dev/null
    if [ $? -eq 0 ]; then
        [[ $debug -eq 1 ]] && echo -e -n "is up\n"
    else
        [[ $debug -eq 1 ]] && echo -e -n "is down\n"
        ipv4_hostdown[i]="${ip}"
    fi
        ((i++))
done

if [[ ${ipv4_hostdown[@]} ]]; then
        echo -n "1 $hostname-v4GREtun - WARNING - Tunnel: "
                for t in "${ipv4_hostdown[@]}"
                do
                        echo -n "$t "
                done
        echo
else
        echo "0 $hostname-v4GREtun - OK - Tunnel"
fi

i=0
for ip in "${ping6_hosts[@]}"; do
        [[ $debug -eq 1 ]] && echo -n "Checking $ip ... "
    ping6 -c 4 -t 20 ${ip} > /dev/null 2> /dev/null
    if [ $? -eq 0 ]; then
        [[ $debug -eq 1 ]] && echo -n -e "is up\n"
    else
        [[ $debug -eq 1 ]] && echo -n -e "is down\n"
        ipv6_hostdown[i]="${ip}"
    fi
        ((i++))
done

if [[ ${ipv6_hostdown[@]} ]]; then
        echo -n "1 $hostname-v6GREtun - WARNING - Tunnel: "
                for t in "${ipv6_hostdown[@]}"
                do
                        echo -n "$t "
                done
        echo
else
        echo "0 $hostname-v6GREtun - OK - Tunnel"
fi
