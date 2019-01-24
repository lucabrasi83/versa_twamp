import ftplib
import sys
from datetime import datetime
import socket
import os

# Define Constants
FTP_SERVER_IP = "11.11.11.14"
FTP_USERNAME = "twamp"
FTP_PASSWORD = "twamp"
LOCAL_HOSTNAME = socket.gethostname()
CSV_FILE_NAME = "twamp_stats_" + LOCAL_HOSTNAME + ".csv"


def str_timestamp():
    now = datetime.now().timestamp()
    timestamp_utc = datetime.utcfromtimestamp(now).strftime('%Y-%m-%d %H:%M:%S') + " UTC"
    return timestamp_utc


def ftp_file_transfer(obj, file_name):
    with open(file_name, 'rb') as csv_file_obj:
        transfer_start_time = datetime.now()

        # Transfer file by 1KB blocks in Binary Mode - Append FTP command to existing file
        obj.storbinary('APPE ' + CSV_FILE_NAME, csv_file_obj, 1024)

        transfer_end_time = datetime.now()
        delta = transfer_end_time - transfer_start_time
        print(str_timestamp(),
              "File Transfer Successful. Took:",
              delta.total_seconds(),
              "Second(s)")


if __name__ == "__main__":

    try:

        with ftplib.FTP(host=FTP_SERVER_IP,
                        user=FTP_USERNAME,
                        passwd=FTP_PASSWORD,
                        timeout=10) as ftp_obj:

            if os.path.exists(CSV_FILE_NAME):
                try:
                    ftp_file_transfer(ftp_obj, CSV_FILE_NAME)
                except Exception as xfer_err:
                    print(str_timestamp(), "Failed to transfer file with error:", xfer_err)
                    sys.exit(1)
                else:
                    os.remove(CSV_FILE_NAME)
            else:
                print(str_timestamp(), CSV_FILE_NAME, "not found in /home/admin/twamp")

    # Catch any exception raised during FTP connection and file transfer
    except Exception as err:
        print(str_timestamp(), "Failed to execute file transfer with error: " + str(err))
        sys.exit(1)
