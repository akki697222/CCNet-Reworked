local modem = peripheral.find("modem")
local monitor = peripheral.find("monitor")
monitor.setTextScale(0.5)
monitor.clear()
monitor.setCursorPos(1,1)
modem.open(10000)
modem.open(11000)
modem.open(31414)
::continue::
local s, e = pcall(function ()
    repeat
        local x, y = monitor.getCursorPos()
        local width, height = monitor.getSize()
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        local serialised_message = textutils.serialiseJSON(message) or message
        monitor.write(serialised_message.." from "..channel)
        if y >= height - 1 then
            monitor.setCursorPos(1, y + 1)
            monitor.scroll(1)
        else
            monitor.setCursorPos(1, y + 1)
        end
    until false
end)
if not s then
    print(e)
    goto continue
end