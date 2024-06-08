local args = { ... }
---@param url string
local function wget(url)
    shell.run("wget " .. url)
end
---@param path string
local function mkdir(path)
    shell.run("mkdir " .. path)
end
---@param path string
local function cd(path)
    shell.run("cd " .. path)
end

local function install_base()
    print("Installing CCNet libraries...")
    mkdir("api")
    mkdir("libraries")
    cd("/")
    wget("https://raw.githubusercontent.com/akki697222/CCNet-Reworked/main/ccnet/config.lua")
    cd("/api")
    wget("https://raw.githubusercontent.com/akki697222/CCNet-Reworked/main/ccnet/api/network.lua")
    cd("/libraries")
    wget("https://raw.githubusercontent.com/akki697222/CCNet-Reworked/main/ccnet/library/json.lua")
    wget("https://raw.githubusercontent.com/akki697222/CCNet-Reworked/main/ccnet/library/logger.lua")
    wget("https://github.com/Pyroxenium/Basalt/releases/download/v1.7/basalt.lua")
    cd("/")
end

local function printHelp()
    print([[
        -- CCNet Installer --
        Installer Ver 1.0
        CCNet Ver 2.0 Reworked
        ----- Arguments -----
        install [application]
        - installs CCNet applications
        check
        - Check available applications
    ]])
end

if args[1] == "check" then

elseif args[1] == "install" then
    if args[2] == "mail" then
        install_base()
        print("Install mails...")
        cd("/")
        wget("https://raw.githubusercontent.com/akki697222/CCNet-Reworked/main/mail/mail.lua")
        wget("https://raw.githubusercontent.com/akki697222/CCNet-Reworked/main/mail/mail_app.lua")
        print("Install Complete!")
    elseif args[2] == "server" then
        install_base()
        wget("https://raw.githubusercontent.com/akki697222/CCNet-Reworked/main/servers/server.lua")
    elseif args[2] == "mailserver" then
        install_base()
        wget("https://raw.githubusercontent.com/akki697222/CCNet-Reworked/main/servers/mailserver.lua")
    else
        install_base()
        print("Install Complete!")
    end
else
    printHelp()
end
