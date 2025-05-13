local Log = GearPicker.Log

--- @class Equipment
--- @field new fun(self: Equipment, player: _G.player, unequipGear: UnequipGear): Equipment
--- @field equipItem fun(self: Equipment, item: any): boolean
--- @field unequipItem fun(self: Equipment, category: string, callback: function): void
--- @field applyGearSet fun(self: Equipment, gearSet: table): boolean
--- @field unequipGear UnequipGear
local Equipment = {
    new = function(self, player, unequipGear, itemManager)
        local instance = {
            player = player,
            unequipGear = unequipGear,
            itemManager = itemManager,
            unequippedItems = {}, -- Store items by category when they're unequipped
            itemSlots = {}, -- Store items by slot for management
            currentLoadout = nil -- Track current loadout/preset
        }
        setmetatable(instance, { __index = self })
        Log.info("Equipment New instance created")
        return instance
    end,

    -- Generic method to unequip an item by category
    unequipItem = function(self, category, callback)
        Log.info("Equipment.unequipItem called for category: " .. category)

        self.unequipGear:takeOff(category, function(item)
            if item then
                -- Store the unequipped item by its category
                self.unequippedItems[category] = item
                
                local itemObj = self.itemManager.GetItem(item)
                local itemName = self.itemManager.GetItemName(itemObj.class)
                Log.info("Successfully unequipped " .. category .. ": " .. itemName)
            end
            return callback(item)
        end)
    end,

    -- Generic method to equip a specific item
    equipItem = function(self, item)
        if not item then
            Log.info("Equipment.equipItem: Aborting due to nil item")
            return false
        end

        local itemObj = self.itemManager.GetItem(item)
        local itemName = self.itemManager.GetItemName(itemObj.class)
        Log.info("Equipping item: " .. itemName)

        if self.player.inventory:HasItem(item) then
            self.player.actor:EquipInventoryItem(item)
            return true
        else
            Log.info("Cannot equip item - not in inventory")
            return false
        end
    end,
    
    -- Re-equip an item that was previously unequipped
    reequipItem = function(self, category)
        local item = self.unequippedItems[category]
        if not item then
            Log.info("Equipment.reequipItem: No unequipped " .. category .. " found")
            return false
        end
        
        local success = self.equipItem(self, item)
        if success then
            self.unequippedItems[category] = nil -- Clear from unequipped items
        end
        return success
    end,
    
    -- Apply a complete gear set based on a loadout configuration
    applyGearSet = function(self, gearSet, callback)
        Log.info("Equipment.applyGearSet: Applying gear set")
        
        if not gearSet or type(gearSet) ~= "table" then
            Log.error("Invalid gear set provided")
            return callback(false)
        end
        
        -- First, unequip all current items
        self:unequipAllItems(function()
            local success = true
            local itemsToEquip = {}
            
            -- Organize items by layer (base layers first)
            for slot, itemId in pairs(gearSet) do
                local item = self.itemManager.GetItem(itemId)
                if item then
                    table.insert(itemsToEquip, {
                        slot = slot,
                        item = item,
                        id = itemId,
                        -- Determine layer priority (lower number = equip first)
                        layer = self:getSlotLayerPriority(slot)
                    })
                else
                    Log.warning("Item not found for slot: " .. slot)
                    success = false
                end
            end
            
            -- Sort by layer priority
            table.sort(itemsToEquip, function(a, b)
                return a.layer < b.layer
            end)
            
            -- Equip items in correct order
            for _, itemData in ipairs(itemsToEquip) do
                if not self:equipItem(itemData.id) then
                    Log.warning("Failed to equip item for slot: " .. itemData.slot)
                    success = false
                end
            end
            
            -- Update current loadout tracking
            if success then
                self.currentLoadout = gearSet
            end
            
            callback(success)
        end)
    end,
    
    -- Unequip all items (used when switching loadouts)
    unequipAllItems = function(self, callback)
        Log.info("Equipment.unequipAllItems: Unequipping all equipment")
        
        -- Define all categories to unequip
        local categories = {
            "Helmet", "Cap", "Hood", "Coif", "HeadChainmail", "NeckGuard",
            "ChestPlate", "Coat", "Gambeson", "Shirt",
            "Sleeves", "Gloves",
            "QuiltedHose", "Shoes", "RowelSpurs",
            "Jewelry1", "Jewelry2"
        }
        
        local remaining = #categories
        local handleCompletion = function()
            remaining = remaining - 1
            if remaining <= 0 then
                callback()
            end
        end
        
        -- Unequip each category
        for _, category in ipairs(categories) do
            self:unequipItem(category, function(item)
                -- Store the item if it was unequipped
                if item then
                    self.unequippedItems[category] = item
                end
                handleCompletion()
            end)
        end
    end,
    
    -- Utility function to determine equipment order (layering)
    getSlotLayerPriority = function(self, slot)
        local layerMap = {
            -- Undergarments (base layer)
            head_under = 1,
            torso_under = 1,
            
            -- Middle layers
            neck = 2,
            torso_middle = 2,
            legs = 2,
            
            -- Outer layers
            arms = 3,
            hands = 3,
            feet = 3,
            
            -- Outermost layers
            head = 4,
            torso_outer = 4,
            torso_outer_layer = 5,
            
            -- Accessories (last)
            feet_accessory = 6,
            jewelry1 = 7,
            jewelry2 = 7
        }
        
        return layerMap[slot] or 10 -- Default to high priority if unknown
    end,
    
    -- Save the current gear set for future use
    saveCurrentGearSet = function(self, presetName)
        Log.info("Equipment.saveCurrentGearSet: Saving current gear as " .. presetName)
        
        -- Implement preset saving logic here
        -- (This would likely involve storing to a configuration file or similar)
    end
}

_G.GearPicker.ClassRegistry.Equipment = Equipment

return Equipment