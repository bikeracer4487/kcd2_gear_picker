-- Early-load compatibility script that runs before any other mod code
-- This ensures we can fix potential issues with old versions or conflicting mods

-- Only run if GearPicker is loaded
if not _G.GearPicker then
    System.LogAlways("$4[ERROR] GearPicker core module not loaded, cannot initialize compatibility fixes")
    return
end

-- Try to load the compatibility module
local success = Script.LoadScript("Scripts/GearPicker/Utils/Compatibility.lua")

if success == 1 then
    System.LogAlways("$2[GearPicker] Loaded compatibility module")
    
    -- Backup original Entity.GetPos immediately, before any mod can override it
    local original_Entity_GetPos = Entity.GetPos
    
    -- Apply compatibility fix for Entity.GetPos
    Entity.GetPos = function(...)
        -- Just pass through to original, no mod code at all
        return original_Entity_GetPos(...)
    end
    
    System.LogAlways("$2[GearPicker] Applied Entity.GetPos compatibility fix")
    
    -- Initialize full compatibility suite after core modules are loaded
    GearPicker.OnCompatibilityInit = function()
        local Compatibility = GearPicker.ClassRegistry.Compatibility
        if Compatibility then
            local compatInstance = Compatibility:new()
            compatInstance:init()
        else
            System.LogAlways("$4[GearPicker WARNING] Compatibility class not properly registered")
        end
    end
    
    System.LogAlways("$2[GearPicker] Compatibility initialization registered")
else
    System.LogAlways("$4[GearPicker ERROR] Failed to load compatibility module")
end