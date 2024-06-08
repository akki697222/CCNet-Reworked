local modem = peripheral.find("modem")
modem.open(10000)
repeat
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    if message.type == "ping" then
        print("Received ping from "..message.source)
        modem.transmit(message.source, 10000, {type = "ping"})
    else
        break
    end
until false