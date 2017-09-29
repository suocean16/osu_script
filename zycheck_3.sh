#!/bin/bash
domain_name="$1"
email_box="$2"

while true
do
    str="/usr/bin/curl --connect-timeout 3 -s -w %{http_code}  -o /dev/null ${domain_name} "
    echo "start checking ${domain_name}"
    ret=`$str`
    echo "return HTTP code ${ret}"
    
    if [ "$ret"X != "200"X ] 
    then
	echo "Your WebSite work bad, send email to you"
        echo "Your website work not right" |  /usr/bin/mail -s "Please check ${domain_name}, seems not work"  ${email_box}
	echo "finished send email"
	let waiting=60*1
	sleep ${waiting}
    else
	echo "Your WebSite work Well"
    fi
    sleep 5
done


#to test this 
#   this command will block traffic
#  /sbin/iptables -I OUTPUT -p tcp --dport 80 -j DROP
#   this command will allowed traffic
#  /sbin/iptables -I OUTPUT -p tcp --dport 80 -j ACCEPT
