# Compatibility Management

This document describes how the GearPicker mod handles compatibility with game functions and ensures smooth operation.

## Overview

The GearPicker mod has been completely refactored to focus on its core functionality of gear optimization. We've cleaned up legacy code references and implemented several mechanisms to prevent conflicts with game functions.

## Key Compatibility Features

### 1. Global Namespace Management

The mod uses a clean global namespace approach to prevent conflicts:

```lua
-- Set up GearPicker global
_G.GearPicker = _G.GearPicker or GearPicker
```

This approach ensures that the mod properly registers its namespace without interfering with other mods.

### 2. Function Patching with Compatibility Module

A dedicated Compatibility module (`Scripts/GearPicker/Utils/Compatibility.lua`) handles potential conflicts with game functions:

```lua
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
end
```

This ensures that critical game functions like `Entity.GetPos` function correctly even when modified by other code.

### 3. Early-Loading Compatibility Script

An early-loading script (`Scripts/Startup/GearPicker_Compatibility.lua`) runs before any other mod code to apply critical fixes:

```lua
-- Backup original Entity.GetPos immediately, before any mod can override it
local original_Entity_GetPos = Entity.GetPos

-- Apply compatibility fix for Entity.GetPos
Entity.GetPos = function(...)
    -- Just pass through to original, no mod code at all
    return original_Entity_GetPos(...)
end
```

This ensures that critical game functions are protected even before the full mod initialization, preventing any errors related to function overriding.

### 4. Error Handling and Graceful Fallbacks

The mod uses robust error handling to prevent crashes:

```lua
catch = function(self, func, ...)
    local success, result = pcall(func, ...)
    if not success then
        local stackTrace = debug.traceback(tostring(result))
        Log.error(tostring(stackTrace))
    end
    return success, result
end
```

This approach allows the mod to catch and log errors without crashing the game, providing better stability and user experience.

## Compatibility Testing

When testing compatibility, we focus on these key aspects:

1. **Loading with existing saves**: Ensure the mod works correctly with all save files
2. **Coexisting with other mods**: Verify that GearPicker doesn't conflict with other mods
3. **Graceful error handling**: Confirm that errors are handled properly without crashing

## Known Compatibility Issues

The mod has been thoroughly refactored to address previous issues:

1. **Entity.GetPos errors**: Fixed in version 1.1.1 with the compatibility module
2. **Missing script errors**: Fixed in version 1.1.1 by ensuring all required scripts are present
3. **Startup errors**: Fixed in version 1.1.1 with improved error handling

If you encounter any other compatibility issues, please report them for further investigation.

## Version History

- **1.1.2**: Removed legacy code references and improved code organization
- **1.1.1**: Added comprehensive compatibility fixes for Entity.GetPos errors and missing scripts
- **1.1.0**: Initial release of GearPicker with basic compatibility support