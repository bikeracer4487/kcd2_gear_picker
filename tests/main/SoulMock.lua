local function mockSoul(mock, spy, args)

    local soul = {
        GetMetaRoles = function(self)
            if args and args.bathhouse_kcd1 then
                return {"367"}
            end
            return {}
        end
    }

    return mock(soul, false)
end

return mockSoul