local function mockEntity(mock, spy, args)
    local mockSoul = dofile("tests/main/SoulMock.lua")

    local Entity = {
        GetName = function(self)
            return "ipsum"
        end,
    }
    Entity.soul = mockSoul(mock, spy, args)

    return mock(Entity, false)
end

return mockEntity