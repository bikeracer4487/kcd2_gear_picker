local function mockSystem(mock, spy, args)
    local linkedEntity = {
        GetName = function(self)
            return args and args.linkedEntity and "LoremShootingRangeIpsum" or nil
        end
    }
    local soul = {
        GetMetaRoles = function(self)
            return args and args.metaRoles or "lorem-ipsum"
        end,
    }
    local entity = {
        soul = soul,
        CountLinks = function(self)
            return args and args.linkedEntity and #args.linkedEntity or 0
        end,
        GetLink = function(self, index)
            return args and args.linkedEntity
                    and args.linkedEntity[1] == "ShootingRange"
                    and linkedEntity or nil
        end
    }

    local System = {
        GetEntityByName = function()
            return entity
        end,

        LogAlways = function()
            return "test"
        end
    }

    local system = mock(System, false)

    return system
end

return mockSystem