local function mockActor(mock, spy, args)
    local Actor = {
        UnequipInventoryItem = function()
        end
    }

    return mock(Actor, false)
end

return mockActor