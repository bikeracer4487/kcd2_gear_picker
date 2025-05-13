local Log = GearPicker.Log

--- @class UnequipGear
--- @field new fun(self: UnequipGear, player: _G.player, equippedItem: EquippedItem, itemCategory: ItemCategory, itemManager: ItemManager): UnequipGear
--- @field takeOff fun(self: UnequipGear, itemCategory: string, callback: function): void
--- @field takeOffSlot fun(self: UnequipGear, slotName: string, callback: function): void
--- @field takeOffAll fun(self: UnequipGear, callback: function): void
--- @field itemCategory ItemCategory
--- @field equippedItem EquippedItem
local UnequipGear = {
    new = function(self, player, equippedItem, itemCategory, itemManager)
        local instance = {
            player = player,
            equippedItem = equippedItem,
            itemCategory = itemCategory,
            itemManager = itemManager,
            lastRemovedItems = {} -- Track recently removed items by category
        }
        setmetatable(instance, { __index = self })
        return instance
    end,

    -- Check if an item is equipped and unequip it
    unequipIfEquipped = function(self, inventoryItem, itemType, callback)
        --- @type UnequipGear
        local this = self
        local item = this.itemManager.GetItem(inventoryItem)
        local itemName = this.itemManager.GetItemName(item.class)
        Log.info("Checking if " .. itemType .. " is equipped: " .. itemName)

        this.equippedItem:isEquipped(inventoryItem, function(isEquipped)
            if not isEquipped then
                Log.info("UnequipGear " .. itemType .. " not equipped")
                callback(nil)
                return
            end

            -- Add to the removed items tracking
            this.lastRemovedItems[itemType] = inventoryItem
            callback(inventoryItem)
        end)
    end,

    -- Take off an item by category
    takeOff = function(self, itemCategory, callback)
        --- @type UnequipGear
        local this = self
        Log.info("UnequipGear.takeOff: " .. itemCategory)
        local itemsToCheck = {}

        for _, inventoryItem in pairs(this.player.inventory:GetInventoryTable()) do
            if this.itemCategory:is(itemCategory, inventoryItem) then
                table.insert(itemsToCheck, inventoryItem)
            end
        end

        if #itemsToCheck == 0 then
            Log.info("UnequipGear: No " .. itemCategory .. " found in inventory")
            return callback()
        end

        local index = 1
        local function processNext()
            if index > #itemsToCheck then
                Log.info("UnequipGear: Finished checking " .. itemCategory .. " items")
                return callback()
            end
            local inventoryItem = itemsToCheck[index]
            this:unequipIfEquipped(inventoryItem, itemCategory, function(newlyUnequippedItem)
                if newlyUnequippedItem then
                    return callback(newlyUnequippedItem)
                end
                index = index + 1
                processNext()
            end)
        end
        processNext()
    end,
    
    -- Take off an item by slot name
    takeOffSlot = function(self, slotName, callback)
        --- @type UnequipGear
        local this = self
        Log.info("UnequipGear.takeOffSlot: " .. slotName)
        
        -- Find which categories belong to this slot
        local categoriesForSlot = {}
        for _, category in ipairs(self:getAllCategories()) do
            if this.itemCategory:getSlotForCategory(category) == slotName then
                table.insert(categoriesForSlot, category)
            end
        end
        
        if #categoriesForSlot == 0 then
            Log.info("UnequipGear: No categories found for slot " .. slotName)
            return callback()
        end
        
        -- Process each category for this slot
        local index = 1
        local function processNextCategory()
            if index > #categoriesForSlot then
                Log.info("UnequipGear: Finished processing slot " .. slotName)
                return callback()
            end
            
            local category = categoriesForSlot[index]
            this:takeOff(category, function(item)
                if item then
                    return callback(item)
                end
                index = index + 1
                processNextCategory()
            end)
        end
        
        processNextCategory()
    end,
    
    -- Take off all equipped gear
    takeOffAll = function(self, callback)
        --- @type UnequipGear
        local this = self
        Log.info("UnequipGear.takeOffAll: Removing all equipped items")
        
        -- Get all gear categories
        local allCategories = self:getAllCategories()
        
        -- Track removed items for potential re-equipping
        this.lastRemovedItems = {}
        
        -- Take off all categories in proper order
        local index = 1
        local removedItems = {}
        
        local function processNextCategory()
            if index > #allCategories then
                Log.info("UnequipGear: All gear has been removed")
                return callback(removedItems)
            end
            
            local category = allCategories[index]
            this:takeOff(category, function(item)
                if item then
                    -- Add to our records
                    table.insert(removedItems, {
                        category = category,
                        item = item
                    })
                    this.lastRemovedItems[category] = item
                end
                
                index = index + 1
                processNextCategory()
            end)
        end
        
        processNextCategory()
    end,
    
    -- Get the most recently removed item of a category
    getLastRemovedItem = function(self, category)
        return self.lastRemovedItems[category]
    end,
    
    -- Helper to get all possible gear categories
    getAllCategories = function(self)
        return {
            -- Head gear (remove outer layers first)
            "Helmet", "Cap", "Hood", "HeadChainmail", "NeckGuard", "Coif",
            
            -- Body gear (outer to inner)
            "ChestPlate", "Coat", "Gambeson", "Shirt",
            
            -- Limbs
            "Sleeves", "Gloves", "QuiltedHose", "Shoes", "RowelSpurs",
            
            -- Accessories
            "Jewelry1", "Jewelry2"
        }
    end,
    
    -- Helper to identify the proper unequipping order for layered gear
    getUnequipOrder = function(self)
        return {
            -- Remove outer layers first
            { slot = "head", categories = {"Helmet", "Cap", "Hood"} },
            { slot = "neck", categories = {"HeadChainmail", "NeckGuard"} },
            { slot = "torso_outer", categories = {"ChestPlate"} },
            { slot = "torso_outer_layer", categories = {"Coat"} },
            { slot = "arms", categories = {"Sleeves"} },
            { slot = "hands", categories = {"Gloves"} },
            { slot = "feet_accessory", categories = {"RowelSpurs"} },
            { slot = "feet", categories = {"Shoes"} },
            { slot = "legs", categories = {"QuiltedHose"} },
            { slot = "torso_middle", categories = {"Gambeson"} },
            { slot = "head_under", categories = {"Coif"} },
            { slot = "torso_under", categories = {"Shirt"} },
            { slot = "jewelry1", categories = {"Jewelry1"} },
            { slot = "jewelry2", categories = {"Jewelry2"} }
        }
    end
}

_G.GearPicker.ClassRegistry.UnequipGear = UnequipGear

return UnequipGear