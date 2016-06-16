#!/usr/bin/env python
#coding:utf-8
"""
  Author:  HieuHT --<>
  Purpose: 
  Created: 06/16/16
"""
import redis
from urllib2 import Request, urlopen
from urllib import urlencode
from json import dumps

REDIS_SERVER = "127.0.0.1"
REDIS_PORT = 6379
REDIS_TIMEOUT = 200
REDIS_SECRET = None
REDIS_DATABASE = 15
KEY_SMS = "IP_SMS"

# Slack
API_WEBHOOK = "https://hooks.slack.com/services/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"
API_CHANNEL = "#alert"
API_USERNAME = "Bulldog"
API_PAYLOAD = {"channel": API_CHANNEL,
               "username": API_USERNAME,
               "text": None,
               "icon_emoji": ":dog:"}
# SMS
SMS_URL = ""

def send_sms(message):
    return False

def send_slack(message):
    if message != "":
        API_PAYLOAD["text"] = message
        payload = dumps(API_PAYLOAD)
        try:
            req = Request(API_WEBHOOK, data=payload)
            res = urlopen(req)
        except Exception, e:
            print e
            
try:
    r = redis.Redis(host=REDIS_SERVER, 
                         port=REDIS_PORT, 
                         db=REDIS_DATABASE, 
                         password=REDIS_SECRET,
                         socket_timeout=REDIS_TIMEOUT)
    while 1:
        message = r.lpop(KEY_SMS)
        if message == None:
            break
        else:
            if not send_sms(message):
                send_slack(message)                               
except Exception, e:
    print e