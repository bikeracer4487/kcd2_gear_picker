-- ClassRegistryFix.lua - Force class registration for inventory scanners
System.LogAlways("$6[GearPicker] Loading ClassRegistryFix.lua to ensure all scanner classes are registered...")

-- Ensure global GearPicker exists
_G.GearPicker = _G.GearPicker or {}
_G.GearPicker.ClassRegistry = _G.GearPicker.ClassRegistry or {}

-- Load the scanner classes if not already loaded
if Script.LoadScript("Scripts/GearPicker/SimplifiedInventoryScan.lua") == 1 then
    System.LogAlways("$6[GearPicker] Successfully loaded SimplifiedInventoryScan.lua in ClassRegistryFix")
    
    -- Force class registration directly from global
    if _G.SimplifiedInventoryScan then
        _G.GearPicker.ClassRegistry.SimplifiedInventoryScan = _G.SimplifiedInventoryScan
        System.LogAlways("$6[GearPicker] Force-registered SimplifiedInventoryScan from global to ClassRegistry")
    end
else
    System.LogAlways("$4[GearPicker] Failed to load SimplifiedInventoryScan.lua in ClassRegistryFix")
end

if Script.LoadScript("Scripts/GearPicker/EmbeddedScan.lua") == 1 then
    System.LogAlways("$6[GearPicker] Successfully loaded EmbeddedScan.lua in ClassRegistryFix")
    
    -- Force class registration directly from global
    if _G.EmbeddedScan then
        _G.GearPicker.ClassRegistry.EmbeddedScan = _G.EmbeddedScan
        System.LogAlways("$6[GearPicker] Force-registered EmbeddedScan from global to ClassRegistry")
    end
else
    System.LogAlways("$4[GearPicker] Failed to load EmbeddedScan.lua in ClassRegistryFix")
end

-- Diagnostic function that checks class registry status
_G.GearPickerVerifyClasses = function()
    System.LogAlways("$6[GearPicker] Verifying class registry status:")
    
    -- List all classes in registry
    for className, _ in pairs(_G.GearPicker.ClassRegistry) do
        System.LogAlways("$6[GearPicker] - Registry contains: " .. className)
    end
    
    -- Check scanner classes specifically
    if _G.GearPicker.ClassRegistry.SimplifiedInventoryScan then
        System.LogAlways("$2[GearPicker] SimplifiedInventoryScan is registered in ClassRegistry ✓")
    else
        System.LogAlways("$4[GearPicker] SimplifiedInventoryScan is MISSING from ClassRegistry ✗")
    end
    
    if _G.GearPicker.ClassRegistry.EmbeddedScan then
        System.LogAlways("$2[GearPicker] EmbeddedScan is registered in ClassRegistry ✓")
    else
        System.LogAlways("$4[GearPicker] EmbeddedScan is MISSING from ClassRegistry ✗")
    end
    
    -- Check for global class availability
    if _G.SimplifiedInventoryScan then
        System.LogAlways("$2[GearPicker] SimplifiedInventoryScan is available as global ✓")
    else
        System.LogAlways("$4[GearPicker] SimplifiedInventoryScan is NOT available as global ✗")
    end
    
    if _G.EmbeddedScan then
        System.LogAlways("$2[GearPicker] EmbeddedScan is available as global ✓")
    else
        System.LogAlways("$4[GearPicker] EmbeddedScan is NOT available as global ✗")
    end
    
    -- Try to fix any missing registrations
    if not _G.GearPicker.ClassRegistry.SimplifiedInventoryScan and _G.SimplifiedInventoryScan then
        _G.GearPicker.ClassRegistry.SimplifiedInventoryScan = _G.SimplifiedInventoryScan
        System.LogAlways("$2[GearPicker] Fixed missing SimplifiedInventoryScan registration ✓")
    end
    
    if not _G.GearPicker.ClassRegistry.EmbeddedScan and _G.EmbeddedScan then
        _G.GearPicker.ClassRegistry.EmbeddedScan = _G.EmbeddedScan
        System.LogAlways("$2[GearPicker] Fixed missing EmbeddedScan registration ✓")
    end
end

