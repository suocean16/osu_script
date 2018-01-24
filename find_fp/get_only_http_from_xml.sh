#!/usr/bin/bash
type=$1
file=$2
tmp1=/tmp/alert_http.tmp
tmp2=/tmp/alert_http_2.tmp
out=./${file}_out.txt

[ $2"" == "" ] && echo -e "Usage :\n\t./get_only_http.sh [xml|sql] alert_file" && exit

zy_xml()
{
        egrep "<alert-msg>[&apos;']+http://" ${file} > ${tmp1}
        sed -i 's/\t<alert-msg>&apos;http/http/' ${tmp1}
        sed -i 's/&apos; not allowed<\/alert-msg>//' ${tmp1}
}

zy_sql()
{
    sqlite3 -list ${file} 'select msg from alerts;' > ${tmp1}
    egrep "^'http://" ${tmp1} > ${tmp2}
    sed -i "s/' not allowed//" ${tmp2}
    sed -i "s/'//" ${tmp2}
    mv ${tmp2} ${tmp1}
}

zy_sortbylen()
{
    [ "x" == "x$1" ] && echo "Usage: zy_sortbylen file" && return 1
    awk ' { print length, $0}'  $1  | sort -n | sed 's/.* //'
}

[ $type == "xml" ] && zy_xml
[ $type == "sql" ] && zy_sql
sort -u ${tmp1} > ${tmp2}
zy_sortbylen ${tmp2} > ${out}

