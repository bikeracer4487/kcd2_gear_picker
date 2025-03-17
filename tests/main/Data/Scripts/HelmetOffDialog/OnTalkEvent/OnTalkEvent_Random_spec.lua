it("takes off helmet having a truthy random", function()
    local factory = makeFactory({ target = "random", mockMathRandomToTruthy = true })
    factory.onTalkEvent:handle()
    assert.spy(factory.equipment.takeOffHelmet).was_called(1)
end)

it("does not take off helmet having a falsy random", function()
    local factory = makeFactory({ target = "random", mockMathRandomToTruthy = false })
    factory.onTalkEvent:handle()
    assert.spy(factory.equipment.takeOffHelmet).was_not_called()
end)

it("does not trigger the helmet only feature", function()
end)

it("does not trigger the ranged feature", function()
end)

function makeFactory(args)
    local createFactory = dofile("tests/main/Data/Scripts/HelmetOffDialog/OnTalkEvent/OnTalkEvent_Factory.lua")

    return createFactory(mock, spy, args)
end
