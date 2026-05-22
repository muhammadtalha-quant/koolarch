-----------------------------------------------------------
---                       APPS                          ---
-----------------------------------------------------------


local terminal = "ghostty"
local browser = "google-chrome-stable"
local vscode = "code"
local explorer = "dolphin"



-------------------------------------------------------------
---                        KEYS                           ---
-------------------------------------------------------------

local function join_keys(key_a, key_b) 
    return key_a .. "+" .. key_b
end

local super = "SUPER"
local control = "CONTROL"
local shift = "SHIFT"
local alt = "ALT"
local enter = "RETURN"

local arrow_left = "LEFT"
local arrow_right = "RIGHT"
local arrow_up = "UP"
local arrow_down = "DOWN"

local left_click = "mouse:272"
local right_click = "mouse:273"
local middle_click = "mouse:274"


-------------------------------------------------------------
---                    LAUNCH APPS                        ---   
-------------------------------------------------------------

hl.bind(
    join_keys(super,enter),
    hl.dsp.exec_cmd(terminal)
)

hl.bind(
    join_keys(super,"B"),
    hl.dsp.exec_cmd(browser)
)

hl.bind(
    join_keys(super,"E"),
    hl.dsp.exec_cmd(explorer)
)

hl.bind(
    join_keys(super,"C"),
    hl.dsp.exec_cmd(vscode)
)


-------------------------------------------------------------
---                 WORKING WITH WINDOWS                  ---   
-------------------------------------------------------------


hl.bind( -- close single window
    join_keys(super,"Q"),
    hl.dsp.window.close()
)

hl.bind( -- close all instances of a window
    join_keys(join_keys(super,shift), "Q"),
    hl.dsp.window.kill()
)

hl.bind( -- toggle float / tile
    join_keys(super,"F"),
    hl.dsp.window.float()
)

hl.bind( -- focus left
    join_keys(super,arrow_left),
    hl.dsp.focus({
        direction = "left"
    })
)

hl.bind( -- focus right
    join_keys(super,arrow_right),
    hl.dsp.focus({
        direction = "right"
    })
)
hl.bind( -- focus up
    join_keys(super,arrow_up),
    hl.dsp.focus({
        direction = "up"
    })
)

hl.bind( -- focus down
    join_keys(super,arrow_down),
    hl.dsp.focus({
        direction = "down"
    })
)

-------------------------------------------------------------
---                WORKING WITH WORKSPACES                ---   
-------------------------------------------------------------

for i = 1, 9 do
    hl.bind(
        join_keys(super,tostring(i)),
        hl.dsp.focus({
            workspace = tostring(i)
        })
    )
end

for i = 1, 9 do
    hl.bind(
        join_keys(
            join_keys(super,shift),
            tostring(i)
        ),
        hl.dsp.window.move({
            workspace = tostring(i)
        })
    )
end

for i = 1, 9 do
    hl.bind(
        join_keys(
            join_keys(super,alt),
            tostring(i)
        ),
        hl.dsp.window.move({
            workspace = tostring(i),
            follow = false,
        })
    )
end

hl.bind(
    join_keys(
        join_keys(super,control),
        arrow_right
    ),
    hl.dsp.focus({
        workspace = "+1"
    })
)

hl.bind(
    join_keys(
        join_keys(super,control),
        arrow_left
    ),
    hl.dsp.focus({
        workspace = "-1"
    })
)