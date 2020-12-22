#!/bin/bash

# AlertAir, aicraft alert utility for Virtual Radar Server
# By spottair.com (Piotr Kozmin, pkozmin@gmail.com)
# Ver. 1.13, 24. Feb. 2020
# Searches for new aircraft every 5 ninutes and sends mail alert
# Requires *** swaks *** for mail handling
# Requires *** sqlite3 *** for database querying

# CONFIGURATION Start

# User-defined variables

# alert receipient's mail address
mail_receipient="name@domain"
# outgoing mail server, gmail recommended
mail_server="smtp.gmail.com"
# outgoing mail user's login
mail_user="name@domain"
# outgoing mail user's password
mail_password="password"
# absolute path to local VRS database file
db_file="<path>/BaseStation.sqb"
# absolute path to base directory of AlertAir files
base_dir="<path>"

# Helper variables, not user-defined

aircraft_file="${base_dir}/alert-config.txt"
db_output="${base_dir}/aircraft-db.txt"
log_file="${base_dir}/alert-log.txt"
mail_body="${base_dir}/mailbody.txt"

set -e

# CONFIGURATION End

# DEFINING FUNCTIONS Start

function get_alerted_list () {

# Read and parse aircraft_file

aircraft_list="'"
aircraft_list+=$(sed '/^#/d' $aircraft_file |
		 sed 's/#.*//g' | 
		 sed ':a;N;$!ba;s/\n/\x27,\x27/g' |
		 sed s/\	\'//)
aircraft_list+="'"
}

function db_query () {

# query the aircraft and flights database

SQL="\
SELECT \
	Aircraft.Registration as 'Reg',\
	Aircraft.RegisteredOwners as 'Airline',\
	Flights.Callsign,\
	Aircraft.ICAOTypeCode as 'ICAO',\
	Aircraft.Type,\
	Aircraft.OperatorFlagCode as 'Operator',\
	Aircraft.ModeSCountry as 'Country',\
	Flights.StartTime as 'First Seen'\
FROM\
	Aircraft\

INNER JOIN\
	Flights ON (Aircraft.AircraftID=Flights.AircraftID)\
WHERE\
        Flights.StartTime BETWEEN datetime('now','localtime','-5 minute') AND datetime('now','localtime')\
	AND\
	(Reg COLLATE NOCASE IN (${aircraft_list}) \
	OR\
	Airline COLLATE NOCASE IN ($aircraft_list) \
	OR\
	ICAO COLLATE NOCASE IN ($aircraft_list) \
	OR\
	Type COLLATE NOCASE IN ($aircraft_list) \
)
ORDER BY\
	Flights.StartTime DESC\
"\


# Querying database

sqlite3 -line $db_file "${SQL}" | sed ':a;N;$!ba;s/= \n/= n\/a\n/g' > $db_output

}

function sending_mail_logging () {

if [ -s $db_output ]; then

sed 's/^[ \t]*//;s/[ \t]*$//' $db_output | sed ':a;N;$!ba;s/\n/\\n/g' > $mail_body

swaks \
--to $mail_receipient \
--from $mail_user \
--header "Subject: AlertAir - new aircraft found" \
--body < $mail_body \
--server $mail_server \
-tls \
--port 587 \
--auth LOGIN \
--auth-user $mail_user \
--auth-password $mail_password \
> /dev/null

else

echo "No matching flight(s) found" > $db_output

fi

# Logging

echo "-----------------------" >> $log_file
date '+%F %T %Z' >> $log_file
cat $db_output >> $log_file

# Removing temp files

rm -f $db_output
rm -f $mail_body

}

# DEFINING FUNCTIONS End


# MAIN Start

get_alerted_list
db_query
sending_mail_logging

# MAIN End
