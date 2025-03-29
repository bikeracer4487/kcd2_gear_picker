it("falsy having zero equipped weight", function()
    local factory = makeFactory({ equipped_weight = "zero" })
    local actual = factory.equippedItem:isEquipped(factory.inventoryItem, function(output)
        return output
    end)
    assert.is_false(actual)
end)

function makeFactory(args)
    local factory = {}

    dofile("tests/main/HelmetOffDialogMock.lua")(mock, spy)

    local player = dofile("tests/main/PlayerMock.lua")(mock, spy, args)

    local soulArgs = {}
    if args and args.equipped_weight == "zero" then
        soulArgs.GetDerivedStat = "0"
    end
    player.soul = dofile("tests/main/SoulMock.lua")(mock, spy, soulArgs)
    factory.player = player

    factory.script = dofile("tests/main/ScriptMock.lua")(mock, spy, args)

    local itemManagerArgs = {}
    if args and args.equipped_weight == "zero" then
        itemManagerArgs.GetItem = "valid"
    end
    factory.itemManager = dofile("tests/main/ItemManagerMock.lua")(mock, spy, itemManagerArgs)

    --- @type EquippedItem
    local EquippedItem = dofile("src/main/Data/Scripts/HelmetOffDialog/EquippedItem.lua")
    factory.equippedItem = EquippedItem:new(
            factory.player, factory.script, factory.itemManager
    )

    return factory
end