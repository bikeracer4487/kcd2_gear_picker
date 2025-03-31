describe("Commands Ranged Setting:", function()
    it("registers command", function()
        local factory = makeFactory()
        factory.commands:init()
        assert.spy(factory.system.AddCCommand).was.called_with(
                "helmet_off_dialog__set_ranged",
                "HelmetOffDialog:commands():setRanged(%line)",
                "Enables or disables removing ranged weapons."
        )
    end)

    it("handles command", function()
        local factory = makeFactory()
        factory.commands:init()
        factory.commands:setRanged("setRanged-lorem-ipsum")
        assert.spy(factory.config.setRanged).was.called_with(
                match.is_ref(factory.config),
                "setRanged-lorem-ipsum"
        )
    end)
end)

describe("Commands Random Setting:", function()
    it("registers command", function()
        local factory = makeFactory()
        factory.commands:init()
        assert.spy(factory.system.AddCCommand).was.called_with(
                "helmet_off_dialog__set_random",
                "HelmetOffDialog:commands():setRandom(%line)",
                "Turns random gear removal on or off."
        )
    end)

    it("handles command", function()
        local factory = makeFactory()
        factory.commands:init()
        factory.commands:setRandom("setRandom-lorem-ipsum")
        assert.spy(factory.config.setRandom).was.called_with(
                match.is_ref(factory.config),
                "setRandom-lorem-ipsum"
        )
    end)
end)

describe("Commands Helmet-Only Setting:", function()
    it("registers command", function()
        local factory = makeFactory()
        factory.commands:init()
        assert.spy(factory.system.AddCCommand).was.called_with(
                "helmet_off_dialog__set_helmet_only",
                "HelmetOffDialog:commands():setHelmetOnly(%line)",
                "Sets the mod to remove only the helmet, leaving coif and chainmail on."
        )
    end)

    it("handles command", function()
        local factory = makeFactory()
        factory.commands:init()
        factory.commands:setHelmetOnly("setHelmetOnly_lorem-ipsum")
        assert.spy(factory.config.setHelmetOnly).was.called_with(
                match.is_ref(factory.config),
                "setHelmetOnly_lorem-ipsum"
        )
    end)
end)

describe("Commands Mod-Off Setting:", function()
    it("registers command", function()
        local factory = makeFactory()
        factory.commands:init()
        assert.spy(factory.system.AddCCommand).was.called_with(
                "helmet_off_dialog__set_mod_off",
                "HelmetOffDialog:commands():setModOff(%line)",
                "Turns mods on or off."
        )
    end)

    it("handles command", function()
        local factory = makeFactory()
        factory.commands:init()
        factory.commands:setModOff("setModOff_lorem-ipsum")
        assert.spy(factory.config.setModOff).was.called_with(
                match.is_ref(factory.config),
                "setModOff_lorem-ipsum"
        )
    end)
end)

describe("Commands Debug Setting:", function()
    it("registers command", function()
        local factory = makeFactory()
        factory.commands:init()
        assert.spy(factory.system.AddCCommand).was.called_with(
                "helmet_off_dialog__set_debug",
                "HelmetOffDialog:commands():setDebug(%line)",
                "Enables debug mode to output logs to check why gear was or wasn’t removed."
        )
    end)

    it("handles command", function()
        local factory = makeFactory()
        factory.commands:init()
        factory.commands:setDebug("setDebug_lorem-ipsum")
        assert.spy(factory.config.setDebug).was.called_with(
                match.is_ref(factory.config),
                "setDebug_lorem-ipsum"
        )
    end)
end)

function makeFactory(args)
    dofile("src/main/Data/Scripts/HelmetOffDialog/utils/dd.lua")

    local factory = {}
    factory.helmetOffDialog = dofile("tests/main/HelmetOffDialogMock.lua")(mock, spy, args)

    local Config = dofile("src/main/Data/Scripts/HelmetOffDialog/Config.lua")
    factory.config = mock(Config, false)

    factory.system = dofile("tests/main/SystemMock.lua")(mock, spy, args)

    --- @type Commands
    local Commands = dofile("src/main/Data/Scripts/HelmetOffDialog/Commands.lua")
    factory.commands = Commands:new(factory.system, factory.config, factory.helmetOffDialog)

    return factory
end