#!/usr/bin/python
# -*- coding: utf-8 -*-

from json import dumps
from httplib2 import Http
import sys

def main():
    """Hangouts Chat incoming webhook quickstart.
    https://stackoverflow.com/questions/65641069/how-to-send-a-message-to-google-hangouts-with-python#:~:text=Go%20to%20the%20room%20to,use%20in%20your%20python%20script.
    Go to the room to which you wish to send a message at https://chat.google.com, 
       and from the dropdown menu next to the room's name, select Manage Webhooks.
    Enter a name and an optional avatar for your bot, and press SAVE. 
    This will give you a webhook URL to use in your python script.

    INSTALL: pip install httplib2

    USAGE e.g.:  python ${JENKINS_HOME}/jenkins_QA_chat.py "job start ${JOB_NAME}"
        echo "$SiteType $SiteId $VERSION Success:${BUILD_SUCCESSFUL} Event:$EVENT_TYPE" > CHAT.txt
	grep -v "TEST REPORT" TEST_RESULT.txt >> CHAT.txt || true
        python ${JENKINS_HOME}/jenkins_QA_chat.py CHAT.txt
    """
    # TestChatBot
    webhook_url = 'https://chat.googleapis.com/v1/spaces/AAAAQUsVWA8/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=y6Gu96DKCjfSNZWwJl_BLG8Js8bxCmQsMVuJU2NbwmY%3D'
    # QA
    #webhook_url = 'https://chat.googleapis.com/v1/spaces/AAAArzPhNpQ/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=Rngftf9xkIj3tR3_Xnyv2yuzAiJXrPsmaw369OnslZs%3D'
    bot_message = {
        'text' : 'Hello from Python script. \n\
*bold* emoji foo bar 🙂😝👍☹️😜😐😯😬☢'}
    # THIS doesn't appear as emojis: ':slightly-smiling-face: :squinting-face-with-tongue: :thumbs-up: :frowning-face: :winking-face-with-tongue: :neutral-face: :hushed-face: :grimacing-face: :radioactive: :biohazard:' # == 🙂😝👍☹️😜😐😯😬☢

    print(sys.argv[0])
    if len(sys.argv) > 1:
        print(sys.argv[1])
        text = None
        try:
            f = open(sys.argv[1],'r')
            text = f.read()
        except:
            text = sys.argv[1]
        bot_message = { 'text' : text }

    message_headers = {'Content-Type': 'application/json; charset=UTF-8'}

    http_obj = Http()

    response = http_obj.request(
        uri=webhook_url,
        method='POST',
        headers=message_headers,
        body=dumps(bot_message),
    )

    print(response)

if __name__ == '__main__':
    main()

