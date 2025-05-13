local Log = GearPicker.Log

--- @class ItemCategory
--- @field is func(self, gearCategory: string, inventoryItem: userdata)
local ItemCategory = {
    new = function(self, itemManager)
        local instance = { itemManager = itemManager }
        setmetatable(instance, { __index = self })
        Log.info("ItemCategory New instance created")
        return instance
    end,

    --- @field is fun(self: ItemCategory, category: string, inventoryItem: any): boolean
    is = function(self, category, inventoryItem)
        --- @type ItemCategory
        local this = self
        local item = this.itemManager.GetItem(inventoryItem)
        if not item then
            Log.info("ItemCategory Invalid item for category check: " .. category)
            return false
        end

        local itemName = this.itemManager.GetItemName(item.class)
        local itemUIName = this.itemManager.GetItemUIName(item.class)
        local lcName = string.lower(itemName)
        local lcUiName = string.lower(itemUIName)

        -- Head gear
        if category == "Helmet" then
            return lcName:find("kettle") ~= nil
                    or lcName:find("bascinet") ~= nil
                    or lcName:find("helmet") ~= nil
                    or lcName:find("skullcap") ~= nil
                    or lcName:find("sallet") ~= nil
                    or lcName:find("armet") ~= nil
        end

        if category == "Cap" then
            return lcName:find("cap") ~= nil
                    and not lcName:find("skullcap") ~= nil
                    or lcName:find("hat") ~= nil
                    or lcName:find("headdress") ~= nil
                    or lcName:find("circlet") ~= nil
        end

        if category == "Hood" then
            return lcName:find("hood") ~= nil
                    or lcName:find("cowl") ~= nil
                    and not lcName:find("coif") ~= nil
        end

        if category == "Coif" then
            return lcName:find("coif") ~= nil
                    or lcName:find("arming cap") ~= nil
                    or lcName:find("padded hood") ~= nil
        end

        if category == "HeadChainmail" or category == "NeckGuard" then
            return lcName:find("coifmail") ~= nil
                    or lcName:find("aventail") ~= nil
                    or lcName:find("gorget") ~= nil
                    or lcName:find("bevor") ~= nil
                    or lcUiName:find("nm_ca_collar") ~= nil
                    or lcUiName:find("nm_ca_hood") ~= nil
        end

        -- Torso gear
        if category == "ChestPlate" then
            return lcName:find("cuirass") ~= nil
                    or lcName:find("plate") ~= nil and lcName:find("chest") ~= nil
                    or lcName:find("brigandine") ~= nil
                    or lcName:find("breastplate") ~= nil
        end

        if category == "Coat" then
            return lcName:find("coat") ~= nil
                    or lcName:find("robe") ~= nil
                    or lcName:find("cloak") ~= nil
                    or lcName:find("surcoat") ~= nil
                    or lcName:find("tunic") ~= nil and not lcName:find("under") ~= nil
        end

        if category == "Gambeson" then
            return lcName:find("gambeson") ~= nil
                    or lcName:find("aketon") ~= nil
                    or lcName:find("arming") ~= nil and lcName:find("doublet") ~= nil
                    or lcName:find("padded") ~= nil and (lcName:find("jacket") ~= nil or lcName:find("vest") ~= nil)
        end

        if category == "Shirt" then
            return lcName:find("shirt") ~= nil
                    or lcName:find("tunic") ~= nil and lcName:find("under") ~= nil
                    or lcName:find("chemise") ~= nil
                    or lcName:find("undershirt") ~= nil
        end

        -- Arm gear
        if category == "Sleeves" then
            return lcName:find("sleeve") ~= nil
                    or lcName:find("bracer") ~= nil
                    or lcName:find("vambrace") ~= nil
                    or lcName:find("gauntlet") ~= nil and lcName:find("arm") ~= nil
        end

        -- Hand gear
        if category == "Gloves" then
            return lcName:find("glove") ~= nil
                    or lcName:find("gauntlet") ~= nil and not lcName:find("arm") ~= nil
                    or lcName:find("mitten") ~= nil
        end

        -- Leg gear
        if category == "QuiltedHose" then
            return lcName:find("hose") ~= nil
                    or lcName:find("chauss") ~= nil
                    or lcName:find("legging") ~= nil and lcName:find("padded") ~= nil
                    or lcName:find("pants") ~= nil
                    or lcName:find("trouser") ~= nil
        end

        -- Foot gear
        if category == "Shoes" then
            return lcName:find("shoe") ~= nil
                    or lcName:find("boot") ~= nil
                    or lcName:find("sabaton") ~= nil
                    or lcName:find("sandal") ~= nil
        end

        if category == "RowelSpurs" then
            return lcName:find("spur") ~= nil
                    or lcName:find("rowel") ~= nil
        end

        -- Jewelry
        if category == "Jewelry1" or category == "Jewelry2" then
            return lcName:find("ring") ~= nil
                    or lcName:find("necklace") ~= nil
                    or lcName:find("amulet") ~= nil
                    or lcName:find("pendant") ~= nil
                    or lcName:find("jewel") ~= nil
        end

        -- Weapon categories
        if category == "RangedWeapon" then
            return lcName:find("bow_") ~= nil
                    or lcName:find("crossbow") ~= nil
        end

        -- Material categories
        if category == "Cloth" then
            return this:isClothMaterial(lcName, lcUiName)
        end

        if category == "Leather" then
            return this:isLeatherMaterial(lcName, lcUiName)
        end

        if category == "Chainmail" then
            return this:isChainmailMaterial(lcName, lcUiName)
        end

        if category == "Plate" then
            return this:isPlateMaterial(lcName, lcUiName)
        end

        Log.info("ItemCategory Unknown category: " .. category)
        return false
    end,

    -- Material detection methods
    isClothMaterial = function(self, lcName, lcUiName)
        return lcName:find("cloth") ~= nil
                or lcName:find("linen") ~= nil
                or lcName:find("wool") ~= nil
                or lcName:find("silk") ~= nil
                or lcName:find("cotton") ~= nil
                or lcName:find("gambeson") ~= nil
                or lcName:find("aketon") ~= nil
                or lcName:find("padded") ~= nil
    end,

    isLeatherMaterial = function(self, lcName, lcUiName)
        return lcName:find("leather") ~= nil
                or lcName:find("hide") ~= nil
                or lcName:find("fur") ~= nil
                or lcName:find("skin") ~= nil
                or lcUiName:find("leather") ~= nil
    end,

    isChainmailMaterial = function(self, lcName, lcUiName)
        return lcName:find("mail") ~= nil
                or lcName:find("chain") ~= nil
                or lcName:find("hauberk") ~= nil
                or lcUiName:find("mail") ~= nil
    end,

    isPlateMaterial = function(self, lcName, lcUiName)
        return lcName:find("plate") ~= nil
                or lcName:find("cuirass") ~= nil
                or lcName:find("bascinet") ~= nil
                or lcName:find("kettle") ~= nil
                or lcName:find("helmet") ~= nil
                or lcName:find("vambrace") ~= nil
                or lcName:find("bracer") ~= nil
                or lcName:find("gauntlet") ~= nil
                or lcName:find("sabaton") ~= nil
                or lcName:find("brigandine") ~= nil
                or lcUiName:find("plate") ~= nil
    end,

    -- Check if an item can be a base layer for another item
    isBaseLayerFor = function(self, baseCategory, targetCategory)
        if targetCategory == "Helmet" then
            return baseCategory == "Coif"
        elseif targetCategory == "ChestPlate" then
            return baseCategory == "Gambeson"
        elseif targetCategory == "QuiltedHose" then
            return false -- No base layer required for hose
        elseif targetCategory == "RowelSpurs" then
            return baseCategory == "Shoes"
        end
        return false
    end,

    -- Get the slot that an item category belongs to
    getSlotForCategory = function(self, category)
        -- Head slots
        if category == "Helmet" or category == "Cap" or category == "Hood" then
            return "head"
        end
        
        if category == "Coif" then
            return "head_under"
        end
        
        if category == "HeadChainmail" or category == "NeckGuard" then
            return "neck"
        end
        
        -- Torso slots
        if category == "ChestPlate" then
            return "torso_outer"
        end
        
        if category == "Coat" then
            return "torso_outer_layer"
        end
        
        if category == "Gambeson" then
            return "torso_middle"
        end
        
        if category == "Shirt" then
            return "torso_under"
        end
        
        -- Arm and hand slots
        if category == "Sleeves" then
            return "arms"
        end
        
        if category == "Gloves" then
            return "hands"
        end
        
        -- Leg and foot slots
        if category == "QuiltedHose" then
            return "legs"
        end
        
        if category == "Shoes" then
            return "feet"
        end
        
        if category == "RowelSpurs" then
            return "feet_accessory"
        end
        
        -- Jewelry slots
        if category == "Jewelry1" then
            return "jewelry1"
        end
        
        if category == "Jewelry2" then
            return "jewelry2"
        end
        
        if category == "RangedWeapon" then
            return "ranged"
        end
        
        return "unknown"
    end
}

_G.GearPicker.ClassRegistry.ItemCategory = ItemCategory

return ItemCategory