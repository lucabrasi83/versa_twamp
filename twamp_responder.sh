#!/bin/bash

# Versa TWAMP Responder Wrapper Script

# Make sure PORTS and DSCP are mapped accordingly for each Class of Service
# Eg: PORTS=(20001 20002) DSCP=(ef cs1) -> UDP port 20001 Corresponds to DSCP ef, UDP port 20002 to DSCP cs1 )
PORTS=(20001 20002 20003)
DSCP=(ef af31 cs7)

# Versa FlexVNF Local IP to source TWAMP packets
LOCAL_END_IP=192.168.1.120

# Standard Output & Error will be recorded in this file
LOG_FILE_NAME=twamp_logs.txt

# Versa FlexVNF Local VR to access network namespace
VERSA_TRANSPORT_VR=WAN-Transport-VR

# Capture the number of TWAMP responder processes running
TWAMP_RESPONDER_PROC_NUM=$(ps aux | grep  "python3 twampycsv.py responder" | grep -v "grep" |  wc -l)

# Capture PID and full execution path of running TWAMP responder processes
TWAMP_RESPONDER_PROCS=$(ps aux | grep  "python3 twampycsv.py responder" | grep -v "grep")


if [[ ${#PORTS[@]} != ${#DSCP[@]} ]]; then
   echo 'PORTS and DSCP Array Lengths are not matching' >> ${LOG_FILE_NAME}
   exit 1
fi

# Check if Responder processes are running
if [[  ${TWAMP_RESPONDER_PROC_NUM} -eq 0  ]]; then

    echo '******************************************************' >> ${LOG_FILE_NAME}
    echo "TWAMP Responder Starting @ $(date)" >>${LOG_FILE_NAME}
    echo '******************************************************' >> ${LOG_FILE_NAME}

    for i in ${!DSCP[@]}; do
        /sbin/ip netns exec ${VERSA_TRANSPORT_VR} python3 twampycsv.py responder \
         --dscp ${DSCP[i]} --padding 1 ${LOCAL_END_IP}:${PORTS[i]} \
            >>${LOG_FILE_NAME} 2>&1 & done
else
    echo "$(date) Responder Processes Already Running as below: " >> ${LOG_FILE_NAME}
    echo "${TWAMP_RESPONDER_PROCS}"  >> ${LOG_FILE_NAME}
fi