--- @class Equipment
--- @field new fun(self: Equipment, log: Log, player: _G.player, equippedItem: EquippedItem): Equipment
local Equipment = {
    new = function(self, log, player, equippedItem)
        log:info("[Equipment] Creating new Equipment instance")
        if HelmetOffDialog.__factories and HelmetOffDialog.__factories.equipment then
            log:info("[Equipment] Returning cached instance")
            return HelmetOffDialog.__factories.equipment
        end
        local instance = {
            log = log,
            player = player,
            equippedItem = equippedItem,
            storedItems = {}
        }
        setmetatable(instance, { __index = self })
        HelmetOffDialog.__factories = HelmetOffDialog.__factories or {}
        HelmetOffDialog.__factories.equipment = instance
        log:info("[Equipment] New instance created")
        return instance
    end,

    equip = function(self, itemType)
        self.log:info("[Equipment] Trying to equip " .. itemType)
        local inventoryItem = self.storedItems[itemType]
        if not inventoryItem then
            self.log:info("[Equipment] No " .. itemType .. " in storage")
            return
        end

        local item = ItemManager.GetItem(inventoryItem)
        if not item then
            self.log:info("[Equipment] Invalid " .. itemType .. " in storage")
            return
        end

        local isTypeCheck = self["is" .. itemType]
        if not isTypeCheck(self, inventoryItem) then
            self.log:info("[Equipment] Stored item is not a " .. itemType)
            return
        end

        local itemName = ItemManager.GetItemName(item.class)
        self.player.actor:EquipInventoryItem(inventoryItem)
        self.storedItems[itemType] = nil
        self.log:info("[Equipment] Equipped " .. itemType .. ": " .. itemName)
    end,

    unequipIfEquipped = function(self, inventoryItem, itemType, callback)
        local item = ItemManager.GetItem(inventoryItem)
        if not item then
            self.log:info("[Equipment] Invalid item")
            callback()
            return
        end

        local itemName = ItemManager.GetItemName(item.class)
        local isTypeCheck = self["is" .. itemType]
        if not isTypeCheck(self, inventoryItem) then
            self.log:info("[Equipment] Not a " .. itemType .. ": " .. itemName)
            callback()
            return
        end

        self.equippedItem:isEquipped(inventoryItem, function(isEquipped)
            if not isEquipped then
                self.log:info("[Equipment] " .. itemType .. " not equipped: " .. itemName)
                callback()
                return
            end

            self.player.actor:UnequipInventoryItem(inventoryItem)
            self.storedItems[itemType] = inventoryItem
            self.log:info("[Equipment] Unequipped " .. itemType .. ": " .. itemName)
            callback()
        end)
    end,

    unequip = function(self, itemType)
        self.log:info("[Equipment] Starting to unequip " .. itemType)
        local inventory = self.player.inventory:GetInventoryTable()

        for _, inventoryItem in pairs(inventory) do
            local item = ItemManager.GetItem(inventoryItem)
            if item then
                local isTypeCheck = self["is" .. itemType]
                if isTypeCheck(self, inventoryItem) then
                    self:unequipIfEquipped(inventoryItem, itemType, function()
                        self.log:info("[Equipment] Finished unequipping " .. itemType)
                    end)
                    return
                end
            end
        end

        self.log:info("[Equipment] No equipped " .. itemType .. " found")
    end,

    isHelmet = function(self, inventoryItem)
        local item = ItemManager.GetItem(inventoryItem)
        local itemName = ItemManager.GetItemName(item.class)
        self.log:info("[Equipment] isHelmet: itemName: " .. itemName)
        local itemUIName = ItemManager.GetItemUIName(item.class)
        self.log:info("[Equipment] isHelmet: itemUIName: " .. itemUIName)
        return string.lower(itemName):find("kettle")
                or string.lower(itemName):find("bascinet")
                -- KCD 1
                or string.lower(itemName):find("helmet")
    end,

    -- Source: https://github.com/OVNI-modding/kcd_inventory_sorting_generator/blob/eab04397c7cf877048a2ac3d250f72793d313e1a/categorizedItems.ini#L217C10-L217C20
    isHeadChainmail = function(self, inventoryItem)
        local item = ItemManager.GetItem(inventoryItem)
        local itemName = ItemManager.GetItemName(item.class)
        self.log:info("[Equipment] isHeadChainmail: itemName: " .. itemName)
        local itemUIName = ItemManager.GetItemUIName(item.class)
        self.log:info("[Equipment] isHeadChainmail: itemUIName: " .. itemUIName)
        return string.lower(itemName):find("coifmail")
                -- KCD 1
                or string.lower(itemUIName):find("nm_ca_collar")
                or string.lower(itemUIName):find("nm_ca_hood")
    end,

    isCoif = function(self, inventoryItem)
        local item = ItemManager.GetItem(inventoryItem)
        local itemName = ItemManager.GetItemName(item.class)
        self.log:info("[Equipment] isCoif: itemName: " .. itemName)
        local itemUIName = ItemManager.GetItemUIName(item.class)
        self.log:info("[Equipment] isCoif: itemUIName: " .. itemUIName)
        return string.lower(itemName):find("coif")
                or string.lower(itemName):find("g_hood_")
    end,

    equipHelmet = function(self)
        self:equip("Helmet")
    end,
    equipHeadChainmail = function(self)
        self:equip("HeadChainmail")
    end,
    equipCoif = function(self)
        self:equip("Coif")
    end,
    unequipHelmet = function(self)
        self.log:info("[Equipment] unequipHelmet")
        self:unequip("Helmet")
    end,
    unequipHeadChainmail = function(self)
        self.log:info("[Equipment] unequipHeadChainmail")
        self:unequip("HeadChainmail")
    end,
    unequipCoif = function(self)
        self.log:info("[Equipment] unequipCoif")
        self:unequip("Coif")
    end
}

HelmetOffDialog.ClassRegistry.Equipment = Equipment