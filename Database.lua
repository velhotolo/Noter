local sqlite3 = require("lsqlite3")
local db = sqlite3.open("notes.db")

-- I was kinda traumatized with my recent experience with Postgres, so I decided to try offline
-- stuff this time. Database creation in SQLITE.

db:exec([[
    CREATE TABLE IF NOT EXISTS notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        note TEXT NOT NULL,
        tag TEXT NOT NULL
    );
]])

local N = {}


-- Retrieve all notes from Database

function N.get_all()
    local notes = {}
    local stmt = db:prepare("SELECT id, note, tag FROM notes")

    if not stmt then
        return notes
    end

    while stmt:step() == sqlite3.ROW do
        table.insert(notes, stmt:get_named_values())
    end

    stmt:finalize() -- this is super important to avoid memory leaks!
    return notes
end



-- The application is a platform to take quick notes. You can use tags to filter them in the future.
--
function N.get_by_tag(tag)
    local stmt = db:prepare("SELECT id, note, tag FROM notes WHERE tag = ?")

    if not stmt then
        return nil
    end

    stmt:bind_values(tag)

    local results = {}
    while stmt:step() == sqlite3.ROW do
        table.insert(results, stmt:get_named_values())
    end

    stmt:finalize()
    return results
end


-- Create notes function

function N.create(note, tag)
    local stmt = db:prepare("INSERT INTO notes (note, tag) VALUES (?, ?)")

    if not stmt then
        return nil
    end

    stmt:bind_values(note, tag)

    local res = stmt:step()
    stmt:finalize()

    if res == sqlite3.DONE then
        return db:last_insert_rowid()
    end
    return nil
end

--Delete notes function

function N.delete(id)
    local stmt = db:prepare("DELETE FROM notes WHERE id = ?")

    if not stmt then
        return false
    end

    stmt:bind_values(id)
    local res = stmt:step()
    stmt:finalize()

    return res == sqlite3.DONE and db:changes() > 0
end

function N.update(note, tag, id)
    local stmt = db:prepare("UPDATE notes SET note = ?, tag = ? WHERE id = ?")

    stmt:bind_values(note, tag, id)
    local res = stmt:step()
    stmt:finalize()

    return res == sqlite3.DONE and db:changes() > 0
end


return N
