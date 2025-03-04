it("starts the mod", function()
    local factory = makeFactory()
    dofile("src/Data/Scripts/Startup/hod_startup.lua")
    assert.spy(factory.Script.LoadScript)
          .was
          .called_with("Scripts/helmet_off_dialog/helmet_off_dialog.lua")
end)

function makeFactory()
    _G.Script = { LoadScript = function()
    end }
    factory = {}
    factory.Script = mock(Script, true)

    return factory
end
