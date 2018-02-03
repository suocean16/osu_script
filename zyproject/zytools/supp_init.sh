filepath=$1
echo "will init ${filepath}"
sub="customer"
if [[ ${filepath} =~ "customer" ]] ;then
        rm  ${filepath}/tmp/ -rf
        rm  ${filepath}/usr/ -rf
        rm  ${filepath}/supp_work -rf
        rm  ${filepath}/*.txt -rf
        ls  ${filepath}/ 

fi
