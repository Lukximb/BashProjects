#!/bin/bash
set +x
clear
readArray=()
writeArray=()
cpuArray=()
maxCurrRead=0
maxCurrWrite=0
maxCurrCpu=0
maxRead=0
maxWrite=0
maxCpu=0
firstRead=$(cat /proc/diskstats | grep 'sda ' | awk '{print $6}')
firstWrite=$(cat /proc/diskstats | grep 'sda ' | awk '{print $10}')
prevRead=$firstRead
prevWrite=$firstWrite
edgeIt=1
wColumn=1
rColumn=28
cColumn=55
line=12
rpoint=0
wPoint=0
rCurrentHight=0
wCurrentHight=0
cpuCurrentHight=0
cleanWArray=()
cleanRArray=()
cleanCArray=()
wSpeed=0
rSpeed=0
wMaxCurrSpeed=0
rMaxCurrSpeed=0
wMaxSpeed=0
rMaxSpeed=0
wPrefix="B"
rPrefix="B"
wMaxCurrPrefix="B"
rMaxCurrPrefix="B"
wMaxPrefix="B"
rMaxPrefix="B"

for x in `seq 0 20`; do cleanWArray+=(13); cleanRArray+=(13); cleanCArray+=(13); done
while [ $edgeIt -le 12 ]; do
        tput cup $edgeIt 0
        echo "|"
        edgeIt=$[edgeIt+1]
done
edgeIt=1
while [ $edgeIt -le 12 ]; do
	tput cup $edgeIt 27
	echo "|"
	edgeIt=$[edgeIt+1]
done
edgeIt=1
while [ $edgeIt -le 12 ]; do
        tput cup $edgeIt 54
        echo "|"
        edgeIt=$[edgeIt+1]
