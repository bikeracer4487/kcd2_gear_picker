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
        
        System.LogAlways("$7[GearPicker] Beginning inventory analysis...")
        System.LogAlways("$7[GearPicker] DIAGNOSTIC: Initializing scan variables")
        
        this.inventoryItems = {}
        this.equippedItems = {}
        this.processingQueue = {}
        this.processingIndex = 1
        this.scanningComplete = false
        this.scanCallback = callback or function() end
        
        -- Print diagnostic info about player and inventory
        System.LogAlways("$7[GearPicker] DIAGNOSTIC: Checking player object...")
        if not this.player then
            System.LogAlways("$4[GearPicker] ERROR: Player object is nil!")
            return
        else
            System.LogAlways("$7[GearPicker] DIAGNOSTIC: Player object exists")
        end
        
        if not this.player.inventory then
            System.LogAlways("$4[GearPicker] ERROR: Player inventory is nil!")
            return
        else
            System.LogAlways("$7[GearPicker] DIAGNOSTIC: Player inventory object exists")
        end
        
        -- Collect all inventory items
        local inventory = this.player.inventory
        System.LogAlways("$7[GearPicker] DIAGNOSTIC: Attempting to get inventory items...")
        
        -- Use pcall to safely call GetItems and catch any errors
        local getItemsSuccess, items = pcall(function() 
            return inventory:GetItems() 
        end)
        
        if not getItemsSuccess then
            System.LogAlways("$4[GearPicker] ERROR: Failed to get inventory items: " .. tostring(items))
            items = {}
        else
            System.LogAlways("$7[GearPicker] DIAGNOSTIC: Successfully retrieved inventory items")
            items = items or {} -- Handle nil result even if pcall succeeded
        end
        
        -- Safety check for nil or empty items table
        if not items or type(items) ~= "table" then
            items = {}
            System.LogAlways("$4[GearPicker] WARNING: GetItems() returned nil or invalid data")
        end
        
        System.LogAlways("$7[GearPicker] Found " .. #items .. " total items in inventory")
        
        -- Filter for gear items and add to processing queue
        System.LogAlways("$7[GearPicker] DIAGNOSTIC: Starting to filter inventory items for gear...")
        System.LogAlways("$7[GearPicker] DIAGNOSTIC: Total inventory items to check: " .. #items)
        
        -- Check for ItemManager availability
        if not this.itemManager then
            System.LogAlways("$4[GearPicker] ERROR: ItemManager is nil!")
            return
        else
            System.LogAlways("$7[GearPicker] DIAGNOSTIC: ItemManager is available")
        end
        
        -- Check if GetItem function exists in ItemManager
        if not this.itemManager.GetItem then
            System.LogAlways("$4[GearPicker] ERROR: ItemManager.GetItem function not found!")
            return
        else
            System.LogAlways("$7[GearPicker] DIAGNOSTIC: ItemManager.GetItem function exists")
        end
        
        local gearCount = 0
        for i = 1, #items do
            local itemId = items[i]
            if not itemId then
                System.LogAlways("$4[GearPicker] WARNING: Found nil item ID at index " .. i)
                goto continue
            end
            
            -- Use pcall to catch any errors with GetItem
            local getItemSuccess, item = pcall(function()
                return this.itemManager.GetItem(itemId)
            end)
            
            if not getItemSuccess then
                System.LogAlways("$4[GearPicker] ERROR: Exception in GetItem for ID at index " .. i .. ": " .. tostring(item))
                goto continue
            end
            
            if not item then
                System.LogAlways("$4[GearPicker] WARNING: ItemManager.GetItem returned nil for ID at index " .. i)
                goto continue
            end
            
            -- Try to get the item name for logging
            local itemName = "unknown"
            if item.class then
                local getNameSuccess, name = pcall(function()
                    return this.itemManager.GetItemName(item.class)
                end)
                
                if getNameSuccess and name then
                    itemName = name
                end
            end
            
            -- Check if it's a gear item
            local isGearSuccess, isGear = pcall(function()
                return this:isGearItem(item)
            end)
            
            if not isGearSuccess then
                System.LogAlways("$4[GearPicker] ERROR: Exception in isGearItem for " .. itemName .. ": " .. tostring(isGear))
                goto continue
            end
            
            if isGear then
                gearCount = gearCount + 1
                table.insert(this.processingQueue, itemId)
                System.LogAlways("$7[GearPicker] Added item to processing queue: " .. itemName)
            end
            
            ::continue::
        end
        
        -- Diagnostic after filtering
        System.LogAlways("$7[GearPicker] DIAGNOSTIC: Filtering complete. Found " .. gearCount .. " gear items.")
        
        System.LogAlways("$7[GearPicker] Identified " .. gearCount .. " gear items to analyze")
        System.LogAlways("$7[GearPicker] Starting gear analysis...")
        
        -- Start processing items one by one
        this:processNextItem()
    end,
    
    -- Process the next item in the queue
    processNextItem = function(self)
        --- @type GearScan
        local this = self
        
        System.LogAlways("$7[GearPicker] DIAGNOSTIC: Processing queue item " .. this.processingIndex .. " of " .. #this.processingQueue)
        
        if this.processingIndex > #this.processingQueue then
            -- Processing complete
            System.LogAlways("$7[GearPicker] DIAGNOSTIC: Processing queue complete, finalizing results...")
            this.scanningComplete = true
            
            -- Use pcall to safely categorize items
            local categorizeSuccess, categorizeError = pcall(function()
                this:categorizeItems()
            end)
            
            if not categorizeSuccess then
                System.LogAlways("$4[GearPicker] ERROR: Failed to categorize items: " .. tostring(categorizeError))
            else
                System.LogAlways("$7[GearPicker] DIAGNOSTIC: Items categorized successfully")
            end
            
            -- Count detected slots for summary
            local slotCounts = {}
            for _, item in ipairs(this.equippedItems) do
                if item.slot then
                    slotCounts[item.slot] = (slotCounts[item.slot] or 0) + 1
                end
            end
            
            -- Count the number of slots (Lua 5.1 safe)
            local slotCount = 0
            for _ in pairs(slotCounts) do
                slotCount = slotCount + 1
            end
            
            -- Log final analysis summary
            System.LogAlways("$7[GearPicker] =========================================================")
            System.LogAlways("$7[GearPicker] ANALYSIS COMPLETE: " .. #this.inventoryItems .. " gear items analyzed")
            System.LogAlways("$7[GearPicker] FOUND " .. #this.equippedItems .. " EQUIPPED ITEMS ACROSS " .. slotCount .. " SLOTS")
            
            -- Check if callback exists
            if not this.scanCallback then
                System.LogAlways("$4[GearPicker] WARNING: No scan callback was provided")
            else
                System.LogAlways("$7[GearPicker] DIAGNOSTIC: Preparing to call scan callback with results")
            end
            
            -- Add a small delay before calling the callback to ensure log messages are processed
            this.equippedItem.script.SetTimer(200, function()
                System.LogAlways("$7[GearPicker] DIAGNOSTIC: Executing callback with results...")
                if this.scanCallback then
                    this.scanCallback(this.inventoryItems, this.equippedItems)
                end
                System.LogAlways("$7[GearPicker] DIAGNOSTIC: Callback execution complete")
            end)
            
            return
        end
        
        -- Log progress frequently for visibility
        local shouldLog = (this.processingIndex == 1) or 
                         (this.processingIndex % 2 == 0) or 
                         (this.processingIndex == #this.processingQueue) or
                         (#this.processingQueue <= 10) -- Always log if few items
        
        if shouldLog then
            System.LogAlways("$7[GearPicker] Analyzing item " .. this.processingIndex .. " of " .. #this.processingQueue)
        end
        
        local inventoryItem = this.processingQueue[this.processingIndex]
        if not inventoryItem then
            System.LogAlways("$4[GearPicker] WARNING: Nil inventory item at processing index " .. this.processingIndex)
            this.processingIndex = this.processingIndex + 1
            this.equippedItem.script.SetTimer(10, function()
                this:processNextItem()
            end)
            return
        end
        
        local item = this.itemManager.GetItem(inventoryItem)
        if not item then
            System.LogAlways("$4[GearPicker] WARNING: ItemManager.GetItem returned nil for processing index " .. this.processingIndex)
            this.processingIndex = this.processingIndex + 1
            this.equippedItem.script.SetTimer(10, function()
                this:processNextItem()
            end)
            return
        end
        
        if not item.class then
            System.LogAlways("$4[GearPicker] WARNING: Item has nil class at processing index " .. this.processingIndex)
            this.processingIndex = this.processingIndex + 1
            this.equippedItem.script.SetTimer(10, function()
                this:processNextItem()
            end)
            return
        end
        
        local itemName = this.itemManager.GetItemName(item.class) or "unknown_item"
        
        -- Get item stats with error handling
        local stats, getStatsSuccess = pcall(function() 
            return this.equippedItem:getItemStats(item) 
        end)
        
        if not getStatsSuccess then
            System.LogAlways("$4[GearPicker] ERROR: Failed to get item stats for " .. itemName)
            stats = {
                id = item.id or 0,
                class = item.class or "unknown",
                name = itemName,
                uiName = itemName,
                stabDefense = 0,
                slashDefense = 0,
                bluntDefense = 0,
                noise = 0,
                visibility = 0,
                conspicuousness = 0,
                charisma = 0,
                weight = 0,
                condition = 0,
                maxCondition = 0,
                isEquipped = false
            }
        end
        
        -- Get material with error handling
        local detectSuccess, material = pcall(function() 
            return this.equippedItem:detectItemMaterial(item) 
        end)
        
        if detectSuccess then
            stats.material = material
        else
            stats.material = "unknown"
            System.LogAlways("$4[GearPicker] ERROR: Failed to detect material for " .. itemName)
        end
        
        -- Display item being processed
        System.LogAlways("$7[GearPicker] Processing: " .. itemName)
        
        -- Determine if item is equipped using a direct API check if available
        stats.isEquipped = false
        
        -- Try to use direct API method if available (most reliable)
        if item.IsEquipped and item:IsEquipped() then
            stats.isEquipped = true
            table.insert(this.equippedItems, stats)
            System.LogAlways("$7[GearPicker] Found equipped (via API): " .. itemName)
        -- Fallback method 1: Check if item has an equipped slot
        elseif item.GetEquippedSlot and item:GetEquippedSlot() ~= nil and item:GetEquippedSlot() ~= "" then
            stats.isEquipped = true
            stats.equippedSlot = item:GetEquippedSlot()
            table.insert(this.equippedItems, stats)
            System.LogAlways("$7[GearPicker] Found equipped (via slot): " .. itemName .. " in slot " .. stats.equippedSlot)
        -- Fallback method 2: Use heuristics based on item stats for armor pieces 
        elseif stats.weight > 0 then
            -- Higher defense values usually indicate equipped armor
            if (stats.stabDefense > 5 or stats.slashDefense > 5) then
                -- Check for armor-like properties
                if this.itemCategory:isArmorItem(item.id) then
                    stats.isEquipped = true
                    table.insert(this.equippedItems, stats)
                    System.LogAlways("$7[GearPicker] Likely equipped armor: " .. itemName)
                end
            -- Special case for charisma items (clothes, jewelry)
            elseif stats.charisma > 5 and (this.itemCategory:isClothesItem(item.id) or this.itemCategory:isJewelryItem(item.id)) then
                stats.isEquipped = true
                table.insert(this.equippedItems, stats)
                System.LogAlways("$7[GearPicker] Likely equipped clothing/jewelry: " .. itemName)
            end
        end
        
        -- Add to inventory items list
        table.insert(this.inventoryItems, stats)
        
        -- Process next item with a short delay to avoid freezing the game
        this.processingIndex = this.processingIndex + 1
        this.equippedItem.script.SetTimer(10, function()
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
            System.LogAlways("$4[GearPicker] DIAGNOSTIC: isGearItem called with nil item")
            return false
        end
        
        -- Try to get the item name for better logging
        local rawItemName = "unknown"
        if item.class then
            local success, name = pcall(function() return this.itemManager.GetItemName(item.class) end)
            if success and name then
                rawItemName = name
            end
        end
        
        -- Check if the item can be equipped
        local canEquip = false
        if item.CanEquip then
            local success, result = pcall(function() return item:CanEquip() end)
            canEquip = success and result or false
        end
        
        -- If the item is already equipped, it's definitely gear
        local isEquipped = false
        if item.IsEquipped then
            local success, result = pcall(function() return item:IsEquipped() end)
            isEquipped = success and result or false
        end
        
        if isEquipped then
            System.LogAlways("$7[GearPicker] DIAGNOSTIC: " .. rawItemName .. " is already equipped, treating as gear")
            return true
        end
        
        -- Get the item name and check categories
        local itemName = ""
        if item.class then
            local success, name = pcall(function() return string.lower(this.itemManager.GetItemName(item.class)) end)
            if success and name then
                itemName = name
            end
        end
        
        -- Check if itemCategory is available
        if not this.itemCategory then
            System.LogAlways("$4[GearPicker] DIAGNOSTIC: itemCategory is nil in isGearItem for " .. rawItemName)
            return false
        end
        
        -- Check if item is in a known gear category (more reliable than name checking)
        local isArmor, isClothes, isJewelry, isWeapon = false, false, false, false
        
        if this.itemCategory.isArmorItem then
            local success, result = pcall(function() return this.itemCategory:isArmorItem(item.id) end)
            isArmor = success and result or false
        end
        
        if this.itemCategory.isClothesItem then
            local success, result = pcall(function() return this.itemCategory:isClothesItem(item.id) end)
            isClothes = success and result or false
        end
        
        if this.itemCategory.isJewelryItem then
            local success, result = pcall(function() return this.itemCategory:isJewelryItem(item.id) end)
            isJewelry = success and result or false
        end
        
        if this.itemCategory.isWeaponItem then
            local success, result = pcall(function() return this.itemCategory:isWeaponItem(item.id) end)
            isWeapon = success and result or false
        end
        
        if isArmor or isClothes or isJewelry or isWeapon then
            System.LogAlways("$7[GearPicker] DIAGNOSTIC: " .. rawItemName .. " identified as gear via category check")
            return true
        end
        
        -- Exclude consumables and certain items
        local isConsumable = false
        if itemName and itemName ~= "" then
            isConsumable = itemName:find("potion") ~= nil
                    or itemName:find("food") ~= nil
                    or itemName:find("drink") ~= nil
                    or itemName:find("apple") ~= nil
                    or itemName:find("bread") ~= nil
                    or itemName:find("meat") ~= nil
                    or itemName:find("herb") ~= nil
        end
        
        -- Exclude non-equipment weapons (arrows, etc.)
        local isArrow = false
        if itemName and itemName ~= "" then
            isArrow = itemName:find("arrow") ~= nil
                    or itemName:find("bolt") ~= nil
        end
        
        -- Exclude miscellaneous items
        local isMisc = false
        if itemName and itemName ~= "" then
            isMisc = itemName:find("torch") ~= nil
                    or itemName:find("lockpick") ~= nil
                    or itemName:find("map") ~= nil
                    or itemName:find("book") ~= nil
        end
        
        -- Check if it's a gear item
        local isGear = canEquip and not isConsumable and not isArrow and not isMisc
        
        if isGear then
            System.LogAlways("$7[GearPicker] DIAGNOSTIC: " .. rawItemName .. " identified as gear via name-based rules")
        end
        
        return isGear
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