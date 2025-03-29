local Log = HelmetOffDialog.Log

--- @class EquippedItem
local EquippedItem = {
    new = function(self, player, script, itemManager)
        local instance = {
            player = player, script = script, itemManager = itemManager
        }
        setmetatable(instance, { __index = self })
        return instance
    end,
    isEquipped = function(self, inventoryItem, callback)
        --- @type EquippedItem
        local this = self

        local oldStats = this:getDerivedStats()

        if tostring(oldStats.equippedWeight) == "0" then
            Log.info("Falsy, due to: ", oldStats,
                    " Player is either in intro game, or wearing no gear")
            return callback(false)
        end

        Log.info("Derived stats before une-quip: ", oldStats)

        local item = this.itemManager.GetItem(inventoryItem)
        local itemName = this.itemManager.GetItemName(item.class)

        Log.info("Taking off item:", itemName)
        this.player.actor:UnequipInventoryItem(item.id)

        this.script.SetTimer(30, function()
            local newStats = this:getDerivedStats()
            Log.info("Derived stats after un-equip: ", newStats)

            --  We have to use tostring because, without it the compared values
            --  return false positives. Presumably, the floating precision
            --  check is not working on CryEngine's Lua.
            local isEquipped = tostring(oldStats.equippedWeight)
                    ~= tostring(newStats.equippedWeight)

            if isEquipped then
                Log.info("Found equipped, now unequipped item: " .. itemName)
            end

            callback(isEquipped)
        end)
    end,
    -- https://warhorse.youtrack.cloud/articles/KM-A-21/Stats-and-skills
    getDerivedStats = function(self)
        --- @type EquippedItem
        local this = self

        local stats = {
            --cha = this.player.soul:GetDerivedStat("cha"),
            --conspicuousness = this.player.soul:GetDerivedStat("con"),
            equippedWeight = this.player.soul:GetDerivedStat("eqw")
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