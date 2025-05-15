Script.LoadScript("Scripts/GearPicker/GearPicker.lua")
GearPicker:init()

function GearPicker:OnGameplayStart(...)
    GearPicker.Log.info("GearPicker mod initialized")
    -- Load core functionality
    Script.LoadScript("Scripts/GearPicker/Config.lua")
    
    -- Load diagnostics and alternative inventory scanner first
    Script.LoadScript("Scripts/GearPicker/Diagnostics.lua")
    Script.LoadScript("Scripts/GearPicker/AlternativeInventory.lua")
    
    -- Load other modules
    Script.LoadScript("Scripts/GearPicker/Commands.lua")
    Script.LoadScript("Scripts/GearPicker/GearScan.lua")
    Script.LoadScript("Scripts/GearPicker/GearOptimizer.lua")
    Script.LoadScript("Scripts/GearPicker/GearSwitcher.lua")
    Script.LoadScript("Scripts/GearPicker/Equipment.lua")
    Script.LoadScript("Scripts/GearPicker/EquippedItem.lua")
    Script.LoadScript("Scripts/GearPicker/ItemCategory.lua")
    Script.LoadScript("Scripts/GearPicker/UnequipGear.lua")
    
    -- Ensure alternative inventory is available
    System.LogAlways("$2[GearPicker] Setting up alternative inventory scanner...")
    if not GearPicker.ClassRegistry.AlternativeInventory then
        System.LogAlways("$4[GearPicker] WARNING: AlternativeInventory not loaded properly, forcing load...")
        -- Force load it again if necessary
        Script.LoadScript("Scripts/GearPicker/AlternativeInventory.lua")
    end
end

UIAction.RegisterEventSystemListener(
        GearPicker,
        "System",
        "OnGameplayStart",
        "OnGameplayStart"
)