it("loads the mod", function()
    local factory = makeFactory()
    assert.spy(factory.script.LoadScript)
          .was
          .called_with("Scripts/HelmetOffDialog/HelmetOffDialog.lua")
end)

it("initializes the mod for KCD", function()
    local factory = makeFactory()
    assert.spy(factory.helmetOffDialog.init).was.called()
end)

describe("KCD1", function()
    it("it enables the game id", function()
        local factory = makeFactory()
        factory.helmetOffDialog:OnGameplayStartKcdOne()
        assert.is_true(HelmetOffDialog.KCD1)
    end)
    it("registers the on talk events", function()
        local factory = makeFactory()
        factory.helmetOffDialog:OnGameplayStartKcdOne()
        assert.spy(factory.script.LoadScript).was.called_with("Scripts/HelmetOffDialog/RegisterOnTalkEvents.lua")
    end)
    it("registers the trade menu events", function()
        local factory = makeFactory()
        factory.helmetOffDialog:OnGameplayStartKcdOne()
        assert.spy(factory.script.LoadScript).was.called_with("Scripts/HelmetOffDialog/RegisterTradeMenuEvents.lua")
    end)

    it("registers on game play start system event", function()
        local factory = makeFactory()
        assert.spy(factory.uiAction.RegisterEventSystemListener)
              .was.called_with(
                match.is_ref(factory.helmetOffDialog),
                "System",
                "OnGameplayStart",
                "OnGameplayStartKcdOne"
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

    dofile("src/main/Data/Scripts/Startup/HelmetOffDialog_Startup.lua")

    return factory
end
