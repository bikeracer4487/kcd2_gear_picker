local function mockActor(mock, spy, args)
    local actor = {
        UnequipInventoryItem = function(self, item)
            return 'lorem'
        end,
        EquipInventoryItem = function(self, item)
            return 'lorem'
        end
    }

    return mock(actor, false)
end

return mockActor