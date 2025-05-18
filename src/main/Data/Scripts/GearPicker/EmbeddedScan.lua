-- EmbeddedScan.lua - A direct backup implementation to use when SimplifiedInventoryScan fails to load

local Log = _G.GearPicker.Log or {
    info = function(...) System.LogAlways("[GearPicker] INFO: " .. tostring(...)) end,
    warning = function(...) System.LogAlways("[GearPicker] WARNING: " .. tostring(...)) end,
    error = function(...) System.LogAlways("[GearPicker] ERROR: " .. tostring(...)) end
}

--- @class EmbeddedScan
local EmbeddedScan = {
    new = function(self, player, script, itemManager, itemCategory)
        local instance = {
            player = player,
            script = script, 
            itemManager = itemManager,
            itemCategory = itemCategory,
            inventoryItems = {}
        }
        setmetatable(instance, { __index = self })
        System.LogAlways("$2[GearPicker] EmbeddedScan instance created")
        return instance
    end,
    
    -- Scan inventory with the sole purpose of gathering gear stats
    scanInventory = function(self, callback)
        --- @type EmbeddedScan
        local this = self
        
        System.LogAlways("$2[GearPicker] Starting embedded gear scanner...")
        
        -- Reset data
        this.inventoryItems = {}
        
        -- Try to get inventory items with multiple approaches
        local inventoryItems = {}
        
        -- Try GetInventoryTable first
        local success = pcall(function()
            local items = this.player.inventory:GetInventoryTable()
            if items and type(items) == "table" then
                System.LogAlways("$2[GearPicker] Successfully retrieved inventory using GetInventoryTable()")
                inventoryItems = items
            end
        end)
        
        -- If still empty, try to get inventory size
        if #inventoryItems == 0 then
            System.LogAlways("$2[GearPicker] Trying direct inventory access...")
            
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
        
        -- Check if we found any items
        if #inventoryItems == 0 then
            System.LogAlways("$4[GearPicker] Could not retrieve any inventory items!")
            if callback then callback({}, {}) end
            return
        end
        
        System.LogAlways("$2[GearPicker] Found " .. #inventoryItems .. " total items in inventory")
        
        -- Process each item we found
        local processedCount = 0
        local gearCount = 0
        
        for _, itemId in ipairs(inventoryItems) do
            processedCount = processedCount + 1
            
            -- Basic progress logging
            if processedCount % 100 == 0 or processedCount == 1 or processedCount == #inventoryItems then
                System.LogAlways("$5[GearPicker] Processing item " .. processedCount .. " of " .. #inventoryItems)
            end
            
            -- Get item details
            local item = nil
            pcall(function() item = this.itemManager.GetItem(itemId) end)
            
            if not item then goto continue end
            
            -- Check if this is potential gear
            local canEquip = false
            pcall(function() 
                if item.CanEquip then 
                    canEquip = item:CanEquip() 
                end 
            end)
            
            if not canEquip then goto continue end
            
            -- Get item name for filtering
            local name = ""
            pcall(function() 
                if item.class then 
                    name = this.itemManager.GetItemName(item.class) or "" 
                end 
            end)
            
            local lcName = string.lower(name)
            
            -- Skip weapons, consumables, etc.
            if lcName:find("sword") or
               lcName:find("axe") or
               lcName:find("mace") or
               lcName:find("bow") or
               lcName:find("arrow") or
               lcName:find("potion") or
               lcName:find("food") or
               lcName:find("torch") then
                goto continue
            end
            
            -- We have a gear item
            gearCount = gearCount + 1
            
            -- Collect basic stats
            local stats = {
                id = itemId,
                name = name,
                uiName = "",
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
            
            -- Try to get UI name
            pcall(function() 
                if item.class then 
                    stats.uiName = this.itemManager.GetItemUIName(item.class) or "" 
                end 
            end)
            
            -- Try to get slot
            pcall(function() 
                if item.GetSlot then 
                    stats.slot = item:GetSlot() or "unknown" 
                end 
            end)
            
            -- Basic stats
            pcall(function()
                if item.GetWeight then stats.weight = item:GetWeight() or 0 end
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
            
            -- Determine slot and material
            if lcName:find("helmet") or lcName:find("bascinet") then
                stats.slot = "head"
                stats.material = "plate"
            elseif lcName:find("coif") then
                stats.slot = "head_under"
                stats.material = lcName:find("mail") and "chainmail" or "cloth"
            elseif lcName:find("chest") or lcName:find("cuirass") then
                stats.slot = "torso_outer"
                stats.material = "plate"
            elseif lcName:find("hauberk") or lcName:find("mail") then
                stats.slot = "torso_middle"
                stats.material = "chainmail"
            elseif lcName:find("gambeson") then
                stats.slot = "torso_under"
                stats.material = "cloth"
            elseif lcName:find("glove") or lcName:find("gauntlet") then
                stats.slot = "hands"
                stats.material = lcName:find("leather") and "leather" or (lcName:find("plate") and "plate" or "cloth")
            elseif lcName:find("boot") or lcName:find("shoe") then
                stats.slot = "feet"
                stats.material = lcName:find("leather") and "leather" or "cloth"
            elseif lcName:find("hood") or lcName:find("hat") then
                stats.slot = "head"
                stats.material = "cloth"
            end
            
            -- Add to inventory items
            table.insert(this.inventoryItems, stats)
            
            -- Log item
            if stats.stabDefense > 0 or stats.slashDefense > 0 or stats.bluntDefense > 0 then
                System.LogAlways(string.format("$5[GearPicker] Found gear: %s (Def: S=%d/L=%d/B=%d)",
                    stats.name, stats.stabDefense, stats.slashDefense, stats.bluntDefense))
            end
            
            ::continue::
        end
        
        -- Final results summary
        System.LogAlways("$6[GearPicker] =========================================================")
        System.LogAlways("$6[GearPicker] SCAN COMPLETE - Processed " .. processedCount .. " items")
        System.LogAlways("$6[GearPicker] Found " .. gearCount .. " equippable gear items")
        System.LogAlways("$6[GearPicker] =========================================================")
        
        -- Call the callback
        if callback then
            callback(this.inventoryItems, {})
        end
    end
}

-- Register as a fallback scanner
_G.GearPicker = _G.GearPicker or {}
_G.GearPicker.ClassRegistry = _G.GearPicker.ClassRegistry or {}
_G.GearPicker.ClassRegistry.EmbeddedScan = EmbeddedScan
System.LogAlways("$2[GearPicker] Successfully registered EmbeddedScan class")

return EmbeddedScan