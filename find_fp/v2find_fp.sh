#!/bin/bash
filename="$1"
false_positive="fp.txt"
alert_right="ar.txt"

echo "new " > $false_positive
echo "new " > $alert_right
while read line
do
#    str="/usr/bin/wget --timeout=3  --spider --level=1 --no-verbose  --no-cache  $line "
    str="/usr/bin/curl --connect-timeout 6 -s -w %{http_code}  -o /dev/null $line "
    echo $str
    ret=`$str`
    if [ "$ret"X != "200"X ]; then
        echo $line >> ${alert_right}
        echo $ret
        echo "right alert: $line"
    else
        echo $line >> ${false_positive}
        echo $ret
        echo "found false-positive: $line"
    fi

done <  $filename
