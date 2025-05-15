-- Diagnostics.lua - A standalone diagnostic script for basic API checks
-- This file shouldn't depend on any other code in the mod

-- Store reference to System.LogAlways to ensure it's available
local LogFunc = System.LogAlways

-- Basic logger function that doesn't depend on other mod code
local function DiagLog(message)
    if LogFunc then
        LogFunc("$3[GearPicker-DIAG] " .. tostring(message))
    end
end

-- Register a global diagnostic function
_G.GearPickerRunDiagnostics = function()
    DiagLog("=========================================================")
    DiagLog("STARTING STANDALONE DIAGNOSTICS")
    DiagLog("=========================================================")
    
    -- Check essential global objects
    DiagLog("Checking System object: " .. (System and "Available" or "MISSING"))
    DiagLog("Checking Script object: " .. (Script and "Available" or "MISSING"))
    DiagLog("Checking ItemManager object: " .. (ItemManager and "Available" or "MISSING"))
    DiagLog("Checking Player object: " .. (player and "Available" or "MISSING"))
    
    -- Check System functions
    if System then
        DiagLog("System.LogAlways: " .. (type(System.LogAlways) == "function" and "Available" or "MISSING"))
        DiagLog("System.GetLocalOSTime: " .. (type(System.GetLocalOSTime) == "function" and "Available" or "MISSING"))
        
        -- Try to get current time
        if type(System.GetLocalOSTime) == "function" then
            local success, result = pcall(function() return System.GetLocalOSTime() end)
            if success then
                DiagLog("GetLocalOSTime works, current hour: " .. (result.hour or "unknown"))
            else
                DiagLog("ERROR: GetLocalOSTime failed: " .. tostring(result))
            end
        end
    end
    
    -- Check player and inventory
    if player then
        DiagLog("player.inventory: " .. (player.inventory and "Available" or "MISSING"))
        DiagLog("player.actor: " .. (player.actor and "Available" or "MISSING"))
        DiagLog("player.soul: " .. (player.soul and "Available" or "MISSING"))
        
        -- Try to get player inventory
        if player.inventory then
            DiagLog("Attempting to call player.inventory:GetItems()")
            local success, items = pcall(function() return player.inventory:GetItems() end)
            
            if success then
                if type(items) == "table" then
                    DiagLog("GetItems succeeded, found " .. #items .. " items")
                    
                    -- Try to inspect the first few items
                    for i = 1, math.min(3, #items) do
                        local itemId = items[i]
                        DiagLog("Item " .. i .. " ID: " .. tostring(itemId))
                        
                        -- Try to get item details if ItemManager exists
                        if ItemManager and type(ItemManager.GetItem) == "function" then
                            local getItemSuccess, item = pcall(function() return ItemManager.GetItem(itemId) end)
                            
                            if getItemSuccess and item then
                                DiagLog("Successfully retrieved item " .. i)
                                
                                -- Try to get item name
                                if type(ItemManager.GetItemName) == "function" and item.class then
                                    local getNameSuccess, name = pcall(function() return ItemManager.GetItemName(item.class) end)
                                    if getNameSuccess and name then
                                        DiagLog("Item " .. i .. " name: " .. name)
                                    else
                                        DiagLog("Failed to get name for item " .. i)
                                    end
                                end
                            else
                                DiagLog("Failed to get item " .. i .. ": " .. tostring(item))
                            end
                        end
                    end
                else
                    DiagLog("ERROR: GetItems returned non-table value: " .. type(items))
                end
            else
                DiagLog("ERROR: GetItems failed: " .. tostring(items))
            end
        end
        
        -- Try to get player derived stats
        if player.soul and type(player.soul.GetDerivedStat) == "function" then
            DiagLog("Attempting to read player derived stats")
            
            local stats = {
                "eqw", -- equipped weight
                "mca", -- max weight capacity
                "stb", -- stab defense
                "sla", -- slash defense
                "noi", -- noise
                "cha"  -- charisma
            }
            
            for _, stat in ipairs(stats) do
                local success, value = pcall(function() return player.soul:GetDerivedStat(stat) end)
                if success then
                    DiagLog("Player stat " .. stat .. ": " .. tostring(value))
                else
                    DiagLog("ERROR: Failed to get player stat " .. stat .. ": " .. tostring(value))
                end
            end
        end
    end
    
    -- Check for Script functions
    if Script then
        DiagLog("Script.LoadScript: " .. (type(Script.LoadScript) == "function" and "Available" or "MISSING"))
        DiagLog("Script.SetTimer: " .. (type(Script.SetTimer) == "function" and "Available" or "MISSING"))
    end
    
    -- Check for GearPicker-specific globals
    DiagLog("GearPicker global: " .. (GearPicker and "Available" or "MISSING"))
    
    if GearPicker then
        DiagLog("GearPicker.VERSION: " .. (GearPicker.VERSION or "MISSING"))
        DiagLog("GearPicker factories available:")
        DiagLog("  gearScan: " .. (type(GearPicker.gearScan) == "function" and "Yes" or "No"))
        DiagLog("  commands: " .. (type(GearPicker.commands) == "function" and "Yes" or "No"))
        DiagLog("  config: " .. (type(GearPicker.config) == "function" and "Yes" or "No"))
        DiagLog("  equippedItem: " .. (type(GearPicker.equippedItem) == "function" and "Yes" or "No"))
        DiagLog("  itemCategory: " .. (type(GearPicker.itemCategory) == "function" and "Yes" or "No"))
        
        -- Test a factory method
        if type(GearPicker.commands) == "function" then
            local success, commands = pcall(function() return GearPicker:commands() end)
            if success and commands then
                DiagLog("Successfully created commands instance")
            else
                DiagLog("ERROR: Failed to create commands instance: " .. tostring(commands))
            end
        end
    end
    
    DiagLog("=========================================================")
    DiagLog("DIAGNOSTIC COMPLETE")
    DiagLog("=========================================================")
end

-- Add a command to run diagnostics
if System and System.AddCCommand then
    System.AddCCommand(
        "gear_picker__run_diagnostics",
        "GearPickerRunDiagnostics()",
        "Runs a standalone diagnostic check for GearPicker"
    )
    DiagLog("Registered diagnostic command: gear_picker__run_diagnostics")
end

return true