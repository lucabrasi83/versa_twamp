import ftplib
import sys
from datetime import datetime
import time
import socket
import os

# Define Constants
FTP_SERVER_IP = "11.11.11.14"
FTP_USERNAME = "twamp"
FTP_PASSWORD = "twamp"
LOCAL_HOSTNAME = socket.gethostname()
CSV_FILE_NAME = "twamp_stats_"
CSV_EXTENSION = ".csv"


def str_timestamp():
    now = datetime.now().timestamp()
    timestamp_utc = datetime.utcfromtimestamp(now).strftime('%Y-%m-%d %H:%M:%S') + " UTC"
    return timestamp_utc


def file_timestanmp():
    now = datetime.now().timestamp()
    file_name_timestamp = datetime.utcfromtimestamp(now).strftime('%Y-%m-%d-%H_%M_%S') + "_UTC"
    return file_name_timestamp


def ftp_file_transfer(obj, file_name):
    with open(file_name, 'rb') as csv_file_obj:
        transfer_start_time = datetime.now()

        # Transfer file by 1KB blocks in Binary Mode - Append FTP command to existing file
        filename_gen = CSV_FILE_NAME + LOCAL_HOSTNAME + "_" + file_timestanmp() + ".csv"
        obj.storbinary('STOR ' + filename_gen, csv_file_obj, 1024)

        transfer_end_time = datetime.now()
        delta = transfer_end_time - transfer_start_time
        print(str_timestamp(),
              "File Transfer Successful. Took:",
              delta.total_seconds(),
              "Second(s)")


if __name__ == "__main__":

    try:
        local_twamp_stats_file = CSV_FILE_NAME + LOCAL_HOSTNAME + CSV_EXTENSION

        with ftplib.FTP(host=FTP_SERVER_IP,
                        user=FTP_USERNAME,
                        passwd=FTP_PASSWORD,
                        timeout=10) as ftp_obj:

            if os.path.exists(local_twamp_stats_file):
                try:
                    ftp_file_transfer(ftp_obj, local_twamp_stats_file)
                except Exception as xfer_err:
                    print(str_timestamp(), "Failed to transfer file with error:", xfer_err)
                    sys.exit(1)
                else:
                    os.remove(local_twamp_stats_file)
            else:
                print(str_timestamp(), local_twamp_stats_file, "not found in /home/admin/twamp")

    # Catch any exception raised during FTP connection and file transfer
    except Exception as err:
        print(str_timestamp(), "Failed to execute file transfer with error: " + str(err))
        sys.exit(1)
