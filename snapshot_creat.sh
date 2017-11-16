#!/bin/bash

zy_createdb()
{
    if [ "s$1" == "s" ]; then 
        echo "Please input datebase name"
    fi 
    db="zy_$1"

    if [ $(zy_showdb | fgrep $db) ]; then
        echo "DataBasa $db is exsited, please change another name"        
        return 1;
    fi 
    mysql -u root  -e "create database $db;"
    
    mysql -u root  -e "use $db; CREATE TABLE \`alert_table\` (  \`date-time\` datetime DEFAULT NULL,  \`alert-msg\` longtext,  \`ip\` varchar(45) DEFAULT NULL, \`remote-name\` varchar(45) DEFAULT NULL,  \`request\` longtext,  \`action\` varchar(45) DEFAULT NULL,  \`request-URI\` longtext, \`method\` varchar(45) DEFAULT NULL,  \`status-code\` varchar(45) DEFAULT NULL,  \`reason\` varchar(45) DEFAULT NULL,  \`reason-code\`varchar(45) DEFAULT NULL,  \`content-type\` varchar(45) DEFAULT NULL,  \`user-agent\` varchar(45) DEFAULT NULL,  \`host\`varchar(45) DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1;"
    
}

zy_drop() {
    if [ "s$1" == "s" ]; then 
        echo "Please input datebase name"
    fi 
    db="$1"

    mysql -u root  -e "drop database $db;"
}

zy_showdb()
{
    if [ $1 == "" ]; then
	    mysql -u root  -e "show databases;" | fgrep "zy_" 
    else
	    mysql -u root  -e "show databases;" | fgrep "zy_"  | fgrep $1
    fi 
}

zy_loaddb()
{ 
    db="$1"
    alert_file="$2"
    
    [ "s${db}" == "s" ] && echo "Please input datebase name" && return 1
	
    [ "s${alert_file}" == "s" ] && echo "Please specify a alert xml file" && return 1
	echo "1"
   # [ $(zy_showdb  ${db}) ] ||  echo "Database not exsit" && return 1
    [ ! -f ${alert_file} ] &&  echo "Alert file is not exsit" && return 1

    echo "will start load database"
    mysql -u root  -e "use ${db}; LOAD XML LOCAL INFILE \"${alert_file}\" INTO TABLE alert_table ROWS IDENTIFIED BY '<alert>';"
}
