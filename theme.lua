local lwtk           = require("lwtk")
local Color          = lwtk.Color
local get            = lwtk.StyleRef.get

local BACKGROUND     = Color "1e1e1e"
local FIELD          = Color "252526"
local BUTTON         = Color "333333"
local BUTTON_HOVER   = Color "3e3e42"
local BUTTON_PRESSED = Color "007acc"
local TEXT           = Color "cccccc"
local TEXT_DISABLED  = Color "6d6d6d"
local BORDER         = Color "3f3f46"
local ACCENT         = Color "007acc"

return {
    { "BackgroundColor",                            BACKGROUND },
    { "TextColor",                                  TEXT },
    { "AccentColor",                                ACCENT },
    { "CursorColor",                                Color "00000000" },
    { "CursorColor:focused",                        ACCENT },
    { "BorderColor@Box",                            BORDER },
    { "TextColor@TitleText",                        ACCENT },
    { "TextSize@FieldLabel",                        18 },
    { "TextSize@FieldValue",                        14 },
    { "BackgroundColor@TextInput",                  FIELD },
    { "BorderColor@TextInput",                      BORDER },
    { "BorderColor@TextInput:focused",              get "AccentColor" },
    { "BackgroundColor@PushButton",                 BUTTON },
    { "BackgroundColor@PushButton:hover",           BUTTON_HOVER },
    { "BackgroundColor@PushButton:pressed",         BUTTON_HOVER },
    { "BackgroundColor@PushButton:pressed+hover",   BUTTON_PRESSED },
    { "BackgroundColor@PushButton:default",         BUTTON },
    { "BackgroundColor@PushButton:default+hover",   BUTTON_HOVER },
    { "BackgroundColor@PushButton:default+pressed", BUTTON_PRESSED },
    { "BackgroundColor@PushButton:focused",         BUTTON },
    { "BackgroundColor@PushButton:focused+hover",   BUTTON_HOVER },
    { "BackgroundColor@PushButton:focused+pressed", BUTTON_PRESSED },
    { "TextColor@PushButton:disabled",              TEXT_DISABLED },
    { "BorderColor@PushButton",                     BORDER },
    { "BorderColor@PushButton:focused",             get "AccentColor" },
    { "BorderColor@PushButton:default",             get "AccentColor" },
}
