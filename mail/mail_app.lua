local basalt = require("libraries.basalt")
local mail = require("mail")
local json = require("libraries.json")
local width, height = term.getSize()
local user = mail.getAddressUser(mail.channel)
local config = require("config")
local function getCenter(text)
    return width / 2 - (string.len(text) / 2)
end

local main = basalt.createFrame():setBackground(config.user.color.main)
local mailwindow = basalt.createFrame():setBackground():setBackground(config.user.color.main)
--panels
main:addPane():setPosition(1, 1):setSize(width, 1):setBackground(config.user.color.sub)
main:addPane():setPosition(1, height):setSize(width, 1):setBackground(config.user.color.sub)
mailwindow:addPane():setPosition(1, 1):setSize(width, 1):setBackground(config.user.color.sub)
local mails = main:addScrollableFrame():setSize(width - 2, height - 4):setPosition(2, 3):setForeground(config.user.color
.text)
mails:addLabel():setText("----------------"):setPosition(2, 1)
--create mail window textboxes
local tolabel = mailwindow:addLabel():setPosition(2, 5):setText("TO"):setForeground(config.user.color.text)
local toinput = mailwindow:addInput():setPosition(10, 5):setSize(width - 10, 1):setForeground(config.user.color.text)
:setInputType("text")
local fromlabel = mailwindow:addLabel():setPosition(2, 3):setText("FROM"):setForeground(config.user.color.text)
local frominput = mailwindow:addInput():setPosition(10, 3):setSize(width - 10, 1):setForeground(config.user.color.text)
:setInputType("text")
local subjectlabel = mailwindow:addLabel():setPosition(2, 7):setText("SUBJECT"):setForeground(config.user.color.text)
local subjectinput = mailwindow:addInput():setPosition(10, 7):setSize(width - 10, 1):setForeground(config.user.color
.text):setInputType("text")
local contentlabel = mailwindow:addLabel():setPosition(2, 9):setText("CONTENT"):setForeground(config.user.color.text)
local contentinput = mailwindow:addTextfield():setPosition(2, 10):setSize(width - 2, (height - 10) - 2):setForeground(
config.user.color.text)
local channellabel = mailwindow:addLabel():setPosition(2, height - 1):setText("ADDRESS"):setForeground(config.user.color
.text)
local channelinput = mailwindow:addInput():setPosition(10, height - 1):setSize(width - 10, 1):setForeground(config.user
.color.text):setInputType("text")
--labels
main:addLabel():setPosition(1, height):setText("User: " .. user):setForeground(config.user.color.text)
main:addLabel():setPosition(getCenter("Mail"), 1):setText("Mail"):setForeground(config.user.color.text)
mailwindow:addLabel():setPosition(getCenter("Create Mail"), 1):setText("Create Mail"):setForeground(config.user.color
.text)
--func
local posY = 2
local function getMail()
    repeat
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if message then
            if message.type == "mail" then
                if message.content then
                    if message.content.to and message.content.from and message.content.subject and message.content.content then
                        local subject = message.content.subject
                        local savemail = {}
                        savemail[subject] = message.content
                        json.dump_v("mails_subject.json", subject)
                        json.dump("mails.json", savemail)
                        posY = posY + 1
                        mails:addLabel():setText("Mail from " .. message.content.from):setPosition(2, posY)
                        posY = posY + 2
                        mails:addLabel():setText("Subject: " .. message.content.subject):setPosition(2, posY)
                        posY = posY + 1
                        for i, v in pairs(textutils.unserialiseJSON(message.content.content)) do
                            posY = posY + 1
                            mails:addLabel():setText(v):setPosition(2, posY)
                        end
                        posY = posY + 2
                        mails:addLabel():setText("----------------"):setPosition(2, posY)
                        posY = posY + 1
                    end
                end
            end
        end
    until false
end
local debug
local function readMail()
    local rjsonfile = fs.open("mails.json", "r")
    local jsonfile = rjsonfile.readAll()
    rjsonfile.close()
    local rmailsubject = fs.open("mails_subject.json", "r")
    local mailsubject = rmailsubject.readAll()
    rmailsubject.close()
    if jsonfile ~= nil and mailsubject ~= nil then
        local mailtbl = textutils.unserialiseJSON(jsonfile)
        local mailsubject = textutils.unserialiseJSON(mailsubject)
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
                    mails:addLabel():setText("Mail from " .. mailtbl[v].from):setPosition(2, posY)
                    posY = posY + 2
                    mails:addLabel():setText("Subject: " .. mailtbl[v].subject):setPosition(2, posY)
                    posY = posY + 1
                    for i, v in pairs(textutils.unserialiseJSON(mailtbl[v].content)) do
                        posY = posY + 1
                        mails:addLabel():setText(v):setPosition(2, posY)
                    end
                    posY = posY + 2
                    mails:addLabel():setText("----------------"):setPosition(2, posY)
                    posY = posY + 1
                end
            end
        end
    end
end

local function sendMail()
    local content = contentinput:getLines()
    --basalt.debug("from "..frominput:getValue().." to "..toinput:getValue().." subject "..subjectinput:getValue().." channel "..channelinput:getValue().." content \n".._content)
    if toinput:getValue() and frominput:getValue() and subjectinput:getValue() and channelinput:getValue() then
        mail.send(frominput:getValue(), toinput:getValue(), subjectinput:getValue(), textutils.serialiseJSON(content),
            channelinput:getValue())
    end
end
--buttons
main:addButton():setPosition(width - 6, 1):setSize(6, 1):setText(" EXIT "):setBackground(colors.red):onClick(function()
    os.queueEvent("terminate") end):setForeground(config.user.color.text)
main:addButton():setPosition(2, 1):setSize(14, 1):setText(" Create Mails "):setBackground(colors.blue):onClick(function()
    main:hide()
    mailwindow:show()
end):setForeground(config.user.color.text)
mailwindow:addButton():setPosition(width - 6, 1):setSize(6, 1):setText(" EXIT "):setBackground(colors.red):onClick(function()
    mailwindow:hide()
    main:show()
end):setForeground(config.user.color.text)
mailwindow:addButton():setPosition(2, 1):setSize(12, 1):setText(" Send Mails "):setBackground(colors.blue):onClick(
sendMail):setForeground(config.user.color.text)

readMail()
parallel.waitForAll(basalt.autoUpdate, getMail)
