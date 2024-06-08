local defaultColor = colors.white
local logger = {}
local loggerver = "0.2.2"

local logColor = {
    info = colors.lime,
    warn = colors.orange,
    error = colors.red,
    debug = colors.blue,
    comm = colors.green
}

local function printColored(message, color)
    term.setTextColor(color)
    io.write(message)
    term.setTextColor(defaultColor)
end

local function printlnColored(message, color)
    term.setTextColor(color)
    print(message)
    term.setTextColor(defaultColor)
end

local function writeColored(message, monitor, color)
    monitor.setTextColor(color)
    monitor.write(message)
    monitor.setTextColor(defaultColor)
end

local function writelnColored(message, monitor, color)
    local x, y = monitor.getCursorPos()
    local w, h = monitor.getSize()
    monitor.setCursorPos(1, y + 1)
    if y >= h then
        monitor.scroll(1)
        monitor.setCursorPos(1, h)
    end
    monitor.setTextColor(color)
    monitor.write(message)
    monitor.setTextColor(defaultColor)
end

local function writeln(message, monitor)
    local x, y = monitor.getCursorPos()
    local w, h = monitor.getSize()
    monitor.setCursorPos(1, y + 1)
    if y >= h then
        monitor.scroll(1)
        monitor.setCursorPos(1, h)
    end
    monitor.write(message)
end

local function write(message, monitor)
    monitor.write(message)
end

logger.initVisualLogger = function (monitor)
    if monitor then
        monitor.setTextScale(0.5)
        monitor.setCursorPos(1,1)
        monitor.clear()
    else
        term.setCursorPos(1,1)
        term.clear()
    end
end

logger.getVisualLogger = function(monitor)
    local obj = {}
    if monitor then
        write("Logger.cc Ver "..loggerver, monitor)
        local x, y = monitor.getCursorPos()
        local w, h = monitor.getSize()
        obj = {
            info = function(message)
                writeln(os.date("%c").." ", monitor)
                writeColored("[INFO] ", monitor, logColor.info)
                writeColored(message, monitor, colors.lightGray)
            end,
            debug = function(message)
                writeln(os.date("%c").." ", monitor)
                writeColored("[DEBUG] ", monitor, logColor.debug)
                writeColored(message, monitor, colors.lightGray)
            end,
            warn = function(message)
                writeln(os.date("%c").." ", monitor)
                writeColored("[WARN] ", monitor,logColor.warn)
                writeColored(message, monitor, colors.lightGray)
            end,
            error = function(message)
                writeln(os.date("%c").." ", monitor)
                writeColored("[ERROR] ", monitor, logColor.error)
                writeColored(message, monitor, colors.lightGray)
            end,
            fatal = function(message, error)
                writeln(os.date("%c").." ", monitor)
                writeColored("[FATAL] ", monitor, logColor.error)
                writeColored(message, monitor, colors.lightGray)
                writelnColored(error, monitor, logColor.error)
            end,
            comm = function (message, src, dest, packet)
                writeln(os.date("%c").." ", monitor)
                writeColored("[COMM] ", monitor, logColor.comm)
                writeColored("["..src.."] \26 ["..dest.."] "..message, monitor, colors.white)
                writelnColored("("..textutils.serialize(packet)..")", monitor, colors.lightGray)
            end,
            commjson = function (message, src, dest, packet)
                writeln(os.date("%c").." ", monitor)
                writeColored("[COMM] ", monitor, logColor.comm)
                writeColored("["..src.."] \26 ["..dest.."] "..message, monitor, colors.white)
                writelnColored("("..textutils.serializeJSON(packet):gsub("%s", "")..")", monitor, colors.lightGray)
            end
        }
    else
        obj = {
            info = function(message)
                print()
                io.write(os.date("%c").." ")
                printColored("[INFO] ", logColor.info)
                printColored(message, colors.lightGray)
            end,
            debug = function (message)
                print()
                io.write(os.date("%c").." ")
                printColored("[DEBUG] ", logColor.debug)
                printColored(message, colors.lightGray)
            end,
            warn = function(message)
                print()
                io.write(os.date("%c").." ")
                printColored("[WARN] ", logColor.warn)
                printColored(message, colors.lightGray)
            end,
            error = function(message)
                print()
                io.write(os.date("%c").." ")
                printColored("[ERROR] ", logColor.error)
                printlnColored(message, colors.lightGray)
            end,
            fatal = function(message, error)
                print()
                io.write(os.date("%c").." ")
                printColored("[FATAL] ", logColor.error)
                printColored(message, colors.lightGray)
                printlnColored(error, logColor.error)
            end,
            comm = function (message, src, dest, packet)
                print()
                io.write(os.date("%c").." ")
                printColored("[COMM] ", colors.green)
                printColored("["..src.."] \26 ["..dest.."] "..message, colors.white)
                printlnColored("("..textutils.serializeJSON(packet)..")", colors.lightGray)
            end,
            commjson = function (message, src, dest, packet)
                print()
                io.write(os.date("%c").." ")
                printColored("[COMM] ", colors.green)
                printColored("["..src.."] \26 ["..dest.."] "..message, colors.white)
                printlnColored("("..textutils.serialize(packet):gsub("%s", "")..")", colors.lightGray)
            end
        }
    end
    return obj
end

function logger.getLogger(path, logname)
    local lPath = path.."/"..logname.."_"..os.date("%Y-%m-%d")..".log"
    local obj = {
        replace = function()
            local logfile = fs.open(lPath, "w+")
            logfile.write("--- Logger.cc Ver "..loggerver.." "..os.date("%Y-%m-%d %H:%M").."---\n")
            logfile.close()
        end,
        init = function()
            if not fs.exists(lPath) then
                local file = fs.open(lPath, "w")
                file.close()
            end
            local logfile = fs.open(lPath, "a")
            logfile.write("--- Logger.cc Ver "..loggerver.." "..os.date("%Y-%m-%d %H:%M").."---\n")
            logfile.close()
        end,
        info = function(message)
            local logfile = fs.open(lPath, "a")
            local log = os.date("%c").." ".."[INFO] "..message
            logfile.write(log.."\n")
            logfile.close()
        end,
        debug = function (message)
            local logfile = fs.open(lPath, "a")
            local log = os.date("%c").." ".."[DEBUG] "..message
            logfile.write(log.."\n")
            logfile.close()
        end,
        warn = function(message)
            local logfile = fs.open(lPath, "a")
            local log = os.date("%c").." ".."[WARN] "..message
            logfile.write(log.."\n")
            logfile.close()
        end,
        error = function(message)
            local logfile = fs.open(lPath, "a")
            local log = os.date("%c").." ".."[ERROR] "..message
            logfile.write(log.."\n")
            logfile.close()
        end,
        fatal = function(message, error)
            local logfile = fs.open(lPath, "a")
            local log = os.date("%c").." ".."[FATAL] "..message
            logfile.write(log.."\n")
            logfile.write(error.."\n")
            logfile.close()
        end,
        comm = function (message, src, dest, packet)
            local logfile = fs.open(lPath, "a")
            local log = os.date("%c").." ".."[COMM] ["..src.."] -> ["..dest.."] "..message
            logfile.write(log.."\n")
            logfile.write("("..textutils.serialize(packet)..")\n")
            logfile.close()
        end,
        commjson = function (message, src, dest, packet)
            local logfile = fs.open(lPath, "a")
            local log = os.date("%c").." ".."[COMM] ["..src.."] -> ["..dest.."] "..message
            logfile.write(log.."\n")
            logfile.write("("..textutils.serializeJSON(packet)..")\n")
            logfile.close()
        end
    }
    return obj
end

return logger
