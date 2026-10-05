local lwtk = require("lwtk")
local N = require("Database")

--This is the second application I'm using lwtk and I'm not really sure about what I'm doing :D
-- So bare with me as the app progresses. There are some funcionalities I want to add but need
-- to read more documentation and the example's codes. So not a lot of comments right now.

local app = lwtk.Application({ name = "Noter" })
local win = lwtk.Window(app, { title = "Noter v0.1", size = { 800, 600 } })
local main_col = lwtk.Column()
local list_container = lwtk.Column()

-- Function used many times

local function refresh_notes()
    while #list_container > 0 do
        local child = list_container[#list_container]
        table.remove(list_container, #list_container)
        child:_setParent(nil)
    end

    local notes = N.get_all()
    if #notes == 0 then
        list_container:addChild(lwtk.TextLabel({ text = "No notes right now..." }))
        return
    end

    for _, n in ipairs(notes) do
        list_container:addChild(lwtk.TextLabel({
            text = string.format("[%s] %s", n.tag, n.note),
        }))
    end
end

-- The goold old helpers creating fields to fill

local function create_field(label_text)
    local container = lwtk.Column()
    local input = lwtk.TextInput({ text = "" })
    container:addChild(lwtk.TextLabel({ text = label_text }))
    container:addChild(input)
    return container, input
end

-- Titles function

local function create_section_header(title)
    return lwtk.TextLabel({ text = string.format("--- %s ---", title) })
end

-- This happens many times through the app. It's basically biding elements (columns, rows, fields)
-- to the main column (which in this case is the entire app)
main_col:addChild(create_section_header("NOTES"))

local col_note, input_note = create_field("Note:")
local col_tag, input_tag = create_field("Tag:")

local gRow = lwtk.Row()
gRow:addChild(col_note)
gRow:addChild(col_tag)
main_col:addChild(gRow)

-- Add button

local btn_add = lwtk.PushButton({ text = "Add" })
btn_add:setOnClicked(function()
    local note = input_note.text or ""
    local tag = input_tag.text or ""

    if not note:match("%S") or not tag:match("%S") then
        return
    end

    local ok, res = pcall(N.create, note, tag)
    if not ok or not res then
        print("ERROR:", res)
        return
    end

    input_note:setText("")
    input_tag:setText("")
    refresh_notes()
    if win.view then
        win.view:postRedisplay()
    end
end)

-- Final bindings

main_col:addChild(btn_add)
main_col:addChild(create_section_header("Registered notes:"))
main_col:addChild(list_container)
refresh_notes()

win:addChild(main_col)
win:show()

app:runEventLoop()
