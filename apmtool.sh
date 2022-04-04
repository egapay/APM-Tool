#!/bin/bash

spawn () {
	./APM$1 $2 &
}

cleanup () {
	killifstat=$( pidof ifstat )
	kill $killifstat
	echo 'Stopping APM...'
	for (( i = 1; i < APMcount; i++ ))
	do
		killid=$( pidof APM$i )
		kill $killid
		echo 'Killed APM'$1': ID:'$killid
	done
}
collect_process ()
{
		
	APM1ps=$(ps aux | egrep APM1 | head -1 | awk '{print $3, $4}' | sed 's/ /,/g')
	APM2ps=$(ps aux | egrep APM2 | head -1 | awk '{print $3, $4}' | sed 's/ /,/g')
	APM3ps=$(ps aux | egrep APM3 | head -1 | awk '{print $3, $4}' | sed 's/ /,/g')
	APM4ps=$(ps aux | egrep APM4 | head -1 | awk '{print $3, $4}' | sed 's/ /,/g')
	APM5ps=$(ps aux | egrep APM5 | head -1 | awk '{print $3, $4}' | sed 's/ /,/g')
	APM6ps=$(ps aux | egrep APM6 | head -1 | awk '{print $3, $4}' | sed 's/ /,/g')	

	echo $SECONDS,$APM1ps >> APM1_metrics.csv
	echo $SECONDS,$APM2ps >> APM2_metrics.csv
	echo $SECONDS,$APM3ps >> APM3_metrics.csv
	echo $SECONDS,$APM4ps >> APM4_metrics.csv
	echo $SECONDS,$APM5ps >> APM5_metrics.csv
	echo $SECONDS,$APM6ps >> APM6_metrics.csv
	
}

collect_system () {
	ifstat_info=$(ifstat ens33 | head -4 | tail -1 | awk '{print $7, $9}' | sed 's/ /,/g' | sed 's/K//g')
	iostat_info=$(iostat | awk '/sda/ {print $4 fflush(stdout)}')
	df_info=$(df -hm / | awk '{print $4}' | tail -1)
	echo $SECONDS,$ifstat_info,$iostat_info,$df_info >> system_metrics.csv
}

set_ifstat () {
	ifstat -d 1
}

trap cleanup EXIT

ipaddress=$1
APMcount=1

if [ $# -gt 0 ]
then
	while true
	do
		for (( i = 1; i < 7; i++ ))
		do
			echo '--- START APM #'$i ' ---'
			spawn $i $ipaddress &
			(( APMcount++ ))
			sleep 1
			if [ $i -eq 6 ]
			then
				set_ifstat
				while true
				do
					sleep 5
					collect_process
					echo 'collect_process running...'
					collect_system
					echo 'collect_system running...'
				done
			fi
		done

	done
else
	echo "You must provide an IP address!"
fi






