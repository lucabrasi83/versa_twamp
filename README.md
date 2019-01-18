# Versa TWAMP Tester

This repo contains custom TWAMP Python script to offer TWAMP Sender/Responder functionality for Versa FlexVNF.

Each Test is saved within a CSV file named twamp_stats.csv in the /home/admin/twamp directory.

## Contents

- [Installation](#installation)
- [Sender](#sender)
- [Responder](#responder)


## Installation
1. Login as root user on the Versa FlexVNF Shell

2. Create twamp directory in /home/admin directory:
    - `mkdir /home/admin/twamp`

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

##### Make sure PORTS and DSCP are mapped accordingly for each Class of Service*
##### Eg: PORTS=(20001 20002) DSCP=(ef cs1) -> UDP port 20001 Corresponds to DSCP ef, UDP port 20002 to DSCP cs1 )

***NOTE: Make sure the UDP ports range is allowed on the Versa FlexVNF otherwise TWAMP traffic will be filtered***
```
PORTS=(20001 20002 20003)
DSCP=(ef af31 cs7)
```

##### Versa FlexVNF Remote TWAMP responder IP
```
FAR_END_IP=192.168.1.120
```

##### Versa FlexVNF Local IP to source TWAMP packets
```
LOCAL_END_IP=192.168.1.28
```

##### Remote Name of the Versa Responder
```
REMOTE_HOSTNAME=REMOTEPC
```

##### Standard Output & Error will be recorded in this file
```
LOG_FILE_NAME=twamp_logs.txt
```

##### Versa FlexVNF Local VR to access network namespace
```
VERSA_TRANSPORT_VR=INTERNET-Transport-VR
```

Standard Output and Error will be logged in the file specified in `LOG_FILE_NAME`


## Responder

The Responder wrapper Shell script will pass the parameters to be executed by the TWAMP Python script.

These parameters can be customized in the variables set in the file as below:

##### Make sure PORTS and DSCP are mapped accordingly for each Class of Service*
##### Eg: PORTS=(20001 20002) DSCP=(ef cs1) -> UDP port 20001 Corresponds to DSCP ef, UDP port 20002 to DSCP cs1 )

***NOTE: Make sure the UDP ports range is allowed on the Versa FlexVNF otherwise TWAMP traffic will be filtered***
```
PORTS=(20001 20002 20003)
DSCP=(ef af31 cs7)
```

##### Versa FlexVNF Local IP to source TWAMP packets
```
LOCAL_END_IP=192.168.1.120
```

##### Standard Output & Error will be recorded in this file
```
LOG_FILE_NAME=twamp_logs.txt
```

##### Versa FlexVNF Local VR to access network namespace
```
VERSA_TRANSPORT_VR=WAN-Transport-VR
```

Standard Output and Error will be logged in the file specified in `LOG_FILE_NAME`

The twamp_responder.sh script will check every 5 minutes if there are active Python processes running the TWAMP 
script as responder. If yes, then nothing happens. If for any reason the processes don't exist anymore, the script will 
attempt to relaunch them.