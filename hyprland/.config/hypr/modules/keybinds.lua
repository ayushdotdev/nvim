local config = require("config")


hl.bind(config.modifier .. " + Q", hl.dsp.window.close())


-- FOCUS
hl.bind(config.modifier .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(config.modifier .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(config.modifier .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(config.modifier .. " + down", hl.dsp.focus({ direction = "down" }))


-- APPLICATIONS
hl.bind(config.modifier .. " + T", hl.dsp.exec_cmd(config.apps.terminal))
hl.bind(config.modifier .. " + B", hl.dsp.exec_cmd(config.apps.browser))
