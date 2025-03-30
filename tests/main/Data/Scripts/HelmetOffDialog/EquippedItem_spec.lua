describe("EquippedItem:", function()
    it("detects having zero equipped weight", function()
        local factory = makeFactory({ equipped_weight = "zero" })
        factory.equippedItem:isEquipped(factory.inventoryItem, function(actual)
            assert.is_false(actual)
        end)
    end)

    it("detects having equipped weight changed", function()
        local factory = makeFactory({ equipped_weight = "changed" })
        factory.equippedItem:isEquipped(factory.inventoryItem, function(actual)
            assert.is_true(actual)
        end)
    end)

    it("detects having equipped weight unchanged", function()
        local factory = makeFactory({ equipped_weight = "unchanged" })
        factory.equippedItem:isEquipped(factory.inventoryItem, function(actual)
            assert.is_false(actual)
        end)
    end)
end)

function makeFactory(args)
    local factory = {}

    dofile("tests/main/HelmetOffDialogMock.lua")(mock, spy)

    local player = dofile("tests/main/PlayerMock.lua")(mock, spy, args)

    local soulArgs = {}
    if args and args.equipped_weight == "zero" then
        soulArgs.GetDerivedStat = "0"
    end
    if args and args.equipped_weight == "changed" then
        soulArgs.GetDerivedStat = { "50", "80" }
    end
    if args and args.equipped_weight == "unchanged" then
        soulArgs.GetDerivedStat = { "50", "50" }
    end
    player.soul = dofile("tests/main/SoulMock.lua")(mock, spy, soulArgs)
    player.actor = dofile("tests/main/ActorMock.lua")(mock, spy, soulArgs)
    factory.player = player

    factory.script = dofile("tests/main/ScriptMock.lua")(mock, spy, args)

    local itemManagerArgs = {}
    if args and args.equipped_weight == "zero" then
        itemManagerArgs.GetItem = "valid"
    end
    if args and args.equipped_weight == "changed" then
        itemManagerArgs.GetItem = "changed"
    end
    if args and args.equipped_weight == "unchanged" then
        itemManagerArgs.GetItem = "unchanged"
    end
    factory.itemManager = dofile("tests/main/ItemManagerMock.lua")(mock, spy, itemManagerArgs)

    --- @type EquippedItem
    local EquippedItem = dofile("src/main/Data/Scripts/HelmetOffDialog/EquippedItem.lua")
    factory.equippedItem = EquippedItem:new(
            factory.player, factory.script, factory.itemManager
    )

    return factory
end