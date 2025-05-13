# Phase 1: Inventory Logging Implementation Plan

## Overview

Before implementing the full gear optimization system, we need to confirm our ability to access and analyze all necessary gear statistics from the game. The first phase of our implementation will focus on creating a working mod that:

1. Scans the player's inventory for all gear items
2. Retrieves and logs all available stats for each item
3. Verifies we can access key stats including:
   - Defensive stats (Stab/Slash/Blunt defense)
   - Stealth stats (Visibility/Conspicuousness/Noise)
   - Social stats (Charisma)
   - Item properties (Weight/Condition/Material)

This logging functionality will serve as a diagnostic tool to ensure we can programmatically access all required data points for implementing the gear optimization algorithms in subsequent phases.

## Implementation Steps

### 1. Extend EquippedItem Class

The `EquippedItem` class currently has limited stats tracking (only equipment weight). We'll extend it to:

- Retrieve and store comprehensive item statistics
- Support scanning items without unequipping them
- Add methods to identify item materials and properties

```lua
-- Enhanced getDerivedStats to collect all necessary player stats
getDerivedStats = function(self)
    local stats = {
        -- Defensive stats
        stabDefense = self.player.soul:GetDerivedStat("stb"),
        slashDefense = self.player.soul:GetDerivedStat("sla"),
        bluntDefense = self.player.soul:GetDerivedStat("blu"),
        
        -- Stealth stats
        noise = self.player.soul:GetDerivedStat("noi"),
        visibility = self.player.soul:GetDerivedStat("vib"),
        conspicuousness = self.player.soul:GetDerivedStat("con"),
        
        -- Social stats
        charisma = self.player.soul:GetDerivedStat("cha"),
        
        -- Other stats
        equippedWeight = self.player.soul:GetDerivedStat("eqw"),
        maxWeight = self.player.soul:GetDerivedStat("mca")
    }
    
    return stats
end

-- New method to get individual item stats
getItemStats = function(self, item)
    local stats = {
        -- Defensive stats
        stabDefense = item:GetStabDefense() or 0,
        slashDefense = item:GetSlashDefense() or 0,
        bluntDefense = item:GetBluntDefense() or 0,
        
        -- Stealth stats
        noise = item:GetNoiseValue() or 0,
        visibility = item:GetVisibilityValue() or 0,
        conspicuousness = item:GetConspicuousness() or 0,
        
        -- Social stats
        charisma = item:GetCharisma() or 0,
        
        -- Physical properties
        weight = item:GetWeight() or 0,
        condition = item:GetCondition() or 0,
        maxCondition = item:GetMaxCondition() or 0,
        
        -- Material properties (to be detected)
        material = self:detectItemMaterial(item),
        
        -- Reference data
        id = item.id,
        class = item.class,
        name = self.itemManager.GetItemName(item.class),
        uiName = self.itemManager.GetItemUIName(item.class),
        isEquipped = nil -- Will be determined separately
    }
    
    return stats
end
```

### 2. Expand ItemCategory Class

The `ItemCategory` class currently only identifies a few item types. We'll expand it to:

- Identify all 16 armor slots accurately
- Support material detection (cloth, leather, chainmail, plate)
- Handle layering requirements recognition

```lua
-- Extend ItemCategory with additional categories
is = function(self, category, inventoryItem)
    -- ... existing code ...
    
    -- Add all 16 armor slot categories
    if category == "Helmet" then
        return lcName:find("kettle") ~= nil
                or lcName:find("bascinet") ~= nil
                or lcName:find("helmet") ~= nil
                or lcName:find("skullcap") ~= nil
    end
    
    if category == "Cap" then
        return lcName:find("cap") ~= nil
                and not lcName:find("skullcap") ~= nil
    end
    
    if category == "Hood" then
        return lcName:find("hood") ~= nil
    end
    
    -- ... additional category checks ...
    
    -- Material detection categories
    if category == "Cloth" then
        return self:isClothMaterial(lcName, lcUiName)
    end
    
    if category == "Leather" then
        return self:isLeatherMaterial(lcName, lcUiName)
    end
    
    if category == "Chainmail" then
        return self:isChainmailMaterial(lcName, lcUiName)
    end
    
    if category == "Plate" then
        return self:isPlateMaterial(lcName, lcUiName)
    end
    
    return false
end

-- Material detection helper methods
isClothMaterial = function(self, lcName, lcUiName)
    return lcName:find("cloth") ~= nil
            or lcName:find("linen") ~= nil
            or lcName:find("wool") ~= nil
            or lcName:find("silk") ~= nil
end

-- ... other material detection methods ...
```

### 3. Create GearScan Class

We'll implement a new `GearScan` class specifically for comprehensive inventory scanning:

