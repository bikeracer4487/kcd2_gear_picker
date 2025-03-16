_G.HodCustomizations = {}

System.LogAlways("set_hide_ranged_weapons.outside")

local log = _G.HelmetOffDialog:log()

function _G.HodCustomizations:set_hide_ranged_weapons(line)
    System.LogAlways("set_hide_ranged_weapons")
    log:info("set_hide_ranged_weapons called with argument: ", line)

    local config = _G.HelmetOffDialog:config()
    local setting = (tostring(line):match("^%s*=?%s*(.-)%s*$") or ""):lower() == "true"

    log:info("Setting hide ranged weapon with value: ", setting)
    config:setHideRangedWeapons(setting)
end

function _G.HodCustomizations:loadConfiguration(actionName, eventName, argTable)
    log:info("HodCustomizations:loadCfg")
    _G.System.ExecuteCommand("exec Mods/helmet_off_dialog/mod.cfg")
end

UIAction.RegisterEventSystemListener(_G.HodCustomizations, "System", "OnLoadingComplete", "loadConfiguration")

_G.System.AddCCommand("HELMETOFFDIALOG-SET-hide_ranged_weapons", "HodCustomizations:set_hide_ranged_weapons(%line)", "");
