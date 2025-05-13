local function mockSystem(mock, spy, args)
    local mockEntity = dofile("tests/main/EntityMock.lua")

    local System = {
        GetEntityByName = function()
            return mockEntity(mock, spy, args)
        end,

        LogAlways = function()
            return "test"
        end,

        GetEntitiesInSphereByClass = function()
            if args and args.metaRole then
                return { mockEntity(mock, spy, { metaRole = args.metaRole }) }
            end

            return {}
        end,
        AddCCommand = function()
        end
    }

    local system = mock(System, false)
    _G.System = system

    return system
end

return mockSystem