-- Enhanced fallback scanner for Commands.lua
_G.EmergencyInventoryScanner = {
    new = function(self, player, script, itemManager)
        local instance = {
            player = player,
            script = script, 
            itemManager = itemManager,
            inventoryItems = {}
        }
        setmetatable(instance, { __index = self })
        System.LogAlways("$5[GearPicker] Created EmergencyInventoryScanner instance")
        return instance
    end,
    
    scanInventory = function(self, callback)
        local this = self
        System.LogAlways("$5[GearPicker] Running emergency scanner...")
        
        -- Reset data
        this.inventoryItems = {}
        
        -- Try multiple approaches to get inventory items
        local inventoryItems = {}
        
        -- Approach 1: Try GetInventoryTable
        local success = pcall(function()
            if this.player.inventory.GetInventoryTable then
                local items = this.player.inventory:GetInventoryTable()
                if items and type(items) == "table" then
                    System.LogAlways("$5[GearPicker] Successfully used GetInventoryTable")
                    inventoryItems = items
                end
            end
        end)
        
        -- Approach 2: Try GetItems
        if #inventoryItems == 0 then
            pcall(function()
                if this.player.inventory.GetItems then
                    local items = this.player.inventory:GetItems()
                    if items and type(items) == "table" then
                        System.LogAlways("$5[GearPicker] Successfully used GetItems")
                        inventoryItems = items
                    end
                end
            end)
        end
        
        -- Approach 3: Try direct access by index
        if #inventoryItems == 0 then
            local count = 0
            pcall(function() 
                if this.player.inventory.GetCount then
                    count = this.player.inventory:GetCount() 
                end
            end)
            
            if count > 0 then
                System.LogAlways("$5[GearPicker] Using direct index access, found " .. count .. " items")
                for i = 0, count - 1 do
                    pcall(function()
                        local item = this.player.inventory:GetItem(i)
                        if item and item.id then
                            table.insert(inventoryItems, item.id)
                        end
                    end)
                end
            end
        end
        
        System.LogAlways("$5[GearPicker] Found " .. #inventoryItems .. " inventory items")
        
        -- Process each item
        for i, itemId in ipairs(inventoryItems) do
            -- Get item details
            local item = nil
            pcall(function() 
                if this.itemManager and this.itemManager.GetItem then
                    item = this.itemManager.GetItem(itemId) 
                end
            end)
            
            if not item then goto continue end
            
            -- Try to get basic item properties
            local stats = {
                id = itemId,
                name = "Unknown Item",
                uiName = "Unknown Item",
                slot = "unknown",
                weight = 0,
                stabDefense = 0,
                slashDefense = 0,
                bluntDefense = 0,
                noise = 0,
                visibility = 0,
                conspicuousness = 0,
                charisma = 0,
                material = "unknown"
            }
            
            -- Get item name
            pcall(function() 
                if item.class and this.itemManager.GetItemName then
                    stats.name = this.itemManager.GetItemName(item.class) or "Unknown Item"
                end
            end)
            
            -- Get UI name
            pcall(function() 
                if item.class and this.itemManager.GetItemUIName then
                    stats.uiName = this.itemManager.GetItemUIName(item.class) or stats.name
                end
            end)
            
            -- Check if item can be equipped (focus on gear)
            local canEquip = false
            pcall(function() 
                if item.CanEquip then
                    canEquip = item:CanEquip()
                end
            end)
            
            if not canEquip then goto continue end
            
            -- Get item slot
            pcall(function() 
                if item.GetSlot then
                    stats.slot = item:GetSlot() or "unknown"
                end
            end)
            
            -- Get defense stats
            pcall(function() 
                if item.GetStabDefense then stats.stabDefense = item:GetStabDefense() or 0 end
                if item.GetSlashDefense then stats.slashDefense = item:GetSlashDefense() or 0 end
                if item.GetBluntDefense then stats.bluntDefense = item:GetBluntDefense() or 0 end
            end)
            
            -- Get stealth stats
            pcall(function() 
                if item.GetNoise then stats.noise = item:GetNoise() or 0 end
                if item.GetVisibility then stats.visibility = item:GetVisibility() or 0 end
                if item.GetConspicuousness then stats.conspicuousness = item:GetConspicuousness() or 0 end
            end)
            
            -- Get social stats
            pcall(function() 
                if item.GetCharisma then stats.charisma = item:GetCharisma() or 0 end
            end)
            
            -- Get weight
            pcall(function() 
                if item.GetWeight then stats.weight = item:GetWeight() or 0 end
            end)
            
            -- Skip weapons (only armor/clothing)
            local lcName = string.lower(stats.name)
            if lcName:find("sword") or lcName:find("axe") or lcName:find("mace") or 
               lcName:find("bow") or lcName:find("arrow") or lcName:find("shield") then
                goto continue
            end
            
            -- Skip consumables and non-gear
            if lcName:find("potion") or lcName:find("food") or lcName:find("drink") or
               lcName:find("herb") or lcName:find("book") or lcName:find("torch") then
                goto continue
            end
            
            -- Only add items with some defensive stats
            if stats.stabDefense > 0 or stats.slashDefense > 0 or stats.bluntDefense > 0 then
                table.insert(this.inventoryItems, stats)
                System.LogAlways("$2[GearPicker] Found gear: " .. stats.name)
            end
            
            ::continue::
        end
        
        System.LogAlways("$6[GearPicker] Emergency scan complete - found " .. #this.inventoryItems .. " gear items")
        
        -- Call the callback with results
        if callback then
            callback(this.inventoryItems, {})
        end
    end
}

-- Add a command to verify classes
if System and System.AddCCommand then
    System.AddCCommand(
        "gear_picker__verify_classes",
        "GearPickerVerifyClasses()",
        "Verifies class registration status for GearPicker"
    )
    System.LogAlways("$6[GearPicker] Registered verification command: gear_picker__verify_classes")
end

-- Run verification immediately
if _G.GearPickerVerifyClasses then
    _G.GearPickerVerifyClasses()
end

System.LogAlways("$6[GearPicker] ClassRegistryFix.lua completed")

return true