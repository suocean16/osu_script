#!/usr/bin/bash
base=`pwd`
tmp_folder=${base}/zytmp
top=${base}
gethttp_cmd=${base}/zytools/get_only_http_from_xml.sh
findfp_cmd=${base}/zytools/v2find_fp.sh

find ${top} -name "usr" -type d | sort | xargs dirname > ${tmp_folder}/usr_file_list.txt
find ${top} -name "*.zip"  | sort | xargs dirname > ${tmp_folder}/zip_file_list.txt

diff ${tmp_folder}/usr_file_list.txt ${tmp_folder}/zip_file_list.txt | fgrep ${base} |  cut -d' '  -f2 > ${tmp_folder}/todo_zip.txt

# will enter  support folder
do_work()
{
    supp_folder=$1
    supp_work=${supp_folder}/supp_work
    af_list=${supp_work}/alert_file.txt
    logs=${supp_folder}/usr/local/waf/logs/

    mkdir ${supp_work}
    cd ${supp_folder}
    unzip *.zip
    find  ${logs}  -name "*alert*" > ${af_list}
    while read line
    do
         ${gethttp_cmd} ${line} 
    done  < ${af_list}
}


while read line   
do   
    echo -e  "${line} \n"   
    do_work ${line}
done < ${tmp_folder}/todo_zip.txt

#####  above code find out http list  create files with this kind of name  _only_http.txt
#####  below code will find false-positive with this kind of name _only_fp.txt

find_fp_cmd="${top}/zytools/v2find_fp.sh"

find ${top} -name "*_only_http.txt"  | sort  > ${tmp_folder}/oh_list.txt
find ${top} -name "*_only_fp.txt"    | sort  > ${tmp_folder}/ofp_list.txt
diff ${tmp_folder}/oh_list.txt ${tmp_folder}/ofp_list.txt | fgrep ${base} |  cut -d' '  -f2 > ${tmp_folder}/todo_findfp.txt

while read line
do
    subfolder=dirname ${lineo} 
   
    cd ${subfolder}
    ${find_fp_cmd} ${line} &

done < ${tmp_folder}/todo_findfp.txt



