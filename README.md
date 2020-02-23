The <b>AlertAir</b> is a small Linux (Bash) utility for Virtual Radar Server to notify via email on new aircraft defined by user.

The general concept for AlertAir is as follows:
* the AlertAir Bash script is exectued by crontab every five minutes
* the VRS BaseStation.sqb database is queried for user-defined aircraft being airborne within the last five minutes
* if there are any aircraft matching user-defined criteria found an email with aircraft data is sent to the user
* the result of every five-minutes query is logged
