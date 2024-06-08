local network = require("network")
local config = require("config")
local basalt = require("basalt")
local modem = peripheral.find("modem")
local channel = config.network.channel
network.init()
network.open(channel)

local mail = {
    user = "not set"
}

function mail.getAddressUser(address)
    local payload = {
        type = "require",
        source = channel,
        destination = config.channel.server,
        content = {
            require = "address_user",
            address = address
        }
    }
    network.transmit(channel, config.channel.server, payload)
    repeat
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if message.type == "reply" then
            if message.content.reply then
                return message.content.reply
            end
        end
    until false
end

function mail.getMailAddress(address)
    local payload = {
        type = "require",
        source = channel,
        destination = config.channel.server,
        content = {
            require = "mail_address",
            address = address
        }
    }
    network.transmit(channel, config.channel.server, payload)
    repeat
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if message.type == "reply" then
            if message.content.reply then
                return message.content.reply
            end
        end
    until false
end

function mail.send(from, to, subject, content, destination)
    local mailaddress_channel = mail.getMailAddress(destination)
    local payload = {
        type = "mail",
        source = channel,
        destination = mailaddress_channel,
        content = {
            from = from,
            to = to,
            subject = subject,
            content = content
        }
    }
    local mailserver_channel = network.getServerChannel("mail_server")
    network.transmit(mailaddress_channel, mailserver_channel, payload)
end

mail.channel = channel

return mail

--mail = require("mail") 
--mail.send("akki", "mameen", "nanmonaiyo", "print('Hello, World!')", 10002)
--