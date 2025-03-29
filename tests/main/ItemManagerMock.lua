local function mockItemManager(mock, spy, args)
    local ItemManager = {
        GetItem = function()
            if not args or not args.GetItem then
                return nil
            end

            if args.GetItem == "invalid" then
                return false
            end

            return dofile("tests/main/ItemMock.lua")(mock, spy, args)
        end,
        GetItemName = function()
            if args and args.GetItemName then
                return args.GetItemName
            end
            return "lorem-ipsum"
        end,
        GetItemUIName = function()
            if args and args.GetItemUIName then
                return "ui_" .. args.GetItemUIName
            end
            return "ui_lorem-ipsum"
        end
    }

    local itemManager = mock(ItemManager, false)

    return itemManager

end

return mockItemManager