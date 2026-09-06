local config = require("config")


hl.bind(config.modifier .. " + Q", hl.dsp.window.close())

hl.bind(config.modifier .. " + T", hl.dsp.exec_cmd(config.apps.terminal))
hl.bind(config.modifier .. " + B", hl.dsp.exec_cmd(config.apps.browser))