done
tput cup 13 0
echo -n "^^^^^^^^^^^^^^^^^^^^^^     ^^^^^^^^^^^^^^^^^^^^^^     ^^^^^^^^^^^^^^^^^^^^^^"
while true; do
	wPrefix="B"
	rPrefix="B"
	wMaxCurrPrefix="B"
	rMaxCurrPrefix="B"
	currentRead=$(cat /proc/diskstats | grep 'sda ' | awk '{print $6}')
	currentWrite=$(cat /proc/diskstats | grep 'sda ' | awk '{print $10}')
	currentCpu=$(cat /proc/loadavg | awk '{print $1}' | sed "s/\\.//" | sed "s/^0*//" )
	deltaRead=$((currentRead-prevRead))
	deltaWrite=$((currentWrite-prevWrite))
	prevRead=$currentRead
	prevWrite=$currentWrite
	maxCurrRead=$deltaRead
	maxCurrWrite=$deltaWrite
	maxCurrCpu=$currentCpu
	if [ ${#writeArray[@]} -lt 20 ]; then
		readArray+=($deltaRead)
		writeArray+=($deltaWrite)
		cpuArray+=($currentCpu)
	else
		k=1
		while [ $k -lt 20 ]; do
			writeArray[$((k-1))]=$[writeArray[$k]]
			readArray[$((k-1))]=$[readArray[$k]]
			cpuArray[$((k-1))]=$[cpuArray[$k]]
			k=$[k+1]
		done
		maxCurrRead=0
        	maxCurrWrite=0
		maxCurrCpu=0
		writeArray[19]=$deltaWrite
		readArray[19]=$deltaRead
		cpuArray[19]=$currentCpu
	fi
	s=0
	while [ $s -lt ${#readArray[@]} ]; do
		if (( maxCurrRead < readArray[$s] )); then
			maxCurrRead=$[readArray[$s]]
		fi
		s=$[s+1]
	done
	s=0
        while [ $s -lt ${#writeArray[@]} ]; do
		if (( maxCurrWrite < writeArray[$s] )); then
			maxCurrWrite=$[writeArray[$s]]
		fi
		s=$[s+1]
	done
	s=0
        while [ $s -lt ${#cpuArray[@]} ]; do
                if (( maxCurrCpu < cpuArray[$s] )); then
                        maxCurrCpu=$[cpuArray[$s]]
                fi
                s=$[s+1]
        done
	if (( maxRead < maxCurrRead )); then
                        maxRead=$maxCurrRead
        fi
	if (( maxWrite < maxCurrWrite )); then
                        maxWrite=$maxCurrWrite
        fi
	if (( maxCpu < maxCurrCpu )); then
                        maxCpu=$maxCurrCpu
        fi
	tmp=0
	while [ $tmp -lt ${#writeArray[@]} ] && [ $tmp -lt ${#readArray[@]} ] && [ $tmp -lt ${#cpuArray[@]} ]; do
		if (( maxCurrWrite > 0 )); then
			wPoint=$((maxCurrWrite/10))
			if (( maxCurrWrite < 10 )); then wPoint=1; fi
			wCurrentHight=$((writeArray[$tmp]/wPoint))
			if (( wCurrentHight > 11 )); then wCurrentHight=11; fi
		fi
		if (( ((13-wCurrentHight)) < cleanWArray[$tmp] )); then
			while (( line >= ((13-wCurrentHight)) )); do
				tput cup -- $line $wColumn
				echo -n "$(tput setab 3) $(tput sgr0)"
				line=$[line-1]
			done
		else
			line=$[cleanWArray[$tmp]]
			while (( line < ((13-wCurrentHight)) )); do
                               tput cup -- $line $wColumn
                               echo -n "$(tput sgr0) "
                               line=$[line+1]
                        done
		fi
		cleanWArray[$tmp]=$line
		line=12
		wColumn=$[wColumn+1]
                if (( maxCurrRead > 0 )); then
                        rPoint=$((maxCurrRead/10))
                        if (( maxCurrRead < 10 )); then rPoint=1; fi
                        rCurrentHight=$((readArray[$tmp]/rPoint))
			if (( rCurrentHight > 11 )); then rCurrentHight=11; fi
                fi
                if (( ((13-rCurrentHight)) < cleanRArray[$tmp] )); then
                        while (( line >= ((13-rCurrentHight)) )); do
                                tput cup -- $line $rColumn
                                echo -n "$(tput setab 4) $(tput sgr0)"
                                line=$[line-1]
                        done
                else
                        line=$[cleanRArray[$tmp]]
                        while (( line < (13-rCurrentHight) )); do
                               tput cup -- $line $rColumn
                               echo -n "$(tput sgr0) "
                               line=$[line+1]
                        done
                fi
                cleanRArray[$tmp]=$line
                line=12
                rColumn=$[rColumn+1]
                cpuCurrentHight=$((cpuArray[$tmp]/40))
		if [ $cpuCurrentHight -eq 0 ]; then cpuCurrentHight=1; fi
		if (( cpuCurrentHight > 11 )); then cpuCurrentHight=11; fi
		if (( ((13-cpuCurrentHight)) < cleanCArray[$tmp] )); then
                        while (( line >= ((13-cpuCurrentHight)) )); do
                                tput cup -- $line $cColumn
                                echo -n "$(tput setab 6) $(tput sgr0)"
                                line=$[line-1]
            		done
		else
                       line=$[cleanCArray[$tmp]]
                        while (( line < (13-cpuCurrentHight) )); do
                               tput cup -- $line $cColumn
                               echo -n "$(tput sgr0) "
                               line=$[line+1]
                        done
                fi
		cleanCArray[$tmp]=$line
                line=12
                cColumn=$[cColumn+1]
                tmp=$[tmp+1]
        done
	wColumn=1
	rColumn=28
	cColumn=55
	wSpeed=$[$deltaWrite*512]
	rSpeed=$[$deltaRead*512]
	wMaxCurrSpeed=$[$maxCurrWrite*512]
        rMaxCurrSpeed=$[$maxCurrRead*512]
	wMaxSpeed=$[$maxWrite*512]
        rMaxSpeed=$[$maxRead*512]
	wTmpMaxSpeed=$wMaxSpeed
	rTmpMaxSpeed=$rMaxSpeed
	if (( wSpeed > 1024 )); then
		wPrefix="KB"
		wSpeed=$[wSpeed/1024]
	fi
	if (( wSpeed > 1024 )); then
                wPrefix="MB"
                wSpeed=$[wSpeed/1024]
        fi
	if (( wSpeed > 1024 )); then
                wPrefix="GB"
                wSpeed=$[wSpeed/1024]
        fi
	if (( rSpeed > 1024 )); then
                rPrefix="KB"
                rSpeed=$[rSpeed/1024]
        fi
	if (( rSpeed > 1024 )); then
                rPrefix="MB"
                rSpeed=$[rSpeed/1024]
        fi
	if (( rSpeed > 1024 )); then
                rPrefix="GB"
                rSpeed=$[rSpeed/1024]
        fi
	if (( wMaxCurrSpeed > 1024 )); then
                wMaxCurrPrefix="KB"
                wMaxCurrSpeed=$[wMaxCurrSpeed/1024]
        fi
        if (( wMaxCurrSpeed > 1024 )); then
                wMaxCurrPrefix="MB"
                wMaxCurrSpeed=$[wMaxCurrSpeed/1024]
        fi
        if (( wMaxCurrSpeed > 1024 )); then
                wMaxCurrPrefix="GB"
                wMaxCurrSpeed=$[wMaxCurrSpeed/1024]
        fi
        if (( rMaxCurrSpeed > 1024 )); then
                rMaxCurrPrefix="KB"
                rMaxCurrSpeed=$[rMaxCurrSpeed/1024]
        fi
        if (( rMaxCurrSpeed > 1024 )); then
                rMaxCurrPrefix="MB"
                rMaxCurrSpeed=$[rMaxCurrSpeed/1024]
        fi
        if (( rMaxCurrSpeed > 1024 )); then
                rMaxCurrPrefix="GB"
                rMaxCurrSpeed=$[rMaxCurrSpeed/1024]
        fi
	if (( wTmpMaxSpeed > 1024 )); then
                wMaxPrefix="KB"
                wTmpMaxSpeed=$[wTmpMaxSpeed/1024]
        fi
        if (( wTmpMaxSpeed > 1024 )); then
                wMaxPrefix="MB"
                wTmpMaxSpeed=$[wTmpMaxSpeed/1024]
        fi
        if (( wTmpMaxSpeed > 1024 )); then
                wMaxPrefix="GB"
                wTmpMaxSpeed=$[wTmpMaxSpeed/1024]
        fi
        if (( rTmpMaxSpeed > 1024 )); then
                rMaxPrefix="KB"
                rTmpMaxSpeed=$[rTmpMaxSpeed/1024]
        fi
        if (( rTmpMaxSpeed > 1024 )); then
                rMaxPrefix="MB"
                rTmpMaxSpeed=$[rTmpMaxSpeed/1024]
        fi
        if (( rTmpMaxSpeed > 1024 )); then
                rMaxPrefix="GB"
                rTmpMaxSpeed=$[rTmpMaxSpeed/1024]
        fi

	tput cup 14 0
	echo -n "Write speed:            "
	tput cup 14 0
	echo -n "Write speed: " $wSpeed " " $wPrefix
	tput cup 14 27
	echo -n "Read speed:            "
	tput cup 14 27
	echo -n "Read speed: " $rSpeed " " $rPrefix
	tput cup 14 54
        echo -n "Cpu:            "
        tput cup 14 54
        echo -n "Cpu: " $[currentCpu/4] "%"
	tput cup 15 0
        echo -n "Max curr speed:            "
        tput cup 15 0
        echo -n "Max curr speed: " $wMaxCurrSpeed " " $wMaxCurrPrefix
        tput cup 15 27
        echo -n "Max curr speed:            "
        tput cup 15 27
        echo -n "Max curr speed: " $rMaxCurrSpeed " " $rMaxCurrPrefix
	tput cup 15 54
        echo -n "Max carr cpu:            "
        tput cup 15 54
        echo -n "Max curr cpu: " $[maxCurrCpu/4] "%"
	tput cup 16 0
        echo -n "Max speed:            "
        tput cup 16 0
        echo -n "Max speed: " $wTmpMaxSpeed " " $wMaxPrefix
        tput cup 16 27
        echo -n "Max speed:            "
        tput cup 16 27
        echo -n "Max speed: " $rTmpMaxSpeed " " $rMaxPrefix
        tput cup 16 54
        echo -n "Max cpu:            "
        tput cup 16 54
        echo -n "Max cpu: " $[maxCpu/4] "%"

	sleep 0.7
done
