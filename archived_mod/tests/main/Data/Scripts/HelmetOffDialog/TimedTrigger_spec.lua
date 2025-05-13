describe("TimedTrigger:", function()
    it("runs callback when check passes", function()
        local factory = makeFactory({ check_result = "pass" })
        factory.timedTrigger:start(1000, factory.checkSpy, factory.runSpy)
        assert.spy(factory.runSpy).was_called(1)
    end)

    it("restarts timer when check fails", function()
        local factory = makeFactory({ check_result = "fail_then_pass" })
        factory.timedTrigger:start(1000, factory.checkSpy, factory.runSpy)
        assert.spy(factory.script.SetTimer).was_called(2)
    end)
end)

function makeFactory(args)
    dofile("tests/main/HelmetOffDialogMock.lua")(mock, spy)
    local factory = {}

    factory.script = dofile("tests/main/ScriptMock.lua")(mock, spy, args)
    factory.checkSpy = spy.new(function()
        if args and args.check_result == "pass" then
            return true
        elseif args and args.check_result == "fail_then_pass" then
            if factory.checkSpy.call_count == nil then
                factory.checkSpy.call_count = 0
            end
            factory.checkSpy.call_count = factory.checkSpy.call_count + 1
            return factory.checkSpy.call_count > 1
        end
        return false
    end)
    factory.runSpy = spy.new(function()
    end)

    local TimedTrigger = dofile("src/main/Data/Scripts/HelmetOffDialog/TimedTrigger.lua")
    factory.timedTrigger = TimedTrigger:new(factory.script)

    return factory
end