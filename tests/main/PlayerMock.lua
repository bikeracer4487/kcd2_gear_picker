local function mockPlayer(mock, spy, args)
    local player = {
        inventory = { GetInventoryTable = function()
        end },
        GetPos = function(self)
            return nil
        end,
        itemManager = dofile("tests/main/ItemManagerMock.lua")(mock, spy, args),
        actor = dofile("tests/main/ActorMock.lua")(mock, spy, args),
        soul = dofile("tests/main/SoulMock.lua")(mock, spy, args),
    }

    return mock(player, false)
end

return mockPlayer