local Log = GearPicker.Log

--- @class GearSwitcher
--- @field new fun(self: GearSwitcher, player: _G.player, equipment: Equipment, gearOptimizer: GearOptimizer): GearSwitcher
--- @field switchToOptimized fun(self: GearSwitcher, optimizationType: string, callback: function): void
--- @field switchToPreset fun(self: GearSwitcher, presetName: string, callback: function): void
--- @field saveCurrentAsPreset fun(self: GearSwitcher, presetName: string): void
--- @field gearOptimizer GearOptimizer
--- @field equipment Equipment
local GearSwitcher = {
    new = function(self, player, equipment, gearOptimizer, itemManager)
        local instance = {
            player = player,
            equipment = equipment,
            gearOptimizer = gearOptimizer,
            itemManager = itemManager,
            presets = {}, -- Store named presets
            activePreset = nil -- Track currently active preset
        }
        setmetatable(instance, { __index = self })
        Log.info("GearSwitcher New instance created")
        
        -- Load saved presets from config if available
        instance:loadPresets()
        
        return instance
    end,
    
    -- Switch to an optimized loadout based on optimization type
    switchToOptimized = function(self, optimizationType, callback)
        --- @type GearSwitcher
        local this = self
        Log.info("GearSwitcher.switchToOptimized: Switching to " .. optimizationType)
        
        -- Use the gear optimizer to calculate the optimal gear set
        this.gearOptimizer:optimize(optimizationType, function(optimizedGearSet)
            if not optimizedGearSet then
                Log.error("GearSwitcher: Failed to optimize gear for " .. optimizationType)
                return callback(false)
            end
            
            -- Apply the optimized gear set using Equipment module
            this.equipment:applyGearSet(optimizedGearSet, function(success)
                if success then
                    Log.info("GearSwitcher: Successfully switched to optimized " .. optimizationType .. " loadout")
                    this.activePreset = "optimized_" .. optimizationType
                else
                    Log.error("GearSwitcher: Failed to apply optimized gear set")
                end
                
                callback(success)
            end)
        end)
    end,
    
    -- Switch to a named preset loadout
    switchToPreset = function(self, presetName, callback)
        --- @type GearSwitcher
        local this = self
        Log.info("GearSwitcher.switchToPreset: Switching to preset '" .. presetName .. "'")
        
        -- Check if preset exists
        local preset = this.presets[presetName]
        if not preset then
            Log.error("GearSwitcher: Preset '" .. presetName .. "' not found")
            return callback(false)
        end
        
        -- Apply the preset gear set
        this.equipment:applyGearSet(preset, function(success)
            if success then
                Log.info("GearSwitcher: Successfully switched to preset '" .. presetName .. "'")
                this.activePreset = presetName
            else
                Log.error("GearSwitcher: Failed to apply preset '" .. presetName .. "'")
            end
            
            callback(success)
        end)
    end,
    
    -- Save current gear as a named preset
    saveCurrentAsPreset = function(self, presetName, callback)
        --- @type GearSwitcher
        local this = self
        Log.info("GearSwitcher.saveCurrentAsPreset: Saving current gear as '" .. presetName .. "'")
        
        -- Gather current equipment by slot
        local currentGear = {}
        local slotCategories = {
            "Helmet", "Cap", "Hood", "Coif", "HeadChainmail", "NeckGuard",
            "ChestPlate", "Coat", "Gambeson", "Shirt",
            "Sleeves", "Gloves", "QuiltedHose", "Shoes", "RowelSpurs",
            "Jewelry1", "Jewelry2", "RangedWeapon"
        }
        
        -- Process all categories to find equipped items
        local remainingCategories = #slotCategories
        
        for _, category in ipairs(slotCategories) do
            -- For each category, find if an item is equipped
            this:findEquippedItemByCategory(category, function(equippedItem)
                if equippedItem then
                    local slot = this.equipment.itemCategory:getSlotForCategory(category)
                    if slot ~= "unknown" then
                        currentGear[slot] = equippedItem
                    end
                end
                
                remainingCategories = remainingCategories - 1
                if remainingCategories <= 0 then
                    -- All categories processed, save the preset
                    this.presets[presetName] = currentGear
                    this:savePresets()
                    Log.info("GearSwitcher: Preset '" .. presetName .. "' saved with " .. 
                             this:countTableEntries(currentGear) .. " items")
                    
                    if callback then
                        callback(true)
                    end
                end
            end)
        end
    end,
    
    -- Helper to find equipped items by category
    findEquippedItemByCategory = function(self, category, callback)
        --- @type GearSwitcher
        local this = self
        
        -- First get all items of this category from inventory
        local items = {}
        for _, inventoryItem in pairs(this.player.inventory:GetInventoryTable()) do
            if this.equipment.itemCategory:is(category, inventoryItem) then
                table.insert(items, inventoryItem)
            end
        end
        
        if #items == 0 then
            return callback(nil)
        end
        
        -- Check each item if it's equipped
        local index = 1
        local checkNext = function()
            if index > #items then
                -- No equipped items found in this category
                return callback(nil)
            end
            
            local item = items[index]
            this.equipment.equippedItem:isEquipped(item, function(isEquipped)
                if isEquipped then
                    -- Found the equipped item
                    return callback(item)
                end
                
                -- Try next item
                index = index + 1
                checkNext()
            end)
        end
        
        checkNext()
    end,
    
    -- Load presets from configuration storage
    loadPresets = function(self)
        -- In a real implementation, this would load from saved config
        -- For now, initializing with empty presets
        self.presets = {}
        Log.info("GearSwitcher: Presets loaded")
    end,
    
    -- Save presets to configuration storage
    savePresets = function(self)
        -- In a real implementation, this would save to config
        Log.info("GearSwitcher: Presets saved")
    end,
    
    -- List all available presets
    listPresets = function(self)
        local presetList = {}
        for name, _ in pairs(self.presets) do
            table.insert(presetList, name)
        end
        return presetList
    end,
    
    -- Delete a preset
    deletePreset = function(self, presetName)
        if self.presets[presetName] then
            self.presets[presetName] = nil
            self:savePresets()
            Log.info("GearSwitcher: Preset '" .. presetName .. "' deleted")
            return true
        end
        return false
    end,
    
    -- Helper function to count entries in a table
    countTableEntries = function(self, tbl)
        local count = 0
        for _, _ in pairs(tbl) do
            count = count + 1
        end
        return count
    end
}

_G.GearPicker.ClassRegistry.GearSwitcher = GearSwitcher

return GearSwitcher