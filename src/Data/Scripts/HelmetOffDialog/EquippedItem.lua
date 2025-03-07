--- @class EquippedItem
--- @field new fun(self: Equipment, helmetOffDialog: HelmetOffDialog, log: Log, player: _G.player, engineScript: _G.Script): Equipment
local EquippedItem = {
    new = function(self, helmetOffDialog, log, player, engineScript)
        log:info("EquippedItem.new")
        if helmetOffDialog.__factories.equippedItem then
            return helmetOffDialog.__factories.equippedItem
        end
        local instance = { log = log, player = player, engineScript = engineScript }
        setmetatable(instance, { __index = self })
        helmetOffDialog.__factories.equippedItem = instance
        return instance
    end,
    isEquipped = function(self, inventoryItem, callback)
        self.log:info("EquippedItem.isEquipped")

        local before = {
            conspicuousness = self.player.soul:GetDerivedStat("con"),
            visibility = self.player.soul:GetDerivedStat("vib")
        }

        self.log:info("EquippedItem.isEquipped: before.conspicuousness: " .. before.conspicuousness)
        self.log:info("EquippedItem.isEquipped: before.visibility: " .. before.visibility)
        self.log:info("EquippedItem.UnequipInventoryItem")
        self.player.actor:UnequipInventoryItem(inventoryItem)

        self.log:info("EquippedItem SetTimer")
        self.engineScript.SetTimer(50, function()
            self.log:info("EquippedItem afterStats")
            local after = {
                conspicuousness = self.player.soul:GetDerivedStat("con"),
                visibility = self.player.soul:GetDerivedStat("vib")
            }
            self.log:info("EquippedItem.isEquipped: after.conspicuousness: " .. after.conspicuousness)
            self.log:info("EquippedItem.isEquipped: after.visibility: " .. after.visibility)

            self.log:info("EquippedItem isEquippedComparison")

            -- 1. Stats like charisma, because are cap at 30, are ignored
            -- 2. Game has a bug where taking off KettleHat04_m02_B4 the derived stats
            -- of visibility change even if said item is NOT equipped
            -- As such, use an AND operator to ensure such edge cases are handled
            -- 3. Visibility stats check removed as it causes a bug where the
            -- comparison fails if the equipped item is fully washed.
            local isEquipped = before.conspicuousness ~= after.conspicuousness

            if isEquipped then
                local item = ItemManager.GetItem(inventoryItem)
                local itemName = ItemManager.GetItemName(item.class)
                self.log:info("Found equipped, now unequipped item: " .. itemName)
            end

            self.log:info("EquippedItem callback")
            callback(isEquipped)
        end)
    end,
}

_G.HelmetOffDialog.ClassRegistry.EquippedItem = EquippedItem

return EquippedItem