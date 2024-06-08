local basalt = require("libraries.basalt")
local mail = require("mail")
local width, height = term.getSize()
local user = mail.getAddressUser(mail.channel)
local config = require("config")
local function getCenter(text)
    return width / 2 - (string.len(text) / 2)
end

local main = basalt.createFrame():setBackground(config.user.color.main)
local mailwindow = basalt.createFrame():setBackground():setBackground(config.user.color.main)
local setup = basalt.createFrame():setBackground():setBackground(config.user.color.main)
--panels
main:addPane():setPosition(1, 1):setSize(width, 1):setBackground(config.user.color.sub)
main:addPane():setPosition(1, height):setSize(width, 1):setBackground(config.user.color.sub)
setup:addPane():setPosition(1, 1):setSize(width, 1):setBackground(config.user.color.sub)
setup:addPane():setPosition(1, height):setSize(width, 1):setBackground(config.user.color.sub)
mailwindow:addPane():setPosition(1, 1):setSize(width, 1):setBackground(config.user.color.sub)
mailwindow:addPane():setPosition(1, height):setSize(width, 1):setBackground(config.user.color.sub)
local mails = main:addScrollableFrame():setSize(width - 2, height - 4):setPosition(2, 3):setForeground(config.user.color
.text)
mails:addLabel():setText("----------------"):setPosition(2, 2):setForeground(config.user.color.text)
setup:addLabel():setText("Mail Setup"):setPosition(getCenter("Mail Setup"), 1):setForeground(config.user.color.text)
--create mail window textboxes
local tolabel = mailwindow:addLabel():setPosition(2, 5):setText("To"):setForeground(config.user.color.text)
local toinput = mailwindow:addInput():setPosition(10, 5):setSize(width - 10, 1):setForeground(config.user.color.text)
:setInputType("text")
local fromlabel = mailwindow:addLabel():setPosition(2, 3):setText("From"):setForeground(config.user.color.text)
local frominput = mailwindow:addInput():setPosition(10, 3):setSize(width - 10, 1):setForeground(config.user.color.text)
:setInputType("text")
local subjectlabel = mailwindow:addLabel():setPosition(2, 7):setText("Subject"):setForeground(config.user.color.text)
local subjectinput = mailwindow:addInput():setPosition(10, 7):setSize(width - 10, 1):setForeground(config.user.color
.text):setInputType("text")
local contentlabel = mailwindow:addLabel():setPosition(2, 9):setText("Content"):setForeground(config.user.color.text)
local contentinput = mailwindow:addTextfield():setPosition(2, 10):setSize(width - 2, (height - 10) - 3):setForeground(
config.user.color.text)
local channellabel = mailwindow:addLabel():setPosition(2, height - 2):setText("Address"):setForeground(config.user.color
.text)
local channelinput = mailwindow:addInput():setPosition(10, height - 2):setSize(width - 10, 1):setForeground(config.user
.color.text):setInputType("text")
local userchannellabel = setup:addLabel():setPosition(2, 5):setText("Channel"):setForeground(config.user.color.text)
local userchannelinput = setup:addInput():setPosition(12, 5):setSize(width - 12, 1):setForeground(config.user.color.text)
:setInputType("number")
local usernamelabel = setup:addLabel():setPosition(2, 3):setText("User Name"):setForeground(config.user.color.text)
local usernameinput = setup:addInput():setPosition(12, 3):setSize(width - 12, 1):setForeground(config.user.color.text)
:setInputType("text")
--labels
main:addLabel():setPosition(1, height):setText("User: " .. user):setForeground(config.user.color.text)
mailwindow:addLabel():setPosition(1, height):setText("User: " .. user):setForeground(config.user.color.text)
main:addLabel():setPosition(getCenter("Mail"), 1):setText("Mail"):setForeground(config.user.color.text)
mailwindow:addLabel():setPosition(getCenter("Mail"), 1):setText("Mail"):setForeground(config.user.color.text)
--func
local posY = 3
local function writeJson(message)
    local mail_subject = fs.open("/mails_subject.json", "r+")
    local mail_subject_content = mail_subject.readAll()
    mail_subject.close()
    local mail_subject_table = textutils.unserialiseJSON(mail_subject_content) or {}
    local subject = message.content.subject
    local mail = fs.open("/mails.json", "r+")
    local mail_content = mail.readAll()
    mail.close()
    local mail_table = textutils.unserialiseJSON(mail_content) or {}
    mail_table[subject] = message.content
    table.insert(mail_subject_table, subject)
    local mail_subject = fs.open("/mails_subject.json", "w+")
    mail_subject.write(textutils.serialiseJSON(mail_subject_table))
    mail_subject.close()
    local mail = fs.open("/mails.json", "w+")
    mail.write(textutils.serialiseJSON(mail_table))
    mail.close()
end
local function getMail()
    repeat
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if message then
            if message.type == "mail" then
                if message.content then
                    if message.content.to and message.content.from and message.content.subject and message.content.content then
                        writeJson(message)
                        posY = posY + 1
                        mails:addLabel():setText("Mail from " .. message.content.from):setPosition(2, posY):setForeground(config.user.color.text)
                        posY = posY + 2
                        mails:addLabel():setText("Subject: " .. message.content.subject):setPosition(2, posY):setForeground(config.user.color.text)
                        posY = posY + 1
                        for i, v in pairs(textutils.unserialiseJSON(message.content.content)) do
                            posY = posY + 1
                            mails:addLabel():setText(v):setPosition(2, posY):setForeground(config.user.color.text)
                        end
                        posY = posY + 2
                        mails:addLabel():setText("----------------"):setPosition(2, posY):setForeground(config.user.color.text)
                        posY = posY + 1
                    end
                end
            end
        end
    until false
