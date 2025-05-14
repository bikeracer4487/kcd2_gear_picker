function GearPicker:OnLoadingComplete()
    -- Very visible startup banner for troubleshooting
    System.LogAlways("********************************************")
    System.LogAlways("$2[GearPicker] Game loading complete - activating mod")
    System.LogAlways("$2[GearPicker] Version " .. _G.GearPicker.VERSION)
    System.LogAlways("********************************************")
    
    -- Check if core module was properly loaded
    if not _G.GearPickerLoaded then
        System.LogAlways("$4[GearPicker ERROR] Core module was not properly loaded!")
        System.LogAlways("$4[GearPicker ERROR] This usually indicates an issue with the mod installation or PAK file.")
        System.LogAlways("$4[GearPicker ERROR] Please check that the mod files are correctly installed.")
        return
    end
    
    -- Initialize key components with detailed logging
    local success = true
    
    -- Try to initialize config
    local configSuccess = pcall(function() GearPicker:config() end)
    if configSuccess then
        System.LogAlways("$2[GearPicker] Config loaded successfully")
    else
        System.LogAlways("$4[GearPicker ERROR] Failed to initialize config")
        success = false
    end
    
    -- Try to initialize commands
    local commandsSuccess = pcall(function() GearPicker:commands():init() end)
    if commandsSuccess then
        System.LogAlways("$2[GearPicker] Commands registered successfully")
    else
        System.LogAlways("$4[GearPicker ERROR] Failed to initialize commands")
        success = false
    end
    
    -- Final initialization message
    if success then
        System.LogAlways("$2[GearPicker] Mod initialized successfully!")
        System.LogAlways("$2[GearPicker] Press F6 to scan inventory")
        System.LogAlways("$2[GearPicker] Press F7 for maximum armor, F8 for stealth, F9 for charisma")
    else
        System.LogAlways("$4[GearPicker ERROR] Mod initialization encountered errors!")
        System.LogAlways("$4[GearPicker ERROR] Some functionality may not work correctly")
    end
end

UIAction.RegisterEventSystemListener(
        GearPicker, "System", "OnLoadingComplete", "OnLoadingComplete"
)