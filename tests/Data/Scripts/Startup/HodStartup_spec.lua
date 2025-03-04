it("starts the mod", function()
    local factory = makeFactory()
    dofile("src/Data/Scripts/Startup/HodStartup.lua")
    assert.spy(factory.Script.LoadScript)
          .was
          .called_with("Scripts/HelmetOffDialog/HelmetOffDialog.lua")
end)

function makeFactory()
    _G.Script = { LoadScript = function()
    end }
    factory = {}
    factory.Script = mock(Script, true)

    return factory
end
