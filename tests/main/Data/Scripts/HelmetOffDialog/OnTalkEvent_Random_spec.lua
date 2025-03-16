describe("Random", function()
    it("takes it off", function()
        local factory = makeFactory({ target = "random", mockMathRandomToTruthy = true })
        factory.onTalkEvent:handle()
        assert.spy(factory.equipment.takeOffHelmet).was_called(1)
    end)
    it("does not take off for non random target", function()
        local factory = makeFactory({ target = "random", mockMathRandomToTruthy = false })
        factory.onTalkEvent:handle()
        assert.spy(factory.equipment.takeOffHelmet).was_not_called()
    end)
end)

function makeFactory(args)
    local createFactory = dofile("tests/main/Data/Scripts/HelmetOffDialog/OnTalkEvent_Factory.lua")

    return createFactory(mock, spy, args)
end
