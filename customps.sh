#!/bin/bash

procdir="/proc"

printf " %5s  %10s  %20s  %10s  %10s  %45s \n" "PID" "USER" "COMMAND" "MEM" "STATE" "CMDLINE"

for pid in $(ls $procdir | grep -P "[0-9]"); do

	pid_dir="${procdir}/${pid}"
	pid_comm="${pid_dir}/comm"
	pid_cmdline="${pid_dir}/cmdline"
	pid_status="${pid_dir}/status"

	uid=''
	user=''
	state=''
	command=''
	cmdline=''
	mem=''

	#USER, STATE, MEM
	if [[ -e $pid_status ]]; then
		#USER
		uid=$(cat $pid_status | awk '/Uid/{ print $2}')
		user=$(id $uid | awk '{print $1}' | awk -F"(" '{print $2}'| awk -F")" '{print $1}')

		#STATE
		state="$(cat $pid_status | awk '/State/{print $3}')"
		
		#MEM
		vmstk="$(cat $pid_status | grep -i "vmstk" | awk '{print $2}')"
		vmdata="$(cat $pid_status | grep -i "vmdata" | awk '{print $2}')"
		mem="$((vmstk + vmdata))kB"

	else
		mem="?????"
		state="?????"
		user="?????"
	fi


	#COMMAND
	if [[ -e $pid_comm ]]; then
		command="[$(tr -d '\0' < $pid_comm)]"
	else
		command="?????"
	fi


	#CMDLINE
	if [[ -e $pid_cmdline ]]; then

		cmdline=$(awk '{print $1}' $pid_cmdline | tr -d '\0')
	else
		cmdline="?????"
	fi

	if [[ ! $cmdline ]]; then
		cmdline="$command"
	fi
	printf " %5s  %10s  %20s  %10s  %10s  %45s \n" $pid $user $command $mem $state $cmdline
	
done
exit 0