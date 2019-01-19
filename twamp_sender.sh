#!/bin/bash

# Versa TWAMP Sender Wrapper Script

# Make sure PORTS and DSCP are mapped accordingly for each Class of Service
# Eg: PORTS=(20001 20002) DSCP=(ef cs1) -> UDP port 20001 Corresponds to DSCP ef, UDP port 20002 to DSCP cs1 )
PORTS=("20001" "20002" "20003")
DSCP=("ef" "af31" "cs7")

# Versa FlexVNF Remote TWAMP responder IP
FAR_END_IP="198.18.10.10"

# Versa FlexVNF Local IP to source TWAMP packets
LOCAL_END_IP="198.18.10.20"

# Remote Name of the Versa Responder
REMOTE_HOSTNAME="D-Hub-1"

# Standard Output & Error will be recorded in this file
LOG_FILE_NAME="twamp_logs.txt"

# Versa FlexVNF Local VR to access network namespace
VERSA_TRANSPORT_VR="INTERNET-Transport-VR"

# TWAMP Sender additional options
TWAMP_SENDER_OPTIONS="-c 20 -i 100 --padding 1"

echo '******************************************************' >> ${LOG_FILE_NAME}
echo "TWAMP Sender Started @ $(date)" >> ${LOG_FILE_NAME}
echo '******************************************************' >> ${LOG_FILE_NAME}

if [[ ${#PORTS[@]} != ${#DSCP[@]} ]]; then
   echo 'PORTS and DSCP Array Lengths are not matching' >> ${LOG_FILE_NAME}
   exit 1
fi

for i in ${!DSCP[@]}; do
	/sbin/ip netns exec ${VERSA_TRANSPORT_VR} python3 twampycsv.py sender \
        --dscp ${DSCP[i]} ${TWAMP_SENDER_OPTIONS} ${FAR_END_IP}:${PORTS[i]} \
		${LOCAL_END_IP}:${PORTS[i]} -rh ${REMOTE_HOSTNAME} \
		>> ${LOG_FILE_NAME} 2>&1 &
done
exit 0