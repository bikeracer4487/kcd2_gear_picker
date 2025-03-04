--- @class EquippedItem
--- @field new fun(self: Equipment, log: Log, player: _G.player, engineScript: _G.Script): Equipment
local EquippedItem = {
    new = function(self, log, player, engineScript)
        if HelmetOffDialog.__factories.equippedItem then
            return HelmetOffDialog.__factories.equippedItem
        end
        local instance = { log = log, player = player, engineScript = engineScript }
        setmetatable(instance, { __index = self })
        HelmetOffDialog.__factories.equippedItem = instance
        return instance
    end,
    isEquipped = function(self, item, callback)
        self.log:info("[EquippedItem] isEquipped")

        local before = {
            charisma = self.player.soul:GetDerivedStat("charisma"),
            conspicuousness = self.player.soul:GetDerivedStat("con"),
            visibility = self.player.soul:GetDerivedStat("vib")
        }

        self.log:info("[EquippedItem] UnequipInventoryItem")
        self.player.actor:UnequipInventoryItem(item)

        self.log:info("[EquippedItem] SetTimer")
        self.engineScript.SetTimer(100, function()
            self.log:info("[EquippedItem] afterStats")
            local after = {
                charisma = self.player.soul:GetDerivedStat("charisma"),
                conspicuousness = self.player.soul:GetDerivedStat("con"),
                visibility = self.player.soul:GetDerivedStat("vib")
            }
            self.log:info("[EquippedItem] EquipInventoryItem")
            self.player.actor:EquipInventoryItem(item)

            self.log:info("[EquippedItem] isEquippedComparison")
            local isEquipped = before.charisma ~= after.charisma
                    or before.conspicuousness ~= after.conspicuousness
                    or before.visibility ~= after.visibility

            self.log:info("[EquippedItem] callback")
            callback(isEquipped)
        end)
    end,
}

HelmetOffDialog.ClassRegistry.EquippedItem = EquippedItem