local network = require("network")
local config = require("config")
local log = require("libraries.logger")
local logger = log.getVisualLogger()
local channel = 11000

--[[
    protocol
    {
        type = "mail",
        source = 00000,
        destination = 00000,
        mail = {
            from = "A",
            to = "B",
            subject = "subject",
            content = "hello, world!"
        }
    }
]]
    
local function time(n)
    local h = math.floor(n / 3600)
    local m = math.floor(n / 60) % 60
    local s = n % 60
    local retval = s .. "s"
    if m > 0 or h > 0 then retval = m .. "m " .. retval end
    if h > 0 then retval = h .. "h " .. retval end
    return retval
end

network.init()
network.open(channel)
term.clear()
term.setCursorPos(1,1)
logger.info("Server Started!")
::continue::
local s, e = pcall(function (...)
    repeat
        local event, side, c, replyChannel, message, distance = os.pullEvent("modem_message")
        logger.info("Received Message")
        if message then
            if message.type == "mail" then
                logger.info("Received Mail")
                if message.content then
                    logger.info("Mail source: "..message.source.." destination: "..message.destination)
                    network.transmit(channel, message.destination, message)
                else
                    logger.error("Invalid mail received.")
                end
            elseif message.type == "ping" then
                logger.info("Received ping")
                network.transmit(channel, message.source, {type = "ping", source = channel, destination = message.source})
            elseif message.type == "info" then
                logger.info("Requested info")
                network.transmit(channel, message.source, { type = "reply", source = channel, destination = message.source, content = {server_name = config.server.name, server_version = config.server.version, uptime = time(os.clock())}})
            end
        else
            logger.error("Message not contain payload.")
        end
    until false
end)
if not s then
    if e == "Terminated" then
        return
    end
    logger.fatal("Error occurred in running server.", e)
    goto continue
end

--modem = peripheral.find("modem") p = {type = "register", source = "10004", destination = "10000", register = {type = "mail_address", address = "akki_debug", "channel" = 10004}} modem.transmit(10000, 10004, p)