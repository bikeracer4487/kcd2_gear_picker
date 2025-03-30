describe("takeOffHelmet", function()
    it("stores unequipped item", function()
        local factory = makeFactory({ takeoff_result = "helmet_item" })
        factory.equipment:takeOffHelmet(function()
        end)
        assert.are_equal("mock_helmet", factory.equipment.unequippedHelmet)
    end)

    it("does not store having no unequipped item", function()
        local factory = makeFactory({ takeoff_result = "no_item" })
        factory.equipment:takeOffHelmet(function()
        end)
        assert.is_nil(factory.equipment.unequippedHelmet)
    end)

    it("calls the callback", function()
        local factory = makeFactory({ takeoff_result = "no_item" })
        local actual
        factory.equipment:takeOffHelmet(function(callback)
            actual = callback
        end)
        assert.are_equal("done", actual)
    end)
end)

describe("takeOffHeadChainmail", function()
    it("stores unequipped item", function()
        local factory = makeFactory({ takeoff_result = "head_chainmail_item" })
        factory.equipment:takeOffHeadChainmail(function()
        end)
        assert.are_equal("mock_head_chainmail", factory.equipment.unequippedHeadChainmail)
    end)

    it("does not store having no unequipped item", function()
        local factory = makeFactory({ takeoff_result = "no_item" })
        factory.equipment:takeOffHeadChainmail(function()
        end)
        assert.is_nil(factory.equipment.unequippedHeadChainmail)
    end)

    it("calls the callback", function()
        local factory = makeFactory({ takeoff_result = "head_chainmail_item" })
        local actual
        factory.equipment:takeOffHeadChainmail(function(callback)
            actual = callback
        end)
        assert.are_equal("done", actual)
    end)
end)

describe("takeOffCoif", function()
    it("stores unequipped item", function()
        local factory = makeFactory({ takeoff_result = "coif_item" })
        factory.equipment:takeOffCoif(function()
        end)
        assert.are_equal("mock_coif", factory.equipment.unequippedCoif)
    end)

    it("does not store having no unequipped item", function()
        local factory = makeFactory({ takeoff_result = "no_item" })
        factory.equipment:takeOffCoif(function()
        end)
        assert.is_nil(factory.equipment.unequippedCoif)
    end)

    it("calls the callback", function()
        local factory = makeFactory({ takeoff_result = "coif_item" })
        local actual
        factory.equipment:takeOffCoif(function(callback)
            actual = callback
        end)
        assert.are_equal("done", actual)
    end)
end)

describe("takeOffFirstRangedWeapon", function()
    it("stores unequipped item", function()
        local factory = makeFactory({ takeoff_result = "first_ranged_item" })
        factory.equipment:takeOffFirstRangedWeapon(function()
        end)
        assert.are_equal("mock_first_ranged", factory.equipment.firstRangedWeapon)
    end)

    it("does not store having no unequipped item", function()
        local factory = makeFactory({ takeoff_result = "no_item" })
        factory.equipment:takeOffFirstRangedWeapon(function()
        end)
        assert.is_nil(factory.equipment.firstRangedWeapon)
    end)

    it("calls the callback", function()
        local factory = makeFactory({ takeoff_result = "first_ranged_item" })
        local actual
        factory.equipment:takeOffFirstRangedWeapon(function(callback)
            actual = callback
        end)
        assert.are_equal("done", actual)
    end)
end)

describe("takeOffSecondRangedWeapon", function()
    it("stores unequipped item", function()
        local factory = makeFactory({ takeoff_result = "second_ranged_item" })
        factory.equipment:takeOffSecondRangedWeapon(function()
        end)
        assert.are_equal("mock_second_ranged", factory.equipment.secondRangedWeapon)
    end)

    it("does not store having no unequipped item", function()
        local factory = makeFactory({ takeoff_result = "no_item" })
        factory.equipment:takeOffSecondRangedWeapon(function()
        end)
        assert.is_nil(factory.equipment.secondRangedWeapon)
    end)

    it("calls the callback", function()
        local factory = makeFactory({ takeoff_result = "second_ranged_item" })
        local actual
        factory.equipment:takeOffSecondRangedWeapon(function(callback)
            actual = callback
        end)
        assert.are_equal("done", actual)
    end)
end)

describe("putOnCoif", function()
    it("equips item", function()
        local factory = makeFactory({ hasUnequippedCoif = true })
        factory.equipment:putOnCoif()
        assert.spy(factory.player.actor.EquipInventoryItem).was.called_with(
                match.is_ref(factory.player.actor),
                factory.unequippedCoif
        )
    end)

    it("resets equipped item", function()
        local factory = makeFactory({ hasUnequippedCoif = true })
        assert.is_not_nil(factory.equipment.unequippedCoif)
        factory.equipment:putOnCoif()
        assert.is_nil(factory.equipment.unequippedCoif)
    end)

    it("aborts having none equipped", function()
        local factory = makeFactory()
        factory.equipment:putOnCoif()
        assert.spy(factory.player.actor.EquipInventoryItem)
              .was_not_called()
    end)
end)

describe("putOnHeadChainmail", function()
    it("equips item", function()
        local factory = makeFactory({ hasUnequippedHeadChainmail = true })
        factory.equipment:putOnHeadChainmail()
        assert.spy(factory.player.actor.EquipInventoryItem).was.called_with(
                match.is_ref(factory.player.actor),
                factory.unequippedHeadChainmail
        )
    end)

    it("resets equipped item", function()
        local factory = makeFactory({ hasUnequippedHeadChainmail = true })
        assert.is_not_nil(factory.equipment.unequippedHeadChainmail)
        factory.equipment:putOnHeadChainmail()
        assert.is_nil(factory.equipment.unequippedHeadChainmail)
    end)

    it("skips equipping having none equipped", function()
        local factory = makeFactory()
        factory.equipment:putOnHeadChainmail()
        assert.spy(factory.player.actor.EquipInventoryItem)
              .was_not_called()
    end)
end)

