local Log = GearPicker.Log

--- @class GearScan
local GearScan = {
    new = function(self, player, itemManager, itemCategory, equippedItem)
        local instance = {
            player = player,
            itemManager = itemManager,
            itemCategory = itemCategory,
            equippedItem = equippedItem,
            inventoryItems = {},
            equippedItems = {},
            processingQueue = {},
            processingIndex = 1,
            scanningComplete = false,
            scanCallback = nil
        }
        setmetatable(instance, { __index = self })
        Log.info("GearScan New instance created")
        return instance
    end,
    
    -- Start scanning the player's inventory
    scanInventory = function(self, callback)
        --- @type GearScan
        local this = self
        
        Log.info("Starting inventory scan")
        this.inventoryItems = {}
        this.equippedItems = {}
        this.processingQueue = {}
        this.processingIndex = 1
        this.scanningComplete = false
        this.scanCallback = callback or function() end
        
        -- Collect all inventory items
        local inventory = this.player.inventory
        local items = inventory:GetItems()
        
        Log.info("Found " .. #items .. " items in inventory")
        
        -- Filter for gear items and add to processing queue
        for i = 1, #items do
            local item = this.itemManager.GetItem(items[i])
            if this:isGearItem(item) then
                table.insert(this.processingQueue, items[i])
            end
        end
        
        -- Start processing items one by one
        this:processNextItem()
    end,
    
    -- Process the next item in the queue
    processNextItem = function(self)
        --- @type GearScan
        local this = self
        
        if this.processingIndex > #this.processingQueue then
            -- Processing complete
            this.scanningComplete = true
            this:categorizeItems()
            Log.info("Inventory scan complete: " .. #this.inventoryItems .. " gear items found")
            
            if this.scanCallback then
                this.scanCallback(this.inventoryItems, this.equippedItems)
            end
            
            return
        end
        
        local inventoryItem = this.processingQueue[this.processingIndex]
        local item = this.itemManager.GetItem(inventoryItem)
        
        -- Get item stats
        local stats = this.equippedItem:getItemStats(item)
        stats.material = this.equippedItem:detectItemMaterial(item)
        
        -- Determine if item is equipped
        this.equippedItem:isEquipped(inventoryItem, function(equipped)
            stats.isEquipped = equipped
            
            -- Add to inventory items list
            table.insert(this.inventoryItems, stats)
            
            -- If equipped, add to equipped items list
            if equipped then
                table.insert(this.equippedItems, stats)
            end
            
            -- Process next item
            this.processingIndex = this.processingIndex + 1
            this:processNextItem()
        end)
    end,
    
    -- Categorize each item by slot type
    categorizeItems = function(self)
        --- @type GearScan
        local this = self
        
        local categories = {
            "Helmet", "Cap", "Hood", "Coif", "HeadChainmail", "NeckGuard",
            "ChestPlate", "Coat", "Gambeson", "Shirt", 
            "Sleeves", "Gloves", "QuiltedHose", "Shoes", 
            "RowelSpurs", "Jewelry1", "Jewelry2", "RangedWeapon"
        }
        
        -- Add category information to each item
        for _, item in ipairs(this.inventoryItems) do
            item.categories = {}
            for _, category in ipairs(categories) do
                if this.itemCategory:is(category, item.id) then
                    table.insert(item.categories, category)
                end
            end
            
            -- Get primary slot
            if #item.categories > 0 then
                item.slot = this.itemCategory:getSlotForCategory(item.categories[1])
            else
                item.slot = "unknown"
            end
        end
    end,
    
    -- Check if an item is a piece of gear (not consumable, quest item, etc.)
    isGearItem = function(self, item)
        --- @type GearScan
        local this = self
        
        if not item then
            return false
        end
        
        -- Check if the item can be equipped
        local canEquip = (item.CanEquip and item:CanEquip()) or false
        
        -- Get the item name and check categories
        local itemName = string.lower(this.itemManager.GetItemName(item.class))
        
        -- Exclude consumables and certain items
        local isConsumable = itemName:find("potion") ~= nil
                or itemName:find("food") ~= nil
                or itemName:find("drink") ~= nil
                or itemName:find("apple") ~= nil
                or itemName:find("bread") ~= nil
                or itemName:find("meat") ~= nil
                or itemName:find("herb") ~= nil
        
        -- Exclude non-equipment weapons (arrows, etc.)
        local isArrow = itemName:find("arrow") ~= nil
                or itemName:find("bolt") ~= nil
        
        -- Exclude miscellaneous items
        local isMisc = itemName:find("torch") ~= nil
                or itemName:find("lockpick") ~= nil
                or itemName:find("map") ~= nil
                or itemName:find("book") ~= nil
        
        -- Check if it's a gear item
        return canEquip and not isConsumable and not isArrow and not isMisc
    end,
    
    -- Log comprehensive inventory information
    logInventoryDetails = function(self)
        --- @type GearScan
        local this = self
        
        if not this.scanningComplete then
            Log.info("Cannot log inventory details - scan not complete")
            return
        end
        
        Log.info("==========================================")
        Log.info("INVENTORY GEAR SCAN - FULL DETAILS")
        Log.info("==========================================")
        
        local categories = {
            "Helmet", "Cap", "Hood", "Coif", "HeadChainmail", "NeckGuard",
            "ChestPlate", "Coat", "Gambeson", "Shirt", 
            "Sleeves", "Gloves", "QuiltedHose", "Shoes", 
            "RowelSpurs", "Jewelry1", "Jewelry2", "RangedWeapon"
        }
        
        -- Log equipped items by category
        Log.info("------------- EQUIPPED GEAR -------------")
        for _, category in ipairs(categories) do
            local categoryItems = {}
            for _, item in ipairs(this.equippedItems) do
                for _, itemCategory in ipairs(item.categories or {}) do
                    if itemCategory == category then
                        table.insert(categoryItems, item)
                    end
                end
            end
            
            if #categoryItems > 0 then
                Log.info("Category: " .. category)
                for _, item in ipairs(categoryItems) do
                    this:logItemDetails(item)
                end
            end
        end
        
        -- Log all inventory items by category
        Log.info("------------- ALL INVENTORY GEAR -------------")
        for _, category in ipairs(categories) do
            local categoryItems = {}
            for _, item in ipairs(this.inventoryItems) do
                for _, itemCategory in ipairs(item.categories or {}) do
                    if itemCategory == category then
                        table.insert(categoryItems, item)
                    end
                end
            end
            
            if #categoryItems > 0 then
                Log.info("Category: " .. category)
                for _, item in ipairs(categoryItems) do
                    this:logItemDetails(item)
                end
            end
        end
        
        -- Log player's overall stats
        local playerStats = this.equippedItem:getDerivedStats()
        Log.info("------------- OVERALL PLAYER STATS -------------")
        Log.info("Total Stab Defense: " .. playerStats.stabDefense)
        Log.info("Total Slash Defense: " .. playerStats.slashDefense)
        Log.info("Total Blunt Defense: " .. playerStats.bluntDefense)
        Log.info("Visibility: " .. playerStats.visibility)
        Log.info("Conspicuousness: " .. playerStats.conspicuousness)
        Log.info("Noise: " .. playerStats.noise)
        Log.info("Charisma: " .. playerStats.charisma)
        Log.info("Equipped Weight: " .. playerStats.equippedWeight)
        Log.info("Weight Capacity: " .. playerStats.maxWeight)
    end,
    
    -- Log detailed information about a specific item
    logItemDetails = function(self, item)
        if not item then
            Log.error("Cannot log details for nil item")
            return
        end
        
        Log.info("  - Name: " .. item.name .. " (" .. item.uiName .. ")")
        Log.info("    Equipped: " .. tostring(item.isEquipped))
        Log.info("    Defense - Stab: " .. item.stabDefense .. 
                 ", Slash: " .. item.slashDefense .. 
                 ", Blunt: " .. item.bluntDefense)
        Log.info("    Stealth - Noise: " .. item.noise .. 
                 ", Visibility: " .. item.visibility .. 
                 ", Conspicuousness: " .. item.conspicuousness)
        Log.info("    Social - Charisma: " .. item.charisma)
        Log.info("    Physical - Weight: " .. item.weight .. 
                 ", Condition: " .. item.condition .. "/" .. item.maxCondition)
        Log.info("    Material: " .. item.material)
        Log.info("    Slot: " .. item.slot)
        
        -- Log categories if available
        if item.categories and #item.categories > 0 then
            local categoriesStr = ""
            for i, category in ipairs(item.categories) do
                if i > 1 then
                    categoriesStr = categoriesStr .. ", "
                end
                categoriesStr = categoriesStr .. category
            end
            Log.info("    Categories: " .. categoriesStr)
        end
    end
}

_G.GearPicker.ClassRegistry.GearScan = GearScan

return GearScan