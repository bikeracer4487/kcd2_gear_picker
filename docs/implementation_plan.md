# Gear Optimization Implementation Plan

## Overview

The Gear Picker mod will use the underlying logic from the Helmet Off Dialog mod but will be completely repurposed to automatically select optimal gear combinations based on different parameters: maximum armor/protection, maximum stealth, and maximum charisma. The mod will leverage KCD2's intricate armor system, which features mandatory layering, complex stats calculations, and strategic outfit management.

## Code Structure

We will focus our implementation exclusively on the code in the `src/main/` directory. The code in `src/helmet_only/`, `src/random/`, and `src/ranged/` will be kept for reference only but will not be used in our implementation.

## KCD2 Armor System Understanding

Based on our analysis of the KCD2 armor system, the following key aspects will inform our implementation:

### 1. Mandatory Layering System

KCD2 enforces specific layering requirements:
- **Head Protection**: A coif must be worn before any helmet
- **Torso Protection**: A gambeson or arming doublet must be worn under a cuirass or plate armor
- **Leg Protection**: Gamboised hose or padded chausses must be worn under leg harnesses
- **Accessories**: Some items like Rowel Spurs require appropriate footwear to be equipped

Our gear picker must respect these dependencies when suggesting or applying optimized loadouts.

### 2. Key Armor Statistics

Each armor piece contributes to multiple stat categories:

**Defensive Stats:**
- **Stab Defense**: Protection against piercing attacks (arrows, spears, daggers)
- **Slash Defense**: Protection against cutting attacks (swords)
- **Blunt Defense**: Protection against impact damage (maces, hammers)

**Stealth Stats:**
- **Visibility**: How easily NPCs visually detect the player; affected by garment color and type
- **Conspicuousness**: How quickly NPCs recognize the player; influenced by clothing type and quality
- **Noise**: Sound generated during movement; heavily influenced by material type

**Social & Utility Stats:**
- **Charisma**: Influences dialogue success and NPC disposition
- **Weight**: Affects movement speed and stamina consumption
- **Durability/Condition**: Item's maximum potential robustness and current repair state
- **Dirt & Blood**: Dynamic indicators affecting Charisma and potentially Conspicuousness

### 3. Stat Calculation Methods

Different stats are calculated using different methods:
- **Defensive Stats**: Values stack cumulatively across all armor pieces
- **Visibility/Conspicuousness**: Outer layers can partially override inner layers
- **Noise**: Cumulative from all equipped items (cannot be hidden)
- **Charisma**: Primarily influenced by visible (outer) layers and their condition/cleanliness

### 4. Material Types and Tradeoffs

KCD2 has distinct armor material categories with inherent tradeoffs:
- **Cloth/Padded**: Very lightweight, quiet, minimal protection (good for stealth)
- **Leather**: Relatively light, quieter than metal, low-to-medium protection
- **Chainmail**: Medium weight, noisy, good protection against slashing
- **Plate**: Very heavy, very noisy, highest protection

## Implementation Strategy

### Phase 1: Foundation & Analysis

1. **Extend Item Detection Mechanism**
   - Enhance the existing weight-based detection to work with all gear types
   - Create new ItemCategory definitions for all 16 armor slots and their variations
   - Implement a comprehensive gear scanning system that respects layering requirements
   - Detect and catalog underlying dependencies (e.g., which items require specific underlayers)

2. **Gear Stats Analysis**
   - Create a system to analyze and store complete gear statistics (all defensive, stealth, and social stats)
   - Implement methods to read the three defense values (Stab, Slash, Blunt)
   - Add analysis for stealth properties (Visibility, Conspicuousness, Noise)
   - Include Charisma, Weight, Condition, and cleanliness tracking
   - Build a gear database that tracks all items in inventory and their attributes

### Phase 2: Core Optimization Features

1. **Gear Selection Algorithms**
   - Implement Maximum Armor algorithm:
     - Prioritize combined defensive stats (weighted balance of Stab/Slash/Blunt protection)
     - Ensure proper layering requirements are satisfied
     - Consider armor material effectiveness against different damage types
     - Respect weight constraints and minimum mobility requirements

   - Implement Maximum Stealth algorithm:
     - Minimize Noise (highest priority for stealth as it cannot be hidden)
     - Optimize for low Visibility using dark-colored and non-reflective items
     - Reduce Conspicuousness with appropriate common clothing
     - Consider time of day and lighting conditions if detectable
     - Include minimal protective gear that doesn't compromise stealth

   - Implement Maximum Charisma algorithm:
     - Prioritize high Charisma on visible (outer) layers
     - Ensure clothing is clean and in good condition
     - Select noble/high-status clothing combinations appropriate for social contexts
     - Include adequate protection without compromising appearance

2. **Gear Swapping System**
   - Extend Equipment class to swap complete outfits respecting layering requirements
   - Implement a sequential equipping process that handles dependencies
   - Mirror KCD2's 3-outfit preset system
   - Ensure proper inventory handling and weight management

### Phase 3: User Interface & Control

1. **Command System**
   - Create console commands for triggering gear optimization for different scenarios
   - Implement hotkey support for quick outfit swapping between presets
   - Add debug/display commands to show current gear stats across all categories

2. **Profile Management**
   - Implement saved profiles for different optimization settings
   - Create custom profile options with mixed priorities (e.g., balanced stealth/protection)
   - Add profile import/export functionality

