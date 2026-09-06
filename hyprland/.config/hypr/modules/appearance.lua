hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,

        border_size = 1,

        col = {
            active_border = outline,
            inactive_border = outline_variant,
        },

        resize_on_border = false,
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,

        active_opacity = 0.9,
        inactive_opacity = 0.7,

        shadow = {
            enabled = false,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled = true,
            size = 5,
            passes = 3,

            ignore_opacity = true,
            new_optimizations = true,

            special = false,
            popups = true,
            xray = true,

            vibrancy = 0.1696,
        },
    },
})
