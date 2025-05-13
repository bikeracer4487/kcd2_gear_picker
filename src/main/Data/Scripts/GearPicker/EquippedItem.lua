local Log = GearPicker.Log

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

        Log.info("Derived stats before unequip: ", oldStats)

        local item = this.itemManager.GetItem(inventoryItem)
        local itemName = this.itemManager.GetItemName(item.class)

        Log.info("Taking off item:", itemName)
        this.player.actor:UnequipInventoryItem(item.id)

        this.script.SetTimer(30, function()
            local newStats = this:getDerivedStats()
            Log.info("Derived stats after unequip: ", newStats)

            --  We have to use tostring because, without it the compared values
            --  return false positives. Presumably, the floating precision
            --  check is not working on CryEngine's Lua.
            local isEquipped = tostring(oldStats.equippedWeight)
                    ~= tostring(newStats.equippedWeight)

            if isEquipped then
                Log.info("Found equipped, now unequipped item: " .. itemName)
            end

            return callback(isEquipped)
        end)
    end,
    
    -- Get item stats without unequipping
    getItemStats = function(self, item)
        --- @type EquippedItem
        local this = self
        
        if not item then
            Log.error("Attempting to get stats for nil item")
            return nil
        end
        
        local itemName = this.itemManager.GetItemName(item.class)
        local itemUIName = this.itemManager.GetItemUIName(item.class)
        
        local stats = {
            -- Basic item information
            id = item.id,
            class = item.class,
            name = itemName,
            uiName = itemUIName,
            
            -- Defensive stats - using safe calls with fallbacks to 0
            stabDefense = (item.GetStabDefense and item:GetStabDefense()) or 0,
            slashDefense = (item.GetSlashDefense and item:GetSlashDefense()) or 0,
            bluntDefense = (item.GetBluntDefense and item:GetBluntDefense()) or 0,
            
            -- Stealth stats
            noise = (item.GetNoiseValue and item:GetNoiseValue()) or 0,
            visibility = (item.GetVisibilityValue and item:GetVisibilityValue()) or 0,
            conspicuousness = (item.GetConspicuousness and item:GetConspicuousness()) or 0,
            
            -- Social stats
            charisma = (item.GetCharisma and item:GetCharisma()) or 0,
            
            -- Physical properties
            weight = (item.GetWeight and item:GetWeight()) or 0,
            condition = (item.GetCondition and item:GetCondition()) or 0,
            maxCondition = (item.GetMaxCondition and item:GetMaxCondition()) or 0,
            
            -- Cleanliness
            dirtLevel = (item.GetDirtLevel and item:GetDirtLevel()) or 0,
            bloodLevel = (item.GetBloodLevel and item:GetBloodLevel()) or 0,
            
            -- Will be determined separately by isEquipped
            isEquipped = false
        }
        
        return stats
    end,
    
    -- https://warhorse.youtrack.cloud/articles/KM-A-21/Stats-and-skills
    getDerivedStats = function(self)
        --- @type EquippedItem
        local this = self

        local stats = {
            -- Defensive stats
            stabDefense = this.player.soul:GetDerivedStat("stb") or 0,
            slashDefense = this.player.soul:GetDerivedStat("sla") or 0,
            bluntDefense = this.player.soul:GetDerivedStat("blu") or 0,
            
            -- Stealth stats
            noise = this.player.soul:GetDerivedStat("noi") or 0,
            visibility = this.player.soul:GetDerivedStat("vib") or 0,
            conspicuousness = this.player.soul:GetDerivedStat("con") or 0,
            
            -- Social stats
            charisma = this.player.soul:GetDerivedStat("cha") or 0,
            
            -- Other stats
            equippedWeight = this.player.soul:GetDerivedStat("eqw") or 0,
            maxWeight = this.player.soul:GetDerivedStat("mca") or 0,
            
            -- Additional stats that might be useful
            secondChances = this.player.soul:GetDerivedStat("hac") or 0,
            bad = this.player.soul:GetDerivedStat("bad") or 0,
            maxStamina = this.player.soul:GetDerivedStat("mst") or 0,
            moraleForCombat = this.player.soul:GetDerivedStat("mor") or 0,
            bleeding = this.player.soul:GetDerivedStat("ble") or 0
        }

        return stats
    end,
    
    -- Attempts to determine the material type of an item
    detectItemMaterial = function(self, item)
        --- @type EquippedItem
        local this = self
        
        if not item then
            return "unknown"
        end
        
        local itemName = string.lower(this.itemManager.GetItemName(item.class))
        local itemUIName = string.lower(this.itemManager.GetItemUIName(item.class))
        
        -- Check for plate materials
        if itemName:find("plate") or 
           itemName:find("cuirass") or 
           itemName:find("bascinet") or
           itemName:find("helm") or
           itemUIName:find("plate") then
            return "plate"
        end
        
        -- Check for chainmail materials
        if itemName:find("mail") or 
           itemName:find("chain") or 
           itemName:find("hauberk") or
           itemUIName:find("mail") then
            return "chainmail"
        end
        
        -- Check for leather materials
        if itemName:find("leather") or 
           itemName:find("hide") or
           itemUIName:find("leather") then
            return "leather"
        end
        
        -- Check for cloth materials
        if itemName:find("cloth") or
           itemName:find("linen") or
           itemName:find("silk") or
           itemName:find("wool") or
           itemName:find("gambeson") or
           itemName:find("aketon") or
           itemUIName:find("cloth") then
            return "cloth"
        end
        
        -- Default if we can't determine
        return "unknown"
    end
}

_G.GearPicker.ClassRegistry.EquippedItem = EquippedItem

return EquippedItem