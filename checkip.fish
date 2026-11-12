#!/usr/bin/env fish

# valid_ip <host> <ip> <dns_server>
# succeeds if <host> resolves to <ip> when queried against <dns_server>
function valid_ip
    set -l name $argv[1]
    set -l ip $argv[2]
    set -l server $argv[3]

    set -l resolved (nslookup $name $server 2>/dev/null | awk '/^Address/ && !/#/ {print $2}')
    contains -- $ip $resolved
end

# DNS server: first script argument, defaults to 8.8.8.8
set -l dns 8.8.8.8
set -q argv[1]; and set dns $argv[1]

cat /etc/hosts | while read -l line
    set line (string replace -r '#.*' '' -- $line) #strip comments
    set fields (string match -ra '\S+' -- $line) #split on whitespace
    test (count $fields) -ge 2; or continue

    set ip $fields[1]
    for name in $fields[2..-1]
        if not valid_ip $name $ip $dns
            echo "Bogus IP for $name in /etc/hosts!"
        end
    end
end
