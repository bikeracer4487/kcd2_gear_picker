local function mockPlayer(mock, spy, args)
    local inventoryArgs = args and args.inventoryArgs or {}
    local inventory = dofile("tests/main/InventoryMock.lua")(mock, spy, inventoryArgs)

    local player = {
        inventory = { GetInventoryTable = function()
        end },
        GetPos = function(self)
            return nil
        end,
        itemManager = dofile("tests/main/ItemManagerMock.lua")(mock, spy, args),
        actor = dofile("tests/main/ActorMock.lua")(mock, spy, args),
        soul = dofile("tests/main/SoulMock.lua")(mock, spy, args),
        inventory = inventory
    }

    return mock(player, false)
end

return mockPlayer