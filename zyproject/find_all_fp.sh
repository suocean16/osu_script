#!/usr/bin/bash
base=`pwd`
tmp_folder=${base}/zytmp
top=${base}
gethttp_cmd=${base}/zytools/get_only_http_from_xml.sh
findfp_cmd=${base}/zytools/v2find_fp.sh

find ${top}  -type d -name "Windows"  -or  -name "usr" | sort | xargs dirname > ${tmp_folder}/unsupp_file_list.txt
#find ${top} -name "usr" -type d | sort | xargs dirname > ${tmp_folder}/unsupp_file_list.txt
find ${top} -name "*.zip"  | sort | xargs dirname > ${tmp_folder}/zip_file_list.txt

diff ${tmp_folder}/unsupp_file_list.txt ${tmp_folder}/zip_file_list.txt | fgrep ${base} |  cut -d' '  -f2 > ${tmp_folder}/todo_zip.txt

echo "OOO: these support file need to be deal with:"
cat  ${tmp_folder}/todo_zip.txt

filter_attack_ip()
{
    alert_folder=$1
    attack_folder=$2
    script_folder=$3

    ${base}/zytools/v4fa_alert_format_filter.sh  ${alert_folder} ${attack_folder} ${script_folder} 
    
}

# rename Windows folder to Linux usr/local...
deal_windows()
{
    win_supp_folder="$1/Windows"
    echo "OOO:check windows"
    if [ ! -d "${win_supp_folder}" ]; then
         echo "OOO:It is not Windows, do not rename folder"
         return 0
    fi
    echo "OOO:It is windows, we rename folders"
    mkdir -p  ${supp_folder}/usr/local    
    mv ${supp_folder}/Program\ Files\ \(x86\)/zyWAF ${supp_folder}/usr/local/waf
    mv ${supp_folder}/Windows/TEMP ${supp_folder}/tmp
    rm ${supp_folder}/Windows -rf
    rm ${supp_folder}/Program\ Files\ \(x86\) -rf  
}

do_work()
{
    supp_folder=$1
    supp_work=${supp_folder}/supp_work
    af_list=${supp_work}/alert_file.txt
    attack_folder=${supp_folder}/attack_folder/
    logs=${supp_folder}/usr/local/waf/logs/

    mkdir ${supp_work}
    mkdir ${attack_folder}
    cd ${supp_folder}
    unzip *.zip

    deal_windows ${supp_folder}

    filter_attack_ip ${logs} ${attack_folder} ${attack_folder}


#    find  ${logs}  -name "*alert*" > ${af_list}
    find  ${attack_folder}  -name "filted_alert.txt" > ${af_list}
    
    while read line
    do
        # it is alert file
        alert_file=$line

        # here create only http url file
        onlyhttp=${alert_file//./_}
        onlyhttp_out="${onlyhttp}_only_http.txt"
        ${gethttp_cmd} ${alert_file} "${onlyhttp_out}" 

        # here do string replace for domain
        sed -i 's/http:\/\/xsh_gxun/http:\/\/xsh.gxun.edu.cn/g' "${onlyhttp_out}" 

        # here check false-positive    
        #${findfp_cmd} ${onlyhttp_out} &
    done  < ${af_list}
    #OOOOOOOOOOo
    exit
}


while read line   
do   
    echo -e  "OOO_Start:${line} \n"   
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
