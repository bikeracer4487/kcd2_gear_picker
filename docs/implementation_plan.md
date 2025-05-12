# Gear Optimization Implementation Plan

## Overview

The Gear Picker mod will use the underlying logic from the Helmet Off Dialog mod but will be completely repurposed to automatically select optimal gear combinations based on different parameters: maximum armor/protection, maximum stealth, and maximum charisma.

## Code Structure

We will focus our implementation exclusively on the code in the `src/main/` directory. The code in `src/helmet_only/`, `src/random/`, and `src/ranged/` will be kept for reference only but will not be used in our implementation.

## Implementation Strategy

### Phase 1: Foundation & Analysis

1. **Extend Item Detection Mechanism**
   - Enhance the existing weight-based detection to work with all gear types
   - Create new ItemCategory definitions for different types of armor and clothing
   - Implement a comprehensive gear scanning system

2. **Gear Stats Analysis**
   - Create a system to analyze and store gear statistics
   - Implement methods to read armor values, noise/visibility values, and charisma values
   - Build a gear database that tracks all items in inventory and their attributes

### Phase 2: Core Optimization Features

1. **Gear Selection Algorithms**
   - Implement Maximum Armor algorithm:
     - Prioritize armor values and protection
     - Consider armor combinations for best overall protection
     - Ensure weight constraints are respected

   - Implement Maximum Stealth algorithm:
     - Minimize noise generation and visibility
     - Prioritize darker clothing and light armor/clothing
     - Balance stealth stats with minimal armor protection

   - Implement Maximum Charisma algorithm:
     - Prioritize charisma bonuses from clothing
     - Consider noble/high-status clothing combinations
     - Balance appearance with adequate protection

2. **Gear Swapping System**
   - Extend Equipment class to swap complete outfits
   - Implement a sequential equipping process
   - Ensure proper inventory handling and weight management

### Phase 3: User Interface & Control

1. **Command System**
   - Create console commands for triggering gear optimization
   - Implement hotkey support for quick outfit swapping
   - Add debug/display commands to show current gear stats

2. **Profile Management**
   - Implement saved profiles for different optimization settings
   - Create custom profile options with mixed priorities
   - Add profile import/export functionality

3. **Configuration Options**
   - Add configuration for optimization priorities
   - Create weight limits and constraints settings
   - Implement toggles for specific gear slots to include/exclude

### Phase 4: Advanced Features

1. **Situation-Based Optimization**
   - Implement auto-detection of stealth situations
   - Add combat awareness to automatically optimize for protection
   - Create social encounter detection for charisma optimization

2. **Compatibility Enhancements**
   - Ensure compatibility with other equipment mods
   - Add support for modded items and custom gear
   - Create an extensible system for classification of new items

## Technical Approach

### Extending the Item Classification System

We'll enhance the current ItemCategory system to recognize and classify all gear types:

```lua
-- Example of extended categories
if category == "ChestArmor" then
    return lcName:find("plate") ~= nil
            or lcName:find("brigandine") ~= nil
            or lcName:find("armor") ~= nil
end

if category == "LightOuterwear" then
    return lcName:find("doublet") ~= nil
            or lcName:find("shirt") ~= nil
            or lcName:find("jupon") ~= nil
end
```

### Gear Stats Collection

We'll add methods to analyze and store gear stats:

```lua
-- Example stats collection for armor pieces
collectGearStats = function(self, inventoryItem)
    local item = self.itemManager.GetItem(inventoryItem)
    local stats = {
        armorValue = item:GetArmorValue() or 0,
        noiseLevel = item:GetNoiseValue() or 0,
        visibility = item:GetVisibilityValue() or 0,
        charisma = item:GetCharismaValue() or 0,
        weight = item:GetWeight() or 0
    }
    return stats
end
```

### Optimization Algorithm Structure

Example structure for armor optimization:

```lua
optimizeForArmor = function(self)
    -- Collect all gear pieces
    local allGear = self:getAllGearBySlot()
    
    -- Calculate best armor combination
    local bestSetup = {}
    
    -- For each slot find the best protection piece
    for slot, pieces in pairs(allGear) do
        local bestPiece = nil
        local bestArmorValue = 0
        
        for _, piece in ipairs(pieces) do
            local stats = self:getGearStats(piece)
            if stats.armorValue > bestArmorValue then
                bestArmorValue = stats.armorValue
                bestPiece = piece
            end
        end
        
        if bestPiece then
            bestSetup[slot] = bestPiece
        end
    end
    
    -- Equip the optimal set
    self:equipGearSet(bestSetup)
end
```

## Project Timeline

1. **Phase 1: Foundation (2-3 weeks)**
   - Complete system analysis
   - Implement basic gear detection enhancements
   - Create initial stat tracking mechanisms

2. **Phase 2: Core Features (3-4 weeks)**
   - Implement the three optimization algorithms
   - Create gear swapping functionality
   - Test and refine core functionality

3. **Phase 3: User Interface (2-3 weeks)**
   - Add command system
   - Implement profile management
   - Create configuration options

4. **Phase 4: Advanced Features (3-4 weeks)**
   - Add situation detection
   - Implement compatibility enhancements
   - Conduct extensive testing

Total estimated timeline: 10-14 weeks for full implementation