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
        name = "Core Server",
        version = "v2.0"
    },
    channel = {
        server = 10000
    }
}

return config