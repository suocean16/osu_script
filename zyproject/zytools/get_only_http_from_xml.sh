#!/usr/bin/bash
file=$1
tmp1=/tmp/alert_http.tmp
tmp2=/tmp/alert_http_2.tmp
out=${file}_only_http.txt
[ $2"" == "" ] || out=${2}

[ $1"" == "" ] && echo -e "Usage :\n\t./get_only_http.sh alert_file [output_file]" && exit

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

/usr/bin/file ${file} 2>/dev/null | fgrep -i sql  && type="sql"
/usr/bin/file ${file} 2>/dev/null | fgrep -i xml  && type="xml"

if [ "x$type" == "xsql" ]; then 
    zy_sql
else
    zy_xml
fi

sort -u ${tmp1} > ${tmp2}
echo ${out}
zy_sortbylen ${tmp2} > ${out}
