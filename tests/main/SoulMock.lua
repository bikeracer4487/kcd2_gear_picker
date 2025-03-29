local function mockSoul(mock, spy, args)

    local soul = {
        GetMetaRoles = function(self)
            if not args then return {} end
            if args.metaRole == "bathhouse_kcd1" then
                return { "367" }
            end

            if args.metaRole == "bathhouse_kcd2" then
                return { "LAZEBNICE_OBJEDNANI" }
            end

            return { "invalid" }
        end
    }

    return mock(soul, false)
end

return mockSoul