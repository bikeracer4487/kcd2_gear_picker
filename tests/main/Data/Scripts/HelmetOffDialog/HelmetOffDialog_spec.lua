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
        assert.stub(factory.script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/Config.lua")
    end)
end)

describe("Log", function()
    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/utils/Log.lua")
    end)
end)

describe("Error", function()
    it("creates a new instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:error()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.Error.new)
              .was.called_with(match.is_ref(factory.HelmetOffDialog.ClassRegistry.Error))
    end)

    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/utils/Error.lua")
    end)
end)

describe("Equipment", function()
    it("creates a new instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:equipment()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.Equipment.new)
              .was.called_with(
                match.is_ref(factory.HelmetOffDialog.ClassRegistry.Equipment),
                factory.player,
                factory.HelmetOffDialog:unequipGear()
        )
    end)

    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/Equipment.lua")
    end)
end)

describe("UnequipGear", function()
    it("creates a new instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:unequipGear()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.UnequipGear.new)
              .was.called_with(
                match.is_ref(factory.HelmetOffDialog.ClassRegistry.UnequipGear),
                factory.player,
                factory.HelmetOffDialog:equippedItem(),
                factory.HelmetOffDialog:itemCategory(),
                factory.itemManager
        )
    end)

    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/UnequipGear.lua")
    end)
end)

describe("TalkEndedEvent", function()
    it("creates a new instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:talkEndedEvent()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.TalkEndedEvent.new)
              .was.called_with(
                match.is_ref(factory.HelmetOffDialog.ClassRegistry.TalkEndedEvent),
                factory.HelmetOffDialog:config(),
                factory.HelmetOffDialog:equipment(),
                factory.HelmetOffDialog:timedTrigger(),
                factory.player
        )
    end)

    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/TalkEndedEvent.lua")
    end)
end)

describe("MetaRole", function()
    it("creates a new instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:metaRole()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.MetaRole.new)
              .was.called_with(
                match.is_ref(factory.HelmetOffDialog.ClassRegistry.MetaRole),
                factory.system
        )
    end)

    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/MetaRole.lua")
    end)
end)

describe("OnTalkEvent", function()
    it("creates a new instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:onTalkEvent()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.OnTalkEvent.new)
              .was.called_with(
                match.is_ref(factory.HelmetOffDialog.ClassRegistry.OnTalkEvent),
                factory.HelmetOffDialog:equipment(),
                factory.HelmetOffDialog:talkEndedEvent(),
                factory.HelmetOffDialog:metaRole(),
                factory.HelmetOffDialog:config()
        )
    end)

    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/OnTalkEvent.lua")
    end)
end)

describe("TimedTrigger", function()
    it("creates a new instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:timedTrigger()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.TimedTrigger.new)
              .was.called_with(
                match.is_ref(factory.HelmetOffDialog.ClassRegistry.TimedTrigger),
                factory.script
        )
    end)

    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/TimedTrigger.lua")
    end)
end)

describe("ItemCategory", function()
    it("creates a new instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:itemCategory()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.ItemCategory.new)
              .was.called_with(
                match.is_ref(factory.HelmetOffDialog.ClassRegistry.ItemCategory),
                factory.itemManager
        )
    end)

    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/ItemCategory.lua")
    end)
end)

describe("EquippedItem", function()
    it("creates a new instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:equippedItem()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.EquippedItem.new)
              .was.called_with(
                match.is_ref(factory.HelmetOffDialog.ClassRegistry.EquippedItem),
                factory.player,
                factory.script
        )
    end)

    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/EquippedItem.lua")
    end)
end)

