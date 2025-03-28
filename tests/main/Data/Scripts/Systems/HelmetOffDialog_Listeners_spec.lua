it("initializes the mod for KCD 2", function()
    local factory = makeFactory()
    HelmetOffDialog:OnLoadingCompleteKcdTwo()
    assert.spy(factory.HelmetOffDialog.init).was.called()
end)

function makeFactory()
    local factory = {}
    local mockSystem = dofile("tests/main/SystemMock.lua")
    _G.System = mockSystem(mock, spy, args)


    _G.Entity = { GetPos = function()
    end }
    _G.UIAction = { RegisterEventSystemListener = function()
    end }
    local HelmetOffDialog = dofile("src/main/Data/Scripts/HelmetOffDialog/HelmetOffDialog.lua")
    factory.HelmetOffDialog = mock(HelmetOffDialog, true)
    _G.HelmetOffDialog = factory.HelmetOffDialog
    dofile("src/main/Data/Scripts/Systems/HelmetOffDialog_Listeners.lua")

    local mockScript = dofile("tests/main/ScriptMock.lua")
    local mockedScript = mockScript(mock, spy)
    factory.Script = mockedScript
    _G.Script = mockedScript

    return factory
end
