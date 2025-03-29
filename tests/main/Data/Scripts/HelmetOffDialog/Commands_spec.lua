describe("turn off mod command", function()
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
        factory.helmetOffDialog:setTurnOff('lorem-ipsum')
        assert.spy(factory.config.setTurnOff).was.called_with(
                match.is_ref(factory.config),
                "lorem-ipsum"
        )
    end)
end)

function makeFactory(args)
    dofile("src/main/Data/Scripts/HelmetOffDialog/utils/dd.lua")

    local factory = {}
    factory.helmetOffDialog = dofile("tests/main/HelmetOffDialogMock.lua")(mock, spy, args)
    --factory.helmetOffDialog = mock(HelmetOffDialog, true)
    --_G.HelmetOffDialog = factory.helmetOffDialog

    local Config = dofile("src/main/Data/Scripts/HelmetOffDialog/Config.lua")
    factory.config = mock(Config, false)

    --local Log = dofile("src/main/Data/Scripts/HelmetOffDialog/utils/Log.lua")
    --local log = mock(Log, true)
    --_G.HelmetOffDialog.Log = log

    factory.system = dofile("tests/main/SystemMock.lua")(mock, spy, args)

    --- @type Commands
    local Commands = dofile("src/main/Data/Scripts/HelmetOffDialog/Commands.lua")
    factory.commands = Commands:new(factory.system, factory.config, factory.helmetOffDialog)

    return factory
end
