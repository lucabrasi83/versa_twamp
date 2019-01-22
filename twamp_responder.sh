#!/bin/bash

# Versa TWAMP Responder Wrapper Script

# Make sure PORTS and DSCP are mapped accordingly for each Class of Service
# Eg: PORTS=(20001 20002 2003) DSCP=(ef af41 af33) -> UDP port 20001 Corresponds to DSCP ef (COS1)
# UDP port 20002 to DSCP af41 (COS2), UDP Port 20003 to DSCP af33 (COS3)
PORTS=("20001" "20002" "20003")
DSCP=("ef" "af41" "af33")

# Versa FlexVNF Local IP to source TWAMP packets
LOCAL_END_IP="198.18.10.10"

# Standard Output & Error will be recorded in this file
LOG_FILE_NAME="twamp_logs.txt"

# Versa FlexVNF Local VR to access network namespace
VERSA_TRANSPORT_VR="WAN-Transport-VR"

# TWAMP Responder additional options
TWAMP_RESPONDER_OPTIONS="--padding 26"

# Kill All Python processes running responder if kill argument is passed
if [[ $1 == 'kill' ]]; then
     proc_array_num=$(ps aux | grep  "python3 twampycsv.py responder" | grep -v "grep" | wc -l )

     if [[ ${proc_array_num} -eq 0 ]]; then
        echo "Nothing to kill"
     else
        proc_array=( $(ps aux | grep  "python3 twampycsv.py responder" | grep -v "grep" | awk '{print $2}') )
        for p in ${proc_array[@]}; do
            echo "Killing PID ${p}"
            kill ${p}
        done
     fi
     exit 0
fi

if [[ ${#PORTS[@]} != ${#DSCP[@]} ]]; then
	echo 'PORTS and DSCP Array Lengths are not matching' >>${LOG_FILE_NAME}
	exit 1
fi

# Check if Responder process is running for each DSCP value
for i in ${!DSCP[@]}; do

	if [[ $(ps aux | grep "python3 twampycsv.py responder --dscp ${DSCP[i]} ${TWAMP_RESPONDER_OPTIONS}
	${LOCAL_END_IP}:${PORTS[i]}" | grep -v "grep" | wc -l ) -eq 1 ]]; then

		echo "$(date) Responder Processes for DSCP ${DSCP[i]} Already Running" >>${LOG_FILE_NAME}

	else

	    echo '***************************************************************************************' >>${LOG_FILE_NAME}
        echo "TWAMP Responder for DSCP ${DSCP[i]} Starting @ $(date)" >>${LOG_FILE_NAME}
        echo '***************************************************************************************' >>${LOG_FILE_NAME}


		/sbin/ip netns exec ${VERSA_TRANSPORT_VR} python3 twampycsv.py responder \
			--dscp ${DSCP[i]} ${TWAMP_RESPONDER_OPTIONS} ${LOCAL_END_IP}:${PORTS[i]} \
			>>${LOG_FILE_NAME} 2>&1 &
	fi
done
exit 0