local Log = HelmetOffDialog.Log

--- @class UnequipGear
--- @field new fun(self: UnequipGear, player: _G.player, equippedItem: EquippedItem, itemCategory: ItemCategory, itemManager: ItemManager): UnequipGear
--- @field itemCategory ItemCategory
--- @field equippedItem EquippedItem
local UnequipGear = {
    new = function(self, player, equippedItem, itemCategory, itemManager)
        local instance = {
            player = player,
            equippedItem = equippedItem,
            itemCategory = itemCategory,
            itemManager = itemManager
        }
        setmetatable(instance, { __index = self })
        return instance
    end,

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

            this.player.actor:UnequipInventoryItem(inventoryItem)
            Log.info("UnequipGear Unequipped " .. itemType .. ": " .. itemName)
            callback(inventoryItem)
        end)
    end,

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
            Log.info("UnequipGear: No equipped " .. itemCategory .. " found")
            return callback()
        end

        local index = 1
        local function processNext()
            if index > #itemsToCheck then
                Log.info("UnequipGear Finished taking off " .. itemCategory)
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
    end
}

_G.HelmetOffDialog.ClassRegistry.UnequipGear = UnequipGear

return UnequipGear