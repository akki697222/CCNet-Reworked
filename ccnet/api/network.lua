local modem = peripheral.find("modem") or error("No modem attached.")
local log = require("logger")
local config = require("config")
local logger = log.getLogger("/logs/network", "network")
local commlog = log.getLogger("/logs/network", "comm")
local counter = 0
local timeout = config.network.timeout
local timeouted = false

local function ping()
    repeat
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if message then
            if message.type == "ping" then
                return
            end
        end
    until false
end

local function wait()
    counter = 0
    repeat
        if counter >= timeout then
            timeouted = true
            return
        end
        sleep(0.1)
        counter = counter + 1
    until false
end

local network = {}

function network.init()
    logger.init()
    commlog.init()
    logger.info("Logger initialized")
    if config.network.channel ~= 10000 then
        logger.info("Sending ping to server...")
        local randomnumber = math.random(65533)
        network.open(randomnumber)
        local ping = network.ping(randomnumber, config.channel.server)
        if ping == "timeout" then
            logger.error("Can't connect to server.")
            print("Can't connect to server.")
        else
            logger.info("ping " .. ping .. "ms")
        end
        network.closeAll()
    end
end

function network.getServerChannel(server)
    local payload = {
        type = "require",
        source = config.network.channel,
        destination = config.channel.server,
        content = {
            require = "server_channel",
            server = server
        }
    }
    network.transmit(config.network.channel, config.channel.server, payload)
    repeat
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if message.type == "reply" then
            if message.content.reply then
                return message.content.reply
            end
        end
    until false
end

function network.open(channel)
    logger.info("Opening channel " .. channel .. "...")
    local s, e = pcall(function() modem.open(channel) end)
    if not s then
        logger.fatal("Error occurred in opening channel", e)
    else
        logger.info("Successfully opened channel " .. channel .. ".")
    end
end

function network.close(channel)
    logger.info("Closing channel " .. channel .. "...")
    modem.close(channel)
    logger.info("Closed channel " .. channel .. ".")
end

function network.transmit(src, dest, payload)
    modem.transmit(tonumber(dest), tonumber(src), payload)
    commlog.comm("Transmitted Packet", src, dest, payload)
end

function network.ping(src, dest)
    local payload = {
        type = "ping",
        destination = dest,
        source = src
    }
    network.transmit(src, dest, payload)
    parallel.waitForAny(ping, wait)
    if timeouted then
        timeouted = false
        return "timeout"
    end
    return counter
end

function network.closeAll()
    logger.info("Closing all channels...")
    modem.closeAll()
    logger.info("Closed all channels.")
end

return network
