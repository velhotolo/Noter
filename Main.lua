local lwtk = require("lwtk")
local N    = require("Database")
-- Basic upvalues
local Column, Row   = lwtk.Column, lwtk.Row
local PushButton    = lwtk.PushButton
local TextLabel     = lwtk.TextLabel
local TitleText     = lwtk.TitleText
local Space         = lwtk.Space

-- Note and tag, super immportant
local note = lwtk.TextInput { text = "" }
local tag  = lwtk.TextInput { text = "" }

local app         = lwtk.Application("Noter")

-- Info regarding the window size feature
local normalSize  = { 1200, 900 }
local miniSize    = { 90, 45 }
local isMinimized = false
local win
local mainContent
local btnToggle

-- Other super important stuff for things to work
local editingId = nil
local list = Column { id = "list" }
local listRows    = {}

-- Refresh list of notes for when adding or deleting
local function refresh()
    for i = #listRows, 1, -1 do
        list:removeChild(listRows[i])
        listRows[i] = nil
    end

    local notes = N.get_all()
    if #notes == 0 then
        listRows[1] = list:addChild(TextLabel {
            text = "No notes right now..." })
        return
    end

    -- Edit and Remove functions
    for _, n in ipairs(notes) do
        listRows[#listRows + 1] = list:addChild(Row {
            TextLabel { text = string.format("[%s] %s", n.tag, n.note) },
            Space {},

            PushButton {
                text = "Edit",
                onClicked = function()
                    note:setText(n.note)
                    tag:setText(n.tag)
                end
            },
            PushButton {
                text = "Remove",
                onClicked = function()
                    N.delete(n.id)
                    refresh()
                end
            }
        })
    end
end

-- Tiny window button
btnToggle = PushButton {
    text      = "Mini",
    onClicked = function()
        isMinimized = not isMinimized

        if isMinimized then
            mainContent:setVisible(false)
            btnToggle:setText("Exp")
            win:setSize(miniSize[1], miniSize[2])
        else
            mainContent:setVisible(true)
            btnToggle:setText("Mini")
            win:setSize(normalSize[1], normalSize[2])
        end

        if win.view then
            win.view:postRedisplay()
        end
    end
}


-- The content for when the window is at it's normal size
mainContent = Column {
    TitleText { text = "Noter v0.1" },
    Row {
            TextLabel { text = "Note:" },
            note,
        },
        Row {
            TextLabel { text = "Tag:" },
            tag,
            PushButton { text = "Save", onClicked = function()
                local note_text = note.text or ""
                local tag_text  = tag.text or ""

                if not note_text:match("%S") or not tag_text:match("%S") then return end

                local ok, res
                if editingId then
                    ok, res = pcall(N.update, editingId, note_text, tag_text)
                else
                    ok, res = pcall(N.create, note_text, tag_text)
                end

                if not ok or not res then
                    print("ERROR:", res)
                    return
                end

                note:setText("")
                tag:setText("")
                editingId = nil
                refresh()
            end },
        },
        TitleText { text = "Registered notes:" },
        list,
    }

-- Window creation

win = app:newWindow {
        title = "Noter",
        size  = normalSize,
        Column {
            Row {
                Space {},
                btnToggle,
            },
            mainContent,
        }
    }



refresh()
win:show()
app:runEventLoop()
