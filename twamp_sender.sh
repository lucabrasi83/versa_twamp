#!/bin/bash

# Versa TWAMP Sender Wrapper Script
# Make sure PORTS and DSCP are mapped accordingly 
# Eg: PORTS=(20001 20002) DSCP=(ef cs1) -> UDP port 20001 Corresponds to DSCP ef, UDP port 20002 to DSCP cs1 )

PORTS=(20001 20002 20003)
DSCP=(ef af31 cs7)
FAR_END_IP=192.168.1.120
LOCAL_END_IP=192.168.1.28
REMOTE_HOSTNAME=REMOTEPC
LOG_FILE_NAME=twamp_logs.txt
VERSA_TRANSPORT_VR=INTERNET-Transport-VR


echo '******************************************************' >> ${LOG_FILE_NAME}
echo "TWAMP Sender Started @ $(date)" >> ${LOG_FILE_NAME}
echo '******************************************************' >> ${LOG_FILE_NAME}

if [[ ${#PORTS[@]} != ${#DSCP[@]} ]]; then
   echo 'PORTS and DSCP Array Lengths are not matching' >> ${LOG_FILE_NAME}
   exit 1
fi

for i in ${!DSCP[@]}; do
	/sbin/ip netns exec ${VERSA_TRANSPORT_VR} python3 twampycsv.py sender \
        --dscp ${DSCP[i]} -c 10 -i 10 ${FAR_END_IP}:${PORTS[i]} \
		${LOCAL_END_IP}:${PORTS[i]} -rh ${REMOTE_HOSTNAME} \
		>> ${LOG_FILE_NAME} 2>&1 & done