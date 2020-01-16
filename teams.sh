#!/bin/bash

# Teams incoming web-hook URL and user name
url='https://outlook.office.com/webhook/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'                # https://dev.outlook.com/Connectors/GetStarted#posting-more-complex-cards

# Zabbix Frontend URL
zabbixurl='https://zabbix.company.com/zabbix/' # e.g. https://zabbix.company.com/zabbix/  -  don't forget ending slash

curlheader='-H "Content-Type: application/json"'
agent='-A "zabbix-teams-alertscript / https://github.com/ericoc/zabbix-slack-alertscript"'
curlmaxtime='-m 60'

## Values received by this script:
# Get the Zabbix severity ($1)
severity="$1"

# The hostname that the event belongs to ($2)
hostname="$2"

# The event name ($3)
eventname="$3"

# The event start time ($4) and date ($5)
time="$4"
date="$5"

# The event ID ($6)
eventid="$6"

# The trigger ID ($7)
triggerid="$7"

# The event status ($8)
status="$8"

# Change message themeColor depending on the severity - green (RECOVERY), red (HIGH and CRITICAL), yellow (Average), orange (Warning), blue (Info) or grey (for everything else)
recoversub='^Resolved?'
highsub='^High?'
criticalsub='^Critical?'
warningsub='^Warning?'
averagesub='^Average?'
infosub='^Information?'

if [[ "$severity" =~ ${recoversub} ]]; then
        THEMECOLOR='00ff00'
elif [[ "$severity" =~ ${highsub} ]]; then
        THEMECOLOR='ffcccb'
elif [[ "$severity" =~ ${criticalsub} ]]; then
        THEMECOLOR='ff0000'
elif [[ "$severity" =~ ${warningsub} ]]; then
        THEMECOLOR='ffa500'
elif [[ "$severity" =~ ${averagesub} ]]; then
        THEMECOLOR='ffff0'
elif [[ "$severity" =~ ${infosub} ]]; then
        THEMECOLOR='0000ff'
else
        THEMECOLOR='555555'
fi

# Build the message subject
subject="${severity}: ${hostname}"

# Build the message text
message="${eventname}"

# Build event link
eventlink="<a href='${zabbixurl}tr_events.php?triggerid=${triggerid}&eventid=${eventid}'>${eventid}</a>"

# Build our JSON payload and send it as a POST request to the Slack incoming web-hook URL

payload=\""{ \\\"@type\\\": \\\"MessageCard\\\", \\\"@context\\\": \\\"http://schema.org/extensions\\\", \\\"themeColor\\\": \\\"${THEMECOLOR}\\\", \\\"summary\\\": \\\"${subject}\\\", \\\"text\\\": \\\"${message}\\\", \\\"sections\\\": [{ \\\"activityTitle\\\": \\\"${subject}\\\", \\\"facts\\\": [{ \\\"name\\\": \\\"Hostname\\\", \\\"value\\\": \\\"${hostname}\\\" }, { \\\"name\\\": \\\"Event ID\\\", \\\"value\\\": \\\"${eventlink}\\\" }, { \\\"name\\\": \\\"Event Started\\\", \\\"value\\\": \\\"${time} ${date}\\\" }, { \\\"name\\\": \\\"Status\\\", \\\"value\\\": \\\"${status}\\\" }, { \\\"name\\\": \\\"Severity\\\", \\\"value\\\": \\\"${severity}\\\" }], \\\"markdown\\\": false }] }"\"

curldata=$(echo -d "$payload")

eval curl $curlmaxtime $curlheader $curldata $webhookurl $agent
