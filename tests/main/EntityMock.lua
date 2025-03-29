local function mockEntity(mock, spy, args)
    local mockSoul = dofile("tests/main/SoulMock.lua")

    local linkedEntity = {
        GetName = function(self)
            return args and args.linkedEntity and "LoremShootingRangeIpsum" or nil
        end
    }

    local Entity = {
        GetName = function(self)
            return "ipsum"
        end,
        CountLinks = function(self)
            return args and args.linkedEntity and 1 or 0
        end,
        GetLink = function(self, index)
            return args and args.linkedEntity == "ShootingRange"
                    and linkedEntity or nil
        end,
        GetPos = function(self)
        end
    }
    Entity.soul = mockSoul(mock, spy, args)
    local entity = mock(Entity, false)

    _G.Entity = entity

    return mock(Entity, false)
end

return mockEntity