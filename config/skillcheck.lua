Config.skillcheck = {
    colors = {
        bg = { 30, 41, 59, 200 },
        text = { 255, 255, 255, 255 },
        skill = {
            base = { 255, 255, 255, 180 },
            success = { 34, 197, 94, 255 },
            failed = { 248, 113, 113, 255 }
        },
        cursor = { 255, 0, 0, 255 },
    },

    -- Default settings if not provided durint runtime. (range for random)
    settings = {
        minigame = 'square',
        duration = { 3000, 7000 },
        difficulty = { 5, 20 },
        minPosition = { 20, 30 },
        flipped = false,
        reverse = false
    },

    -- Keys
    keys = {
        ['1'] = {
            keys = { '1', 'NUMPAD1' }
        },
        ['2'] = {
            keys = { '2', 'NUMPAD2' }
        },
        ['3'] = {
            keys = { '3', 'NUMPAD3' }
        },
        ['4'] = {
            keys = { '4', 'NUMPAD4' }
        },
        ['Q'] = {
            keys = 'Q'
        },
        ['W'] = {
            keys = 'W'
        },
        ['E'] = {
            keys = 'E'
        },
        ['R'] = {
            keys = 'R'
        }
    }
}
