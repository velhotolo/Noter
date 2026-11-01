local lwtk        = require("lwtk")
local N           = require("Database")

-- 1. Upvalues and interface setup
local Column, Row = lwtk.Column, lwtk.Row
local PushButton  = lwtk.PushButton
local TextLabel   = lwtk.TextLabel
local TitleText   = lwtk.TitleText
local Space       = lwtk.Space

local PER_COLUMN  = 20
local MAX_NOTES   = 150

-- 2. Text fields
local note        = lwtk.TextInput { text = "" }
local tag         = lwtk.TextInput { text = "" }

-- 3. App state
local app = lwtk.Application("Noter")
app:addStyle(require("theme"))
local win, mainContent

local editingId    = nil
local filterByNote = ""
local filterByTag  = ""
local sortModes = {
    { label = "Sort: original", key = nil },
    { label = "Sort: note A-Z", key = "note" },
    { label = "Sort: tag A-Z",  key = "tag" },
}
local sortIndex = 1

local list         = Row { id = "list" }
local listRows     = {}

-- Sort notes function (will make sense down below)
local function sortNotes(notes)
    local key = sortModes[sortIndex].key
    if not key then return notes end

    table.sort(notes, function(a, b)
        local va = tostring(a[key]):lower()
        local vb = tostring(b[key]):lower()
        if va == vb then
            return a.id < b.id
        end
        return va < vb
    end)

    return notes
end

-- 4. Data filter. I merged tags and notes now.
local function getVisibleNotes()
    local all = N.get_notes()

    if filterByNote == "" and filterByTag == "" then
        return sortNotes(all)
    end

    local result = {}
    for _, n in ipairs(all) do
        local matchNote = true
        local matchTag = true

        if filterByNote ~= "" then
            matchNote = tostring(n.note):lower():find(filterByNote, 1, true) ~= nil
        end

        if filterByTag ~= "" then
            matchTag = tostring(n.tag):lower():find(filterByTag, 1, true) ~= nil
        end

        if matchNote and matchTag then
            result[#result + 1] = n
        end
    end

    return sortNotes(result)
end

-- 5. Building the list
local function buildNoteRow(n, refreshFunc)
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
                refreshFunc()
            end
        },
    }
end

local function refresh()
    for i = #listRows, 1, -1 do
        list:removeChild(listRows[i])
        listRows[i] = nil
    end

    local notes = getVisibleNotes()

    if #notes == 0 then
        local msg = "No notes found with those filters...."
        listRows[1] = list:addChild(TextLabel { text = msg })
        return
    end

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

-- 6. Button's actions
local function onSave()
local note_text = note.text or ""
local tag_text  = tag.text or ""

    if not note_text:match("%S") or not tag_text:match("%S") then return end

    if not editingId and #N.get_all() >= MAX_NOTES then
        print("Note limit of " .. MAX_NOTES .. " reached!")
        return
    end

    local ok, res
    if editingId then
        ok, res = pcall(N.update, note_text, tag_text, editingId)
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

local function onSort(button)
    sortIndex = (sortIndex % #sortModes) + 1
    button:setText(sortModes[sortIndex].label)
    refresh()
end

local function onSearchCombined()
    local n_text = note.text or ""
    local t_text = tag.text or ""

    filterByNote = n_text:lower():match("^%s*(.-)%s*$") or ""
    filterByTag  = t_text:lower():match("^%s*(.-)%s*$") or ""

    refresh()
end

local function onClear()
note:setText("")
tag:setText("")
refresh()
end

-- 7. Interface and main loop
mainContent = Column {
   TitleText { text = "Noter v0.4" },

    Row {
        TextLabel { text = "Note:" },
        note,
        PushButton { text = sortModes[1].label, onClicked = onSort }, -- this button has 3 modes to sort the columns
        PushButton { text = "Search", onClicked = onSearchCombined },
        PushButton { text = "Clear", onClicked = onClear},
    },
    Row {
        TextLabel { text = "Tag:  " },
        tag,
        PushButton { text = "Save", onClicked = onSave },
        PushButton { text = "Search", onClicked = onSearchCombined },
        PushButton { text = "Clear", onClicked = onClear},
    },

    TitleText { text = "Registered notes:" },
    list,
}

win = app:newWindow {
    title = "Noter 0.4",
    size  = {1200, 900},
    Column {
        Row { Space {},
        mainContent},
    },
}

refresh()
win:show()
app:runEventLoop()
