local function mockItemManager(mock, spy, args)
    local ItemManager = {
        GetItem = function()
            if args and args.GetItem == "invalid" then
                return false
            end

            if args and args.name then
                return dofile("tests/main/ItemMock.lua")(mock, spy, args)
            end
        end,
        GetItemName = function()
            if args and args.name then
                return args.name
            end
        end,
        GetItemUIName = function()
            if args and args.name then
                return "ui_" .. args.name
            end
        end
    }

    local itemManager = mock(ItemManager, false)

    return itemManager

end

return mockItemManager