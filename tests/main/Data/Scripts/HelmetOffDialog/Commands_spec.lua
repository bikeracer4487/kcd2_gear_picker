describe("random setting", function()
    it("registers the command", function()
        local factory = makeFactory()
        factory.commands:handle()
        assert.spy(factory.system.AddCCommand).was.called_with(
                "helmet_off_dialog__set_random",
                "HelmetOffDialog:setRandom(%line)"
        )
    end)

    it("handles the command", function()
        local factory = makeFactory()
        factory.commands:handle()
        factory.helmetOffDialog:setRandom("setRandom-lorem-ipsum")
        assert.spy(factory.config.setRandom).was.called_with(
                match.is_ref(factory.config),
                "setRandom-lorem-ipsum"
        )
    end)
end)
describe("helmet only setting", function()
    it("registers the command", function()
        local factory = makeFactory()
        factory.commands:handle()
        assert.spy(factory.system.AddCCommand).was.called_with(
                "helmet_off_dialog__set_helmet_only",
                "HelmetOffDialog:setHelmetOnly(%line)"
        )
    end)

    it("handles the command", function()
        local factory = makeFactory()
        factory.commands:handle()
        factory.helmetOffDialog:setHelmetOnly("setHelmetOnly_lorem-ipsum")
        assert.spy(factory.config.setHelmetOnly).was.called_with(
                match.is_ref(factory.config),
                "setHelmetOnly_lorem-ipsum"
        )
    end)
end)

describe("turn off mod setting", function()
    it("registers the command", function()
        local factory = makeFactory()
        factory.commands:handle()
        assert.spy(factory.system.AddCCommand).was.called_with(
                "helmet_off_dialog__set_turn_off",
                "HelmetOffDialog:setTurnOff(%line)"
        )
    end)

    it("handles the command", function()
        local factory = makeFactory()
        factory.commands:handle()
        factory.helmetOffDialog:setTurnOff("setTurnOff_lorem-ipsum")
        assert.spy(factory.config.setTurnOff).was.called_with(
                match.is_ref(factory.config),
                "setTurnOff_lorem-ipsum"
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
