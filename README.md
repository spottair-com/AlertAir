# AlertAir
The **AlertAir** is a small Linux (Bash) utility for Virtual Radar Server to notify via email on new aircraft defined by user.

The general concept for AlertAir is as follows:
* the AlertAir Bash script is exectued by crontab every five minutes
* the VRS BaseStation.sqb database is queried for user-defined aircraft being airborne within the last five minutes
* if there are any aircraft matching user-defined criteria found an email with aircraft data is sent to the user
* the result of every five-minutes query is logged

## Prerequisites
* Virtual Radar Server up and running (Mono-based Linux version)
* Plugin DataBase Writer installed
* BaseStation.sqb database being fed with aircraft/flight data

## Setup
* Download the ZIP file
* Create a directory (e.g. within your home folder) und unzip the files into it
* Make the script file executable (chmod +x AlertAir.sh)
* Open the alertair-config.txt file to define your own aircraft to alert
* Open the AlertAir.sh file and head to the section "User-defined variables" to set your specific mail parameters etc.
* Don't alter the section "Helper variables, not user-defined" in the AlertAir.sh file
