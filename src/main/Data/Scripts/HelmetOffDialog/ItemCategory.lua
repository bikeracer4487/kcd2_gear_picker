local Log = HelmetOffDialog.Log

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

        if category == "Helmet" then
            return lcName:find("kettle") ~= nil
                    or lcName:find("bascinet") ~= nil
                    or lcName:find("helmet") ~= nil
                    or lcName:find("skullcap") ~= nil
        end

        if category == "HeadChainmail" then
            return lcName:find("coifmail")
                    or lcUiName:find("nm_ca_collar")
                    or lcUiName:find("nm_ca_hood")
        end

        if category == "Coif" then
            return lcName:find("coif") ~= nil
                    or lcName:find("g_hood_") ~= nil
        end

        if category == "RangedWeapon" then
            return lcName:find("bow_")
                    or lcName:find("crossbow")
        end

        Log.info("ItemCategory Unknown category: " .. category)
        return false
    end
}

_G.HelmetOffDialog.ClassRegistry.ItemCategory = ItemCategory

return ItemCategory