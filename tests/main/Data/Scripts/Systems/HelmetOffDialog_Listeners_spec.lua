describe("KCD2:", function()
    it("it enables the game id", function()
        local factory = makeFactory()
        factory.helmetOffDialog:OnLoadingCompleteKcdTwo()
        assert.is_true(HelmetOffDialog.KCD2)
    end)
    it("registers the on talk events", function()
        local factory = makeFactory()
        factory.helmetOffDialog:OnLoadingCompleteKcdTwo()
        assert.spy(factory.script.LoadScript).was.called_with("Scripts/HelmetOffDialog/RegisterOnTalkEvents.lua")
    end)
    it("registers the trade menu events", function()
        local factory = makeFactory()
        factory.helmetOffDialog:OnLoadingCompleteKcdTwo()
        assert.spy(factory.script.LoadScript).was.called_with(
                "Scripts/HelmetOffDialog/RegisterTradeMenuEvents.lua"
        )
    end)

    it("registers on loading complete system event", function()
        local factory = makeFactory()
        assert.spy(factory.uiAction.RegisterEventSystemListener)
              .was.called_with(
                match.is_ref(factory.helmetOffDialog),
                "System",
                "OnLoadingComplete",
                "OnLoadingCompleteKcdTwo"
        )
    end)
end)

function makeFactory()
    local factory = {}
    dofile("tests/main/SystemMock.lua")(mock, spy)
    dofile("tests/main/EntityMock.lua")(mock, spy)
    factory.helmetOffDialog = dofile("tests/main/HelmetOffDialogMock.lua")(mock, spy)
    factory.uiAction = dofile("tests/main/UIActionMock.lua")(mock, spy)
    factory.script = dofile("tests/main/ScriptMock.lua")(mock, spy)
    _G.Script = factory.script

    dofile("src/main/Data/Scripts/Systems/HelmetOffDialog_Listeners.lua")

    return factory
end
