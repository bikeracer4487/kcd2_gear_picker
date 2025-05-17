-- SimplifiedInventoryScan.lua - A simplified direct inventory scanning approach
-- Based on the original approach from archived_mod that's known to work

local Log = _G.GearPicker.Log

--- @class SimplifiedInventoryScan
local SimplifiedInventoryScan = {
    new = function(self, player, script, itemManager, itemCategory)
        local instance = {
            player = player,
            script = script, 
            itemManager = itemManager,
            itemCategory = itemCategory,
            inventoryItems = {},
            equippedItems = {}
        }
        setmetatable(instance, { __index = self })
        Log.info("SimplifiedInventoryScan: New instance created")
        System.LogAlways("$2[GearPicker] SimplifiedInventoryScan instance created")
        return instance
    end,
    
    -- Scan the inventory using direct approach
    scanInventory = function(self, callback)
        --- @type SimplifiedInventoryScan
        local this = self
        
        System.LogAlways("$2[GearPicker] Starting simplified inventory scan...")
        
        -- Reset data
        this.inventoryItems = {}
        this.equippedItems = {}
        
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
        local equippedCount = 0
        
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
            
            -- Simple filter for potential gear items
            if not this:isPotentialGear(item) then goto continue end
            
            -- We have a potential gear item - collect stats
            gearCount = gearCount + 1
            
            -- Collect item stats and add to inventory items
            local stats = this:collectItemStats(item, itemId)
            if stats then
                table.insert(this.inventoryItems, stats)
                
                -- Check if equipped and add to equipped list if so
                if stats.isEquipped then
                    equippedCount = equippedCount + 1
                    table.insert(this.equippedItems, stats)
                end
            end
            
            ::continue::
        end
        
        -- Final results summary
        System.LogAlways("$6[GearPicker] =========================================================")
        System.LogAlways("$6[GearPicker] SCAN COMPLETE - Processed " .. processedCount .. " items")
        System.LogAlways("$6[GearPicker] Found " .. gearCount .. " gear items")
        System.LogAlways("$6[GearPicker] Found " .. equippedCount .. " equipped items")
        System.LogAlways("$6[GearPicker] =========================================================")
        
        -- If we have a callback, call it with our results
        if callback then
            callback(this.inventoryItems, this.equippedItems)
        end
    end,
    
    -- Check if an item is potentially gear (armor, weapon, etc.)
    isPotentialGear = function(self, item)
        if not item then return false end
        
        -- Check if it's an item that can be equipped
        local canEquip = false
        pcall(function() 
            if item.CanEquip then 
                canEquip = item:CanEquip()
            end
        end)
        
        -- Check if it's already equipped
        local isEquipped = false
        pcall(function()
            if item.IsEquipped then
                isEquipped = item:IsEquipped()
            end
        end)
        
        -- Get the item name and class for filtering
        local name = ""
        local uiName = ""
        pcall(function()
            if item.class then
                name = self.itemManager.GetItemName(item.class) or ""
                uiName = self.itemManager.GetItemUIName(item.class) or ""
            end
        end)
        
        -- Apply some basic filtering using name patterns
        local lcName = string.lower(name)
        
        -- Skip consumables and non-equipment
        if lcName:find("potion") or 
           lcName:find("herb") or
           lcName:find("book") or
           lcName:find("apple") or
           lcName:find("mushroom") or
           lcName:find("flower") or
           lcName:find("alcohol") or
           lcName:find("torch") or
           lcName:find("arrow") then
            return false
        end
        
        -- Return result - if it can be equipped or is equipped, it's potential gear
        return canEquip or isEquipped
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
            isEquipped = false,
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
            
            -- Categories
            categories = {}
        }
        
        -- Get basic item info
        pcall(function()
            if item.class then
                stats.name = self.itemManager.GetItemName(item.class) or "Unknown"
                stats.uiName = self.itemManager.GetItemUIName(item.class) or ""
            end
        end)
        
        -- Check if equipped
        pcall(function()
            if item.IsEquipped then
                stats.isEquipped = item:IsEquipped()
            end
            
            -- Check equipped slot as alternative
            if item.GetEquippedSlot then
                local slot = item:GetEquippedSlot()
                if slot and slot ~= "" then
                    stats.isEquipped = true
                end
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
        
        -- Log any item with some stats
        if stats.stabDefense > 0 or stats.slashDefense > 0 or stats.bluntDefense > 0 or
           stats.noise > 0 or stats.visibility > 0 or stats.charisma > 0 then
            System.LogAlways("$5[GearPicker] Found item: " .. stats.name .. " (" .. (stats.isEquipped and "equipped" or "not equipped") .. ")")
        end
        
        -- For equipped items, show more detail
        if stats.isEquipped then
            local defenseStr = ""
            if stats.stabDefense > 0 then defenseStr = defenseStr .. "Stab=" .. stats.stabDefense .. " " end
            if stats.slashDefense > 0 then defenseStr = defenseStr .. "Slash=" .. stats.slashDefense .. " " end
            if stats.bluntDefense > 0 then defenseStr = defenseStr .. "Blunt=" .. stats.bluntDefense .. " " end
            
            if defenseStr ~= "" then
                System.LogAlways("$3[GearPicker]   Defense: " .. defenseStr)
            end
            
            if stats.weight > 0 then
                System.LogAlways("$3[GearPicker]   Weight: " .. stats.weight)
            end
            
            if stats.slot and stats.slot ~= "unknown" then
                System.LogAlways("$3[GearPicker]   Slot: " .. stats.slot)
            end
        end
        
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
        elseif lcName:find("sword") or lcName:find("axe") or lcName:find("mace") then
            stats.slot = "weapon"
            table.insert(stats.categories, "weapon")
        elseif lcName:find("shield") then
            stats.slot = "offhand"
            table.insert(stats.categories, "shield")
        elseif lcName:find("bow") or lcName:find("crossbow") then
            stats.slot = "ranged"
            table.insert(stats.categories, "ranged")
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

-- Register the class in the global registry
_G.GearPicker.ClassRegistry.SimplifiedInventoryScan = SimplifiedInventoryScan

return SimplifiedInventoryScan