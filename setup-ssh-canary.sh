#!/bin/sh

if [ -z ${whereami+x} ]; then :; else echo "missing 'whereami' env" && exit 1; fi
if [ -z ${slackurl+x} ]; then :; else echo "missing 'slackurl' env" && exit 1; fi
if [ -z ${slackchannel+x} ]; then :; else echo "missing 'slackchannel' env" && exit 1; fi

echo '#!/bin/sh
if [ "$PAM_TYPE" != "close_session" ]; then
  content="\"attachments\": [ { \"mrkdwn_in\": [\"text\", \"fallback\"], \"fallback\": \"SSH login: $PAM_USER connected to \`$whereami\`\", \"text\": \"SSH login to \`$whereami\`\", \"fields\": [ { \"title\": \"User\", \"value\": \"$PAM_USER\", \"short\": true }, { \"title\": \"IP Address\", \"value\": \"$PAM_RHOST\", \"short\": true } ], \"color\": \"#F35A00\" } ]"
  curl -X POST --data-urlencode "payload={\"channel\": \"$slackchannel\", \"mrkdwn\": true, \"username\": \"ssh-bot\", $content, \"icon_emoji\": \":computer:\"}" $slackurl
fi
' > /etc/ssh/notify.sh
chown root:root /etc/ssh/notify.sh
chmod 000755 /etc/ssh/notify.sh

#TODO make idempotent
#if [ "$(cat /etc/pam.d/sshd)" != *_"notify.sh"_* ]; then
echo "session optional pam_exec.so seteuid /etc/ssh/notify.sh" >> /etc/pam.d/sshd

sudo service sshd restart
