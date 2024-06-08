local log = require("libraries.logger")
local logger = log.getLogger("/logs", "json")
local json = {}

function json.serialize(table)
    return textutils.serialiseJSON(table)
end

function json.unserialise(str)
    return textutils.unserialiseJSON(str)
end

function json.dump(path, tables)
    logger.info("Dumping json...")
    local table_raw
    local rawfile = fs.open(path, "r")
    logger.info("JSON: " .. rawfile.readAll())
    table_raw = textutils.unserialiseJSON(rawfile.readAll())
    rawfile.close()
    table.insert(table_raw, tables)
    local rawfile = fs.open(path, "w+")
    rawfile.write(textutils.serialiseJSON(table_raw))
    rawfile.close()
end

function json.dump_v(path, value)
    logger.info("Dumping json...")
    local table_raw
    local rawfile = fs.open(path, "r")
    logger.info("JSON: " .. rawfile.readAll())
    table_raw = json.unserialise(rawfile.readAll())
    rawfile.close()
    table.insert(table_raw, value)
    local rawfile = fs.open(path, "w+")
    rawfile.write(json.serialize(table_raw))
    rawfile.close()
end

function json.dump_kv(path, key, value)
    local table_raw
    local rawfile = fs.open(path, "r")
    if rawfile.readAll() ~= nil then
        table_raw = json.unserialise(rawfile.readAll())
        rawfile.close()
    end
    table_raw[key] = value
    local rawfile = fs.open(path, "w+")
    rawfile.write(json.serialize(table_raw))
    rawfile.close()
end

function json.read(path)
    local rawfile = fs.open(path, "r")
    return rawfile.readAll()
end

return json
