--- @class ItemCategory
--- @field new fun(self: ItemCategory, helmetOffDialog: HelmetOffDialog, log: Log, itemManager: ItemManager): ItemCategory
--- @field is func(self, gearCategory: string, inventoryItem: userdata)
local ItemCategory = {
    new = function(self, helmetOffDialog, log, itemManager)
        if helmetOffDialog.__factories.itemCategory then
            return helmetOffDialog.__factories.itemCategory
        end
        local instance = {
            log = log,
            itemManager = itemManager,
            helmetOffDialog = helmetOffDialog
        }
        setmetatable(instance, { __index = self })
        helmetOffDialog.__factories.itemCategory = instance
        log:info("ItemCategory New instance created")
        return instance
    end,

    --- @field is fun(self: ItemCategory, category: string, inventoryItem: any): boolean
    is = function(self, itemCategory, inventoryItem)
        local item = self.itemManager.GetItem(inventoryItem)
        if not item then
            self.log:info("ItemCategory Invalid item for category check: " .. itemCategory)
            return false
        end

        local itemName = self.itemManager.GetItemName(item.class)
        local itemUIName = self.itemManager.GetItemUIName(item.class)

        if itemCategory == "Helmet" then
            return string.lower(itemName):find("kettle")
                    or string.lower(itemName):find("bascinet")
                    or string.lower(itemName):find("helmet")
        end

        if itemCategory == "HeadChainmail" then
            return string.lower(itemName):find("coifmail")
                    or string.lower(itemUIName):find("nm_ca_collar")
                    or string.lower(itemUIName):find("nm_ca_hood")
        end

        if itemCategory == "Coif" then
            return string.lower(itemName):find("coif")
                    or string.lower(itemName):find("g_hood_")
        end

        self.log:info("ItemCategory Unknown category: " .. itemCategory)
        return false
    end
}

_G.HelmetOffDialog.ClassRegistry.ItemCategory = ItemCategory

return ItemCategory