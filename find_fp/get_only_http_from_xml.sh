#!/usr/bin/bash
file=$1


zy_sortbylen()
{
    [ "x" == "x$1" ] && echo "Usage: zy_sortbylen file" && return 1
    awk ' { print length, $0}'  $1  | sort -n | sed 's/.* //'
}

egrep "<alert-msg>[&apos;']+http://" alert.xml > /tmp/alert_http.tmp
sed -i 's/\t<alert-msg>&apos;http/http/' /tmp/alert_http.tmp
sed -i 's/&apos; not allowed<\/alert-msg>//' /tmp/alert_http.tmp

sort -u /tmp/alert_http.tmp > /tmp/alert_http_2.tmp
zy_sortbylen /tmp/alert_http_2.tmp > ./only_${file}
