#!/bin/bash

# Versa TWAMP Sender Wrapper Script

# Make sure PORTS and DSCP are mapped accordingly for each Class of Service
# Eg: PORTS=(20001 20002 2003) DSCP=(ef af41 af33) -> UDP port 20001 Corresponds to DSCP ef (COS1)
# UDP port 20002 to DSCP af41 (COS2), UDP Port 20003 to DSCP af33 (COS3)
PORTS=("20001" "20002" "20003")
DSCP=("ef" "af41" "af33")

# Versa FlexVNF Local IP to source TWAMP packets
LOCAL_END_IP="198.18.10.20"

# Versa FlexVNF Remote TWAMP Primary responder IP
FAR_END_IP="198.18.10.10"

# Remote Name of the Versa Primary Responder
REMOTE_HOSTNAME="D-Hub-1"

# Versa FlexVNF Remote TWAMP Secondary Responder IP (Required only for Versa Secondary Responder)
SEC_FAR_END_IP="198.18.10.15"

# Remote Name of the Versa Secondary Responder (Required only for Versa Secondary Responder)
SEC_REMOTE_HOSTNAME="D-Spoke-2"

# Versa FlexVNF Remote TWAMP Secondary Responder IP (Required only for Versa Tertiary Responder)
TER_FAR_END_IP="198.18.10.15"

# Remote Name of the Versa Tertiary Responder (Required only for Versa Tertiary Responder)
TER_REMOTE_HOSTNAME="D-Spoke-3"

# Standard Output & Error will be recorded in this file
LOG_FILE_NAME="twamp_logs.log"

# Versa FlexVNF Local VR to access network namespace
VERSA_TRANSPORT_VR="INTERNET-Transport-VR"

# TWAMP Sender additional options
TWAMP_SENDER_OPTIONS="-c 1000 -i 60 --padding 50"

# Kill All Python processes running responder if kill argument is passed
if [[ $1 == 'kill' ]]; then
    proc_array_num=$(ps aux | grep "python3 twampycsv.py sender" | grep -v "grep" | wc -l)

    if [[ ${proc_array_num} -eq 0 ]]; then
        echo "Nothing to kill"
    else
        proc_array=($(ps aux | grep "python3 twampycsv.py sender" | grep -v "grep" | awk '{print $2}'))
        for p in ${proc_array[@]}; do
            echo "Killing PID ${p}"
            kill ${p}
        done
    fi
    exit 0
fi

echo '***************************************************************************************' >>${LOG_FILE_NAME}
echo "TWAMP Sender to Destination ${FAR_END_IP} Started @ $(date)" >>${LOG_FILE_NAME}
echo '***************************************************************************************' >>${LOG_FILE_NAME}

if [[ ${#PORTS[@]} != ${#DSCP[@]} ]]; then
    echo 'PORTS and DSCP Array Lengths are not matching' >>${LOG_FILE_NAME}
    exit 1
fi

for i in ${!DSCP[@]}; do
    /sbin/ip netns exec ${VERSA_TRANSPORT_VR} python3 twampycsv.py sender \
        --dscp ${DSCP[i]} ${TWAMP_SENDER_OPTIONS} ${FAR_END_IP}:${PORTS[i]} \
        ${LOCAL_END_IP}:${PORTS[i]} -rh ${REMOTE_HOSTNAME} \
        >>${LOG_FILE_NAME} 2>&1 &
done

# Helper function to handle secondary and tertiary responders
# The Versa TWAMP Responder Hostname is passed as the first argument while its IP address as the second argument
additional_responders() {
    # Capture current number of running TWAMP sender processes
    proc_array_num=$(ps aux | grep "python3 twampycsv.py sender" | grep -v "grep" | wc -l)

    # Loop until the number of TWAMP sender processes comes down to 0
    while [[ ${proc_array_num} -ne 0 ]]; do
        sleep 1
        proc_array_num=$(ps aux | grep "python3 twampycsv.py sender" | grep -v "grep" | wc -l)
    done

    echo '***************************************************************************************' >>${LOG_FILE_NAME}
    echo "TWAMP Sender to Destination $1 Started @ $(date)" >>${LOG_FILE_NAME}
    echo '***************************************************************************************' >>${LOG_FILE_NAME}

    for i in ${!DSCP[@]}; do

        /sbin/ip netns exec ${VERSA_TRANSPORT_VR} python3 twampycsv.py sender \
            --dscp ${DSCP[i]} ${TWAMP_SENDER_OPTIONS} $1:${PORTS[i]} \
            ${LOCAL_END_IP}:${PORTS[i]} -rh $2 \
            >>${LOG_FILE_NAME} 2>&1 &

    done

}

if [[ ${SEC_FAR_END_IP} != "" && ${SEC_REMOTE_HOSTNAME} != "" ]]; then

    # Pause 5 seconds upon launching the probes to secondary responder
    sleep 5

    additional_responders ${SEC_FAR_END_IP} ${SEC_REMOTE_HOSTNAME}

fi

if [[ ${TER_FAR_END_IP} != "" && ${TER_REMOTE_HOSTNAME} != "" ]]; then

    # Pause 5 seconds upon launching the probes to tertiary responder
    sleep 5

    additional_responders ${TER_FAR_END_IP} ${TER_REMOTE_HOSTNAME}

fi

exit 0
