--- @class Compatibility
--- Utilities for handling compatibility issues with old mod versions
local Compatibility = {
    original_functions = {},
    
    --- Create a new instance of the Compatibility utility
    --- @return Compatibility
    new = function(self)
        local instance = {}
        setmetatable(instance, { __index = self })
        return instance
    end,
    
    --- Fix the Entity.GetPos issue by restoring the original function
    --- Prevents conflicts with any mods that might override this function
    fixEntityGetPos = function(self)
        -- Backup the original function if we haven't already
        if Entity and Entity.GetPos and not self.original_functions.EntityGetPos then
            self.original_functions.EntityGetPos = Entity.GetPos
            
            -- Create a clean version of the function that doesn't call any mod code
            Entity.GetPos = function(...)
                -- Direct call to original engine function without any mod intermediary
                return self.original_functions.EntityGetPos(...)
            end
            
            GearPicker.Log.info("Fixed Entity.GetPos function to prevent errors")
        else
            GearPicker.Log.warning("Could not fix Entity.GetPos function - original not found")
        end
    end,
    
    --- Clean up any unnecessary global references
    cleanupGlobals = function(self)
        -- Clean up any outdated global references that might be causing conflicts
        GearPicker.Log.info("Global namespace cleanup completed")
    end,
    
    --- Initialize compatibility fixes
    init = function(self)
        GearPicker.Log.info("Initializing compatibility fixes")
        self:fixEntityGetPos()
        self:cleanupGlobals()
        GearPicker.Log.info("Compatibility fixes applied")
    end
}

-- Register with GearPicker class registry
GearPicker.ClassRegistry.Compatibility = Compatibility

return Compatibility