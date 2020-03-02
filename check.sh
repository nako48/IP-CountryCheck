#!/bin/bash
callback(){
	requests=$(curl -s "https://4stars.wtf/country.php?ip=$1" --compressed -L)
	countryCode=$(echo $requests | grep -Po '(?<=country_code":)[^},]*' | tr -d '[]"' | sed 's/\(<[^>]*>\|<\/>\|{1|}\)//g')
	countryName=$(echo $requests | grep -Po '(?<=country_name":)[^},]*' | tr -d '[]"' | sed 's/\(<[^>]*>\|<\/>\|{1|}\)//g')
	resultjson=$(echo $requests | grep -Po '(?<=error":)[^},]*' | tr -d '[]"' | sed 's/\(<[^>]*>\|<\/>\|{1|}\)//g')
	if [[ $resultjson =~ "0" ]]; then
		printf "$1 => [$countryName]\n"
		echo "$1">>result/$countryCode.txt
	elif [[ $resultjson =~ "1" ]]; then
		printf "$1\n"
		echo "$1">>result/OTHER.txt
	else
		printf "DEAD => $1\n"
		echo "$1">>result/DEAD.txt
	fi
}
if [[ ! -d result ]]; then
	mkdir result
fi
cat << "EOF"
                      .".
                     /  |
                    /  /
                   / ,"
       .-------.--- /
      "._ __.-/ o. o\
         "   (    Y  )
              )     /
             /     (
            /       Y
        .-"         |
       /  _     \    \
      /    `. ". ) /' )
     Y       )( / /(,/
    ,|      /     )
   ( |     /     /
    " \_  (__   (__        [NakoCoders - Checker Country By IP]
        "-._,)--._,)
EOF
echo ""
read -p "Select Your List: " listo;

multithread_limit=7
IFS=$'\r\n' GLOBIGNORE='*' command eval 'list=($(cat $listo))'
for (( i = 0; i < "${#list[@]}"; i++ )); 
do
	target="${list[$i]}"
	((cthread=cthread%multithread_limit)); ((cthread++==0)) && wait
	callback ${target} &
done
wait
