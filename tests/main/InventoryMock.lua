local function mockInventory(mock, spy, args)
    local inventory = {
        HasItem = function()
            return args and args.hasItem
        end
    }

    return mock(inventory, false)

end

return mockInventory