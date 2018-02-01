#!/usr/bin/bash
#res_path="`pwd`/attack_result"
res_path="`pwd`"
target_folder="./"

# find_attack option alert-msg.*ffff  escape
find_attack()
{
	option=$1
	need=$2
	escape=$3
	title=$4
	outfile=${res_path}/${5}

        find ${target_folder} -name "alert*" \
                | xargs egrep  -h ${option} "${need}"\
                | egrep -v "${escape}"  > ${outfile}

	if [ -s ${outfile} ] ; then
		echo "</table><br/>" >> ${outfile}
		line=`fgrep -r "Alert Message" ${outfile} | wc | awk '{printf("<h4>Attack %s times</h4>", $1)}'`
		sed  -i "1i $line" ${outfile}
		echo "find attack to ${title} --- ${line}"
	else
		rm ${outfile}
		echo "no attack to ${title}"
	fi
}

find_attack "-A 1 -B 1" "alert-msg.*FCKeditor" "<none-need-escape>" "FCKeditor Attack" "fckeditor.html"
find_attack "-A 1 -B 1" "alert-msg.*((org.apache.struts2)|(HttpServlet))" "<none-need-escape>" "Java Struts2 Attack" "java_struts2.html"
find_attack "-A 1 -B 1" "alert-msg.*etc.+passwd" "<none-need-escape>" "Linux Password Attack" "etc_passwd.html"
find_attack "-A 1 -B 1" "alert-msg.*(\.asp\?|\.aspx\?)" "<none-need-escape>" "ASP Detect Attack" "asp_detect.html"
find_attack "-B 4" "<request>PUT" "<remote-name>" "File upload Attack" "http_put.html"
find_attack "-A 1 -B 1" "alert-msg.*www.agri-check.com" "<none-need-escape>" "Gambling Web Site" "gambling_agri.html"
find_attack "-A 1 -B 1" "alert-msg.*download\.php\?open=" "<none-need-escape>" "PHP code injection" "php_code.html"
find_attack "-A 1 -B 1" "alert-msg.*(phpinfo|php\?)" "<none-need-escape>" "PHP detect" "php_detect.html"
find_attack "-A 1 -B 1" "alert-msg.*method=screen.get.*timestamp=.*mode=2.*screenid" "<none-need-escape>" "Zabbix system detect" "zabbix.html"
find_attack "-B 4" "<request>.*/.*((\.rar)|(\.zip)|(\.tar)|(tar\.gz)|(\.gz)) HTTP" "<remote-name>" "Get WebServer Left file" "fetch_compression.html"
find_attack "-A 1 -B 1" "alert-msg.*((\.gitignore)|(\.git))" "<none-need-escape>" "Get left GIT file" "detect_git.html"
#find_attack "-A 1 -B 1" "alert-msg.*select.*from" "<none-need-escape>" "SQL Injection" "SQL_injection.html"
find_attack "-i -A 1 -B 1" "alert-msg.*select[%* ]" "<none-need-escape>" "SQL Injection" "SQL_injection.html"
find_attack "-A 1 -B 1" "alert-msg.*((WindowsPowerShell)|(cmd\.exe))" "<none-need-escape>" "Windows system attack" "win_attack.html"
find_attack "-B 4" "<request>(OPTIONS)|(PROPFIND)|(CONNECT)" "<remote-name>" "HTTP Method Attack" "http_method_attack.html"
