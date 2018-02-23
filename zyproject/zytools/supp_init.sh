filepath=$1
usage="Usage:\n\t\t$0 path_to_date\n\t\teg: $0 customers/dxqh/2018_2_12/"
[ "x${filepath}" == "x" ] && echo -e "$usage" && exit

echo "will init ${filepath}"
sub="customer"
if [[ ${filepath} =~ "customer" ]] ;then
        rm  ${filepath}/tmp/ -rf
        rm  ${filepath}/usr/ -rf
        rm  ${filepath}/supp_work -rf
        rm  ${filepath}/*.txt -rf
        rm  ${filepath}/attack_folder -rf
        rm  ${filepath}/attack_folder -rf
        rm  ${filepath}/attack_folder -rf
        rm  ${filepath}/Program* -rf
        rm  ${filepath}/Windows -rf
        ls  ${filepath}/ 

fi
