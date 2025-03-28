it("loads the mod", function()
    local factory = makeFactory()
    dofile("src/main/Data/Scripts/Systems/HelmetOffDialog_Listeners.lua")
    assert.spy(factory.Script.LoadScript)
          .was
          .called_with("Scripts/HelmetOffDialog/HelmetOffDialog.lua")
end)

it("initializes the mod for KCD 1", function()
    local factory = makeFactory()
    HelmetOffDialog:OnGameplayStartKcdOne()
    assert.spy(factory.HelmetOffDialog.init).was.called()
end)

function makeFactory()
    local factory = {}
    local mockSystem = dofile("tests/main/SystemMock.lua")
    _G.System = mockSystem(mock, spy, args)

    local mockScript = dofile("tests/main/ScriptMock.lua")
    local mockedScript = mockScript(mock, spy)
    _G.Script = mockedScript

    _G.Entity = { GetPos = function()
    end }
    _G.UIAction = { RegisterEventSystemListener = function()
    end }
    _G.HelmetOffDialog = nil
    local HelmetOffDialog = dofile("src/main/Data/Scripts/HelmetOffDialog/HelmetOffDialog.lua")
    factory.HelmetOffDialog = mock(HelmetOffDialog, true)
    factory.Script = mock(Script, true)
    dofile("src/main/Data/Scripts/Startup/HelmetOffDialog_Startup.lua")

    return factory
end
