local config = {
    user = {
        color = {
            main = colors.lightGray,
            sub = colors.gray,
            text = colors.white
        }
    },
    network = {
        channel = 10001,
        timeout = 50, --milliseconds
    },
    server = {
        name = "Server",
        id = "server_core",
        version = "1.0.0"
    },
    channel = {
        server = 10000
    },
    vesions = {
        network = "1.0.0",
        mail = "1.0.0",
        logger = "0.2.2",
        json = "1.0.0"
    }
}

return config