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

function makeFactory(args)
    dofile("tests/main/HelmetOffDialogMock.lua")(mock, spy)
    local factory = {}

    local itemManagerArgs = { GetItem = "valid" }
    factory.itemManager = dofile("tests/main/ItemManagerMock.lua")(mock, spy, itemManagerArgs)
    factory.player = dofile("tests/main/PlayerMock.lua")(mock, spy, args)
    local UnequipGear = dofile("src/main/Data/Scripts/HelmetOffDialog/UnequipGear.lua")
    factory.unequipGear = mock(UnequipGear, true)
    factory.unequipGear.takeOff = spy.new(function(self, category, callback)
        if not args then
            return nil
        end

        if args.takeoff_result == 'no_item' then
            return callback(nil)
        end

        if args.takeoff_result == "helmet_item" then
            return callback("mock_helmet")
        end

        if args.takeoff_result == "head_chainmail_item" then
            return callback("mock_head_chainmail")
        end

        if args.takeoff_result == "coif_item" then
            return callback("mock_coif")
        end

        if args.takeoff_result == "first_ranged_item" then
            return callback("mock_first_ranged")
        end

    end)

    local Equipment = dofile("src/main/Data/Scripts/HelmetOffDialog/Equipment.lua")
    factory.equipment = Equipment:new(
            factory.player, factory.unequipGear, factory.itemManager
    )

    return factory
end
