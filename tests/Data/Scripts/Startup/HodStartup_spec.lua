it("loads the mod", function()
    local factory = makeFactory()
    dofile("src/Data/Scripts/Startup/HelmetOffDialog_Startup.lua")
    assert.spy(factory.Script.LoadScript)
          .was
          .called_with("Scripts/HelmetOffDialog/HelmetOffDialog.lua")
end)

it("initializes the mod", function()
    local factory = makeFactory()
    dofile("src/Data/Scripts/Startup/HelmetOffDialog_Startup.lua")
    assert.spy(factory.HelmetOffDialog.init).was.called()
end)

function makeFactory()
    local factory = {}
    _G.Script = { LoadScript = function()
    end }
    local HelmetOffDialog = dofile("src/Data/Scripts/HelmetOffDialog/HelmetOffDialog.lua")
    factory.HelmetOffDialog = mock(HelmetOffDialog, true)
    factory.Script = mock(Script, true)

    return factory
end
