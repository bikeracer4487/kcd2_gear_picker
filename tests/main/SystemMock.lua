local function mockSystem(mock, spy, args)
    local soul = {
        GetMetaRoles = function(self)
            return args and args.metaRoles or "lorem-ipsum"
        end
    }
    local entity = { soul = soul }
    local System = {
        GetEntityByName = function()
            return entity
        end,

        LogAlways = function()
            return "test"
        end
    }

    local system = mock(System, false)

    return {
        system = system,
    }
end

return mockSystem