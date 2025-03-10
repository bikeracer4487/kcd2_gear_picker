describe("helmet: ", function()
    it("takes it off, for the random version mod", function()
        local factory = makeFactory({ randomVersion = true, mockMathRandomToTruthy = true })
        factory.onTalkEvent:handle()
        assert.spy(factory.equipment.takeOffHelmet).was_called(1)
    end)
    it("does not take off, for the random version mod", function()
        local factory = makeFactory({ randomVersion = true, mockMathRandomToTruthy = false })
        factory.onTalkEvent:handle()
        assert.spy(factory.equipment.takeOffHelmet).was_not_called()
    end)
end)

function makeFactory(args)
    local createFactory = dofile("tests/Data/Scripts/HelmetOffDialog/OnTalkEvent_Factory.lua")

    return createFactory(mock, spy, args)
end
