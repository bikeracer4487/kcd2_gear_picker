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
        
        -- Add keybinds for quick optimization
        this.system.ExecuteCommand("bind f7 gear_picker__optimize_armor")
        this.system.ExecuteCommand("bind f8 gear_picker__optimize_stealth")
        this.system.ExecuteCommand("bind f9 gear_picker__optimize_charisma")
        
        Log.info("All commands registered. Gear scan is bound to F6 key.")
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
    scanInventory = function(self)
        Log.info("Starting inventory scan...")
        System.LogAlways("$3[GearPicker] Starting inventory scan. Results will be logged to console.")
        
        -- Force debug mode on temporarily for detailed logging
        local originalDebug = GearPicker:config().is_debug
        GearPicker:config().is_debug = true
        
        local gearScan = GearPicker:gearScan()
        gearScan:scanInventory(function(inventoryItems, equippedItems)
            System.LogAlways("$3[GearPicker] Scan complete: " .. #inventoryItems .. " gear items found, " .. #equippedItems .. " equipped")
            System.LogAlways("$3[GearPicker] Detailed inventory analysis:")
            -- Log inventory details through explicit system logs for visibility
            System.LogAlways("$3[GearPicker] ==========================================")
            System.LogAlways("$3[GearPicker] INVENTORY GEAR SCAN - FULL DETAILS")
            System.LogAlways("$3[GearPicker] ==========================================")
            
            -- Log all equipped items
            System.LogAlways("$3[GearPicker] ------------- EQUIPPED GEAR -------------")
            for _, item in ipairs(equippedItems) do
                System.LogAlways("$3[GearPicker] " .. item.name .. " (" .. item.uiName .. ")")
                System.LogAlways("$3[GearPicker]   Defense - Stab: " .. item.stabDefense .. 
                      ", Slash: " .. item.slashDefense .. 
                      ", Blunt: " .. item.bluntDefense)
                System.LogAlways("$3[GearPicker]   Stealth - Noise: " .. item.noise .. 
                      ", Visibility: " .. item.visibility .. 
                      ", Conspicuousness: " .. item.conspicuousness)
                System.LogAlways("$3[GearPicker]   Charisma: " .. item.charisma .. 
                      ", Material: " .. item.material)
                if item.categories and #item.categories > 0 then
                    local categoriesStr = ""
                    for i, category in ipairs(item.categories) do
                        if i > 1 then categoriesStr = categoriesStr .. ", " end
                        categoriesStr = categoriesStr .. category
                    end
                    System.LogAlways("$3[GearPicker]   Categories: " .. categoriesStr)
                end
            end
            
            -- Log player's overall stats
            local playerStats = gearScan.equippedItem:getDerivedStats()
            System.LogAlways("$3[GearPicker] ------------- OVERALL PLAYER STATS -------------")
            System.LogAlways("$3[GearPicker] Total Stab Defense: " .. playerStats.stabDefense)
            System.LogAlways("$3[GearPicker] Total Slash Defense: " .. playerStats.slashDefense)
            System.LogAlways("$3[GearPicker] Total Blunt Defense: " .. playerStats.bluntDefense)
            System.LogAlways("$3[GearPicker] Visibility: " .. playerStats.visibility)
            System.LogAlways("$3[GearPicker] Conspicuousness: " .. playerStats.conspicuousness)
            System.LogAlways("$3[GearPicker] Noise: " .. playerStats.noise)
            System.LogAlways("$3[GearPicker] Charisma: " .. playerStats.charisma)
            
            -- Also run the regular log function for more detailed logs
            gearScan:logInventoryDetails()
            
            -- Restore original debug setting
            GearPicker:config().is_debug = originalDebug
        end)
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