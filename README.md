# Versa TWAMP Tester

This repo contains custom TWAMP Python script to offer TWAMP Sender/Responder functionality for Versa FlexVNF.

TWAMP session results are saved within a CSV file named twamp_stats.csv in the /home/admin/twamp directory.

## Contents

- [Installation](#installation)
- [Sender](#sender)
- [Responder](#responder)


## Installation
1. Login as root user on the Versa FlexVNF Shell

2. Create twamp directory in /home/admin directory and set permissions for admin user to access the directory:
    - `mkdir /home/admin/twamp && chmod 777 /home/admin/twamp`

3. Copy the Python script twampycsv.py and Shell scripts (twamp_sender.sh / twamp_responder.sh) in the 
`/home/admin/twamp` directory.

4. Ensure the Shell scripts are executable:
    - `cd /home/admin/twamp && chmod a+x twamp_*.sh`

5. As root user, create the Cron Jobs on the Responder and Sender:

    - Sender:
    
        . `crontab -e`
        
        . Cron Job content below:
        ```bash
            PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
            SHELL=/bin/bash
            */5 * * * * cd /home/admin/twamp && ./twamp_sender.sh
        ```
        . Save the Cron Job definition and verify it's properly accepted with `crontab -l`
    
    - Responder:
    
        . `crontab -e`
        
        . Cron Job Content below:
        
        ```bash
            PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
            SHELL=/bin/bash
            */5 * * * * cd /home/admin/twamp && ./twamp_responder.sh
        ```
        
        . Save the Cron Job definition and verify it's properly accepted with `crontab -l`

## Sender

The Sender wrapper Shell script will pass the parameters to be executed by the TWAMP Python script.

These parameters can be customized in the variables set in the file as below:

##### PORTS and DSCP must be mapped accordingly for each Class of Service*
##### Eg: PORTS=(20001 20002 2003) DSCP=(ef af41 af33) -> UDP port 20001 Corresponds to DSCP ef (COS1)
##### UDP port 20002 to DSCP af41 (COS2), UDP Port 20003 to DSCP af33 (COS3)

***NOTE: Make sure the UDP ports range is allowed on the Versa FlexVNF otherwise TWAMP traffic will be filtered***
```
PORTS=("20001" "20002" "20003")
DSCP=("ef" "af31" "cs7")
```

##### Versa FlexVNF Remote TWAMP responder IP
```
FAR_END_IP="198.18.10.10"
```

##### Versa FlexVNF Remote TWAMP Secondary responder IP (Optional)
```
SEC_FAR_END_IP=""
```

##### Versa FlexVNF Local IP to source TWAMP packets
```
LOCAL_END_IP="198.18.10.20"
```

##### Remote Name of the Versa Responder
```
REMOTE_HOSTNAME="D-Hub-1"
```

##### Remote Name of the Versa Secondary Responder (Optional)
```
SEC_REMOTE_HOSTNAME=""
```

##### Standard Output & Error will be recorded in this file
```
LOG_FILE_NAME="twamp_logs.txt"
```

##### Versa FlexVNF Local VR to access network namespace
```
VERSA_TRANSPORT_VR="INTERNET-Transport-VR"
```

##### TWAMP Session Options to be passed to the Python utility
```
TWAMP_SENDER_OPTIONS="-c 1000 -i 60 --padding 50"
```


## Responder

The Responder wrapper Shell script will pass the parameters to be executed by the TWAMP Python script.

These parameters can be customized in the variables set in the file as below:

##### PORTS and DSCP must be mapped accordingly for each Class of Service*
##### Eg: PORTS=(20001 20002 2003) DSCP=(ef af41 af33) -> UDP port 20001 Corresponds to DSCP ef (COS1)
##### UDP port 20002 to DSCP af41 (COS2), UDP Port 20003 to DSCP af33 (COS3)

***NOTE: Make sure the UDP ports range is allowed on the Versa FlexVNF otherwise TWAMP traffic will be filtered***
```
PORTS=("20001" "20002" "20003")
DSCP=("ef" "af31" "cs7")
```

##### Versa FlexVNF Local IP to source TWAMP packets
```
LOCAL_END_IP="198.18.10.10"
```

##### Standard Output & Error will be recorded in this file
```
LOG_FILE_NAME="twamp_logs.txt"
```

##### Versa FlexVNF Local VR to access network namespace
```
VERSA_TRANSPORT_VR="WAN-Transport-VR"
```

##### TWAMP Session Options to be passed to the Python utility
```
TWAMP_RESPONDER_OPTIONS="--padding 26"
```

The twamp_responder.sh script will check every interval specified in the Cron Job, if there are active Python responder 
processes running the TWAMP with the given parameters. If yes, then nothing happens. If for any reason one or more 
processes don't exist anymore, the script will attempt to relaunch them.

***NOTE: You can pass the kill argument to the twamp responder Shell script to kill all ongoing Python responder 
processes: `./twamp_responder.sh kill`***