function makeFactory()
    local factory = {}
    local player = {
        inventory = { GetInventoryTable = function()
        end },
        actor = {}
    }
    local script = {
        LoadScript = function()
        end
    }
    factory.script = mock(script, true)
    _G.Script = script

    local system = {
        GetEntityByName = function()
        end,
        LogAlways = function()
        end
    }
    factory.system = mock(system, true)
    _G.System = system

    local itemManager = {
        GetItem = function()
        end
    }

    local HelmetOffDialog = dofile("src/main/Data/Scripts/HelmetOffDialog/HelmetOffDialog.lua")

    local Config = dofile("src/main/Data/Scripts/HelmetOffDialog/Config.lua")
    Config = mock(Config, true)
    Config.new = function(self)
        return Config
    end
    Config.new = spy.new(Config.new)
    HelmetOffDialog.ClassRegistry.Config = Config

    local Log = dofile("src/main/Data/Scripts/HelmetOffDialog/utils/Log.lua")
    Log = mock(Log, true)
    Log.new = function(self)
        return Log
    end
    Log.new = spy.new(Log.new)
    HelmetOffDialog.ClassRegistry.Log = Log

    local UnequipGear = dofile("src/main/Data/Scripts/HelmetOffDialog/UnequipGear.lua")
    UnequipGear = mock(UnequipGear, true)
    UnequipGear.new = function(self)
        return UnequipGear
    end
    HelmetOffDialog.ClassRegistry.UnequipGear = UnequipGear

    local ItemCategory = dofile("src/main/Data/Scripts/HelmetOffDialog/ItemCategory.lua")
    ItemCategory = mock(ItemCategory, true)
    ItemCategory.new = spy.new(ItemCategory.new)
    HelmetOffDialog.ClassRegistry.ItemCategory = ItemCategory

    local EquippedItem = dofile("src/main/Data/Scripts/HelmetOffDialog/EquippedItem.lua")
    EquippedItem = mock(EquippedItem, true)
    EquippedItem.new = function(self)
        return EquippedItem
    end
    EquippedItem.new = spy.new(EquippedItem.new)
    HelmetOffDialog.ClassRegistry.EquippedItem = EquippedItem

    local Equipment = dofile("src/main/Data/Scripts/HelmetOffDialog/Equipment.lua")
    Equipment = mock(Equipment, true)
    Equipment.new = function(self)
        return Equipment
    end
    Equipment.new = spy.new(Equipment.new)
    HelmetOffDialog.ClassRegistry.Equipment = Equipment

    local UnequipGear = dofile("src/main/Data/Scripts/HelmetOffDialog/UnequipGear.lua")
    local unequipGear = mock(UnequipGear, true)
    unequipGear.new = spy.new(function(self)
        return unequipGear
    end)
    HelmetOffDialog.ClassRegistry.UnequipGear = unequipGear

    local TalkEndedEvent = dofile("src/main/Data/Scripts/HelmetOffDialog/TalkEndedEvent.lua")
    local talkEndedEvent = mock(TalkEndedEvent, true)
    TalkEndedEvent.new = spy.new(function(self)
        return talkEndedEvent
    end)
    HelmetOffDialog.ClassRegistry.TalkEndedEvent = talkEndedEvent

    local MetaRole = dofile("src/main/Data/Scripts/HelmetOffDialog/MetaRole.lua")
    local metaRole = mock(MetaRole, true)
    metaRole.new = spy.new(function()
        return talkEndedEvent
    end)
    HelmetOffDialog.ClassRegistry.MetaRole = MetaRole

    local TimedTrigger = dofile("src/main/Data/Scripts/HelmetOffDialog/TimedTrigger.lua")
    local timedTrigger = mock(TimedTrigger, true)
    timedTrigger.new = spy.new(function()
        return timedTrigger
    end)
    HelmetOffDialog.ClassRegistry.TimedTrigger = TimedTrigger

    local Error = dofile("src/main/Data/Scripts/HelmetOffDialog/utils/Error.lua")
    local error = mock(Error, true)
    error.new = spy.new(function()
        return error
    end)
    HelmetOffDialog.ClassRegistry.Error = error

    local OnTalkEvent = dofile("src/main/Data/Scripts/HelmetOffDialog/OnTalkEvent.lua")
    local onTalkEvent = mock(OnTalkEvent, true)
    onTalkEvent.new = spy.new(function()
        return onTalkEvent
    end)
    HelmetOffDialog.ClassRegistry.OnTalkEvent = onTalkEvent

    factory.HelmetOffDialog = HelmetOffDialog
    factory.player = mock(player, true)
    _G.player = player
    factory.itemManager = mock(itemManager, true)
    _G.ItemManager = itemManager

    return factory
end