local network = require("network")
network.init()
local randomnumber = math.random(65533)
network.open(randomnumber)
while true do
    local input = read()
    if input == "ping" then
        local pingms = network.ping(randomnumber, 10000)
        if pingms == "timeout" then
            print("ping timeouted")
        else
            print(pingms.."ms")
        end
    elseif input == "exit" then
        break
    end
end