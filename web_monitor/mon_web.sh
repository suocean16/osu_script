#!/usr/bin/bash
base="/root/zy/osu_script/web_monitor"
out="$base/zy/index.html"
break_base="${base}/zy/break"
log="${base}/zy/break/webmonitor.log"

pidof $0 && exit

zysendmail() 
{
	break_file=$1
	url=${2:7:18}
	action=$3

	if [ ${action} == "back" ]; then
		aliyun_temp="SMS_130910438"
	else
		aliyun_temp="SMS_123738824"
	fi
	echo "will send email for ${url} ${action}" >> ${log}
	#echo $PATH >> ${log}	
	/root/zy/osu_script/web_monitor/sms/dysms_python/api_demo/aliyun-python-sdk-dysmsapi/demo.py ${url} 15810130943 ${aliyun_temp}
	#echo $? >> ${log}

}

echo "<html><head></head><body><br/><h1> Web Health Monitor</h1><table style=\"border:1px solid \" width=\"1000\" border=\"1\" cellspacing=\"0\" cellpadding=\"20\" >" > $out
while read line
do   
    if [ `expr match "$line" ".*#"` -ne 0 ]; then
	continue
    fi
	
    #echo $line 
    url=`echo -e  $line  | awk '{print $2}' ` 
    title=`echo -e $line  | awk '{print $1}' ` 
    break_file=${break_base}/${title}

    str="/usr/bin/curl -m 12  --connect-timeout 6 -s -w %{http_code}  -o /dev/null $url "
    #echo $str
    ret=`$str`
    now=`date "+%Y-%m-%d %H:%M:%S"`
    echo "<tr><td>${now}</td><td>$url</td><td>" >> $out
    
    if [ "$ret"X != "200"X ]; then
        echo "not work" >> $out    
	echo "${now} This url  $url not work" >> ${break_file}
	breaktime=`fgrep ${url} ${break_file} | wc | awk '{print $1}'`
	if [[ ${breaktime} -eq 3 ]]; then
	    echo $(zysendmail ${break_file} ${url} "break")
	fi
	echo -e "URL not work : ${url}\n"
    else
        echo "work well" >> $out
	echo "URL work well : ${url}"
	if [ -e ${break_file} ]; then
		new_break_file=${break_file}_`date +%Y%m%d_%H%M%S`
		mv  ${break_file} ${new_break_file}
		breaktime=`fgrep ${url} ${new_break_file} | wc | awk '{print $1}'`
		if [[ ${breaktime} -eq 3 ]]; then
			echo $(zysendmail ${new_break_file} ${url} "back")
		fi		
	fi
    fi

    echo "</td></tr>" >> $out
done < ${base}/weblist.txt

echo "</table></html>" >> $out

