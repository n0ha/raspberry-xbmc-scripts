#!/bin/bash
line="5/* * * * * /home/pi/s/services-html.sh > /home/pi/web/services-status.txt"
(crontab -l; echo "$line" ) | crontab -
