local config = require("config")

hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon")
end)
