#!/usr/bin/bash
#res_path="`pwd`/attack_result"

[ "x$3" = "x" ] && echo -e "Usage:\n\t$0 alert_folder output_folder script_folder"  && exit 0

# result *.html is in here
res_path="`pwd`"

# alert.xml in in here
alert_folder="./"

[ $2 != "" ] && res_path=${2} && alert_folder=${1} && script_folder=${3}


# find_attack option alert-msg.*ffff  escape
find_attack()
{
	option=$1
	need=$2
	escape=$3
	title=$4
	outfile=${res_path}/${5}

        find ${alert_folder} -name "alert*" \
                | xargs egrep  -h ${option} "${need}"\
                | egrep -v "${escape}"  > ${outfile}

	if [ -s ${outfile} ] ; then
		line=`fgrep -r "<alert-msg>" ${outfile} | wc | awk '{printf("<h4>Attack %s times</h4>", $1)}'`
		sed  -i "1i $line" ${outfile}
		echo "find attack to ${title} --- ${line}"
	else
		rm ${outfile}
		echo "no attack to ${title}"
	fi
}


#find_attack "-A 1 -B 1" "alert-msg.*FCKeditor" "<none-need-escape>" "FCKeditor Attack" "fckeditor.html"
find_attack "-A 1 -B 1" "alert-msg.*((org.apache.struts2)|(HttpServlet))" "<none-need-escape>" "Java Struts2 Attack" "java_struts2.html"
find_attack "-A 1 -B 1" "alert-msg.*etc.+passwd" "<none-need-escape>" "Linux Password Attack" "etc_passwd.html"
#find_attack "-A 1 -B 1" "alert-msg.*(\.asp\?|\.aspx\?)" "<none-need-escape>" "ASP Detect Attack" "asp_detect.html"
find_attack "-B 4" "<request>PUT" "<remote-name>" "File upload Attack" "http_put.html"
find_attack "-A 1 -B 1" "alert-msg.*www.agri-check.com" "<none-need-escape>" "Gambling Web Site" "gambling_agri.html"
find_attack "-A 1 -B 1" "alert-msg.*download\.php\?open=" "<none-need-escape>" "PHP code injection" "php_code.html"
find_attack "-A 1 -B 1" "alert-msg.*(phpinfo|php\?)" "<none-need-escape>" "PHP detect" "php_detect.html"
find_attack "-A 1 -B 1" "alert-msg.*method=screen.get.*timestamp=.*mode=2.*screenid" "<none-need-escape>" "Zabbix system detect" "zabbix.html"
find_attack "-B 4" "<request>.*/.*((\.rar)|(\.zip)|(\.tar)|(tar\.gz)|(\.gz)) HTTP" "<remote-name>" "Get WebServer Left file" "fetch_compression.html"
find_attack "-A 1 -B 1" "alert-msg.*((\.gitignore)|(\.git))" "<none-need-escape>" "Get left GIT file" "detect_git.html"
find_attack "-i -A 1 -B 1" "alert-msg.*select[%* ]" "<none-need-escape>" "SQL Injection" "SQL_injection.html"
find_attack "-A 1 -B 1" "alert-msg.*((WindowsPowerShell)|(cmd\.exe))" "<none-need-escape>" "Windows system attack" "win_attack.html"
find_attack "-B 4" "<request>(OPTIONS)|(PROPFIND)|(CONNECT)" "<remote-name>" "HTTP Method Attack" "http_method_attack.html"

# this line do not filte IP address take place times.
#awk '/<ip>/{gsub("\t","");printf("%s|\n",$0)}' ${res_path}*.html | sort -u | awk 'BEGIN{printf "egrep -v \""};{printf $0}END{printf("<ip><ipf><ip><ip><ip>\"  ")}'  > ${script_folder}/except_ip.sh

# we filter the IP address:
# when a IP address take place more than 4 times , we assume it is a attack IP address.
awk '/<ip>/{gsub("\t","");printf("%s|\n",$0)}' ${res_path}*.html |  uniq -c | sort -n | egrep -v " [0-4] " | awk '{print $2}' | awk 'BEGIN{printf "egrep -h -v \""};{printf $0}END{printf("<ip><ipf><ip><ip><ip>\"  ")}'  > ${script_folder}/except_ip.sh

echo -n "${alert_folder}/* " >> ${script_folder}/except_ip.sh
echo -n " | fgrep -A 1   -B 1 \"<ip>\" "  >> ${script_folder}/except_ip.sh
chmod a+x ${script_folder}/except_ip.sh
${script_folder}/except_ip.sh > ${script_folder}/filted_alert.txt



