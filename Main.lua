local lwtk = require("lwtk")
local N    = require("Database")

-- Upvalues

local Column, Row = lwtk.Column, lwtk.Row
local PushButton  = lwtk.PushButton
local TextLabel   = lwtk.TextLabel
local TitleText   = lwtk.TitleText
local Space       = lwtk.Space

-- Set up

local PER_COLUMN = 10
local MAX_NOTES  = 30
local NORMAL_SIZE = { 1200, 900 }
local MINI_SIZE   = { 90, 45 }

-- Fields

local note   = lwtk.TextInput { text = "" }
local tag    = lwtk.TextInput { text = "" }
local search = lwtk.TextInput { text = "" }   -- tag filter

-- State

local app = lwtk.Application("Noter")
local win, mainContent, btnToggle

local isMinimized = false
local editingId   = nil
local filterTerm  = ""        -- current search term
local list        = Row { id = "list" }
local listRows    = {}        -- columns and labels on screen

-- Data

local function getVisibleNotes()
    local all = N.get_all()
    if filterTerm == "" then
        return all, #all
    end

    local result = {}
    for _, n in ipairs(all) do
        if tostring(n.tag):lower():find(filterTerm, 1, true) then
            result[#result + 1] = n
        end
    end
    return result, #all
end

-- List

local function buildNoteRow(n, refresh)
    return Row {
        TextLabel { text = string.format("[%s] %s", n.tag, n.note) },
        Space {},
        PushButton {
            text = "Edit",
            onClicked = function()
                editingId = n.id
                note:setText(n.note)
                tag:setText(n.tag)
            end
        },
        PushButton {
            text = "Remove",
            onClicked = function()
                if editingId == n.id then editingId = nil end
                N.delete(n.id)
                refresh()
            end
        },
    }
end

local function refresh()
    -- clean screen
    for i = #listRows, 1, -1 do
        list:removeChild(listRows[i])
        listRows[i] = nil
    end

    local notes = getVisibleNotes()

    if #notes == 0 then
        local msg = (filterTerm == "") and "No notes right now..."
                                        or "No notes with this tag..."
        listRows[1] = list:addChild(TextLabel { text = msg })
        return
    end

    -- columns set up
    local columns = {}
    for i, n in ipairs(notes) do
        if i > MAX_NOTES then break end

        local colIndex = math.floor((i - 1) / PER_COLUMN) + 1
        if not columns[colIndex] then
            columns[colIndex] = list:addChild(Column {})
            listRows[#listRows + 1] = columns[colIndex]
        end

        columns[colIndex]:addChild(buildNoteRow(n, refresh))
    end
end

-- Actions

local function onSave()
    local note_text = note.text or ""
    local tag_text  = tag.text or ""

    if not note_text:match("%S") or not tag_text:match("%S") then return end

    if not editingId and #N.get_all() >= MAX_NOTES then
        print("Limit of " .. MAX_NOTES .. " notes reached")
        return
    end

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
end

local function onSearch()
    local text = search.text or ""
    filterTerm = text:lower():match("^%s*(.-)%s*$")   -- trim spaces
    refresh()
end

local function onClear()
    search:setText("")
    filterTerm = ""
    refresh()
end

local function onToggleSize()
    isMinimized = not isMinimized

    if isMinimized then
        mainContent:setVisible(false)
        btnToggle:setText("Exp")
        win:setSize(MINI_SIZE[1], MINI_SIZE[2])
    else
        mainContent:setVisible(true)
        btnToggle:setText("Mini")
        win:setSize(NORMAL_SIZE[1], NORMAL_SIZE[2])
    end

    if win.view then
        win.view:postRedisplay()
    end
end

-- Interface
btnToggle = PushButton { text = "Mini", onClicked = onToggleSize }

mainContent = Column {
    TitleText { text = "Noter v0.2" },

    Row {
        TextLabel { text = "Note:" },
        note,
    },
    Row {
        TextLabel { text = "Tag:" },
        tag,
        PushButton { text = "Save", onClicked = onSave },
    },

    TitleText { text = "Registered notes:" },

    Row {
        TextLabel { text = "Filter by tag:" },
        search,
        PushButton { text = "Search", onClicked = onSearch },
        PushButton { text = "Clear",  onClicked = onClear },
    },

    list,
}

win = app:newWindow {
    title = "Noter",
    size  = NORMAL_SIZE,
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
