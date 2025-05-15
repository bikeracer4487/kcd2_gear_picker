-- AlternativeInventory.lua - Workaround for GetItems() API issues

-- Store reference to System.LogAlways to ensure it's available
local LogFunc = System.LogAlways

-- Basic logger function that doesn't depend on other mod code
local function AltLog(message)
    if LogFunc then
        LogFunc("$3[GearPicker-ALT] " .. tostring(message))
    end
end

-- Alternative inventory scanning module
local AlternativeInventory = {
    -- Create new instance
    new = function(self, player, itemManager)
        local instance = {
            player = player,
            itemManager = itemManager
        }
        
        setmetatable(instance, { __index = self })
        AltLog("Alternative inventory scanner initialized")
        return instance
    end,
    
    -- Scan equipped items using player stats
    scanEquippedItems = function(self)
        --- @type AlternativeInventory
        local this = self
        
        AltLog("Starting alternative equipped item scan")
        local results = {}
        
        -- Check player and required objects
        if not this.player then
            AltLog("ERROR: Player object not available")
            return results
        end
        
        if not this.player.inventory then
            AltLog("ERROR: Player inventory not available")
            return results
        end
        
        if not this.player.soul then
            AltLog("ERROR: Player soul not available")
            return results
        end
        
        AltLog("Checking player equipment slots")
        
        -- Define equipment slots to check
        local slots = {
            "head", "neck", "body", "hands", "legs", "feet",
            "ringL", "ringR", "leftHand", "rightHand", "cloak",
            "amulet", "boots", "outfit", "helmet", "armor"
        }
        
        -- Try to get equipped items from player slots
        for _, slot in ipairs(slots) do
            local success, slotItem = pcall(function()
                -- Try different methods to access slot item
                if this.player.inventory["Get" .. slot .. "Item"] then
                    return this.player.inventory["Get" .. slot .. "Item"](this.player.inventory)
                end
                
                if this.player.inventory["GetSlotItem"] then
                    return this.player.inventory:GetSlotItem(slot)
                end
                
                return nil
            end)
            
            if success and slotItem then
                AltLog("Found item in slot: " .. slot)
                
                -- Get basic item info
                local itemInfo = {
                    id = slotItem.id or 0,
                    slot = slot,
                    name = "Unknown",
                    isEquipped = true
                }
                
                -- Try to get item name
                if slotItem.class and this.itemManager and this.itemManager.GetItemName then
                    local nameSuccess, name = pcall(function()
                        return this.itemManager.GetItemName(slotItem.class)
                    end)
                    
                    if nameSuccess and name then
                        itemInfo.name = name
                        AltLog("Slot " .. slot .. " contains: " .. name)
                    end
                end
                
                -- Get additional stats if available
                if slotItem.GetWeight then
                    itemInfo.weight = slotItem:GetWeight()
                end
                
                table.insert(results, itemInfo)
            end
        end
        
        -- Try to get player stats
        local eqWeight = 0
        if this.player.soul.GetDerivedStat then
            local success, weight = pcall(function()
                return this.player.soul:GetDerivedStat("eqw")
            end)
            
            if success and weight then
                eqWeight = weight
                AltLog("Player equipped weight: " .. weight)
            end
        end
        
        AltLog("Alternative scan complete, found " .. #results .. " equipped items")
        return results
    end,
    
    -- Scan entire inventory using alternative methods
    scanInventory = function(self, callback)
        --- @type AlternativeInventory
        local this = self
        
        AltLog("Starting alternative full inventory scan")
        
        -- Try different approaches to get inventory items
        
        -- First approach: Try to manually enumerate inventory slots
        local equippedItems = this:scanEquippedItems()
        
        -- Second approach: Try to access inventory item slots directly
        local inventoryItems = {}
        
        -- Attempt to get a hint about how many items are in inventory from weight
        local approxItemCount = 0
        if this.player and this.player.inventory and this.player.inventory.GetWeight then
            local success, weight = pcall(function() 
                return this.player.inventory:GetWeight()
            end)
            
            if success then
                AltLog("Inventory weight: " .. tostring(weight))
                -- Rough estimate: assume average item weighs 2-5 units
                approxItemCount = math.ceil(weight / 3)
                AltLog("Estimated inventory items: ~" .. approxItemCount)
            end
        end
        
        -- Try to enumerate inventory using GetItemByIndex
        if this.player and this.player.inventory and this.player.inventory.GetItemByIndex then
            local maxItems = math.max(100, approxItemCount * 2) -- Try reasonable number of slots
            
            for i = 0, maxItems do
                local success, item = pcall(function()
                    return this.player.inventory:GetItemByIndex(i)
                end)
                
                if success and item then
                    local itemInfo = {
                        id = item.id or 0,
                        name = "Unknown"
                    }
                    
                    -- Try to get item name
                    if item.class and this.itemManager and this.itemManager.GetItemName then
                        local nameSuccess, name = pcall(function()
                            return this.itemManager.GetItemName(item.class)
                        end)
                        
                        if nameSuccess and name then
                            itemInfo.name = name
                            AltLog("Found inventory item: " .. name)
                        end
                    end
                    
                    -- Check if it's equipped
                    if item.IsEquipped then
                        local eqSuccess, isEquipped = pcall(function()
                            return item:IsEquipped()
                        end)
                        
                        if eqSuccess then
                            itemInfo.isEquipped = isEquipped
                            
                            if isEquipped then
                                AltLog("Item is equipped: " .. itemInfo.name)
                            end
                        end
                    end
                    
                    table.insert(inventoryItems, itemInfo)
                end
            end
        end
        
        -- Log summary
        AltLog("Alternative inventory scan complete")
        AltLog("Found " .. #equippedItems .. " equipped items")
        AltLog("Found " .. #inventoryItems .. " total inventory items")
        
        -- Call callback if provided
        if callback and type(callback) == "function" then
            AltLog("Calling provided callback with scan results")
            callback(inventoryItems, equippedItems)
        end
        
        return inventoryItems, equippedItems
    end
}

-- Register global function for direct access
_G.GearPickerAltInventoryScan = function()
    AltLog("===============================================")
    AltLog("Running alternative inventory scan")
    AltLog("===============================================")
    
    -- Create scanner and run scan
    local scanner = AlternativeInventory:new(_G.player, _G.ItemManager)
    
    local items, equipped = scanner:scanInventory(function(items, equipped)
        AltLog("Scan callback executed")
        
        -- Log equipped items
        AltLog("Equipped Items (" .. #equipped .. "):")
        for i, item in ipairs(equipped) do
            AltLog(i .. ". " .. item.name .. " (Slot: " .. item.slot .. ")")
        end
        
        -- Log all inventory items (up to 10)
        AltLog("Inventory Items (showing up to 10 of " .. #items .. "):")
        for i = 1, math.min(10, #items) do
            local item = items[i]
            AltLog(i .. ". " .. item.name .. (item.isEquipped and " [EQUIPPED]" or ""))
        end
    end)
    
    AltLog("===============================================")
    AltLog("Alternative scan complete")
    AltLog("===============================================")
    
    return items, equipped
end

-- Add a command to run the alternative scan
if System and System.AddCCommand then
    System.AddCCommand(
        "gear_picker__alt_scan",
        "GearPickerAltInventoryScan()",
        "Runs an alternative inventory scan using multiple methods"
    )
    AltLog("Registered alternative scan command: gear_picker__alt_scan")
end

return AlternativeInventory