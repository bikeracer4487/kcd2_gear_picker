-- ApiLimitations.lua - Handle KCD2 API limitations gracefully

-- Store reference to System.LogAlways to ensure it's available
local LogFunc = System.LogAlways

-- Basic logger function that doesn't depend on other mod code
local function ApiLog(message)
    if LogFunc then
        LogFunc("$6[GearPicker-API] " .. tostring(message))
    end
end

-- Handle API limitations in KCD2
local ApiLimitations = {
    -- Create new instance
    new = function(self)
        local instance = {}
        setmetatable(instance, { __index = self })
        ApiLog("API Limitations handler initialized")
        return instance
    end,
    
    -- Create simulated inventory for when actual scanning fails
    createSimulatedInventory = function(self, equippedWeight)
        ApiLog("Creating simulated inventory based on equipped weight: " .. tostring(equippedWeight))
        
        -- Determine number of items to simulate based on weight
        local equipCount = math.ceil(equippedWeight / 10) -- Assume average item weighs 10 units
        equipCount = math.max(1, math.min(10, equipCount)) -- Keep between 1-10 items
        
        ApiLog("Simulating " .. equipCount .. " equipped items")
        
        -- Common armor slots
        local slots = {
            "head", "torso_outer", "torso_middle", "arms", 
            "legs", "feet", "hands", "jewelry1"
        }
        
        -- Create simulated equipped items
        local equippedItems = {}
        local inventoryItems = {}
        
        -- Weight distribution for different slots
        local weightPerItem = equippedWeight / equipCount
        
        -- Add simulated equipped items
        for i = 1, equipCount do
            local slotIndex = ((i-1) % #slots) + 1
            local slot = slots[slotIndex]
            
            -- Create simulated item
            local item = {
                id = -i,  -- Negative ID to indicate simulated item
                name = "Simulated " .. slot:gsub("_", " "):gsub("^%l", string.upper) .. " Item",
                slot = slot,
                weight = weightPerItem,
                isEquipped = true,
                isSimulated = true,
                stabDefense = math.random(5, 15),
                slashDefense = math.random(5, 15),
                bluntDefense = math.random(5, 15),
                noise = math.random(1, 5),
                visibility = math.random(1, 5),
                conspicuousness = math.random(1, 5),
                charisma = math.random(0, 10)
            }
            
            -- Add to equipped items
            table.insert(equippedItems, item)
            table.insert(inventoryItems, item)
            
            ApiLog("Created simulated item for slot: " .. slot)
        end
        
        -- Create some additional inventory items
        for i = 1, 5 do
            local slotIndex = ((i-1) % #slots) + 1
            local slot = slots[slotIndex]
            
            -- Create simulated inventory item
            local item = {
                id = -100 - i,  -- Different negative range for unequipped items
                name = "Alternative " .. slot:gsub("_", " "):gsub("^%l", string.upper) .. " Item",
                slot = slot,
                weight = weightPerItem * 0.8,
                isEquipped = false,
                isSimulated = true,
                stabDefense = math.random(4, 12),
                slashDefense = math.random(4, 12),
                bluntDefense = math.random(4, 12),
                noise = math.random(1, 6),
                visibility = math.random(1, 6),
                conspicuousness = math.random(1, 6),
                charisma = math.random(0, 12)
            }
            
            -- Add to inventory items
            table.insert(inventoryItems, item)
        end
        
        ApiLog("Created " .. #equippedItems .. " simulated equipped items")
        ApiLog("Created " .. #inventoryItems .. " total simulated inventory items")
        
        return inventoryItems, equippedItems
    end,
    
    -- Get a warning message about API limitations
    getWarningMessage = function(self)
        return [[
[IMPORTANT] Limited Inventory Access
-------------------------------------------------------------------------------
Due to KCD2 API limitations, GearPicker cannot access specific item details.
The mod can detect that you have equipment weighing 92.2 units but cannot
identify individual items.

What this means:
- The mod shows simulated items based on your equipped weight
- Gear optimization will not function normally
- Weight stats are accurate, but item stats are simulated

This limitation exists because the game doesn't expose the required APIs.
Future game updates may resolve this issue.
-------------------------------------------------------------------------------
]]
    end
}

-- Register in GearPicker's class registry
_G.GearPicker.ClassRegistry.ApiLimitations = ApiLimitations
ApiLog("Registered ApiLimitations in GearPicker.ClassRegistry")

return ApiLimitations