describe("Random variant", function()
    it("takes it off", function()
        local factory = makeFactory({ randomVariant = true, mockMathRandomToTruthy = true })
        factory.onTalkEvent:handle()
        assert.spy(factory.equipment.takeOffHelmet).was_called(1)
    end)
    it("does not take off for non random variant", function()
        local factory = makeFactory({ randomVariant = true, mockMathRandomToTruthy = false })
        factory.onTalkEvent:handle()
        assert.spy(factory.equipment.takeOffHelmet).was_not_called()
    end)
end)

function makeFactory(args)
    local createFactory = dofile("tests/Data/Scripts/HelmetOffDialog/OnTalkEvent_Factory.lua")

    return createFactory(mock, spy, args)
end
