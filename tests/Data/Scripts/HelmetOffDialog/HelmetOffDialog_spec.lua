describe("Config", function()
    it("creates a new Config instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:config()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.Config.new)
              .was.called_with(
                match.is_ref(factory.HelmetOffDialog.ClassRegistry.Config),
                factory.HelmetOffDialog.MOD_NAME)
    end)

    it("loads the Config script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.Script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/Config.lua")
    end)
end)

function makeFactory()
    _G.System = {
        LogAlways = function()
        end
    }
    Script = {
        LoadScript = function()
        end
    }

    local factory = {}
    local HelmetOffDialog = dofile("src/Data/Scripts/HelmetOffDialog/HelmetOffDialog.lua")
    local Config = dofile("src/Data/Scripts/HelmetOffDialog/Config.lua")
    HelmetOffDialog.ClassRegistry.Config = mock(Config, true)
    factory.HelmetOffDialog = HelmetOffDialog
    factory.Script = mock(Script, true)
    _G.Script = Script

    return factory
end