--- @class UnequipGear
--- @field new fun(self: UnequipGear, helmetOffDialog: HelmetOffDialog, log: Log, actor: _G.player.actor, equippedItem: EquippedItem, itemCategory: ItemCategory, itemManager: ItemManager): UnequipGear
--- @field itemCategory ItemCategory
--- @field equippedItem EquippedItem
local UnequipGear = {
    new = function(
            self,
            helmetOffDialog,
            log,
            actor,
            equippedItem,
            itemCategory,
            itemManager,
            inventory
    )
        log:info("UnequipGear.new")

        if helmetOffDialog.__factories.unequipGear then
            return helmetOffDialog.__factories.unequipGear
        end
        local instance = {
            helmetOffDialog = helmetOffDialog,
            log = log,
            actor = actor,
            equippedItem = equippedItem,
            itemCategory = itemCategory,
            itemManager = itemManager,
            inventory = inventory
        }
        setmetatable(instance, { __index = self })
        helmetOffDialog.__factories.unequipGear = instance
        return instance
    end,

    unequipIfEquipped = function(self, inventoryItem, itemType, callback)
        --- @type UnequipGear
        local this = self
        local item = this.itemManager.GetItem(inventoryItem)
        local itemName = this.itemManager.GetItemName(item.class)
        this.log:info("Checking if " .. itemType .. " is equipped: " .. itemName)

        this.equippedItem:isEquipped(inventoryItem, function(isEquipped)
            if not isEquipped then
                this.log:info("UnequipGear " .. itemType .. " not equipped")
                callback(nil)
                return
            end

            this.actor:UnequipInventoryItem(inventoryItem)
            this.log:info("UnequipGear Unequipped " .. itemType .. ": " .. itemName)
            callback(inventoryItem)
        end)
    end,

    takeOff = function(self, itemCategory, callback)
        --- @type UnequipGear
        local this = self
        this.log:info("UnequipGear.takeOff: " .. itemCategory)
        local itemsToCheck = {}

        for _, inventoryItem in pairs(this.inventory:GetInventoryTable()) do
            if this.itemCategory:is(itemCategory, inventoryItem) then
                table.insert(itemsToCheck, inventoryItem)
            end
        end

        if #itemsToCheck == 0 then
            this.log:info("UnequipGear: No equipped " .. itemCategory .. " found")
            return callback()
        end

        local index = 1
        local function processNext()
            if index > #itemsToCheck then
                self.log:info("UnequipGear Finished taking off " .. itemCategory)
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