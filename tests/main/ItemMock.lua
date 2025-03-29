local function mockItem(mock, spy, args)
    local Item = {
    }

    local item = mock(Item, false)

    return item

end

return mockItem