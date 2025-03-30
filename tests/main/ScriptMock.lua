local function mockScript(mock, spy, args)
    local Script = {
        LoadScript = function()
        end,
        SetTimer = function(ms, callback)
           return callback()
        end
    }

    local script = mock(Script, false)

    return script
end

return mockScript