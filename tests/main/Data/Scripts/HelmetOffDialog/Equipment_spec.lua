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

function makeFactory(args)
    dofile("tests/main/HelmetOffDialogMock.lua")(mock, spy)
    local factory = {}

    factory.player = dofile("tests/main/PlayerMock.lua")(mock, spy, args)
    local UnequipGear = dofile("src/main/Data/Scripts/HelmetOffDialog/UnequipGear.lua")
    factory.unequipGear = mock(UnequipGear, true)
    factory.unequipGear.takeOff = spy.new(function(self, category, callback)
        if args and args.takeoff_result == "helmet_item" then
            callback("mock_helmet")
        else
            callback(nil)
        end
    end)

    local Equipment = dofile("src/main/Data/Scripts/HelmetOffDialog/Equipment.lua")
    factory.equipment = Equipment:new(factory.player, factory.unequipGear)

    return factory
end
