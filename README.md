<div align="center">

## ✨ Updates
    
So after almost having a stroke trying to figure out how the windows work on LWTK and how to implement filtering by tags, it's finally done. 
I noticed that previously it was adding notes vertically, and after some point, the window disappeared :D I thought about creating multiple windows to hold more data but it felt a little counter-intuitive and there's no real documentation on LWTK (just code examples). My solution was creating more columns after some point (10 and 20), and setting a 30 notes limit. And I guess all the planned stuff is done now (edit, filter, remove, etc) yay!
I also added a feature where you click on a button and reduce its size quite a lot. I was aiming to make it "always on top", but apparently LWTK doesn't support this. Phew

# 📝 Noter

**A tiny desktop notebook to get your notes off the desk and onto your laptop.**

![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?logo=lua&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-3-003B57?logo=sqlite&logoColor=white)
![Status](https://img.shields.io/badge/status-early%20development-orange)
![Version](https://img.shields.io/badge/version-0.1-blue)

</div>

---

## 💡 Why Noter?

My desk is always covered in scraps of paper where I jot things down all day long.
Noter is my attempt to do the same thing on my laptop: quick, simple, tagged notes that live in one place, so the desk can finally breathe. 🌿

## ✨ Features

**Available now (v0.2)**

- ➕ Add a note with a tag
- 📋 View all registered notes in a list
- 💾 Notes persist locally in a SQLite database (`notes.db`)

**Planned**

- 🏷️ Filter notes by tag (done)
- 🔍 Search through notes (ahm.. I don't think I'm going to do this)
- 🗑️ Delete notes from the interface (done)
- ✏️ Edit existing notes (done)

> 🧩 The database layer already includes `get_by_tag`, `update` and `delete`.
> They just aren't wired to the interface yet.

## 🛠️ Built With

| Tool | Purpose |
|------|---------|
| 🌙 [Lua](https://www.lua.org/) | Programming language |
| 🪟 LWTK | GUI toolkit |
| 🗄️ [lsqlite3](http://lua.sqlite.org/) | SQLite bindings for Lua |

## 📁 Project Structure

```
noter/
├── Main.lua       # 🪟 User interface (LWTK)
├── Database.lua   # 🗄️ Data layer (SQLite CRUD)
├── notes.db       # 💾 Created automatically on first run
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- Lua
- [`lsqlite3`](http://lua.sqlite.org/)
- LWTK (see its documentation for installation instructions)

### Running

Run the app **from the project folder**, so `require("Database")` and `notes.db` resolve correctly:

```bash
cd noter
lua Main.lua
```

The `notes` table is created automatically the first time you run it.

## 🧠 How It Works

```
┌──────────────┐   calls   ┌───────────────┐   reads/writes   ┌──────────┐
│   Main.lua   │ ────────▶ │  Database.lua │ ───────────────▶ │ notes.db │
│  (LWTK UI)   │ ◀──────── │     (N)       │ ◀─────────────── │ (SQLite) │
└──────────────┘  results  └───────────────┘                  └──────────┘
```

The UI and the database run in the same process, so button callbacks talk to the data layer directly. No server, no routes. 🎯

### Database API

| Function | Description |
|----------|-------------|
| `N.get_all()` | Returns every note |
| `N.get_by_tag(tag)` | Returns notes with the given tag |
| `N.create(note, tag)` | Inserts a note and returns its id |
| `N.update(id, note, tag)` | Updates a note, returns `true` on success |
| `N.delete(id)` | Deletes a note, returns `true` on success |

## 🗺️ Roadmap

- [x] Create and list notes
- [x] Persistent storage with SQLite
- [x] Filter by tag
- [x] Delete from the UI
- [x] Edit from the UI

## 🤝 Contributing

This is a personal learning project, but ideas and suggestions are welcome. Feel free to open an issue! 💬

---

<div align="center">

Made with ☕ and Lua, to keep the desk clean.

</div>