describe("putOnHelmet", function()
    it("equips item", function()
        local factory = makeFactory({
            hasUnequippedHelmet = true, inventoryHasItem = true
        })
        factory.equipment:putOnHelmet()
        assert.spy(factory.player.actor.EquipInventoryItem).was.called_with(
                match.is_ref(factory.player.actor),
                factory.unequippedHelmet
        )
    end)

    it("resets equipped item", function()
        local factory = makeFactory({ hasUnequippedHelmet = true })
        assert.is_not_nil(factory.equipment.unequippedHelmet)
        factory.equipment:putOnHelmet()
        assert.is_nil(factory.equipment.unequippedHelmet)
    end)

    it("skips equipping having none equipped", function()
        local factory = makeFactory()
        factory.equipment:putOnHelmet()
        assert.spy(factory.player.actor.EquipInventoryItem)
              .was_not_called()
    end)

    it("aborts having no such item in inventory", function()
        local factory = makeFactory({
            hasUnequippedHelmet = true, inventoryHasItem = false
        })
        factory.equipment:putOnHelmet()
        assert.spy(factory.player.actor.EquipInventoryItem)
              .was_not_called()
    end)
end)

describe("putOnFirstRangedWeapon", function()
    it("equips item", function()
        local factory = makeFactory({ hasUnequippedFirstRangedWeapon = true })
        factory.equipment:putOnFirstRangedWeapon()
        assert.spy(factory.player.actor.EquipInventoryItem).was.called_with(
                match.is_ref(factory.player.actor),
                factory.unequippedFirstRangedWeapon
        )
    end)

    it("resets equipped item", function()
        local factory = makeFactory({ hasUnequippedFirstRangedWeapon = true })
        assert.is_not_nil(factory.equipment.unequippedFirstRangedWeapon)
        factory.equipment:putOnFirstRangedWeapon()
        assert.is_nil(factory.equipment.unequippedFirstRangedWeapon)
    end)

    it("skips equipping having none equipped", function()
        local factory = makeFactory()
        factory.equipment:putOnFirstRangedWeapon()
        assert.spy(factory.player.actor.EquipInventoryItem)
              .was_not_called()
    end)
end)

describe("putOnSecondRangedWeapon", function()
    it("equips item", function()
        local factory = makeFactory({ hasUnequippedSecondRangedWeapon = true })
        factory.equipment:putOnSecondRangedWeapon()
        assert.spy(factory.player.actor.EquipInventoryItem).was.called_with(
                match.is_ref(factory.player.actor),
                factory.unequippedSecondRangedWeapon
        )
    end)

    it("resets equipped item", function()
        local factory = makeFactory({ hasUnequippedSecondRangedWeapon = true })
        assert.is_not_nil(factory.equipment.unequippedSecondRangedWeapon)
        factory.equipment:putOnSecondRangedWeapon()
        assert.is_nil(factory.equipment.unequippedSecondRangedWeapon)
    end)

    it("skips equipping having none equipped", function()
        local factory = makeFactory()
        factory.equipment:putOnSecondRangedWeapon()
        assert.spy(factory.player.actor.EquipInventoryItem)
              .was_not_called()
    end)
end)

function makeFactory(args)
    dofile("tests/main/HelmetOffDialogMock.lua")(mock, spy)
    local factory = {}

    local playerArgs = {}
    if args and args.inventoryHasItem ~= nil then
        playerArgs.inventoryArgs = { hasItem = args.inventoryHasItem }
    end

    factory.player = dofile("tests/main/PlayerMock.lua")(mock, spy, playerArgs)
    factory.unequipGear = dofile("tests/main/UnequipGearMock.lua")(mock, spy, args)
    factory.itemManager = dofile("tests/main/ItemManagerMock.lua")(mock, spy, { GetItem = "valid" })

    local Equipment = dofile("src/main/Data/Scripts/HelmetOffDialog/Equipment.lua")
    factory.equipment = Equipment:new(
            factory.player, factory.unequipGear, factory.itemManager
    )
    if args and args.hasUnequippedCoif then
        factory.equipment.unequippedCoif = "coif-lorem-ipsum"
        factory.unequippedCoif = factory.equipment.unequippedCoif
    end

    if args and args.hasUnequippedHeadChainmail then
        factory.equipment.unequippedHeadChainmail = "head-chain-mail-lorem-ipsum"
        factory.unequippedHeadChainmail = factory.equipment.unequippedHeadChainmail
    end

    if args and args.hasUnequippedHelmet then
        factory.equipment.unequippedHelmet = "helmet-lorem-ipsum"
        factory.unequippedHelmet = factory.equipment.unequippedHelmet
    end

    if args and args.hasUnequippedFirstRangedWeapon then
        factory.equipment.unequippedFirstRangedWeapon = "FirstRangedWeapon-lorem-ipsum"
        factory.unequippedFirstRangedWeapon = factory.equipment.unequippedFirstRangedWeapon
    end

    if args and args.hasUnequippedSecondRangedWeapon then
        factory.equipment.unequippedSecondRangedWeapon = "SecondRangedWeapon-lorem-ipsum"
        factory.unequippedSecondRangedWeapon = factory.equipment.unequippedSecondRangedWeapon
    end

    return factory
end
