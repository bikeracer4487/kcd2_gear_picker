--- @class Equipment
--- @field new fun(self: Equipment, helmetOffDialog: HelmetOffDialog, log: Log, player: _G.player, equippedItem: EquippedItem, itemCategory: ItemCategory, unequipGear: UnequipGear): Equipment
--- @field putOnCoif fun(self: Equipment)
--- @field putOnHelmet fun(self: Equipment)
--- @field putOnHeadChainmail fun(self: Equipment)
--- @field putOnFirstRangedWeapon fun(self: Equipment)
--- @field putOnSecondRangedWeapon fun(self: Equipment)
--- @field log Log
--- @field unequipGear UnequipGear
local Equipment = {
    new = function(self, helmetOffDialog, log, player, unequipGear)
        log:info("Equipment.new")
        if helmetOffDialog.__factories.equipment then
            return helmetOffDialog.__factories.equipment
        end
        local instance = {
            log = log,
            player = player,
            unequipGear = unequipGear,
            helmetOffDialog = helmetOffDialog,
            unequippedHelmet = nil,
            unequippedHeadChainmail = nil,
            unequippedCoif = nil,
            firstRangedWeapon = nil,
            secondRangedWeapon = nil
        }
        setmetatable(instance, { __index = self })
        helmetOffDialog.__factories.equipment = instance
        log:info("Equipment New instance created")
        return instance
    end,

    putOnHelmet = function(self)
        self.log:info("Equipment.putOnHelmet")
        if self.unequippedHelmet then
            self.player.actor:EquipInventoryItem(self.unequippedHelmet)
            self.unequippedHelmet = nil
        end
    end,

    putOnHeadChainmail = function(self)
        self.log:info("Equipment.putOnHeadChainmail")
        if self.unequippedHeadChainmail then
            self.player.actor:EquipInventoryItem(self.unequippedHeadChainmail)
            self.unequippedHeadChainmail = nil
        end
    end,

    putOnCoif = function(self)
        self.log:info("Equipment.putOnCoif")
        if self.unequippedCoif then
            self.player.actor:EquipInventoryItem(self.unequippedCoif)
            self.unequippedCoif = nil
        end
    end,

    takeOffHelmet = function(self, callback)
        --- @type Equipment
        local this = self
        this.log:info("Equipment.takeOffHelmet")
        this.unequipGear:takeOff("Helmet", function(unequippedHelmet)
            if unequippedHelmet then
                self.unequippedHelmet = unequippedHelmet
            end
            callback()
        end)
    end,

    takeOffHeadChainmail = function(self, callback)
        self.log:info("Equipment.takeOffHeadChainmail")
        self.unequipGear:takeOff("HeadChainmail", function(unequippedHeadChainmail)
            if unequippedHeadChainmail then
                self.unequippedHeadChainmail = unequippedHeadChainmail
            end
            callback()
        end)
    end,

    takeOffCoif = function(self, callback)
        self.log:info("Equipment.takeOffCoif")
        self.unequipGear:takeOff("Coif", function(unequippedCoif)
            if unequippedCoif then
                self.unequippedCoif = unequippedCoif
            end
            callback()
        end)
    end,

    takeOffFirstRangedWeapon = function(self, callback)
        self.log:info("Equipment.takeOffFirstRangedWeapon")
        self.unequipGear:takeOff("RangedWeapon", function(unequippedRangedWeapon)
            if unequippedRangedWeapon then
                self.firstRangedWeapon = unequippedRangedWeapon
            end
            callback()
        end)
    end,
    takeOffSecondRangedWeapon = function(self, callback)
        self.log:info("Equipment.takeOffSecondRangedWeapon")
        self.unequipGear:takeOff("RangedWeapon", function(unequippedRangedWeapon)
            if unequippedRangedWeapon then
                self.secondRangedWeapon = unequippedRangedWeapon
            end
            callback()
        end)
    end,

    putOnFirstRangedWeapon = function(self)
        self.log:info("Equipment.putOnFirstRangedWeapon")
        if self.firstRangedWeapon then
            self.player.actor:EquipInventoryItem(self.firstRangedWeapon)
            self.firstRangedWeapon = nil
        end
    end,
    putOnSecondRangedWeapon = function(self)
        self.log:info("Equipment.putOnSecondRangedWeapon")
        if self.secondRangedWeapon then
            self.player.actor:EquipInventoryItem(self.secondRangedWeapon)
            self.secondRangedWeapon = nil
        end
    end,

}

_G.HelmetOffDialog.ClassRegistry.Equipment = Equipment

return Equipment