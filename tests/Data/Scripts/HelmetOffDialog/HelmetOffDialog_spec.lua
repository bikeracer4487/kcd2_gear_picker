describe("Config", function()
    it("creates a new instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:config()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.Config.new)
              .was.called_with(
                match.is_ref(factory.HelmetOffDialog.ClassRegistry.Config),
                factory.HelmetOffDialog.MOD_NAME)
    end)

    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.Script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/Config.lua")
    end)
end)

describe("Log", function()
    it("creates a new instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:log()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.Log.new)
              .was.called_with(
                match.is_ref(factory.HelmetOffDialog.ClassRegistry.Log),
                factory.HelmetOffDialog.MOD_NAME,
                factory.HelmetOffDialog:config())
    end)

    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.Script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/utils/Log.lua")
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
    local Log = dofile("src/Data/Scripts/HelmetOffDialog/utils/Log.lua")
    HelmetOffDialog.ClassRegistry.Log = mock(Log, true)
    factory.HelmetOffDialog = HelmetOffDialog
    factory.Script = mock(Script, true)
    _G.Script = Script

    return factory
end