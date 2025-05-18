local Log = _G.GearPicker.Log

--- @class Commands
--- @field new fun(self: Commands, system: _G.System): Commands
--- @field system _G.System
--- @field config Config
local Commands = {
    new = function(self, system, config)
        local instance = { system = system, config = config }
        setmetatable(instance, { __index = self })
        Log.info("Commands New instance created")
        return instance
    end,
    
    init = function(self)
        --- @type Commands
        local this = self

        -- Core mod commands
        this.system.AddCCommand(
                "gear_picker__set_mod_off",
                "GearPicker:commands():setModOff(%line)",
                "Turns the gear picker mod on or off."
        )
        this.system.AddCCommand(
                "gear_picker__set_debug",
                "GearPicker:commands():setDebug(%line)",
                "Enables debug mode to output detailed logs."
        )
        
        -- Inventory scanning commands
        this.system.AddCCommand(
                "gear_picker__scan_inventory",
                "GearPicker:commands():scanInventory()",
                "Scans and logs all inventory items with stats."
        )
        this.system.AddCCommand(
                "gear_picker__scan_inventory_simplified",
                "GearPicker:commands():scanInventorySimplified()",
                "Scans inventory using simplified approach based on the original mod."
        )
        
        -- Optimization priority commands
        this.system.AddCCommand(
                "gear_picker__set_priority_armor",
                "GearPicker:commands():setPriorityArmor(%line)",
                "Sets the priority weight for armor optimization (0-100)."
        )
        this.system.AddCCommand(
                "gear_picker__set_priority_stealth",
                "GearPicker:commands():setPriorityStealth(%line)",
                "Sets the priority weight for stealth optimization (0-100)."
        )
        this.system.AddCCommand(
                "gear_picker__set_priority_charisma",
                "GearPicker:commands():setPriorityCharisma(%line)",
                "Sets the priority weight for charisma optimization (0-100)."
        )
        
        -- Defense weight commands
        this.system.AddCCommand(
                "gear_picker__set_stab_defense_weight",
                "GearPicker:commands():setStabDefenseWeight(%line)",
                "Sets the weight for stab defense in armor optimization (0-100)."
        )
        this.system.AddCCommand(
                "gear_picker__set_slash_defense_weight",
                "GearPicker:commands():setSlashDefenseWeight(%line)",
                "Sets the weight for slash defense in armor optimization (0-100)."
        )
        this.system.AddCCommand(
                "gear_picker__set_blunt_defense_weight",
                "GearPicker:commands():setBluntDefenseWeight(%line)",
                "Sets the weight for blunt defense in armor optimization (0-100)."
        )
        
        -- Stealth weight commands
        this.system.AddCCommand(
                "gear_picker__set_noise_weight",
                "GearPicker:commands():setNoiseWeight(%line)",
                "Sets the weight for noise in stealth optimization (0-100)."
        )
        this.system.AddCCommand(
                "gear_picker__set_visibility_weight",
                "GearPicker:commands():setVisibilityWeight(%line)",
                "Sets the weight for visibility in stealth optimization (0-100)."
        )
        this.system.AddCCommand(
                "gear_picker__set_conspicuousness_weight",
                "GearPicker:commands():setConspicuousnessWeight(%line)",
                "Sets the weight for conspicuousness in stealth optimization (0-100)."
        )
        
        -- Weight limit commands
        this.system.AddCCommand(
                "gear_picker__set_max_weight_percentage",
                "GearPicker:commands():setMaxWeightPercentage(%line)",
                "Sets the maximum weight percentage for optimization (0-100)."
        )
        
        -- Feature flag commands
        this.system.AddCCommand(
                "gear_picker__set_auto_optimize",
                "GearPicker:commands():setAutoOptimize(%line)",
                "Enables/disables automatic optimization on situation change."
        )
        
        -- Optimization commands
        this.system.AddCCommand(
                "gear_picker__optimize_armor",
                "GearPicker:commands():optimizeArmor()",
                "Optimizes gear for maximum protection."
        )
        this.system.AddCCommand(
                "gear_picker__optimize_stealth",
                "GearPicker:commands():optimizeStealth()",
                "Optimizes gear for maximum stealth."
        )
        this.system.AddCCommand(
                "gear_picker__optimize_charisma",
                "GearPicker:commands():optimizeCharisma()",
                "Optimizes gear for maximum charisma."
        )
        
        -- Gear preset commands
        this.system.AddCCommand(
                "gear_picker__save_preset",
                "GearPicker:commands():savePreset(%line)",
                "Saves current gear as a named preset (e.g., 'combat', 'stealth', 'town')."
        )
        this.system.AddCCommand(
                "gear_picker__load_preset",
                "GearPicker:commands():loadPreset(%line)",
                "Loads a previously saved gear preset by name."
        )
        this.system.AddCCommand(
                "gear_picker__list_presets",
                "GearPicker:commands():listPresets()",
                "Lists all saved gear presets."
        )
        this.system.AddCCommand(
                "gear_picker__delete_preset",
                "GearPicker:commands():deletePreset(%line)",
                "Deletes a saved preset by name."
        )
        
        -- Bind F6 key to inventory scan for easy testing
        this.system.ExecuteCommand("bind f6 gear_picker__scan_inventory")
        
        -- Bind Alt+F6 to simplified inventory scan
        this.system.ExecuteCommand("bind alt+f6 gear_picker__scan_inventory_simplified")
        
        -- Add keybinds for quick optimization
        this.system.ExecuteCommand("bind f7 gear_picker__optimize_armor")
        this.system.ExecuteCommand("bind f8 gear_picker__optimize_stealth")
        this.system.ExecuteCommand("bind f9 gear_picker__optimize_charisma")
        
        Log.info("All commands registered. Gear scan is bound to F6 key, simplified scan to Alt+F6.")
        Log.info("Quick optimization: F7=Armor, F8=Stealth, F9=Charisma")
    end,

    -- Core mod settings
    setModOff = function(self, input)
        Log.info("setModOff called with argument: ", input)
        self.config:setModOff(input)
    end,
    
    setDebug = function(self, input)
        Log.info("setDebug called with argument: ", input)
        self.config:setDebug(input)
    end,
    
    -- Optimization priority settings
    setPriorityArmor = function(self, input)
        Log.info("setPriorityArmor called with argument: ", input)
        self.config:setPriorityArmor(input)
    end,
    
    setPriorityStealth = function(self, input)
        Log.info("setPriorityStealth called with argument: ", input)
        self.config:setPriorityStealth(input)
    end,
    
    setPriorityCharisma = function(self, input)
        Log.info("setPriorityCharisma called with argument: ", input)
        self.config:setPriorityCharisma(input)
    end,
    
    -- Defense weight settings
    setStabDefenseWeight = function(self, input)
        Log.info("setStabDefenseWeight called with argument: ", input)
        self.config:setStabDefenseWeight(input)
    end,
    
    setSlashDefenseWeight = function(self, input)
        Log.info("setSlashDefenseWeight called with argument: ", input)
        self.config:setSlashDefenseWeight(input)
    end,
    
    setBluntDefenseWeight = function(self, input)
        Log.info("setBluntDefenseWeight called with argument: ", input)
        self.config:setBluntDefenseWeight(input)
    end,
    
    -- Stealth weight settings
    setNoiseWeight = function(self, input)
        Log.info("setNoiseWeight called with argument: ", input)
        self.config:setNoiseWeight(input)
    end,
    
    setVisibilityWeight = function(self, input)
        Log.info("setVisibilityWeight called with argument: ", input)
        self.config:setVisibilityWeight(input)
    end,
    
    setConspicuousnessWeight = function(self, input)
        Log.info("setConspicuousnessWeight called with argument: ", input)
        self.config:setConspicuousnessWeight(input)
    end,
    
    -- Weight limit settings
    setMaxWeightPercentage = function(self, input)
        Log.info("setMaxWeightPercentage called with argument: ", input)
        self.config:setMaxWeightPercentage(input)
    end,
    
    -- Feature flag settings
    setAutoOptimize = function(self, input)
        Log.info("setAutoOptimize called with argument: ", input)
        self.config:setAutoOptimize(input)
    end,
    
    -- Gear scanning command
    scanInventorySimplified = function(self)
        System.LogAlways("$2[GearPicker] =========================================================")
        System.LogAlways("$2[GearPicker] STARTING SIMPLIFIED INVENTORY SCAN...")
        System.LogAlways("$2[GearPicker] =========================================================")
        
        -- Create a direct version of the callback that uses System.LogAlways
        local directLogInventoryDetails = function(inventoryItems, equippedItems)
            System.LogAlways("\n$6[GearPicker] =========================================================")
            System.LogAlways("$6[GearPicker] SIMPLIFIED SCAN RESULTS - " .. #inventoryItems .. " items, " .. #equippedItems .. " equipped")
            System.LogAlways("$6[GearPicker] =========================================================")
            
            -- Log equipped items
            System.LogAlways("\n$5[GearPicker] EQUIPPED ITEMS:")
            for i, item in ipairs(equippedItems) do
                System.LogAlways("$2[GearPicker] " .. i .. ". " .. item.name)
                
                -- Add details if available
                if item.slot then
                    System.LogAlways("$2[GearPicker]    Slot: " .. item.slot)
                end
                
                -- Weight
                if item.weight and item.weight > 0 then
                    System.LogAlways("$2[GearPicker]    Weight: " .. item.weight)
                end
            end
            
            -- Log player's overall weight stats if available
            local playerStats = GearPicker:equippedItem():getDerivedStats()
            if playerStats.equippedWeight then
                System.LogAlways("\n$6[GearPicker] PLAYER EQUIPMENT WEIGHT: " .. playerStats.equippedWeight)
            end
            
            -- Send final completion message
            System.LogAlways("\n$6[GearPicker] =========================================================")
            System.LogAlways("$6[GearPicker] Simplified inventory scan complete!")
            System.LogAlways("$6[GearPicker] =========================================================")
        end
        
        -- Check if simplified scanner is available
        if not GearPicker.simplifiedInventoryScan or type(GearPicker.simplifiedInventoryScan) ~= "function" then
            System.LogAlways("$4[GearPicker] ERROR: Simplified inventory scanner not available!")
            return
        end
        
        -- Create and use the simplified inventory scanner
        local simplifiedScanner = GearPicker:simplifiedInventoryScan()
        if not simplifiedScanner then
            System.LogAlways("$4[GearPicker] ERROR: Failed to create simplified inventory scanner!")
            return
        end
        
        -- Start the scan
        System.LogAlways("$7[GearPicker] DIAGNOSTIC: Starting simplified inventory scan...")
        simplifiedScanner:scanInventory(directLogInventoryDetails)
        
        -- Add a progress indicator
        for i = 1, 10 do
            local timeout = i * 300 -- 300ms, 600ms, 900ms, etc.
            GearPicker:timedTrigger():start(timeout, function() 
                return true 
            end, function()
                System.LogAlways("$5[GearPicker] Simplified scan in progress... (" .. i .. "/10)")
            end)
        end
    end,
    
    scanInventory = function(self)
        System.LogAlways("$2[GearPicker] =========================================================")
        System.LogAlways("$2[GearPicker] STARTING INVENTORY SCAN...")
        System.LogAlways("$2[GearPicker] =========================================================")
        
        -- Try to run diagnostics first
        if _G.GearPickerRunDiagnostics then
            System.LogAlways("$2[GearPicker] Running pre-scan diagnostics...")
            _G.GearPickerRunDiagnostics()
        else
            System.LogAlways("$4[GearPicker] WARNING: Diagnostics function not available")
        end
        
        -- Callback for inventory scan results
        local displayInventoryResults = function(inventoryItems, _)
            System.LogAlways("\n$6[GearPicker] =========================================================")
            System.LogAlways("$6[GearPicker] INVENTORY SCAN RESULTS - " .. #inventoryItems .. " items")
            System.LogAlways("$6[GearPicker] =========================================================")
            
            -- Group items by slot for better organization
            local slotGroups = {}
            for _, item in ipairs(inventoryItems) do
                local slot = item.slot or "unknown"
                if not slotGroups[slot] then
                    slotGroups[slot] = {}
                end
                table.insert(slotGroups[slot], item)
            end
            
            -- Sort slots for consistent display
            local orderedSlots = {
                "head", "head_under", "neck", 
                "torso_outer", "torso_middle", "torso_under",
                "arms", "hands", "legs", "feet",
                "jewelry", "unknown"
            }
            
            -- Display items by slot
            for _, slot in ipairs(orderedSlots) do
                local slotItems = slotGroups[slot] or {}
                if #slotItems > 0 then
                    -- Convert slot name to friendly display name
                    local friendlySlotName = slot:gsub("_", " ")
                    friendlySlotName = friendlySlotName:sub(1,1):upper() .. friendlySlotName:sub(2)
                    System.LogAlways("\n$6[GearPicker] SLOT: " .. friendlySlotName .. " (" .. #slotItems .. " items)")
                    
                    -- Sort items by defense value
                    table.sort(slotItems, function(a, b) 
                        local defA = (a.stabDefense or 0) + (a.slashDefense or 0) + (a.bluntDefense or 0)
                        local defB = (b.stabDefense or 0) + (b.slashDefense or 0) + (b.bluntDefense or 0)
                        return defA > defB
                    end)
                    
                    -- Display only the top 5 items per slot to avoid flooding console
                    local itemsToShow = math.min(5, #slotItems)
                    for i = 1, itemsToShow do
                        local item = slotItems[i]
                        
                        -- Colorize output based on item material
                        local colorCode = "$5" -- Default
                        if item.material == "plate" then
                            colorCode = "$7" -- Silver/gray for plate
                        elseif item.material == "chainmail" then
                            colorCode = "$1" -- Blue for chainmail
                        elseif item.material == "leather" then
                            colorCode = "$4" -- Red for leather
                        elseif item.material == "cloth" then
                            colorCode = "$2" -- Green for cloth
                        end
                        
                        -- Display item with material-based color
                        System.LogAlways(colorCode .. "[GearPicker]   » " .. item.name)
                        
                        -- Defense stats
                        local defenseString = "Defense: "
                        if item.stabDefense > 0 or item.slashDefense > 0 or item.bluntDefense > 0 then
                            if item.stabDefense > 0 then defenseString = defenseString .. "Stab=" .. item.stabDefense .. " " end
                            if item.slashDefense > 0 then defenseString = defenseString .. "Slash=" .. item.slashDefense .. " " end
                            if item.bluntDefense > 0 then defenseString = defenseString .. "Blunt=" .. item.bluntDefense .. " " end
                            System.LogAlways(colorCode .. "[GearPicker]     " .. defenseString)
                        end
                        
                        -- Stealth stats
                        local stealthString = "Stealth: "
                        if item.noise > 0 or item.visibility > 0 or item.conspicuousness > 0 then
                            if item.noise > 0 then stealthString = stealthString .. "Noise=" .. item.noise .. " " end
                            if item.visibility > 0 then stealthString = stealthString .. "Vis=" .. item.visibility .. " " end
                            if item.conspicuousness > 0 then stealthString = stealthString .. "Consp=" .. item.conspicuousness .. " " end
                            System.LogAlways(colorCode .. "[GearPicker]     " .. stealthString)
                        end
                        
                        -- Other stats
                        local otherStatsString = ""
                        if item.charisma > 0 then otherStatsString = otherStatsString .. "Charisma=" .. item.charisma .. " " end
                        if item.material ~= "unknown" then otherStatsString = otherStatsString .. "Material=" .. item.material .. " " end
                        if item.weight > 0 then otherStatsString = otherStatsString .. "Weight=" .. item.weight .. " " end
                        if otherStatsString ~= "" then
                            System.LogAlways(colorCode .. "[GearPicker]     " .. otherStatsString)
                        end
                    end
                    
                    -- If there are more items, show a count
                    if #slotItems > itemsToShow then
                        System.LogAlways("$5[GearPicker]   ... and " .. (#slotItems - itemsToShow) .. " more items")
                    end
                end
            end
            
            -- Summary message
            System.LogAlways("\n$6[GearPicker] =========================================================")
            System.LogAlways("$6[GearPicker] Inventory scan complete! Press F6 to scan again.")
            System.LogAlways("$6[GearPicker] Use F7 to optimize for armor, F8 for stealth, F9 for charisma")
            System.LogAlways("$6[GearPicker] =========================================================")
        end
        
        -- Try to use simplifiedInventoryScan - our new streamlined approach
        System.LogAlways("$7[GearPicker] Trying to use SimplifiedInventoryScan...")
        local scanner = GearPicker:simplifiedInventoryScan()
        
        if not scanner then
            System.LogAlways("$4[GearPicker] WARNING: SimplifiedInventoryScan not available, trying alternative approaches...")
            
            -- Try to reload the script
            System.LogAlways("$7[GearPicker] Attempting to reload SimplifiedInventoryScan.lua...")
            if Script.LoadScript("Scripts/GearPicker/SimplifiedInventoryScan.lua") == 1 then
                System.LogAlways("$2[GearPicker] SimplifiedInventoryScan.lua loaded, trying again...")
                scanner = GearPicker:simplifiedInventoryScan()
            end
            
            -- If still not available, try GearScan as fallback
            if not scanner and GearPicker.gearScan then
                System.LogAlways("$7[GearPicker] Falling back to GearScan...")
                scanner = GearPicker:gearScan()
                if scanner then
                    System.LogAlways("$7[GearPicker] Using GearScan as fallback...")
                else
                    System.LogAlways("$4[GearPicker] ERROR: No inventory scanner available!")
                    return
                end
            else if not scanner then
                System.LogAlways("$4[GearPicker] ERROR: All inventory scanning methods failed!")
                return
            end
            end
        end
        
        System.LogAlways("$7[GearPicker] Starting inventory scan...")
        scanner:scanInventory(displayInventoryResults)
    end,
    
    -- Optimization commands
    optimizeArmor = function(self)
        Log.info("Optimizing for maximum armor protection...")
        System.LogAlways("$3[GearPicker] Optimizing for maximum armor protection...")
        
        local gearSwitcher = GearPicker:gearSwitcher()
        gearSwitcher:switchToOptimized("armor", function(success)
            if success then
                System.LogAlways("$3[GearPicker] Successfully optimized gear for armor protection")
            else
                System.LogAlways("$4[GearPicker] Failed to optimize gear for armor protection")
            end
        end)
    end,
    
    optimizeStealth = function(self)
        Log.info("Optimizing for maximum stealth...")
        System.LogAlways("$3[GearPicker] Optimizing for maximum stealth...")
        
        local gearSwitcher = GearPicker:gearSwitcher()
        gearSwitcher:switchToOptimized("stealth", function(success)
            if success then
                System.LogAlways("$3[GearPicker] Successfully optimized gear for stealth")
            else
                System.LogAlways("$4[GearPicker] Failed to optimize gear for stealth")
            end
        end)
    end,
    
    optimizeCharisma = function(self)
        Log.info("Optimizing for maximum charisma...")
        System.LogAlways("$3[GearPicker] Optimizing for maximum charisma...")
        
        local gearSwitcher = GearPicker:gearSwitcher()
        gearSwitcher:switchToOptimized("charisma", function(success)
            if success then
                System.LogAlways("$3[GearPicker] Successfully optimized gear for charisma")
            else
                System.LogAlways("$4[GearPicker] Failed to optimize gear for charisma")
            end
        end)
    end,
    
    -- Preset management commands
    savePreset = function(self, presetName)
        if not presetName or presetName == "" then
            System.LogAlways("$4[GearPicker] Error: Preset name is required")
            return
        end
        
        Log.info("Saving current gear as preset: " .. presetName)
        System.LogAlways("$3[GearPicker] Saving current gear as preset: " .. presetName)
        
        local gearSwitcher = GearPicker:gearSwitcher()
        gearSwitcher:saveCurrentAsPreset(presetName, function(success)
            if success then
                System.LogAlways("$3[GearPicker] Successfully saved preset: " .. presetName)
            else
                System.LogAlways("$4[GearPicker] Failed to save preset: " .. presetName)
            end
        end)
    end,
    
    loadPreset = function(self, presetName)
        if not presetName or presetName == "" then
            System.LogAlways("$4[GearPicker] Error: Preset name is required")
            return
        end
        
        Log.info("Loading gear preset: " .. presetName)
        System.LogAlways("$3[GearPicker] Loading gear preset: " .. presetName)
        
        local gearSwitcher = GearPicker:gearSwitcher()
        gearSwitcher:switchToPreset(presetName, function(success)
            if success then
                System.LogAlways("$3[GearPicker] Successfully loaded preset: " .. presetName)
            else
                System.LogAlways("$4[GearPicker] Failed to load preset: " .. presetName .. " (preset may not exist)")
            end
        end)
    end,
    
    listPresets = function(self)
        Log.info("Listing all gear presets")
        System.LogAlways("$3[GearPicker] Available gear presets:")
        
        local gearSwitcher = GearPicker:gearSwitcher()
        local presets = gearSwitcher:listPresets()
        
        if #presets == 0 then
            System.LogAlways("$3[GearPicker] No presets found. Use gear_picker__save_preset to create one.")
            return
        end
        
        for i, presetName in ipairs(presets) do
            System.LogAlways("$3[GearPicker]   " .. i .. ". " .. presetName)
        end
    end,
    
    deletePreset = function(self, presetName)
        if not presetName or presetName == "" then
            System.LogAlways("$4[GearPicker] Error: Preset name is required")
            return
        end
        
        Log.info("Deleting gear preset: " .. presetName)
        
        local gearSwitcher = GearPicker:gearSwitcher()
        local success = gearSwitcher:deletePreset(presetName)
        
        if success then
            System.LogAlways("$3[GearPicker] Successfully deleted preset: " .. presetName)
        else
            System.LogAlways("$4[GearPicker] Failed to delete preset: " .. presetName .. " (preset may not exist)")
        end
    end
}

_G.GearPicker.ClassRegistry.Commands = Commands

return Commands