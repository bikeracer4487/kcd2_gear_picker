local Log = _G.HelmetOffDialog.Log

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

        -- Original mod commands
        this.system.AddCCommand(
                "helmet_off_dialog__set_mod_off",
                "HelmetOffDialog:commands():setModOff(%line)",
                "Turns mods on or off."
        )
        this.system.AddCCommand(
                "helmet_off_dialog__set_ranged",
                "HelmetOffDialog:commands():setRanged(%line)",
                "Enables or disables removing ranged weapons."
        )
        this.system.AddCCommand(
                "helmet_off_dialog__set_random",
                "HelmetOffDialog:commands():setRandom(%line)",
                "Turns random gear removal on or off."
        )
        this.system.AddCCommand(
                "helmet_off_dialog__set_helmet_only",
                "HelmetOffDialog:commands():setHelmetOnly(%line)",
                "Sets the mod to remove only the helmet, leaving coif and chainmail on."
        )
        this.system.AddCCommand(
                "helmet_off_dialog__set_debug",
                "HelmetOffDialog:commands():setDebug(%line)",
                "Enables debug mode to output logs to check why gear was or wasn't removed."
        )
        
        -- New gear picker commands
        this.system.AddCCommand(
                "gear_picker__scan_inventory",
                "HelmetOffDialog:commands():scanInventory()",
                "Scans and logs all inventory items with stats"
        )
        
        -- Bind F6 key to inventory scan for easy testing
        this.system.ExecuteCommand("bind f6 gear_picker__scan_inventory")
        
        Log.info("All commands registered. Gear scan is bound to F6 key.")
    end,

    -- Original mod commands
    setRanged = function(self, input)
        Log.info("setRanged called with argument: ", input)
        self.config:setRanged(input)
    end,
    setRandom = function(self, input)
        Log.info("setRandom called with argument: ", input)
        self.config:setRandom(input)
    end,
    setHelmetOnly = function(self, input)
        Log.info("setHelmetOnly called with argument: ", input)
        self.config:setHelmetOnly(input)
    end,
    setModOff = function(self, input)
        Log.info("setModOff called with argument: ", input)
        self.config:setModOff(input)
    end,
    setDebug = function(self, input)
        Log.info("setDebug called with argument: ", input)
        self.config:setDebug(input)
    end,
    
    -- New gear picker commands
    scanInventory = function(self)
        Log.info("Starting inventory scan...")
        System.LogAlways("$3[GearPicker] Starting inventory scan. Results will be logged to console.")
        
        local gearScan = HelmetOffDialog:gearScan()
        gearScan:scanInventory(function(inventoryItems, equippedItems)
            System.LogAlways("$3[GearPicker] Scan complete: " .. #inventoryItems .. " gear items found, " .. #equippedItems .. " equipped")
            gearScan:logInventoryDetails()
        end)
    end
}

_G.HelmetOffDialog.ClassRegistry.Commands = Commands

return Commands