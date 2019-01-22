#!/bin/bash

# Versa TWAMP Sender Wrapper Script

# Make sure PORTS and DSCP are mapped accordingly for each Class of Service
# Eg: PORTS=(20001 20002 2003) DSCP=(ef af41 af33) -> UDP port 20001 Corresponds to DSCP ef (COS1)
# UDP port 20002 to DSCP af41 (COS2), UDP Port 20003 to DSCP af33 (COS3)
PORTS=("20001" "20002" "20003")
DSCP=("ef" "af41" "af33")

# Versa FlexVNF Remote TWAMP Primary responder IP
FAR_END_IP="198.18.10.10"

# Versa FlexVNF Remote TWAMP Secondary Responder IP (Optional)
SEC_FAR_END_IP=""

# Versa FlexVNF Local IP to source TWAMP packets
LOCAL_END_IP="198.18.10.20"

# Remote Name of the Versa Primary Responder
REMOTE_HOSTNAME="D-Hub-1"

# Remote Name of the Versa Secondary Responder (Optional)
SEC_REMOTE_HOSTNAME=""

# Standard Output & Error will be recorded in this file
LOG_FILE_NAME="twamp_logs.txt"

# Versa FlexVNF Local VR to access network namespace
VERSA_TRANSPORT_VR="INTERNET-Transport-VR"

# TWAMP Sender additional options
TWAMP_SENDER_OPTIONS="-c 1000 -i 60 --padding 50"

echo '***************************************************************************************' >> ${LOG_FILE_NAME}
echo "TWAMP Sender to Destination ${FAR_END_IP} Started @ $(date)" >> ${LOG_FILE_NAME}
echo '***************************************************************************************' >> ${LOG_FILE_NAME}

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

if [[ ${SEC_FAR_END_IP} != "" && ${SEC_REMOTE_HOSTNAME} != "" ]]; then

    echo '***************************************************************************************' >> ${LOG_FILE_NAME}
    echo "TWAMP Sender to Destination ${SEC_FAR_END_IP} Started @ $(date)" >> ${LOG_FILE_NAME}
    echo '***************************************************************************************' >> ${LOG_FILE_NAME}


    for i in ${!DSCP[@]}; do

    /sbin/ip netns exec ${VERSA_TRANSPORT_VR} python3 twampycsv.py sender \
        --dscp ${DSCP[i]} ${TWAMP_SENDER_OPTIONS} ${SEC_FAR_END_IP}:${PORTS[i]} \
		${LOCAL_END_IP}:${PORTS[i]} -rh ${SEC_REMOTE_HOSTNAME} \
		>> ${LOG_FILE_NAME} 2>&1 &

	done
fi
exit 0