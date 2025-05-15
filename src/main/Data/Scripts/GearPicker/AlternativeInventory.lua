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
    
    -- Helper function to extract item info consistently
    extractItemInfo = function(self, item, source)
        --- @type AlternativeInventory
        local this = self
        
        if not item then
            return nil
        end
        
        -- Basic item info structure
        local itemInfo = {
            id = item.id or 0,
            name = "Unknown item",
            source = source or "unknown",
            isEquipped = false
        }
        
        -- Try to get item name
        if item.class and this.itemManager and this.itemManager.GetItemName then
            local nameSuccess, name = pcall(function()
                return this.itemManager.GetItemName(item.class)
            end)
            
            if nameSuccess and name then
                itemInfo.name = name
                AltLog("Found item from " .. (source or "unknown") .. ": " .. name)
            end
        end
        
        -- Try alternate name properties
        if not itemInfo.name or itemInfo.name == "Unknown item" then
            if item.name then
                itemInfo.name = item.name
            elseif item.GetName and type(item.GetName) == "function" then
                local success, name = pcall(function() return item:GetName() end)
                if success and name then
                    itemInfo.name = name
                end
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
        
        -- Try to get weight if available
        if item.GetWeight then
            local success, weight = pcall(function() return item:GetWeight() end)
            if success and weight then
                itemInfo.weight = weight
            end
        elseif item.weight then
            itemInfo.weight = item.weight
        end
        
        -- Try to get slot if available
        if item.GetSlot then
            local success, slot = pcall(function() return item:GetSlot() end)
            if success and slot then
                itemInfo.slot = slot
            end
        elseif item.slot then
            itemInfo.slot = item.slot
        end
        
        return itemInfo
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
        
        AltLog("Checking player equipment stats")
        
        -- Special method to try getting equipped items from the inventory
        if this.player.inventory.GetEquippedItems then
            AltLog("Found GetEquippedItems method, trying to access equipped items directly")
            
            local success, equippedItems = pcall(function()
                return this.player.inventory:GetEquippedItems()
            end)
            
            if success and equippedItems and type(equippedItems) == "table" then
                AltLog("Successfully got " .. #equippedItems .. " equipped items via GetEquippedItems()")
                
                for i, item in ipairs(equippedItems) do
                    local itemInfo = this:extractItemInfo(item, "GetEquippedItems() direct access")
                    if itemInfo then
                        itemInfo.isEquipped = true
                        table.insert(results, itemInfo)
                    end
                end
            else
                AltLog("GetEquippedItems() failed or returned nil/non-table")
            end
        end
        
        -- Special case for KCD2: Try to access the active equipment
        if this.player.activeEquipment then
            AltLog("Found player.activeEquipment, trying to access")
            
            if type(this.player.activeEquipment) == "table" then
                AltLog("activeEquipment is a table, examining contents")
                
                for slotName, item in pairs(this.player.activeEquipment) do
                    if item then
                        AltLog("Found item in activeEquipment slot: " .. tostring(slotName))
                        
                        local itemInfo = this:extractItemInfo(item, "activeEquipment." .. tostring(slotName))
                        if itemInfo then
                            itemInfo.isEquipped = true
                            itemInfo.slot = tostring(slotName)
                            table.insert(results, itemInfo)
                        end
                    end
                end
            elseif type(this.player.activeEquipment) == "userdata" and this.player.activeEquipment.GetEquippedItems then
                AltLog("activeEquipment is an object with GetEquippedItems method")
                
                local success, eqItems = pcall(function()
                    return this.player.activeEquipment:GetEquippedItems()
                end)
                
                if success and eqItems and type(eqItems) == "table" then
                    AltLog("Successfully got " .. #eqItems .. " items from activeEquipment:GetEquippedItems()")
                    
                    for i, item in ipairs(eqItems) do
                        local itemInfo = this:extractItemInfo(item, "activeEquipment:GetEquippedItems()")
                        if itemInfo then
                            itemInfo.isEquipped = true
                            table.insert(results, itemInfo)
                        end
                    end
                end
            end
        end
        
        -- First approach: Try to derive equipped items from player stats
        local equippedWeight = 0
        if this.player.soul and this.player.soul.GetDerivedStat then
            local success, weight = pcall(function()
                return this.player.soul:GetDerivedStat("eqw")
            end)
            
            if success and weight and weight > 0 then
                equippedWeight = weight
                AltLog("Player has equipped gear with weight: " .. weight)
                
                -- Create a placeholder entry to show equipped weight
                table.insert(results, {
                    id = 0,
                    slot = "unknown",
                    name = "Some equipped gear detected",
                    weight = weight,
                    isEquipped = true
                })
            end
        end
        
        -- Check if player has direct equipment table
        if this.player.equipment then
            AltLog("Player has equipment table, trying to access directly")
            
            if type(this.player.equipment) == "table" then
                for slot, item in pairs(this.player.equipment) do
                    if item then
                        AltLog("Found direct equipment item in slot: " .. tostring(slot))
                        
                        local itemInfo = {
                            id = item.id or 0,
                            slot = tostring(slot),
                            name = "Unknown direct equipment",
                            isEquipped = true
                        }
                        
                        -- Try to get name
                        if item.class and this.itemManager and this.itemManager.GetItemName then
                            local success, name = pcall(function()
                                return this.itemManager.GetItemName(item.class)
                            end)
                            
                            if success and name then
                                itemInfo.name = name
                            end
                        end
                        
                        table.insert(results, itemInfo)
                    end
                end
            end
        end
        
        AltLog("Checking player equipment slots")
        
        -- Define equipment slots to check (expanded list)
        local slots = {
            -- Standard slots
            "head", "neck", "body", "hands", "legs", "feet",
            "ringL", "ringR", "leftHand", "rightHand", "cloak",
            "amulet", "boots", "outfit", "helmet", "armor",
            
            -- KCD2-specific slots
            "head_under", "torso_outer", "torso_outer_layer", "torso_middle", "torso_under",
            "arms", "hands", "legs", "feet", "feet_accessory",
            "jewelry1", "jewelry2", "ranged",
            
            -- Generic slot names
            "Helmet", "Chest", "Gloves", "Boots", "Weapon", "Shield",
            "HeadArmor", "ChestArmor", "HandArmor", "LegArmor", "FootArmor"
        }
        
        -- Try to get equipped items from player slots
        for _, slot in ipairs(slots) do
            -- First try with explicit methods (Get<Slot>Item)
            local methodName = "Get" .. slot:sub(1,1):upper() .. slot:sub(2) .. "Item"
            local success, slotItem
            
            -- Try with inventory
            if this.player.inventory[methodName] then
                success, slotItem = pcall(function()
                    return this.player.inventory[methodName](this.player.inventory)
                end)
            end
            
            -- Try directly with player
            if not (success and slotItem) and this.player[methodName] then
                success, slotItem = pcall(function()
                    return this.player[methodName](this.player)
                end)
            end
            
            -- Try generic slot access with inventory.GetSlotItem
            if not (success and slotItem) and this.player.inventory.GetSlotItem then
                success, slotItem = pcall(function()
                    return this.player.inventory:GetSlotItem(slot)
                end)
            end
            
            -- Try player.GetEquippedItem if available
            if not (success and slotItem) and this.player.GetEquippedItem then
                success, slotItem = pcall(function()
                    return this.player:GetEquippedItem(slot)
                end)
            end
            
            -- Process item if found
            if success and slotItem then
                AltLog("Found item in slot: " .. slot)
                
                -- Get basic item info
                local itemInfo = {
                    id = slotItem.id or 0,
                    slot = slot,
                    name = "Unknown item in " .. slot,
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
                    local weightSuccess, weight = pcall(function()
                        return slotItem:GetWeight()
                    end)
                    
                    if weightSuccess and weight then
                        itemInfo.weight = weight
                    end
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
        
        -- First approach: Try to manually enumerate inventory slots
        local equippedItems = this:scanEquippedItems()
        
        -- Make a copy of equipped items for the full inventory list
        local inventoryItems = {}
        for _, item in ipairs(equippedItems) do
            table.insert(inventoryItems, item)
        end
        
        -- Try more methods to access inventory
        AltLog("Trying multiple methods to access inventory items")
        
        -- Method 1: Check if player has direct inventory items table
        if this.player.inventoryItems and type(this.player.inventoryItems) == "table" then
            AltLog("Found player.inventoryItems table, checking contents")
            for i, item in ipairs(this.player.inventoryItems) do
                if item then
                    local itemInfo = this:extractItemInfo(item, "player.inventoryItems direct access")
                    if itemInfo then
                        table.insert(inventoryItems, itemInfo)
                    end
                end
            end
        end
        
        -- Method 2: Check player.items if it exists
        if this.player.items and type(this.player.items) == "table" then
            AltLog("Found player.items table, checking contents")
            for i, item in ipairs(this.player.items) do
                if item then
                    local itemInfo = this:extractItemInfo(item, "player.items direct access")
                    if itemInfo then
                        table.insert(inventoryItems, itemInfo)
                    end
                end
            end
        end
        
        -- Method 3: Access the inventory contents table if it exists
        if this.player.inventory.contents and type(this.player.inventory.contents) == "table" then
            AltLog("Found inventory.contents table, checking items")
            for i, item in ipairs(this.player.inventory.contents) do
                if item then
                    local itemInfo = this:extractItemInfo(item, "inventory.contents direct access")
                    if itemInfo then
                        table.insert(inventoryItems, itemInfo)
                    end
                end
            end
        end
        
        -- Method 4: Try to find an EnumerateItems method
        if this.player.inventory.EnumerateItems then
            AltLog("Found EnumerateItems method, trying to use it")
            local success, items = pcall(function()
                return this.player.inventory:EnumerateItems()
            end)
            
            if success and items and type(items) == "table" then
                AltLog("Successfully enumerated " .. #items .. " items")
                for i, item in ipairs(items) do
                    local itemInfo = this:extractItemInfo(item, "EnumerateItems method")
                    if itemInfo then
                        table.insert(inventoryItems, itemInfo)
                    end
                end
            end
        end
        
        -- Method 5: Look for a GetCount and GetItem pattern
        if this.player.inventory.GetCount then
            local success, count = pcall(function()
                return this.player.inventory:GetCount()
            end)
            
            if success and count and count > 0 then
                AltLog("Inventory has " .. count .. " items according to GetCount")
                
                -- If we have GetCount, try GetItem(index) with aggressive approach
                if this.player.inventory.GetItem then
                    -- Sample only 10 items to avoid performance issues (1 from each percentile of inventory)
                    for i = 1, 10 do
                        local index = math.floor((i-1) * count / 10)
                        local getItemSuccess, item = pcall(function()
                            return this.player.inventory:GetItem(index)
                        end)
                        
                        if getItemSuccess then
                            if item then
                                AltLog("Successfully got inventory item at index " .. index)
                                
                                local itemInfo = this:extractItemInfo(item, "GetItem(" .. index .. ")")
                                if itemInfo then
                                    table.insert(inventoryItems, itemInfo)
                                end
                                
                                -- Try to inspect item more deeply to see its structure
                                AltLog("Item details from GetItem(" .. index .. "):")
                                
                                -- Check common properties
                                for _, prop in ipairs({"id", "class", "name", "weight", "slot", "equipped"}) do
                                    if item[prop] ~= nil then
                                        AltLog("  - " .. prop .. ": " .. tostring(item[prop]))
                                    end
                                end
                                
                                -- Look for methods
                                for _, method in ipairs({"GetName", "GetWeight", "GetClass", "IsEquipped", "GetEquippedSlot"}) do
                                    if type(item[method]) == "function" then
                                        local methodSuccess, result = pcall(function() return item[method](item) end)
                                        if methodSuccess then
                                            AltLog("  - " .. method .. "(): " .. tostring(result))
                                        end
                                    end
                                end
                            else
                                AltLog("Item at index " .. index .. " is nil")
                            end
                        else
                            AltLog("Failed to get item at index " .. index .. ": " .. tostring(item))
                        end
                    end
                    
                    AltLog("Sampled 10 inventory items to analyze API structure")
                    
                    -- Look for any equipped items specifically
                    AltLog("Searching specifically for equipped items in inventory...")
                    local foundEquipped = 0
                    
                    -- Try just the first 50 items to avoid performance issues
                    local searchLimit = math.min(50, count)
                    for i = 0, searchLimit-1 do
                        local success, item = pcall(function()
                            return this.player.inventory:GetItem(i)
                        end)
                        
                        if success and item then
                            -- Check if it's equipped using various methods
                            local isEquipped = false
                            
                            -- Method 1: IsEquipped function
                            if type(item.IsEquipped) == "function" then
                                local eqSuccess, eqResult = pcall(function() return item:IsEquipped() end)
                                if eqSuccess and eqResult then
                                    isEquipped = true
                                end
                            end
                            
                            -- Method 2: equipped property
                            if item.equipped ~= nil and item.equipped == true then
                                isEquipped = true
                            end
                            
                            -- Method 3: GetEquippedSlot function returns non-nil
                            if type(item.GetEquippedSlot) == "function" then
                                local slotSuccess, slot = pcall(function() return item:GetEquippedSlot() end)
                                if slotSuccess and slot and slot ~= "" then
                                    isEquipped = true
                                end
                            end
                            
                            if isEquipped then
                                foundEquipped = foundEquipped + 1
                                local itemInfo = this:extractItemInfo(item, "GetItem(" .. i .. ") [EQUIPPED]")
                                if itemInfo then
                                    itemInfo.isEquipped = true
                                    table.insert(inventoryItems, itemInfo)
                                    table.insert(equippedItems, itemInfo)
                                    AltLog("Found equipped item at index " .. i)
                                end
                            end
                        end
                    end
                    
                    AltLog("Found " .. foundEquipped .. " equipped items in first " .. searchLimit .. " inventory slots")
                end
            end
        end
        
        -- Method 6: Attempt to get a hint about inventory size from weight
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
        
        -- Method 7: Try to enumerate inventory using GetItemByIndex
        if this.player and this.player.inventory and this.player.inventory.GetItemByIndex then
            AltLog("Found GetItemByIndex method, trying to access inventory items")
            
            local maxItems = math.max(100, approxItemCount * 2) -- Try reasonable number of slots
            local foundCount = 0
            
            for i = 0, maxItems do
                local success, item = pcall(function()
                    return this.player.inventory:GetItemByIndex(i)
                end)
                
                if success and item then
                    foundCount = foundCount + 1
                    local itemInfo = this:extractItemInfo(item, "GetItemByIndex(" .. i .. ")")
                    if itemInfo then
                        table.insert(inventoryItems, itemInfo)
                    end
                end
            end
            
            AltLog("Found " .. foundCount .. " items using GetItemByIndex method")
        end
        
        -- Method 8: Direct property access for certain game APIs
        if this.player.inventory.items and type(this.player.inventory.items) == "table" then
            AltLog("Found inventory.items direct property, scanning...")
            local itemCount = 0
            
            for id, item in pairs(this.player.inventory.items) do
                if item then
                    itemCount = itemCount + 1
                    local itemInfo = this:extractItemInfo(item, "inventory.items[" .. tostring(id) .. "]")
                    if itemInfo then
                        table.insert(inventoryItems, itemInfo)
                    end
                end
            end
            
            AltLog("Found " .. itemCount .. " items in inventory.items property")
        end
        
        -- Log summary
        AltLog("Alternative inventory scan complete")
        AltLog("Found " .. #equippedItems .. " equipped items")
        AltLog("Found " .. #inventoryItems .. " total inventory items")
        
        -- If we only found placeholder items but no actual gear details,
        -- use ApiLimitations to create simulated gear
        if #equippedItems == 1 and equippedItems[1].name == "Some equipped gear detected" then
            AltLog("Only found placeholder equipped item, creating simulated inventory")
            
            -- Get player's equipped weight
            local equippedWeight = 0
            if this.player.soul and this.player.soul.GetDerivedStat then
                local success, weight = pcall(function()
                    return this.player.soul:GetDerivedStat("eqw")
                end)
                
                if success and weight and weight > 0 then
                    equippedWeight = weight
                end
            end
            
            -- Create simulated items
            if _G.GearPicker.ClassRegistry.ApiLimitations then
                local apiLimitations = _G.GearPicker.ClassRegistry.ApiLimitations:new()
                local simInventory, simEquipped = apiLimitations:createSimulatedInventory(equippedWeight)
                
                AltLog("Created " .. #simEquipped .. " simulated equipped items")
                AltLog("Created " .. #simInventory .. " total simulated inventory items")
                
                -- Use simulated items instead of placeholders
                inventoryItems = simInventory
                equippedItems = simEquipped
                
                -- Show warning about API limitations
                local warningMsg = apiLimitations:getWarningMessage()
                for _, line in ipairs(string.gmatch(warningMsg, "[^\r\n]+")) do
                    AltLog("WARNING: " .. line)
                    System.LogAlways("$4[GearPicker] " .. line)
                end
            else
                AltLog("ApiLimitations not found in registry, cannot create simulated inventory")
            end
        end
        
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
            AltLog(i .. ". " .. item.name .. " (Slot: " .. (item.slot or "unknown") .. ")")
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

-- Register the class in GearPicker's class registry
_G.GearPicker.ClassRegistry.AlternativeInventory = AlternativeInventory
AltLog("Registered AlternativeInventory in GearPicker.ClassRegistry")

return AlternativeInventory