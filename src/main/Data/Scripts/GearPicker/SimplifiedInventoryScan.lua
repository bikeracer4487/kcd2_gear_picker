-- SimplifiedInventoryScan.lua - A direct inventory scanning approach focused on gathering item stats

local Log = GearPicker.Log

--- @class SimplifiedInventoryScan
local SimplifiedInventoryScan = {
    new = function(self, player, script, itemManager, itemCategory)
        local instance = {
            player = player,
            script = script, 
            itemManager = itemManager,
            itemCategory = itemCategory,
            inventoryItems = {},
            equippedItems = {},
            processingQueue = {},
            processingIndex = 1,
            scanningComplete = false,
            scanCallback = nil
        }
        setmetatable(instance, { __index = self })
        Log.info("SimplifiedInventoryScan: New instance created")
        return instance
    end,
    
    -- Scan the inventory and collect all gear items
    scanInventory = function(self, callback)
        --- @type SimplifiedInventoryScan
        local this = self
        
        System.LogAlways("$2[GearPicker] Starting simplified inventory scan...")
        
        -- Reset scanning state
        this.inventoryItems = {}
        this.equippedItems = {}
        this.processingQueue = {}
        this.processingIndex = 1
        this.scanningComplete = false
        this.scanCallback = callback or function() end
        
        -- Safety checks for player and inventory
        if not this.player or not this.player.inventory then
            System.LogAlways("$4[GearPicker] ERROR: Cannot access player or inventory")
            return
        end
        
        -- Try to get all inventory items using multiple methods
        local allItems = {}
        
        -- Method 1: Try GetInventoryTable (more reliable in some game versions)
        local success, inventoryTable = pcall(function() 
            return this.player.inventory:GetInventoryTable() 
        end)
        
        if success and inventoryTable and type(inventoryTable) == "table" then
            System.LogAlways("$2[GearPicker] Successfully retrieved inventory using GetInventoryTable()")
            allItems = inventoryTable
        else
            -- Method 2: Try GetItems (standard API)
            System.LogAlways("$3[GearPicker] GetInventoryTable failed, trying GetItems()")
            local getItemsSuccess, items = pcall(function() 
                return this.player.inventory:GetItems() 
            end)
            
            if getItemsSuccess and items and type(items) == "table" then
                System.LogAlways("$2[GearPicker] Successfully retrieved inventory using GetItems()")
                allItems = items
            else
                System.LogAlways("$4[GearPicker] ERROR: Failed to retrieve inventory items")
                this.scanCallback({}, {})
                return
            end
        end
        
        -- Count and log total items found
        System.LogAlways("$2[GearPicker] Found " .. #allItems .. " total inventory items")
        
        -- Filter for gear items and add to processing queue
        for i, inventoryItemId in ipairs(allItems) do
            -- Skip nil items
            if not inventoryItemId then
                goto continue
            end
            
            -- Get item object
            local getItemSuccess, item = pcall(function()
                return this.itemManager.GetItem(inventoryItemId)
            end)
            
            if not getItemSuccess or not item then
                goto continue
            end
            
            -- Try to get item name for logging
            local itemName = "unknown"
            if item.class then
                local getNameSuccess, name = pcall(function()
                    return this.itemManager.GetItemName(item.class)
                end)
                
                if getNameSuccess and name then
                    itemName = name
                end
            end
            
            -- Check if this is a potential gear item (armor, weapon, etc.)
            local isGearSuccess, isGear = pcall(function()
                return this:isGearItem(item)
            end)
            
            if isGearSuccess and isGear then
                -- Add to processing queue
                table.insert(this.processingQueue, {
                    id = inventoryItemId,
                    item = item,
                    name = itemName
                })
                
                -- Log every 5th item to avoid spamming
                if #this.processingQueue % 5 == 0 or #this.processingQueue == 1 then
                    System.LogAlways("$2[GearPicker] Added gear to queue: " .. itemName .. " (Total: " .. #this.processingQueue .. ")")
                end
            end
            
            ::continue::
        end
        
        System.LogAlways("$2[GearPicker] Identified " .. #this.processingQueue .. " gear items to analyze")
        System.LogAlways("$2[GearPicker] Starting gear stats collection...")
        
        -- Start processing items one by one
        this:processNextItem()
    end,
    
    -- Process the next item in the queue to collect stats
    processNextItem = function(self)
        --- @type SimplifiedInventoryScan
        local this = self
        
        -- Check if we're done processing all items
        if this.processingIndex > #this.processingQueue then
            System.LogAlways("$2[GearPicker] Processing complete, finalizing results...")
            this.scanningComplete = true
            
            -- Count equipped items for summary
            local equippedCount = 0
            for _, item in ipairs(this.inventoryItems) do
                if item.isEquipped then
                    equippedCount = equippedCount + 1
                    table.insert(this.equippedItems, item)
                end
            end
            
            -- Log summary
            System.LogAlways("$2[GearPicker] =========================================================")
            System.LogAlways("$2[GearPicker] ANALYSIS COMPLETE: " .. #this.inventoryItems .. " gear items analyzed")
            System.LogAlways("$2[GearPicker] FOUND " .. equippedCount .. " equipped items")
            
            -- Delay before calling the callback to ensure log messages are processed
            this.script.SetTimer(100, function()
                if this.scanCallback then
                    this.scanCallback(this.inventoryItems, this.equippedItems)
                end
            end)
            
            return
        end
        
        -- Process current item
        local shouldLog = (this.processingIndex == 1) or 
                         (this.processingIndex % 5 == 0) or 
                         (this.processingIndex == #this.processingQueue)
        
        if shouldLog then
            System.LogAlways("$2[GearPicker] Processing item " .. this.processingIndex .. " of " .. #this.processingQueue)
        end
        
        local queueItem = this.processingQueue[this.processingIndex]
        if not queueItem or not queueItem.item then
            this.processingIndex = this.processingIndex + 1
            this.script.SetTimer(10, function()
                this:processNextItem()
            end)
            return
        end
        
        local item = queueItem.item
        local itemName = queueItem.name
        
        -- Create a stats structure for this item
        local stats = {
            id = queueItem.id,
            class = item.class or "unknown",
            name = itemName,
            isEquipped = false,
            weight = 0,
            stabDefense = 0,
            slashDefense = 0,
            bluntDefense = 0,
            noise = 0,
            visibility = 0,
            conspicuousness = 0,
            charisma = 0,
            condition = 1,
            maxCondition = 1
        }
        
        -- Collect equipment stats (with error handling)
        
        -- 1. Basic stats (weight, condition)
        pcall(function()
            if item.GetWeight then stats.weight = item:GetWeight() 
            elseif item.weight then stats.weight = item.weight end
            
            if item.GetCondition then stats.condition = item:GetCondition()
            elseif item.condition then stats.condition = item.condition end
            
            if item.GetMaxCondition then stats.maxCondition = item:GetMaxCondition()
            elseif item.maxCondition then stats.maxCondition = item.maxCondition end
        end)
        
        -- 2. Defense stats
        pcall(function()
            if item.GetStabDefense then stats.stabDefense = item:GetStabDefense()
            elseif item.stabDefense then stats.stabDefense = item.stabDefense end
            
            if item.GetSlashDefense then stats.slashDefense = item:GetSlashDefense()
            elseif item.slashDefense then stats.slashDefense = item.slashDefense end
            
            if item.GetBluntDefense then stats.bluntDefense = item:GetBluntDefense()
            elseif item.bluntDefense then stats.bluntDefense = item.bluntDefense end
        end)
        
        -- 3. Stealth stats
        pcall(function()
            if item.GetNoise then stats.noise = item:GetNoise()
            elseif item.noise then stats.noise = item.noise end
            
            if item.GetVisibility then stats.visibility = item:GetVisibility()
            elseif item.visibility then stats.visibility = item.visibility end
            
            if item.GetConspicuousness then stats.conspicuousness = item:GetConspicuousness()
            elseif item.conspicuousness then stats.conspicuousness = item.conspicuousness end
        end)
        
        -- 4. Social stats
        pcall(function()
            if item.GetCharisma then stats.charisma = item:GetCharisma()
            elseif item.charisma then stats.charisma = item.charisma end
        end)
        
        -- 5. Equipment slot and equipped status
        pcall(function()
            if item.GetSlot then stats.slot = item:GetSlot() 
            elseif item.slot then stats.slot = item.slot end
            
            if item.GetEquippedSlot then stats.equippedSlot = item:GetEquippedSlot() end
            
            -- Check if item is equipped using direct API
            if item.IsEquipped then
                stats.isEquipped = item:IsEquipped()
            elseif stats.equippedSlot and stats.equippedSlot ~= "" then
                stats.isEquipped = true
            end
        end)
        
        -- 6. Material type
        pcall(function()
            if item.GetMaterialType then stats.material = item:GetMaterialType()
            elseif item.materialType then stats.material = item.materialType end
            
            -- Try to determine material from item properties if not directly available
            if not stats.material or stats.material == "" then
                -- Check for armor material based on stats pattern
                if stats.slashDefense > stats.stabDefense * 1.5 and stats.slashDefense > stats.bluntDefense * 1.5 then
                    stats.material = "chainmail"
                elseif stats.stabDefense > 20 and stats.slashDefense > 20 and stats.bluntDefense > 20 then
                    stats.material = "plate"
                elseif stats.stabDefense < 10 and stats.slashDefense < 10 and stats.charisma > 0 then
                    stats.material = "cloth"
                elseif stats.stabDefense > 5 and stats.slashDefense > 5 and stats.bluntDefense < 15 then
                    stats.material = "leather"
                end
            end
        end)
        
        -- 7. Get category information
        if this.itemCategory then
            stats.categories = {}
            
            pcall(function()
                if this.itemCategory:isArmorItem(queueItem.id) then
                    table.insert(stats.categories, "armor")
                end
                
                if this.itemCategory:isClothesItem(queueItem.id) then
                    table.insert(stats.categories, "clothes")
                end
                
                if this.itemCategory:isJewelryItem(queueItem.id) then
                    table.insert(stats.categories, "jewelry")
                end
                
                if this.itemCategory:isWeaponItem(queueItem.id) then
                    table.insert(stats.categories, "weapon")
                end
            end)
        end
        
        -- Add to inventory items list
        table.insert(this.inventoryItems, stats)
        
        -- Process next item with a short delay
        this.processingIndex = this.processingIndex + 1
        this.script.SetTimer(10, function()
            this:processNextItem()
        end)
    end,
    
    -- Check if an item is a potential gear piece (not consumable, quest item, etc.)
    isGearItem = function(self, item)
        --- @type SimplifiedInventoryScan
        local this = self
        
        if not item then
            return false
        end
        
        -- Use category info if available (most reliable)
        if this.itemCategory then
            if this.itemCategory:isArmorItem(item.id) or
               this.itemCategory:isClothesItem(item.id) or
               this.itemCategory:isJewelryItem(item.id) or
               this.itemCategory:isWeaponItem(item.id) then
                return true
            end
        end
        
        -- Check if it can be equipped
        local canEquip = false
        if item.CanEquip then
            local success, result = pcall(function() return item:CanEquip() end)
            canEquip = success and result
        end
        
        -- If the item is already equipped, it's definitely gear
        local isEquipped = false
        if item.IsEquipped then
            local success, result = pcall(function() return item:IsEquipped() end)
            isEquipped = success and result
        end
        
        if isEquipped then
            return true
        end
        
        -- Get the item name to check for non-gear items
        local itemName = ""
        if item.class then
            local success, name = pcall(function() 
                return string.lower(this.itemManager.GetItemName(item.class))
            end)
            
            if success and name then
                itemName = name
            end
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
        
        return isGear
    end,
    
    -- Log inventory details for debugging
    logInventoryDetails = function(self)
        --- @type SimplifiedInventoryScan
        local this = self
        
        if not this.scanningComplete then
            Log.info("Cannot log inventory details - scan not complete")
            return
        end
        
        Log.info("==========================================")
        Log.info("SIMPLIFIED INVENTORY SCAN RESULTS")
        Log.info("==========================================")
        
        -- Log total stats
        Log.info("Found " .. #this.inventoryItems .. " gear items")
        Log.info("Found " .. #this.equippedItems .. " equipped items")
        
        -- Log equipped items
        if #this.equippedItems > 0 then
            Log.info("---------- EQUIPPED ITEMS ----------")
            for i, item in ipairs(this.equippedItems) do
                Log.info(i .. ". " .. item.name)
                if item.slot then
                    Log.info("   Slot: " .. item.slot)
                end
                
                -- Show defense stats if available
                if item.stabDefense > 0 or item.slashDefense > 0 or item.bluntDefense > 0 then
                    Log.info("   Defense: Stab=" .. item.stabDefense .. 
                           ", Slash=" .. item.slashDefense .. 
                           ", Blunt=" .. item.bluntDefense)
                end
            end
        end
    end
}

-- Register the class in GearPicker's class registry
_G.GearPicker.ClassRegistry.SimplifiedInventoryScan = SimplifiedInventoryScan

-- Export for use in other modules
return SimplifiedInventoryScan