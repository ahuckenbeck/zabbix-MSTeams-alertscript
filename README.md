Zabbix Microsoft Teams AlertScript
========================


About
-----
This is simply a Bash script that uses the custom alert script functionality within [Zabbix](http://www.zabbix.com/) along with the incoming web-hook feature of [Microsoft Teams](https://www.microsoft.com/) 
It is heavily based on the previous Zabbix Slack alert script here: https://github.com/ericoc/zabbix-slack-alertscript

#### Versions
This works with Zabbix 1.8.x or greater - including 2.2, 2.4, 3.x and 4.x!

#### Huge thanks and appreciation to:

* [Eric OC](https://github.com/ericoc/) for the original script on which this modification is based 

Installation (work in progress)
------------

### The script itself

This teams.sh script needs to be placed in the `AlertScriptsPath` directory that is specified within the Zabbix servers' configuration file (`zabbix_server.conf`) and must be executable by the user running the zabbix_server binary (usually "zabbix") on the Zabbix server:

	[root@zabbix ~]# grep AlertScriptsPath /etc/zabbix/zabbix_server.conf
	### Option: AlertScriptsPath
	AlertScriptsPath=/usr/local/share/zabbix/alertscripts
	
	[root@zabbix ~]# chown zabbix:zabbix /usr/local/share/zabbix/alertscripts/teams.sh	
	[root@zabbix ~]# ls -lh /usr/local/share/zabbix/alertscripts/teams.sh
	-rwxr-xr-x 1 zabbix zabbix 1.4K Dec 27 13:48 /usr/local/share/zabbix/alertscripts/teams.sh

If you do change `AlertScriptsPath` (or any other values) within `zabbix_server.conf`, a restart of the Zabbix server software is required.

Configuration
-------------

### MS Teams web-hook

An incoming web-hook integration must be created within your Teams account:

https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/connectors-using

### Within the Zabbix web interface

When logged in to the Zabbix servers web interface with super-administrator privileges, navigate to the "Administration" tab, access the "Media Types" sub-tab, and click the "Create media type" button.

You need to create a media type as follows:

* **Name**: Zabbix
* **Type**: Script
* **Script name**: teams.sh

...and ensure that it is enabled before clicking "Save", like so:

However, on Zabbix 3.x and greater, media types are configured slightly differently and you must explicity define the parameters sent to the `teams.sh` script. On Zabbix 4.x, two script parameters should be added as follows:

* `{ALERT.SUBJECT}`
* `{ALERT.MESSAGE}`

Finally, an action can then be created on the "Actions" sub-tab of the "Configuration" tab within the Zabbix servers web interface to notify the Mircosoft Teams Channel ensuring that the "Subject" is "PROBLEM" for "Default message" and "RECOVERY" should you choose to send a "Recovery message".

Keeping the messages short is probably a good idea; use something such as the following for the contents of each message:

	{TRIGGER.NAME} - {HOSTNAME} ({IPADDRESS})

Testing
-------
Assuming that you have set a valid Teams web-hook URL within your "teams.sh" file, you can execute the script manually (as opposed to via Zabbix) from Bash on a terminal:

	$ bash teams.sh 'PROBLEM' 'Oh no! Something is wrong!'

More Information
----------------
* [Slack incoming web-hook functionality](https://my.slack.com/services/new/incoming-webhook)
* [Zabbix 2.2 custom alertscripts documentation](https://www.zabbix.com/documentation/2.2/manual/config/notifications/media/script)
* [Zabbix 2.4 custom alertscripts documentation](https://www.zabbix.com/documentation/2.4/manual/config/notifications/media/script)
* [Zabbix 3.x custom alertscripts documentation](https://www.zabbix.com/documentation/3.0/manual/config/notifications/media/script)
* [Zabbix 4.4 custom alertscripts documentation](https://www.zabbix.com/documentation/4.4/manual/config/notifications/media/script)
