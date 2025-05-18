--- @class GearPicker @global
local GearPicker = {
    MOD_NAME = "__DYNAMICALLY_INJECTED__",
    ENVIRONMENT = "__DYNAMICALLY_INJECTED__",
    VERSION = "1.1.4",

    ClassRegistry = {},
    __factories = {},

    --- @type Config
    config = function(self)
        --- @type GearPicker
        local this = self

        if this.__factories.config then
            return this.__factories.config
        end

        --- @type Config
        local Config = this.ClassRegistry.Config
        this.__factories.config = Config:new(GearPicker.ENVIRONMENT)

        return this.__factories.config
    end,
    
    error = function(self)
        --- @type GearPicker
        local this = self

        if this.__factories.error then
            return this.__factories.error
        end
        --- @type Error
        local Error = this.ClassRegistry.Error
        this.__factories.error = Error:new()
        return this.__factories.error
    end,
    
    equipment = function(self)
        --- @type GearPicker
        local this = self
        --- @type Equipment
        if this.__factories.equipment then
            return this.__factories.equipment
        end
        local Equipment = this.ClassRegistry.Equipment
        this.__factories.equipment = Equipment:new(
                _G.player, this:unequipGear(), _G.ItemManager
        )
        return this.__factories.equipment
    end,
    
    unequipGear = function(self)
        --- @type GearPicker
        local this = self
        --- @type UnequipGear
        local UnequipGear = this.ClassRegistry.UnequipGear

        if this.__factories.unequipGear then
            return this.__factories.unequipGear
        end

        this.__factories.unequipGear = UnequipGear:new(
                _G.player,
                this:equippedItem(),
                this:itemCategory(),
                _G.ItemManager
        )

        return this.__factories.unequipGear
    end,
    
    timedTrigger = function(self)
        --- @type GearPicker
        local this = self

        if this.__factories.timedTrigger then
            return this.__factories.timedTrigger
        end

        --- @type TimedTrigger
        local TimedTrigger = this.ClassRegistry.TimedTrigger
        this.__factories.timedTrigger = TimedTrigger:new(_G.Script)

        return this.__factories.timedTrigger
    end,
    
    equippedItem = function(self)
        --- @type GearPicker
        local this = self

        if this.__factories.equippedItem then
            return this.__factories.equippedItem
        end

        --- @type EquippedItem
        local EquippedItem = this.ClassRegistry.EquippedItem
        this.__factories.equippedItem = EquippedItem:new(
                _G.player, _G.Script, _G.ItemManager
        )

        return this.__factories.equippedItem
    end,
    
    itemCategory = function(self)
        if self.__factories.itemCategory then
            return self.__factories.itemCategory
        end

        --- @type ItemCategory
        local ItemCategory = self.ClassRegistry.ItemCategory
        self.__factories.itemCategory = ItemCategory:new(_G.ItemManager)

        return self.__factories.itemCategory
    end,
    
    --- @type Commands
    commands = function(self)
        --- @type GearPicker
        local this = self
        if this.__factories.commands then
            return this.__factories.commands
        end
        --- @type Commands
        local Commands = this.ClassRegistry.Commands
        this.__factories.commands = Commands:new(_G.System, this:config())
        return this.__factories.commands
    end,
    
    --- @type GearScan
    gearScan = function(self)
        --- @type GearPicker
        local this = self
        
        if this.__factories.gearScan then
            return this.__factories.gearScan
        end
        
        --- @type GearScan
        local GearScan = this.ClassRegistry.GearScan
        this.__factories.gearScan = GearScan:new(
                _G.player, 
                _G.ItemManager, 
                this:itemCategory(), 
                this:equippedItem()
        )
        
        return this.__factories.gearScan
    end,
    
    --- @type GearOptimizer
    gearOptimizer = function(self)
        --- @type GearPicker
        local this = self
        
        if this.__factories.gearOptimizer then
            return this.__factories.gearOptimizer
        end
        
        --- @type GearOptimizer
        local GearOptimizer = this.ClassRegistry.GearOptimizer
        this.__factories.gearOptimizer = GearOptimizer:new(
                _G.player,
                _G.ItemManager,
                this:itemCategory(),
                this:equippedItem(),
                this:gearScan()
        )
        
        return this.__factories.gearOptimizer
    end,
    
    --- @type GearSwitcher
    gearSwitcher = function(self)
        --- @type GearPicker
        local this = self
        
        if this.__factories.gearSwitcher then
            return this.__factories.gearSwitcher
        end
        
        --- @type GearSwitcher
        local GearSwitcher = this.ClassRegistry.GearSwitcher
        this.__factories.gearSwitcher = GearSwitcher:new(
                _G.player,
                this:equipment(),
                this:gearOptimizer(),
                _G.ItemManager
        )
        
        return this.__factories.gearSwitcher
    end,
    
    init = function(self)
        -- Visible startup message to confirm mod loading
        System.LogAlways("$2[GearPicker] Mod initializing...")
        
        --- @type GearPicker
        local this = self
        this.__factories = {}

        local modName = "GearPicker"
        local scripts = {
            string.format("Scripts/%s/Utils/Log.lua", modName),
            string.format("Scripts/%s/Utils/Error.lua", modName),
            string.format("Scripts/%s/Utils/Inspect.lua", modName),
            string.format("Scripts/%s/Utils/dd.lua", modName),
            string.format("Scripts/%s/Utils/Compatibility.lua", modName),
            string.format("Scripts/%s/TimedTrigger.lua", modName),
            string.format("Scripts/%s/Config.lua", modName),
            string.format("Scripts/%s/Equipment.lua", modName),
            string.format("Scripts/%s/EquippedItem.lua", modName),
            string.format("Scripts/%s/UnequipGear.lua", modName),
            string.format("Scripts/%s/ItemCategory.lua", modName),
            string.format("Scripts/%s/ApiLimitations.lua", modName),
            string.format("Scripts/%s/AlternativeInventory.lua", modName),
            string.format("Scripts/%s/SimplifiedInventoryScan.lua", modName),
            string.format("Scripts/%s/EmbeddedScan.lua", modName),
            string.format("Scripts/%s/Commands.lua", modName),
            string.format("Scripts/%s/GearScan.lua", modName),
            string.format("Scripts/%s/GearOptimizer.lua", modName),
            string.format("Scripts/%s/GearSwitcher.lua", modName),
            string.format("Scripts/%s/Diagnostics.lua", modName),
        }
        
        -- Log script loading details
        local loadedCount = 0
        local failedCount = 0
        
        for _, script in ipairs(scripts) do
            local result = Script.LoadScript(script)
            if result ~= 1 then
                System.LogAlways("$4[GearPicker ERROR] Unable to load script: " .. script)
                failedCount = failedCount + 1
            else
                -- Add extra logging for the SimplifiedInventoryScan file
                if script:find("SimplifiedInventoryScan.lua") then
                    System.LogAlways("$2[GearPicker] Successfully loaded SimplifiedInventoryScan.lua")
                    -- Check if it was properly registered
                    if this.ClassRegistry and this.ClassRegistry.SimplifiedInventoryScan then
                        System.LogAlways("$2[GearPicker] SimplifiedInventoryScan class properly registered")
                    else
                        System.LogAlways("$4[GearPicker ERROR] SimplifiedInventoryScan not registered after loading")
                    end
                end
                loadedCount = loadedCount + 1
            end
        end
        
        -- Summary logging
        System.LogAlways(string.format("$2[GearPicker] Startup status: Loaded %d scripts, Failed %d scripts", loadedCount, failedCount))
        
        if failedCount > 0 then
            System.LogAlways("$4[GearPicker WARNING] Some scripts failed to load. Mod may not function properly!")
        else
            System.LogAlways("$2[GearPicker] All scripts loaded successfully!")
        end
        
        -- Global initialization hook for debugging
        _G.GearPickerLoaded = true
        
        GearPicker.Log.info("All classes loaded.")
        this:commands():init()
        
        -- Run compatibility fixes if available
        if self.OnCompatibilityInit then
            System.LogAlways("$2[GearPicker] Running compatibility fixes...")
            self.OnCompatibilityInit()
        end
        
        -- Final confirmation message
        System.LogAlways(string.format("$2[GearPicker] Mod v%s initialized. Press F6 to scan inventory (Alt+F6 for simplified scan), F7-F9 for quick gear optimization.", self.VERSION))
    end,
    
    -- Add compatibility utility factory method
    compatibility = function(self)
        --- @type GearPicker
        local this = self
        
        if this.__factories.compatibility then
            return this.__factories.compatibility
        end
        
        --- @type Compatibility
        local Compatibility = this.ClassRegistry.Compatibility
        if not Compatibility then
            System.LogAlways("$4[GearPicker ERROR] Compatibility class not found in registry")
            return nil
        end
        
        this.__factories.compatibility = Compatibility:new()
        return this.__factories.compatibility
    end,
    
    --- Alternative inventory scanner to work around API limitations
    alternativeInventory = function(self)
        --- @type GearPicker
        local this = self
        
        if this.__factories.alternativeInventory then
            return this.__factories.alternativeInventory
        end
        
        --- @type AlternativeInventory
        local AlternativeInventory = this.ClassRegistry.AlternativeInventory
        if not AlternativeInventory then
            System.LogAlways("$4[GearPicker ERROR] AlternativeInventory class not found in registry")
            return nil
        end
        
        this.__factories.alternativeInventory = AlternativeInventory:new(_G.player, _G.ItemManager)
        return this.__factories.alternativeInventory
    end,
    
    --- API Limitations handler
    apiLimitations = function(self)
        --- @type GearPicker
        local this = self
        
        if this.__factories.apiLimitations then
            return this.__factories.apiLimitations
        end
        
        --- @type ApiLimitations
        local ApiLimitations = this.ClassRegistry.ApiLimitations
        if not ApiLimitations then
            System.LogAlways("$4[GearPicker ERROR] ApiLimitations class not found in registry")
            return nil
        end
        
        this.__factories.apiLimitations = ApiLimitations:new()
        return this.__factories.apiLimitations
    end,
    
    --- Simplified inventory scanner that combines approaches from archived mod
    simplifiedInventoryScan = function(self)
        --- @type GearPicker
        local this = self
        
        if this.__factories.simplifiedInventoryScan then
            return this.__factories.simplifiedInventoryScan
        end
        
        System.LogAlways("$7[GearPicker] Getting SimplifiedInventoryScan from ClassRegistry...")
        
        -- Do a full diagnostic to help debug the issue
        if not this.ClassRegistry then
            System.LogAlways("$4[GearPicker ERROR] ClassRegistry is nil!")            
            return nil
        end
        
        -- List available classes in the registry
        System.LogAlways("$7[GearPicker] Classes in registry:")
        for className, _ in pairs(this.ClassRegistry) do
            System.LogAlways("$7[GearPicker]   - " .. className)
        end
        
        -- First try SimplifiedInventoryScan
        local SimplifiedInventoryScan = this.ClassRegistry.SimplifiedInventoryScan
        if SimplifiedInventoryScan then
            System.LogAlways("$2[GearPicker] Found SimplifiedInventoryScan class, creating instance...")
            this.__factories.simplifiedInventoryScan = SimplifiedInventoryScan:new(
                _G.player, 
                _G.Script, 
                _G.ItemManager,
                this:itemCategory()
            )
            
            if this.__factories.simplifiedInventoryScan then
                System.LogAlways("$2[GearPicker] Successfully created SimplifiedInventoryScan instance")
                return this.__factories.simplifiedInventoryScan
            end
        end
        
        -- Try EmbeddedScan as fallback
        System.LogAlways("$7[GearPicker] SimplifiedInventoryScan not available, trying EmbeddedScan...")
        local EmbeddedScan = this.ClassRegistry.EmbeddedScan
        if EmbeddedScan then
            System.LogAlways("$2[GearPicker] Found EmbeddedScan class, creating instance...")
            this.__factories.simplifiedInventoryScan = EmbeddedScan:new(
                _G.player, 
                _G.Script, 
                _G.ItemManager,
                this:itemCategory()
            )
            
            if this.__factories.simplifiedInventoryScan then
                System.LogAlways("$2[GearPicker] Successfully created EmbeddedScan instance as fallback")
                return this.__factories.simplifiedInventoryScan
            end
        end
        
        System.LogAlways("$4[GearPicker ERROR] No inventory scanner found in ClassRegistry")
        return nil
    end,
    
    --- Embedded backup inventory scanner
    embeddedScan = function(self)
        --- @type GearPicker
        local this = self
        
        if this.__factories.embeddedScan then
            return this.__factories.embeddedScan
        end
        
        local EmbeddedScan = this.ClassRegistry.EmbeddedScan
        if not EmbeddedScan then
            System.LogAlways("$4[GearPicker ERROR] EmbeddedScan class not found in registry")
            return nil
        end
        
        this.__factories.embeddedScan = EmbeddedScan:new(
            _G.player, 
            _G.Script, 
            _G.ItemManager,
            this:itemCategory()
        )
        
        return this.__factories.embeddedScan
    end,
}

-- Set up GearPicker global
_G.GearPicker = _G.GearPicker or GearPicker

-- Provide easier check for other mods or scripts to detect if GearPicker is loaded
_G.IsGearPickerLoaded = function()
    return _G.GearPickerLoaded == true
end

-- Log initial load for troubleshooting
System.LogAlways("$2[GearPicker] Script loaded - base module ready")

return GearPicker;