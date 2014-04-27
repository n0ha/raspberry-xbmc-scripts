#!/bin/bash

LOG_FILE="/home/pi/web/services-status.html"
exec 6>&1 # Link file descriptor #6 with stdout. Saves stdout 
exec 7>&2 # Link file descriptor #7 with stderr. Saves stderr
exec > "$LOG_FILE" 2>&1

COUCHPOTATO=`ps uax|grep "/usr/bin/python CouchPotato.py"|grep -v grep|wc -l`
TRANSMISSION=`ps uax|grep "/usr/bin/transmission-daemon"|grep -v grep|wc -l`
LIGHTTPD=`ps uax|grep "/usr/sbin/lighttpd"|grep -v grep|wc -l`
XBMC=`ps uax|grep "/home/pi/.xbmc-current/xbmc-bin/lib/xbmc/xbmc.bin"|grep -v grep|wc -l`
SICKBEARD=`ps uax|grep "python /home/pi/.sickbeard/SickBeard.py -q"|grep -v grep|wc -l`
NZBGET=`ps uax|grep "/home/pi/.nzbget/bin/nzbget -D"|grep -v grep|wc -l`

function started() {
	echo -e "<b>$1</b><span style=\"color:green;\">STARTED</span>"
}

function stopped() {
	echo -e "<b>$1</b><span style=\"color:red;\">STOPPED</span>"
}

echo "<pre>Last updated: $(date)<br/>"
if [ $COUCHPOTATO -eq 1 ]; then  started "Couchpotato   "; else stopped "Couchpotato   "; fi
if [ $TRANSMISSION -eq 1 ]; then started "Transmission  "; else stopped "Transmission  "; fi
if [ $LIGHTTPD -eq 1 ]; then     started "LigHTTPd      "; else stopped "LigHTTPd      "; fi
if [ $XBMC -gt 0 ]; then         started "XBMC          "; else stopped "XBMC          "; fi
if [ $SICKBEARD -gt 0 ]; then    started "SickBeard     "; else stopped "SickBeard     "; fi
if [ $NZBGET -eq 1 ]; then       started "NZBGet        "; else stopped "NZBGet        "; fi
echo "</pre>"
	
# restore streams
exec 1>&6 6>&- # Restore stdout and close file descriptor #6
exec 2>&7 7>&-      # Restore stderr and close file descriptor #7
