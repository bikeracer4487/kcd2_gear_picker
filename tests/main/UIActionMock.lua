local function mockUIAction(mock, spy, args)
    local UIAction = { RegisterEventSystemListener = function()
    end }

    local uiAction = mock(UIAction, false)
    _G.UIAction = uiAction

    return uiAction
end

return mockUIAction