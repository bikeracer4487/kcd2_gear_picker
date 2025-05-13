Script.LoadScript("Scripts/GearPicker/GearPicker.lua")
GearPicker:init()

function GearPicker:OnGameplayStart(...)
    GearPicker.Log.info("GearPicker mod initialized")
    -- Load core functionality
    Script.LoadScript("Scripts/GearPicker/Config.lua")
    Script.LoadScript("Scripts/GearPicker/Commands.lua")
    Script.LoadScript("Scripts/GearPicker/GearScan.lua")
    Script.LoadScript("Scripts/GearPicker/GearOptimizer.lua")
    Script.LoadScript("Scripts/GearPicker/GearSwitcher.lua")
    Script.LoadScript("Scripts/GearPicker/Equipment.lua")
    Script.LoadScript("Scripts/GearPicker/EquippedItem.lua")
    Script.LoadScript("Scripts/GearPicker/ItemCategory.lua")
    Script.LoadScript("Scripts/GearPicker/UnequipGear.lua")
end

UIAction.RegisterEventSystemListener(
        GearPicker,
        "System",
        "OnGameplayStart",
        "OnGameplayStart"
)