-- SimplifiedInventoryScan.lua - A direct inventory scanning approach focused on stats collection
-- No simulation, no equipped state tracking, just pure inventory item data

local Log = _G.GearPicker.Log

--- @class SimplifiedInventoryScan
local SimplifiedInventoryScan = {
    new = function(self, player, script, itemManager, itemCategory)
        local instance = {
            player = player,
            script = script, 
            itemManager = itemManager,
            itemCategory = itemCategory,
            inventoryItems = {}
        }
        setmetatable(instance, { __index = self })
        Log.info("SimplifiedInventoryScan: New instance created")
        System.LogAlways("$2[GearPicker] SimplifiedInventoryScan instance created")
        return instance
    end,
    
    -- Scan inventory with the sole purpose of gathering gear stats
    scanInventory = function(self, callback)
        --- @type SimplifiedInventoryScan
        local this = self
        
        System.LogAlways("$2[GearPicker] Starting simplified gear scanner...")
        
        -- Reset data
        this.inventoryItems = {}
        
        -- Try to get inventory items with multiple approaches
        local inventoryItems = {}
        
        -- First try GetInventoryTable (more reliable in some game versions)
        local success = pcall(function()
            local items = this.player.inventory:GetInventoryTable()
            if items and type(items) == "table" then
                System.LogAlways("$2[GearPicker] Successfully retrieved inventory using GetInventoryTable()")
                inventoryItems = items
            end
        end)
        
        -- If still empty, try iterating through inventory numerically
        if #inventoryItems == 0 then
            System.LogAlways("$2[GearPicker] Trying direct inventory access...")
            
            -- Try to get inventory size
            local inventorySize = 0
            pcall(function() 
                inventorySize = this.player.inventory:GetCount() 
            end)
            
            if inventorySize > 0 then
                System.LogAlways("$2[GearPicker] Inventory size: " .. inventorySize)
                
                -- Iterate through inventory slots by index
                for i = 0, inventorySize - 1 do
                    pcall(function()
                        local item = this.player.inventory:GetItem(i)
                        if item and item.id then
                            table.insert(inventoryItems, item.id)
                        end
                    end)
                end
            end
        end
        
        -- Log the results of our attempts
        System.LogAlways("$2[GearPicker] Found " .. #inventoryItems .. " total items in inventory")
        
        -- Process each item we found
        local processedCount = 0
        local gearCount = 0
        
        for _, itemId in ipairs(inventoryItems) do
            processedCount = processedCount + 1
            
            -- Basic progress logging (every 100 items)
            if processedCount % 100 == 0 or processedCount == 1 or processedCount == #inventoryItems then
                System.LogAlways("$5[GearPicker] Processing item " .. processedCount .. " of " .. #inventoryItems)
            end
            
            -- Get item details (with error handling)
            local item = nil
            pcall(function() item = this.itemManager.GetItem(itemId) end)
            
            if not item then goto continue end
            
            -- Simple filter for potential gear items (ONLY equippable armor/clothing)
            if not this:isEquippableGear(item) then goto continue end
            
            -- We have a potential gear item - collect stats
            gearCount = gearCount + 1
            
            -- Collect item stats and add to inventory items
            local stats = this:collectItemStats(item, itemId)
            if stats then
                table.insert(this.inventoryItems, stats)
                
                -- Log each gear item found
                local infoStr = string.format("$5[GearPicker] Found gear: %s (Def: S=%d/L=%d/B=%d)",
                    stats.name, stats.stabDefense, stats.slashDefense, stats.bluntDefense)
                
                System.LogAlways(infoStr)
            end
            
            ::continue::
        end
        
        -- Final results summary
        System.LogAlways("$6[GearPicker] =========================================================")
        System.LogAlways("$6[GearPicker] SCAN COMPLETE - Processed " .. processedCount .. " items")
        System.LogAlways("$6[GearPicker] Found " .. gearCount .. " equippable gear items")
        System.LogAlways("$6[GearPicker] =========================================================")
        
        -- If we have a callback, call it with our results (sending empty array as second parameter)
        if callback then
            callback(this.inventoryItems, {})
        end
    end,
    
    -- Check if an item is equippable armor/clothing (NOT weapons)
    isEquippableGear = function(self, item)
        if not item then return false end
        
        -- Check if it's an item that can be equipped
        local canEquip = false
        pcall(function() 
            if item.CanEquip then 
                canEquip = item:CanEquip()
            end
        end)
        
        if not canEquip then return false end
        
        -- Get the item name for filtering
        local name = ""
        pcall(function()
            if item.class then
                name = self.itemManager.GetItemName(item.class) or ""
            end
        end)
        
        local lcName = string.lower(name)
        
        -- Skip weapons (we only want armor/clothing)
        if lcName:find("sword") or
           lcName:find("axe") or
           lcName:find("mace") or
           lcName:find("bow") or
           lcName:find("arrow") or
           lcName:find("shield") or
           lcName:find("hammer") then
            return false
        end
        
        -- Skip consumables and non-equipment
        if lcName:find("potion") or 
           lcName:find("herb") or
           lcName:find("book") or
           lcName:find("food") or
           lcName:find("torch") or
           lcName:find("lockpick") then
            return false
        end
        
        return true
    end,
    
    -- Collect stats for an item
    collectItemStats = function(self, item, itemId)
        if not item then return nil end
        
        -- Create basic stats object
        local stats = {
            id = itemId,
            name = "Unknown Item",
            uiName = "",
            slot = "unknown",
            weight = 0,
            
            -- Defense stats
            stabDefense = 0,
            slashDefense = 0,
            bluntDefense = 0,
            
            -- Stealth stats
            noise = 0,
            visibility = 0,
            conspicuousness = 0,
            
            -- Social stats
            charisma = 0,
            
            -- Physical properties
            condition = 1,
            maxCondition = 1,
            
            -- Material type
            material = "unknown",
            
            -- Categories (armor slot categories)
            categories = {}
        }
        
        -- Get basic item info
        pcall(function()
            if item.class then
                stats.name = self.itemManager.GetItemName(item.class) or "Unknown"
                stats.uiName = self.itemManager.GetItemUIName(item.class) or ""
            end
        end)
        
        -- Get item slot
        pcall(function()
            if item.GetSlot then
                stats.slot = item:GetSlot() or "unknown"
            end
        end)
        
        -- Basic stats
        pcall(function()
            if item.GetWeight then stats.weight = item:GetWeight() or 0 end
            if item.GetCondition then stats.condition = item:GetCondition() or 1 end
            if item.GetMaxCondition then stats.maxCondition = item:GetMaxCondition() or 1 end
        end)
        
        -- Defense stats
        pcall(function()
            if item.GetStabDefense then stats.stabDefense = item:GetStabDefense() or 0 end
            if item.GetSlashDefense then stats.slashDefense = item:GetSlashDefense() or 0 end
            if item.GetBluntDefense then stats.bluntDefense = item:GetBluntDefense() or 0 end
        end)
        
        -- Stealth stats
        pcall(function()
            if item.GetNoise then stats.noise = item:GetNoise() or 0 end
            if item.GetVisibility then stats.visibility = item:GetVisibility() or 0 end
            if item.GetConspicuousness then stats.conspicuousness = item:GetConspicuousness() or 0 end
        end)
        
        -- Social stats
        pcall(function()
            if item.GetCharisma then stats.charisma = item:GetCharisma() or 0 end
        end)
        
        -- Categorize the item
        self:categorizeItem(stats)
        
        return stats
    end,
    
    -- Categorize an item based on its properties
    categorizeItem = function(self, stats)
        local lcName = string.lower(stats.name)
        
        -- Detect item type by name patterns
        if lcName:find("helmet") or lcName:find("bascinet") or lcName:find("cap") then
            stats.slot = "head"
            table.insert(stats.categories, "helmet")
            stats.material = "plate"
        elseif lcName:find("coif") then
            stats.slot = "head_under"
            table.insert(stats.categories, "coif")
            
            if lcName:find("mail") then
                stats.material = "chainmail"
            else
                stats.material = "cloth"
            end
        elseif lcName:find("chest") or lcName:find("cuirass") or lcName:find("brigandine") then
            stats.slot = "torso_outer"
            table.insert(stats.categories, "chestplate")
            stats.material = "plate"
        elseif lcName:find("hauberk") or lcName:find("mail") then
            stats.slot = "torso_middle"
            table.insert(stats.categories, "chainmail")
            stats.material = "chainmail"
        elseif lcName:find("gambeson") or lcName:find("aketon") or lcName:find("arming") then
            stats.slot = "torso_under"
            table.insert(stats.categories, "gambeson")
            stats.material = "cloth"
        elseif lcName:find("glove") or lcName:find("gauntlet") then
            stats.slot = "hands"
            table.insert(stats.categories, "gloves")
            
            if lcName:find("leather") then
                stats.material = "leather"
            elseif lcName:find("plate") then
                stats.material = "plate"
            else
                stats.material = "cloth"
            end
        elseif lcName:find("boot") or lcName:find("shoe") then
            stats.slot = "feet"
            table.insert(stats.categories, "shoes")
            
            if lcName:find("leather") then
                stats.material = "leather"
            else
                stats.material = "cloth"
            end
        elseif lcName:find("hood") or lcName:find("hat") then
            stats.slot = "head"
            table.insert(stats.categories, "hood")
            stats.material = "cloth"
        elseif lcName:find("pant") or lcName:find("hose") or lcName:find("leg") or lcName:find("chausse") then
            stats.slot = "legs"
            table.insert(stats.categories, "legs")
            
            if lcName:find("mail") then
                stats.material = "chainmail"
            elseif lcName:find("plate") then
                stats.material = "plate"
            elseif lcName:find("leather") then
                stats.material = "leather"
            else
                stats.material = "cloth"
            end
        elseif lcName:find("sleeve") or lcName:find("arm") then
            stats.slot = "arms"
            table.insert(stats.categories, "arms")
            
            if lcName:find("mail") then
                stats.material = "chainmail"
            elseif lcName:find("plate") then
                stats.material = "plate"
            elseif lcName:find("leather") then
                stats.material = "leather"
            else
                stats.material = "cloth"
            end
        elseif lcName:find("ring") or lcName:find("necklace") or lcName:find("pendant") then
            stats.slot = "jewelry"
            table.insert(stats.categories, "jewelry")
        end
        
        -- Determine material type if not already set
        if stats.material == "unknown" then
            -- Try to infer material from defense stats
            if stats.slashDefense > stats.stabDefense * 1.5 and stats.slashDefense > stats.bluntDefense * 1.5 then
                stats.material = "chainmail"  -- Chainmail is much better against slash
            elseif stats.stabDefense > 15 and stats.slashDefense > 15 and stats.bluntDefense > 15 then
                stats.material = "plate"  -- Plate has high defense across all types
            elseif stats.stabDefense < 5 and stats.slashDefense < 5 and stats.charisma > 0 then
                stats.material = "cloth"  -- Cloth has low defense but often has charisma
            elseif stats.stabDefense > 3 and stats.slashDefense > 3 and stats.bluntDefense < 10 then
                stats.material = "leather"  -- Leather has moderate defense
            end
        end
    end
}

-- Register the class in the global registry with multiple attempts
_G.GearPicker = _G.GearPicker or {}
_G.GearPicker.ClassRegistry = _G.GearPicker.ClassRegistry or {}

-- Register twice to ensure it works
_G.GearPicker.ClassRegistry.SimplifiedInventoryScan = SimplifiedInventoryScan

-- Also make it globally accessible for emergency fallback
_G.SimplifiedInventoryScan = SimplifiedInventoryScan

-- Verify the registration
if _G.GearPicker.ClassRegistry.SimplifiedInventoryScan then
    System.LogAlways("$2[GearPicker] Successfully registered SimplifiedInventoryScan in ClassRegistry")
else
    System.LogAlways("$4[GearPicker] ERROR: Failed to register SimplifiedInventoryScan in ClassRegistry!")
    
    -- Try one more time
    _G.GearPicker.ClassRegistry = _G.GearPicker.ClassRegistry or {}
    _G.GearPicker.ClassRegistry.SimplifiedInventoryScan = SimplifiedInventoryScan
    System.LogAlways("$2[GearPicker] Second attempt to register SimplifiedInventoryScan")
end

-- Register a function to check SimplifiedInventoryScan availability
_G.VerifySimplifiedInventoryScan = function()
    System.LogAlways("$6[GearPicker] Verifying SimplifiedInventoryScan availability")
    
    if _G.SimplifiedInventoryScan then
        System.LogAlways("$2[GearPicker] SimplifiedInventoryScan is available as global variable")
    else
        System.LogAlways("$4[GearPicker] SimplifiedInventoryScan is NOT available as global variable!")
    end
    
    if _G.GearPicker and _G.GearPicker.ClassRegistry and _G.GearPicker.ClassRegistry.SimplifiedInventoryScan then
        System.LogAlways("$2[GearPicker] SimplifiedInventoryScan is registered in ClassRegistry")
    else
        System.LogAlways("$4[GearPicker] SimplifiedInventoryScan is NOT registered in ClassRegistry!")
    end
    
    return true
end

-- Verify immediately
_G.VerifySimplifiedInventoryScan()

System.LogAlways("$2[GearPicker] Successfully registered SimplifiedInventoryScan class globally")

return SimplifiedInventoryScan