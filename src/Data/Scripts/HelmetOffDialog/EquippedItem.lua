--- @class EquippedItem
--- @field new fun(self: Equipment, helmetOffDialog: HelmetOffDialog, log: Log, player: _G.player, engineScript: _G.Script): Equipment
--- @field log Log
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
        --- @type EquippedItem
        local this = self
        this.log:info("EquippedItem.isEquipped")

        local oldStats = this:getDerivedStats()
        this.log:info("Derived stats before une-quip: ", oldStats)

        this.player.actor:UnequipInventoryItem(inventoryItem)

        this.log:info("EquippedItem SetTimer")
        this.engineScript.SetTimer(20, function()
            this.log:info("EquippedItem afterStats")
            local newStats = this:getDerivedStats()
            this.log:info("Derived stats after un-equip: ", newStats)

            -- - Stats like charisma, because are cap at 30, are ignored
            -- - Visibility stats check removed as it causes a bug where the
            --  comparison fails if the equipped item is fully washed.
            -- - We have to use tostring because, without it the visibility was
            --  returning false positives. Presumably, the floating precision
            --  check is not working on CryEngine/KCD games.
            local isEquipped = tostring(oldStats.conspicuousness) ~= tostring(newStats.conspicuousness)

            if isEquipped then
                local item = ItemManager.GetItem(inventoryItem)
                local itemName = ItemManager.GetItemName(item.class)
                this.log:info("Found equipped, now unequipped item: " .. itemName)
            end

            this.log:info("EquippedItem callback")
            callback(isEquipped)
        end)
    end,
    getDerivedStats = function(self)
        --- @type EquippedItem
        local this = self
        local stats = {
            --cha = this.player.soul:GetDerivedStat("cha"),
            conspicuousness = this.player.soul:GetDerivedStat("con"),
            --visibility = this.player.soul:GetDerivedStat("vib"),
            --secondChances = this.player.soul:GetDerivedStat("hac"),
            --bad = this.player.soul:GetDerivedStat("bad"),
            --maxStamina = this.player.soul:GetDerivedStat("mst"),
            --moraleForCombat = this.player.soul:GetDerivedStat("mor"),
            --bleeding = this.player.soul:GetDerivedStat("ble")
        }

        return stats
    end
}

_G.HelmetOffDialog.ClassRegistry.EquippedItem = EquippedItem

return EquippedItem