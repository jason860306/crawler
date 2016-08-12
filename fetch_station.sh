#!/bin/sh

# 查站名代号
station_code=($(curl --insecure "https://kyfw.12306.cn/otn/resources/js/framework/station_name.js?station_version=1.8395" | grep -oE "@[^@]+" | gawk '{split($0,z,"|");print z[2]","z[3]}'))
echo "station count=" ${#station_code[@]}

# 读取用户发站站名
read -p "发站: "
from_station=$REPLY

declare -a from_station_arr
for station in "${station_code[@]}"
do
	echo "\"$station\"" | grep -q $from_station
	if [ $? -eq 0 ]; then
		from_station_arr[${#from_station_arr[@]}]="$station"
	fi
done
if [ ${#from_station_arr[@]} -eq 0 ]; then
	echo "没有你要出发的站台"
fi
for ((i=0;i<${#from_station_arr[@]};++i))
do
	echo "$i: ${from_station_arr[$i]}"
done
read -p "你可以从以上站台出发，请输入站台代号: "
from_station_code=$(echo "\"${from_station_arr[$REPLY]}\"" | awk -F, '{ print $2 }')
echo "station_code=$from_station_code"

# 读取用户到站站名
read -p "到站: "
to_station=$REPLY

declare -a to_station_arr
for station in "${station_code[@]}"
do
	echo "\"$station\"" | grep -q $to_station
	if [ $? -eq 0 ]; then
		to_station_arr[${#to_station_arr[@]}]="$station"
	fi
done
if [ ${#to_station_arr[@]} -eq 0 ]; then
	echo "没有你要到达的站台"
fi
for ((i=0;i<${#to_station_arr[@]};++i))
do
	echo "$i: ${to_station_arr[$i]}"
done
read -p "你可以从以上站台出发，请输入站台代号: "
to_station_code=$(echo "\"${to_station_arr[$REPLY]}\"" | awk -F, '{ print $2 }')
echo "station_code=$to_station_code"

# 读取用户出发日期
read -p "日期 (xxxx-xx-xx, empty for today): "
query_date=$REPLY
if [ -z "$query_date" ]
	query_date=$(date +%Y-%m-%d)
echo "出发日期: $query_date"

# 成人票 or 学生票
read -p "0. 成人票 1. 学生票"
purpose_arr=("ADULT" "0X00")
purpose=${purpose_arr[$REPLY]}

fetch_url="https://kyfw.12306.cn/otn/lcxxcx/query?purpose_codes=\"$purpose\"&queryDate=\"$query_data\"&from_station=\"$from_station_code\"&to_station=\"$to_station_code\""
echo $fetch_url

# 爬站站车票信息
curl --insecure --user-agent "Mozilla/5.0 (X11; Linux i686; rv:38.0) Gecko/20100101 Firefox/38.0" $fetch_url
