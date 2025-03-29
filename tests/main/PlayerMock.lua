local function mockPlayer(mock, spy, args)
    local player = {
        inventory = { GetInventoryTable = function()
        end },
        actor = {},
        itemManager = {
            GetItem = function()
            end
        },
        GetPos = function(self)
            return nil
        end
    }
    player.soul = dofile("tests/main/SoulMock.lua")(mock, spy, args)

    return mock(player, false)
end

return mockPlayer