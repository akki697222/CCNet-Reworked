local network = require("api.network")
local config = require("config")
local log = require("libraries.logger")
local logger = log.getVisualLogger()
local channel = config.network.channel
local channels = {
    server_core = 10000
}
if not fs.exists("mail_addresses.json") then
    local file = fs.open("mail_addresses.json", "w")
    file.write("{}")
    file.close()
end
network.init()
network.open(channel)
term.clear()
term.setCursorPos(1,1)
logger.info("Server Started!")

local function time(n)
    local h = math.floor(n / 3600)
    local m = math.floor(n / 60) % 60
    local s = n % 60
    local retval = s .. "s"
    if m > 0 or h > 0 then retval = m .. "m " .. retval end
    if h > 0 then retval = h .. "h " .. retval end
    return retval
end

local function core()
    repeat
        local event, side, c, replyChannel, message, distance = os.pullEvent("modem_message")
        logger.info("Received Message")
        if message then
            if message.type == "require" then
                logger.info("Received request")
                if message.content then
                    logger.info("Valid Message")
                    if message.content.require == "server_channel" then
                        logger.info("Required Channel: " .. message.content.server)
                        local transmited = false
                        for key, value in pairs(channels) do
                            if key == message.content.server then
                                local payload = {
                                    type = "reply",
                                    source = channel,
                                    destination = message.source,
                                    content = {
                                        reply = value
                                    }
                                }
                                network.transmit(channel, message.source, payload)
                                transmited = true
                                break
                            end
                        end
                        logger.info("Reply ended")
                        if not transmited then
                            local payload = {
                                type = "reply",
                                source = channel,
                                destination = message.source,
                                content = {
                                    reply = "notfound"
                                }
                            }
                            network.transmit(channel, message.source, payload)
                        end
                    elseif message.content.require == "mail_address" then
                        logger.info("Required mail address: " .. message.content.address)
                        local file = fs.open("mail_addresses.json", "r")
                        local mail_addresses = textutils.unserialiseJSON(file.readAll())
                        if mail_addresses == nil then
                            mail_addresses = {}
                        end
                        file.close()
                        local transmited = false
                        for key, value in pairs(mail_addresses) do
                            if key == message.content.address then
                                logger.info("Requested address " .. message.content.address .. " channel is " .. value)
                                local payload = {
                                    type = "reply",
                                    source = channel,
                                    destination = message.source,
                                    content = {
                                        reply = value
                                    }
                                }
                                network.transmit(channel, message.source, payload)
                                transmited = true
                                break
                            end
                        end
                        logger.info("Reply ended")
                        if not transmited then
                            local payload = {
                                type = "reply",
                                source = channel,
                                destination = message.source,
                                content = {
                                    reply = "notfound"
                                }
                            }
                            network.transmit(channel, message.source, payload)
                        end
                    elseif message.content.require == "address_user" then
                        logger.info("Required mail address: " .. message.content.address)
                        local file = fs.open("mail_addresses.json", "r")
                        local mail_addresses = textutils.unserialiseJSON(file.readAll())
                        if mail_addresses == nil then
                            mail_addresses = {}
                        end
                        file.close()
                        local transmited = false
                        for key, value in pairs(mail_addresses) do
                            if value == message.content.address then
                                logger.info("Requested channel " .. message.content.address .. " address is " .. key)
                                local payload = {
                                    type = "reply",
                                    source = channel,
                                    destination = message.source,
                                    content = {
                                        reply = key
                                    }
                                }
                                network.transmit(channel, message.source, payload)
                                transmited = true
                                break
                            end
                        end
                        if not transmited then
                            local payload = {
                                type = "reply",
                                source = channel,
                                destination = message.source,
                                content = {
                                    reply = "notfound"
                                }
                            }
                            network.transmit(channel, message.source, payload)
                        end

                    end
                else
                    logger.error("Invalid packet received.")
                end
            elseif message.type == "info" then
                logger.info("Requested info")
                network.transmit(channel, message.source, { type = "reply", source = channel, destination = message.source, content = {server_name = config.server.name, server_version = config.server.version, uptime = time(os.clock())}})
            elseif message.type == "ping" then
                logger.info("Received ping")
                network.transmit(channel, message.source, { type = "ping", source = channel, destination = message.source })
            elseif message.type == "register" then
                logger.info("Received register request")
                if message.register.type then
                    if message.register.type == "mail_address" then
                        if message.register.address and message.register.channel then
                            logger.info("Registering address " ..
                            message.register.address .. " to channel " .. message.register.channel)
                            local file = fs.open("mail_addresses.json", "r")
                            local mail_addresses = textutils.unserialiseJSON(file.readAll())
                            if mail_addresses == nil then
                                mail_addresses = {}
                            end
                            file.close()
                            local file = fs.open("mail_addresses.json", "w+")
                            mail_addresses[message.register.address] = message.register.channel
                            file.write(textutils.serialiseJSON(mail_addresses))
                            file.close()
                        end
                    elseif message.register.type == "server" then
                        if message.register.servername and message.register.channel then
                            logger.info("Registering server "..message.register.servername)
                            channels[message.register.servername] = message.register.channel
                        end
                    end
                else
                    logger.error("Invalid packet received.")
                end
            end
        else
            logger.error("Message not contain payload.")
        end
    until false
end

if not fs.exists("mail_addresses.json") then
    local file = fs.open("mail_addresses.json", "w")
    file.close()
end

core()
