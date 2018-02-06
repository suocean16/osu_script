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
        alert_file=$line
        # here create only http url file
        onlyhttp=${alert_file//./_}
        onlyhttp_out="${onlyhttp}.txt"
        ${gethttp_cmd} ${alert_file} "${onlyhttp_out}" 

        # here do string replace for domain
        sed -i 's/http:\/\/xsh_gxun/http:\/\/xsh.gxun.edu.cn/g' "${onlyhttp_out}" 

        # here check false-positive    
        ${findfp_cmd} ${onlyhttp_out} &
    done  < ${af_list}
}


while read line   
do   
    echo -e  "${line} \n"   
    do_work ${line}
done < ${tmp_folder}/todo_zip.txt

#####  above code find out http list  create files with this kind of name  _only_http.txt
#####  below code will find false-positive with this kind of name _only_fp.txt
tmp () 
{
findfp_cmd="${top}/zytools/v2find_fp.sh"

find ${top} -name "*_only_http.txt"  | sort  > ${tmp_folder}/oh_list.txt
find ${top} -name "*_only_fp.txt"    | sort  > ${tmp_folder}/ofp_list.txt
diff ${tmp_folder}/oh_list.txt ${tmp_folder}/ofp_list.txt | fgrep ${base} |  cut -d' '  -f2 > ${tmp_folder}/todo_findfp.txt

while read line
do
    subfolder=dirname ${lineo} 
   
    cd ${subfolder}
    ${findfp_cmd} ${line} &

done < ${tmp_folder}/todo_findfp.txt


}
