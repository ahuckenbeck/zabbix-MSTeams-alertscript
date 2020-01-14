#!/bin/bash

# Teams incoming web-hook URL and user name
url='https://outlook.office.com/webhook/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'                # https://dev.outlook.com/Connectors/GetStarted#posting-more-complex-cards
curlheader='-H "Content-Type: application/json"'
agent='-A "zabbix-teams-alertscript / https://github.com/ahuckenbeck/zabbix-MSTeams-alertscript"'
curlmaxtime='-m 60'

## Values received by this script:
# Subject = $1 (usually either PROBLEM or RECOVERY)
# Message = $2 (whatever message the Zabbix action sends, preferably something like "Zabbix server is unreachable for 5 minutes - Zabbix server (127.0.0.1)")

# Get the Zabbix subject ($2 - hopefully either PROBLEM or RECOVERY)
subject="$1"

# Change message themeColor depending on the subject - green (RECOVERY), red (PROBLEM), or grey (for everything else)
recoversub='^RECOVER(Y|ED)?$'
if [[ "$subject" =~ ${recoversub} ]]; then
        THEMECOLOR='43EA00'
elif [ "$subject" == 'PROBLEM' ]; then
        THEMECOLOR='EA4300'
else
        THEMECOLOR='555555'
fi

# The message that we want to send to Slack is the "subject" value ($2 / $subject - that we got earlier)
#  followed by the message that Zabbix actually sent us ($3)
message="${subject}: $2"

# Build our JSON payload and send it as a POST request to the Slack incoming web-hook URL

payload=\""{\\\"title\\\": \\\"${subject} \\\", \\\"text\\\": \\\"${message} \\\", \\\"themeColor\\\": \\\"${THEMECOLOR}\\\"}"\"

curldata=$(echo -d "$payload")

eval curl $curlmaxtime $curlheader $curldata $url $agent
