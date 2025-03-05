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

describe("Equipment", function()
    it("creates a new instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:equipment()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.Equipment.new)
              .was.called_with(
                match.is_ref(factory.HelmetOffDialog.ClassRegistry.Equipment),
                factory.HelmetOffDialog,
                factory.HelmetOffDialog:log(),
                factory.player,
                factory.HelmetOffDialog:unequipGear()
        )
    end)

    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.Script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/Equipment.lua")
    end)
end)

function makeFactory()
    local player = {}
    _G.System = {
        LogAlways = function()
        end
    }
    local Script = {
        LoadScript = function()
        end
    }

    local factory = {}
    local HelmetOffDialog = dofile("src/Data/Scripts/HelmetOffDialog/HelmetOffDialog.lua")

    local Config = dofile("src/Data/Scripts/HelmetOffDialog/Config.lua")
    Config = mock(Config, true)
    Config.new = function(self)
        return Config
    end
    Config.new = spy.new(Config.new)
    HelmetOffDialog.ClassRegistry.Config = Config

    local Log = dofile("src/Data/Scripts/HelmetOffDialog/utils/Log.lua")
    Log = mock(Log, true)
    Log.new = function(self)
        return Log
    end
    Log.new = spy.new(Log.new)
    HelmetOffDialog.ClassRegistry.Log = Log

    local UnequipGear = dofile("src/Data/Scripts/HelmetOffDialog/UnequipGear.lua")
    UnequipGear = mock(UnequipGear, true)
    UnequipGear.new = function(self)
        return UnequipGear
    end
    HelmetOffDialog.ClassRegistry.UnequipGear = UnequipGear

    local ItemCategory = dofile("src/Data/Scripts/HelmetOffDialog/ItemCategory.lua")
    ItemCategory = mock(ItemCategory, true)
    ItemCategory.new = function(self)
        return ItemCategory
    end
    HelmetOffDialog.ClassRegistry.ItemCategory = ItemCategory

    local EquippedItem = dofile("src/Data/Scripts/HelmetOffDialog/EquippedItem.lua")
    EquippedItem = mock(EquippedItem, true)
    EquippedItem.new = function(self)
        return EquippedItem
    end
    EquippedItem.new = spy.new(EquippedItem.new)
    HelmetOffDialog.ClassRegistry.EquippedItem = EquippedItem

    local Equipment = dofile("src/Data/Scripts/HelmetOffDialog/Equipment.lua")
    Equipment = mock(Equipment, true)
    Equipment.new = function(self)
        return Equipment
    end
    Equipment.new = spy.new(Equipment.new)
    HelmetOffDialog.ClassRegistry.Equipment = Equipment

    factory.HelmetOffDialog = HelmetOffDialog
    factory.Script = mock(Script, true)
    factory.player = mock(player, true)
    _G.Script = Script
    _G.player = player

    return factory
end