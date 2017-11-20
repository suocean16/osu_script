#!/bin/bash

zy_sortbylen()
{
    [ "x" == "x$1" ] && echo "Usage: zy_sortbylen file" && return 1
    awk ' { print length, $0}'  $1  | sort -n | sed 's/.* //'
}

zy_createdb()
{
    if [ "s$1" == "s" ]; then 
        echo "Please input datebase name for example \"zy_createdb debang\""
        return 1
    fi 
    db="zy_$1"

    if [ $(zy_showdb | fgrep $db) ]; then
        echo "DataBasa $db is exsited (or similar), please change another database name"        
        return 1;
    fi 
    mysql -u root  -e "create database $db;"
    [ ! $? ] && echo "create database failed" && return 1
    
    mysql -u root  -e "use $db; CREATE TABLE \`alert_table\` (  \`date-time\` datetime DEFAULT NULL,  \`alert-msg\` longtext,  \`ip\` varchar(45) DEFAULT NULL, \`remote-name\` varchar(45) DEFAULT NULL,  \`request\` longtext,  \`action\` varchar(45) DEFAULT NULL,  \`request-URI\` longtext, \`method\` varchar(45) DEFAULT NULL,  \`status-code\` varchar(45) DEFAULT NULL,  \`reason\` varchar(45) DEFAULT NULL,  \`reason-code\`varchar(45) DEFAULT NULL,  \`content-type\` varchar(45) DEFAULT NULL,  \`user-agent\` varchar(45) DEFAULT NULL,  \`host\`varchar(45) DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1;"
    [ ! $? ] && echo "create alert_table failed" && return 1
    echo "create database and alert_table success"
}

confirm(){
        read -p "Continue (y/n)?" choice
        case "$choice" in 
          y|Y ) echo "yes";;
          n|N ) echo "no";;
          * ) echo "invalid";;
        esac
}

zy_drop() {
    if [ "s$1" == "s" ]; then 
        echo "zy_drop database [table]"
        return 1;
    fi 
    db="$1"
    table="${2}"

    if [ "x${table}" != "x" ]; then
        [ $(confirm) == "yes" ] && mysql -u root  -e "use $db; drop view if exists ${table}"
    else 
        [ $(confirm) == "yes" ] && mysql -u root  -e "drop database $db;"
    fi
}

zy_showdb()
{
    if [ "x$1" == "x" ]; then
	    mysql -u root  -e "show databases;" | fgrep "zy_" 
    else
	    mysql -u root  -e "show databases;" | fgrep "zy_"  | fgrep $1
    fi 
}

#this command will help to import all alert file into database
#ls alert.xml* |xargs -n1 |while read file ;do  zy_loaddb zy_zhongou $file ;done;

zy_loaddb()
{ 
    db="$1"
    alert_file="$2"
    
    [ "s${db}" == "s" -o "s${alert_file}" == "s" ] && echo -e "Usage:\t\n\tzy_loaddb database alert_file " && return 1
    [ ! $(zy_showdb  ${db}) ] &&  echo "Database not exsit" && return 1
    [ ! -f ${alert_file} ] &&  echo "Alert file is not exsit" && return 1

    mysql -u root  -e "use ${db}; LOAD XML LOCAL INFILE \"${alert_file}\" INTO TABLE alert_table ROWS IDENTIFIED BY '<alert>';"
    [ $? ] && echo -e "load database ${alert_file} success" 
}

# zy_exe zy_osu "select * from alert_table where \`alert-msg\` regexp \"localhost\";"
zy_exe() 
{
    db="$1"
    cmd="$2"
    mysql -u root  -e "use ${db}; ${cmd} " 
}

#zy_view_without zy_osu alert_table vv1  "download\/ewebEditFiles\/.*png"
zy_view_without() {
    db=$1
    base=$2
    new=$3
    filter=$4    


    [ "x${filter}" == "x" ] && echo "zy_view_without database_name, base, viewer, msg_filter to create new viewer" && return 1
    $(zy_drop ${db} ${new})

    cmd="create view ${new} as select * from ${base} where \`alert-msg\` not regexp \"${filter}\";"

    echo "${cmd}"
    mysql -u root  -e "use ${db}; ${cmd} "
}

zy_useage(){
    echo -e "Main commands:"
    echo -e "\tstep 1: zy_showdb:\tTo see if there is conflicate database name" 
    echo -e "\tstep 2: zy_createdb:\tTo creat a database and alert_table, it will add prefix zy_ to your name." 
    echo -e "\tstep 3: zy_loaddb:\tTo load one alert file into database."
    echo -e "\nOther commands:\n\tzy_exec:\t\tTo run any SQL command."
    echo -e "\tzy_view_without:\tTo create a new view without the folling regexp."
    echo -e "\tzy_drop:\tTo drop the database or view."
    
}
