#!/usr/bin/env fish
cat /etc/hosts | while read -l line
  set line (string replace -r '#.*' '' -- $line) #strip comments
  set fields (string match -ra '\S+' -- $line) #split on whitespace
  test (count $fields) -ge 2; or continue

  set ip $fields[1]
  for name in $fields[2..-1]
    set resolved (nslookup $name 2>/dev/null | awk '/^Address/ && !/#/ {print $2}')
    if not contains -- $ip $resolved
      echo "Bogus IP for $name in /etc/hosts!"
    end
  end
end
