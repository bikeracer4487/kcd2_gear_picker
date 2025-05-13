local function mockItem(mock, spy, args)
    local Item = { class = "lorem-ipsum" }

    local item = mock(Item, false)

    return item

end

return mockItem