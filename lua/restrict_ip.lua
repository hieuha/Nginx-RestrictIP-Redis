-- Redis Configuration
local redis_server = "127.0.0.1"
local redis_port = 6379
local redis_timeout = 200
local redis_secret = nil
local appname = "RESTRICT-IP"
local database = 6

-- Notification
local enable_sms = true
local enable_email = true
local daywork = {2, 3, 4, 5, 6, 7}
local daytime = {}
local level_sms = 100
local level_block = 200

-- redis IP keys
local redis_whitelist_key = "IP_WHITELIST"
local redis_blacklist_key = "IP_BLACKLIST"
local redis_score_badip = "IP_SCORE"
local redis_sendsms = "IP_IS_SEND_SMS"

-- API SMS

-- API Webhook Slack
local slack_webhook = "https://hooks.slack.com/services/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"
local slack_channel = "#alert"
local slack_username = "dog"

-- block time
local block_time = 600000 -- 10 minutes, 600000 milliseconds 
local rule_block = "444"
-- Client
local client_remoteip = ngx.var.remote_addr
local client_url = ngx.var.host .. '/' .. ngx.var.uri
local client_message = client_remoteip .. ": " .. client_url


-- Functions
local function isStillBlocking(time_start)
    local time_now = os.time()
    local time_diff = math.abs(time_start - time_now)
    if time_diff >= block_time then
        return false
    end
    return true
end

local function ruleBlock(rule)
    ngx.log(ngx.ERR, appname..": block the IP "..client_remoteip)
    if rule == "403" then
        return ngx.exit(ngx.HTTP_FORBIDDEN)
    elseif rule == "444" then
        return ngx.exit(ngx.HTTP_CLOSE)
    else if rule == "404" then
        return ngx.exit(ngx.HTTP_NOT_FOUND)
    elseif rule == "iptables" then
        -- set rule for block Network layer
        return
    else
        return ngx.exit(ngx.HTTP_FORBIDDEN)
    end
end

local function notiSlack(slack_message){
    if slack_message ~= ngx.null then
        local http = require "resty.http"
        local httpc = http.new()
        local payload = 'payload={"channel": "'..slack_channel..'", "username": "'..slack_username..'", "text": "'..slack_message..'", "icon_emoji": ":ghost:"}'
        local res, err = httpc:request_uri(slack_webhook, {
            method = "POST",
            body = payload,
        })
    end
}

-- Init Redis Connection
local resty = require "resty.redis"
local redis = resty:new()
redis:set_timeout(redis_timeout)
local isConnected, err = redis:connect(redis_server, redis_port)
if not isConnected then
    ngx.log(ngx.ERR, appname..": could not connect to redis @"..redis_port..": "..err)
    return
else
    if redis_secret ~= nil then
        local isConnected, err = redis:auth(redis_secret)
        if not isConnected then
            ngx.log(ngx.ERR, appname..": failed to authenticate"..redis_port..": "..err)
            return
        end
    end
    redis:select(database)
end

local is_white_ip_eixsted, err = redis:sismember(redis_whitelist_key, client_remoteip)
if is_white_ip_eixsted == 1 then
    return
else
    local time_start, err = redis:zscore(redis_blacklist_key, client_remoteip)
    if time_start ~= ngx.null then
        if isStillBlocking(time_start) then
            blockAcion(rule_block)
        else
            -- Remove Bad IP
            ngx.log(ngx.ERR, appname..": removed the bad IP "..client_remoteip)
            redis:zrem(redis_blacklist_key, client_remoteip)
        end
    end
end

-- Check IP Score For Making An Alarm
local ip_score, err = redis:hget(redis_score_badip, client_remoteip)
if ip_score ~= ngx.null then
    if ip_score >= level_sms then
        ngx.log(ngx.ERR, appname..": SMS - Slack "..client_remoteip)
        notiSlack(client_message)
    else if ip_score >= level_block then
        ngx.log(ngx.ERR, appname..": Blocking "..client_remoteip)
        blockAcion(rule_block)
    end
    return
end
-- Default allow all request
return