3. **Configuration Options**
   - Add configuration for optimization priorities and stat weighting
   - Create weight limits and mobility threshold settings
   - Implement toggles for specific gear slots to include/exclude from optimization
   - Add options to prioritize specific damage type protection (stab/slash/blunt)

### Phase 4: Advanced Features

1. **Situational Optimization**
   - Implement auto-detection of stealth situations
   - Add combat awareness to automatically optimize for protection
   - Create social encounter detection for charisma optimization
   - Consider time of day for visibility optimizations

2. **Compatibility Enhancements**
   - Ensure compatibility with other equipment mods
   - Add support for modded items and custom gear
   - Create an extensible system for classification of new items

## Technical Approach

### Extending the Item Classification System

We'll enhance the current ItemCategory system to recognize and classify all gear types across the 16 armor slots:

```lua
-- Example of extended categories with material distinctions
if category == "ChestPlate" then
    return lcName:find("plate") ~= nil
            or lcName:find("cuirass") ~= nil
            or lcName:find("breastplate") ~= nil
end

if category == "ChainmailTorso" then
    return lcName:find("mail") ~= nil
            or lcName:find("hauberk") ~= nil
            or lcName:find("chainmail") ~= nil
end

if category == "Gambeson" then
    return lcName:find("gambeson") ~= nil
            or lcName:find("arming") ~= nil and lcName:find("doublet") ~= nil
            or lcName:find("aketon") ~= nil
            or lcName:find("padded") ~= nil and lcName:find("jacket") ~= nil
end

-- Required layering dependencies
IsBaseLayerFor = function(self, category, targetCategory)
    if targetCategory == "Helmet" then
        return category == "Coif"
    elseif targetCategory == "ChestPlate" then
        return category == "Gambeson"
    elseif targetCategory == "LegPlate" then
        return category == "QuilledHose"
    end
    return false
end
```

### Comprehensive Gear Stats Collection

We'll expand stats collection to include all relevant properties:

```lua
collectGearStats = function(self, inventoryItem)
    local item = self.itemManager.GetItem(inventoryItem)
    local stats = {
        -- Defensive stats
        stabDefense = item:GetStabDefense() or 0,
        slashDefense = item:GetSlashDefense() or 0,
        bluntDefense = item:GetBluntDefense() or 0,
        
        -- Stealth stats
        noise = item:GetNoiseValue() or 0,
        visibility = item:GetVisibilityValue() or 0,
        conspicuousness = item:GetConspicuousnessValue() or 0,
        
        -- Social and utility stats
        charisma = item:GetCharismaValue() or 0,
        weight = item:GetWeight() or 0,
        durability = item:GetDurability() or 0,
        condition = item:GetCondition() or 0,
        dirtLevel = item:GetDirtLevel() or 0,
        bloodLevel = item:GetBloodLevel() or 0,
        
        -- Material properties
        material = self:determineItemMaterial(item),
        isOuter = self:isOuterLayer(item),
        requiredUnderlayer = self:getRequiredUnderlayer(item)
    }
    return stats
end
```

### Layered Optimization Algorithm Structure

Example structure for stealth optimization that respects layering requirements:

```lua
optimizeForStealth = function(self)
    -- Collect all gear pieces
    local allGear = self:getAllGearBySlot()
    local bestSetup = {}
    local layeringRequirements = {}
    
    -- First pass: Find minimal noise items for each slot
    for slot, pieces in pairs(allGear) do
        local bestPiece = nil
        local lowestNoise = math.huge
        
        for _, piece in ipairs(pieces) do
            local stats = self:getGearStats(piece)
            -- Prioritize noise first for stealth
            if stats.noise < lowestNoise then
                lowestNoise = stats.noise
                bestPiece = piece
                
                -- Track layering requirements
                if stats.requiredUnderlayer then
                    layeringRequirements[slot] = stats.requiredUnderlayer
                end
            end
        end
        
        if bestPiece then
            bestSetup[slot] = bestPiece
        end
    end
    
    -- Second pass: Ensure all required underlayers are present
    for slot, requiredType in pairs(layeringRequirements) do
        local underlayerSlot = self:getSlotForCategory(requiredType)
        if not bestSetup[underlayerSlot] then
            -- Find the quietest underlayer of required type
            local bestUnderlayer = self:findBestItemOfCategory(requiredType, "noise", "lowest")
            if bestUnderlayer then
                bestSetup[underlayerSlot] = bestUnderlayer
            end
        end
    end
    
    -- Final optimization pass for visibility and conspicuousness
    self:optimizeVisualStealth(bestSetup)
    
    -- Equip the optimal set
    self:equipGearSet(bestSetup)
end
```

## Project Timeline

1. **Phase 1: Foundation (3-4 weeks)**
   - Complete system analysis and armor mechanics documentation
   - Implement comprehensive gear detection for all 16 slots
   - Create layering dependency tracking
   - Develop detailed stat tracking mechanisms for all armor properties

2. **Phase 2: Core Features (4-5 weeks)**
   - Implement the three optimization algorithms with layering requirements
   - Create gear swapping functionality that respects dependencies
   - Test and refine core functionality with different gear combinations

3. **Phase 3: User Interface (2-3 weeks)**
   - Add command system
   - Implement profile management
   - Create configuration options

4. **Phase 4: Advanced Features (3-4 weeks)**
   - Add situation detection
   - Implement compatibility enhancements
   - Conduct extensive testing

Total estimated timeline: 12-16 weeks for full implementation