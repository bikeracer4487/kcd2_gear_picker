local function mockScript(mock, spy, args)
    local Script = {
        LoadScript = function()
        end
    }

    local script = mock(Script, true)
    _G.Script = script

    return script
end

return mockScript