```lua
--- @class GearScan
local GearScan = {
    new = function(self, player, itemManager, itemCategory, equippedItem)
        local instance = {
            player = player,
            itemManager = itemManager,
            itemCategory = itemCategory,
            equippedItem = equippedItem,
            inventoryItems = {},
            equippedItems = {}
        }
        setmetatable(instance, { __index = self })
        return instance
    end,
    
    -- Scan the entire player inventory
    scanInventory = function(self)
        local inventory = self.player.inventory
        local items = inventory:GetItems()
        self.inventoryItems = {}
        
        for i = 1, #items do
            local item = self.itemManager.GetItem(items[i])
            if self:isGearItem(item) then
                local stats = self.equippedItem:getItemStats(item)
                -- Check if item is equipped
                self.equippedItem:isEquipped(items[i], function(equipped)
                    stats.isEquipped = equipped
                    if equipped then
                        table.insert(self.equippedItems, stats)
                    end
                end)
                table.insert(self.inventoryItems, stats)
            end
        end
        
        return self.inventoryItems
    end,
    
    -- Determine if an item is gear (not consumables, quest items, etc.)
    isGearItem = function(self, item)
        -- Logic to detect if item is gear
    end,
    
    -- Log all inventory information
    logInventoryDetails = function(self)
        local Log = HelmetOffDialog.Log
        Log.info("==========================================")
        Log.info("INVENTORY GEAR SCAN - FULL DETAILS")
        Log.info("==========================================")
        
        local categories = {
            "Helmet", "Cap", "Hood", "Coif", "NeckGuard",
            "ChestPlate", "Coat", "Gambeson", "Shirt", 
            "Sleeves", "Gloves", "QuiltedHose", "Shoes", 
            "RowelSpurs", "Jewelry1", "Jewelry2"
        }
        
        -- Log equipped items by category
        Log.info("------------- EQUIPPED GEAR -------------")
        for _, category in ipairs(categories) do
            Log.info("Category: " .. category)
            for _, item in ipairs(self.equippedItems) do
                if self.itemCategory:is(category, item.id) then
                    self:logItemDetails(item)
                end
            end
        end
        
        -- Log all inventory items
        Log.info("------------- ALL INVENTORY GEAR -------------")
        for _, item in ipairs(self.inventoryItems) do
            self:logItemDetails(item)
        end
        
        -- Log player's overall stats
        local playerStats = self.equippedItem:getDerivedStats()
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
        local Log = HelmetOffDialog.Log
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
    end
}

_G.HelmetOffDialog.ClassRegistry.GearScan = GearScan

return GearScan
```

### 4. Add Scanning Commands

We'll implement commands to trigger the inventory scan:

```lua
-- Add to Commands.lua
init = function(self)
    -- ... existing code ...
    
    -- Add inventory scanning commands
    self.system:ExecuteCommand("bind f5 pp_GearScan_Inventory()")
    self.system:AddCCommand(
        "pp_GearScan_Inventory",
        function() self:scanInventory() end,
        "Scan and log all inventory items with stats"
    )
end,

scanInventory = function(self)
    local gearScan = HelmetOffDialog:gearScan()
    gearScan:scanInventory()
    gearScan:logInventoryDetails()
end
```

### 5. Update HelmetOffDialog Factory

Add the GearScan factory method to the main HelmetOffDialog class:

```lua
-- Add to HelmetOffDialog.lua
gearScan = function(self)
    --- @type HelmetOffDialog
    local this = self
    
    if this.__factories.gearScan then
        return this.__factories.gearScan
    end
    
    --- @type GearScan
    local GearScan = this.ClassRegistry.GearScan
    this.__factories.gearScan = GearScan:new(
        _G.player, _G.ItemManager, this:itemCategory(), this:equippedItem()
    )
    
    return this.__factories.gearScan
end,

init = function(self)
    -- ... existing code ...
    
    -- Add GearScan.lua to script loading
    local scripts = {
        -- ... existing scripts ...
        string.format("Scripts/%s/GearScan.lua", modName),
    }
    
    -- ... rest of init function ...
end
```

## Implementation Challenges & Solutions

### 1. Item Property Access

**Challenge:** The game may not expose all necessary item properties through direct API calls.
**Solution:** We'll implement multiple detection strategies:
- Direct API calls where available (e.g., `GetStabDefense()`)
- Name/description parsing for properties not directly exposed
- Weight differential testing for equippable status

### 2. Asynchronous Weight Testing

**Challenge:** The weight-based detection method is asynchronous using callbacks, which complicates inventory scanning.
**Solution:** We'll implement a sequential scanning approach that handles the asynchronous nature of the detection system, using a queue of items to process.

### 3. Material Detection

**Challenge:** Material types may not be directly accessible via API.
**Solution:** We'll implement pattern matching on item names, descriptions, and categories to infer materials.

## Expected Outputs

The inventory logging phase will provide comprehensive logs including:

1. A complete list of all gear items in inventory with detailed stats
2. Categorization of items by slot and material type
3. Equipped vs. unequipped status for each item
4. Overall player stats with all equipment equipped

This data will be essential for validating our ability to access the required information for implementing the optimization algorithms in the next phase.

## Success Criteria

This phase will be considered complete when:

1. We can successfully scan and log all gear items in the player's inventory
2. We can retrieve all critical stats for each item (defensive, stealth, social)
3. We can detect which items are currently equipped
4. We can categorize items by their slot type (all 16 armor slots)
5. We can identify item materials and properties

The logs generated by this phase will inform our approach to the next phases of development, particularly the gear selection algorithms that will form the core of the mod.