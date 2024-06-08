local args = {...}

local function wget(url)
    shell.run("wget "..url)
end

local function mkdir(path)
    shell.run("mkdir "..path)
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
    
end