end
local debug
local function readMail()
    local rjsonfile = fs.open("/mails.json", "r+")
    local jsonfile = rjsonfile.readAll()
    rjsonfile.close()
    local rmailsubject = fs.open("/mails_subject.json", "r+")
    local mailsubject = rmailsubject.readAll()
    rmailsubject.close()
    if jsonfile ~= nil and mailsubject ~= nil then
        local mailtbl = textutils.unserialiseJSON(jsonfile)
        local mailsubject = textutils.unserialiseJSON(mailsubject)
        if mailtbl == nil then
            mailtbl = {}
        end
        if mailsubject == nil then
            mailsubject = {}
        end
        if mailtbl and mailsubject then
            for k, v in pairs(mailsubject) do
                --basalt.debug(k .. " " .. v)
                --basalt.debug(mailtbl[v])
                if not mailtbl[v] then
                    return
                end
                if mailtbl[v].to and mailtbl[v].from and mailtbl[v].subject and mailtbl[v].content then
                    --basalt.debug(mailtbl[v].to .. " " ..mailtbl[v].from .. " " .. mailtbl[v].subject .. " " .. mailtbl[v].content)
                    posY = posY + 1
                    mails:addLabel():setText("Mail from " .. mailtbl[v].from):setPosition(2, posY):setForeground(config
                    .user.color.text)
                    posY = posY + 2
                    mails:addLabel():setText("Subject: " .. mailtbl[v].subject):setPosition(2, posY):setForeground(
                    config.user.color.text)
                    posY = posY + 1
                    for i, v in pairs(textutils.unserialiseJSON(mailtbl[v].content)) do
                        posY = posY + 1
                        mails:addLabel():setText(v):setPosition(2, posY):setForeground(config.user.color.text)
                    end
                    posY = posY + 2
                    mails:addLabel():setText("----------------"):setPosition(2, posY):setForeground(config.user.color
                    .text)
                    posY = posY + 1
                end
            end
        end
    end
end

local function setup_func()
    local username = usernameinput:getValue()
    local channelinput = userchannelinput:getValue()
    if username:gsub(" ", "") ~= "" or username ~= nil then
        if channelinput:gsub(" ", "") ~= "" or channelinput ~= nil then
            local modem = peripheral.find("modem")
            local payload = { type = "register", source = config.network.channel, destination = 10000, register = { type = "mail_address", address = username, channel = channelinput } }
            modem.transmit(10000, config.network.channel, payload)
            setup:hide()
            mailwindow:hide()
            main:show()
            return
        else
            return
        end
    else
        return
    end
end

local function sendMail()
    local content = contentinput:getLines()
    --basalt.debug("from "..frominput:getValue().." to "..toinput:getValue().." subject "..subjectinput:getValue().." channel "..channelinput:getValue().." content \n".._content)
    local to_, from_, subject_, channel_ = toinput:getValue(), frominput:getValue(), subjectinput:getValue(),
        channelinput:getValue()
    if to_:gsub(" ", "") ~= "" and from_:gsub(" ", "") ~= "" and subject_:gsub(" ", "") ~= "" and channel_:gsub(" ", "") ~= "" then
        mail.send(frominput:getValue(), toinput:getValue(), subjectinput:getValue(), textutils.serialiseJSON(content),
            channelinput:getValue())
    end
end
--buttons
main:addButton():setPosition(width - 6, 1):setSize(6, 1):setText(" EXIT "):setBackground(colors.red):onClick(function()
    os.queueEvent("terminate") end):setForeground(config.user.color.text)
main:addButton():setPosition(2, 1):setSize(8, 1):setText(" Create "):setBackground(colors.blue):onClick(function()
    main:hide()
    mailwindow:show()
end):setForeground(config.user.color.text)
mailwindow:addButton():setPosition(width - 6, 1):setSize(6, 1):setText(" BACK "):setBackground(colors.red):onClick(function()
    mailwindow:hide()
    main:show()
end):setForeground(config.user.color.text)
mailwindow:addButton():setPosition(2, 1):setSize(6, 1):setText(" Send "):setBackground(colors.blue):onClick(sendMail)
    :setForeground(config.user.color.text)
setup:addButton():setPosition(width - 4, height):setSize(4, 1):setText(" OK "):setBackground(colors.blue):onClick(
setup_func):setForeground(config.user.color.text)

if not fs.exists("/mails_subject.json") then
    local file = fs.open("/mails_subject.json", "w")
    file.write("{}")
    file.close()
end
if not fs.exists("/mails.json") then
    local file = fs.open("/mails.json", "w")
    file.write("{}")
    file.close()
end

local setup_f = fs.open(".mailapp", "r+")
local setup_bool = setup_f.readAll()
if string.find(setup_bool, "false") then
    setup_f.close()
    local setup_f = fs.open(".mailapp", "w+")
    setup_f.write("true")
    setup_f.close()
    main:hide()
    mailwindow:hide()
    setup:show()
end

local s, e = pcall(readMail)
if not s then
    main:addLabel():setText("Too many mails saved. please delete some mails."):setPosition(2, 2):setForeground(colors
    .red)
end
parallel.waitForAll(basalt.autoUpdate, getMail)
