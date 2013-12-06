#! /bin/sh


env=$1
grp=""
dir=`pwd`

has_static=0
has_dynamic=0
has_html=0

rets=`./git-pull.sh ${env}`
for line in ${rets}
do
	if [[$line == *js || $line == *css ]];then
		has_static=1
	fi

	if [[ $line == *php || $line == *txt || $line == *html ]];then
		has_dynamic=1
	fi

	if [[ $line == *html ]];then
		has_html=1
	fi
done
