it("takes off helmet having a truthy random", function()
    local factory = makeFactory({ features = "random", mockMathRandomToTruthy = true })
    factory.onTalkEvent:handle(factory.twinEntity)
    assert.spy(factory.equipment.takeOffHelmet).was_called(1)
end)

it("does not take off helmet having a falsy random", function()
    local factory = makeFactory({ features = "random", mockMathRandomToTruthy = false })
    factory.onTalkEvent:handle(factory.twinEntity)
    assert.spy(factory.equipment.takeOffHelmet).was_not_called()
end)

function makeFactory(args)
    local createFactory = dofile("tests/main/Data/Scripts/HelmetOffDialog/OnTalkEvent/OnTalkEvent_Factory.lua")

    return createFactory(mock, spy, args)
end
