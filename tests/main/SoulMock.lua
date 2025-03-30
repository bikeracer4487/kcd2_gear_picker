local function mockSoul(mock, spy, args)
    local derivedStatIndex = 0
    local derivedStatObject = nil

    local soul = {
        GetMetaRoles = function(self)
            if not args then
                return {}
            end
            if args.metaRole == "bathhouse_kcd1" then
                return { "367" }
            end
            if args.metaRole == "bathhouse_kcd2" then
                return { "LAZEBNICE_OBJEDNANI" }
            end
            return { "invalid" }
        end,
        GetDerivedStat = function()
            if not args or args.GetDerivedStat == nil then
                return nil
            end
            local value = args.GetDerivedStat
            if type(value) == "string" then
                return value
            end
            if type(value) == "table" then
                if value ~= derivedStatObject then
                    derivedStatIndex = 0
                    derivedStatObject = value
                end
                derivedStatIndex = derivedStatIndex + 1
                if derivedStatIndex > #value then
                    derivedStatIndex = 1
                end
                return value[derivedStatIndex]
            end
            return nil
        end
    }

    return mock(soul, false)
end

return mockSoul