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
                factory.HelmetOffDialog,
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
                factory.HelmetOffDialog,
                factory.player.actor,
                factory.HelmetOffDialog:equippedItem(),
                factory.HelmetOffDialog:itemCategory(),
                factory.itemManager,
                factory.player.inventory
        )
    end)

    it("loads the script", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:init()
        assert.stub(factory.script.LoadScript)
              .was.called_with("Scripts/HelmetOffDialog/UnequipGear.lua")
    end)
end)

describe("ItemCategory", function()
    it("creates a new instance", function()
        local factory = makeFactory()
        factory.HelmetOffDialog:itemCategory()
        assert.stub(factory.HelmetOffDialog.ClassRegistry.ItemCategory.new)
              .was.called_with(
                match.is_ref(factory.HelmetOffDialog.ClassRegistry.ItemCategory),
                factory.HelmetOffDialog,
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

-- TODO
--it("uses the cached factory", function()
--    local factory = makeFactory()
--    local cachedOnTalkEvent = factory.onTalkEvent:new(
--            factory.helmetOffDialog, factory.player
--    )
--    assert.equal(cachedOnTalkEvent, factory.onTalkEvent)
--end)
--

function makeFactory()
    local player = {
        inventory = { GetInventoryTable = function()
        end },
        actor = {}
    }
    _G.System = {
        LogAlways = function()
        end
    }
    local script = {
        LoadScript = function()
        end
    }
    local itemManager = {
        GetItem = function()
        end
    }

    local factory = {}
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
    UnequipGear = mock(UnequipGear, true)
    UnequipGear.new = spy.new(function(self)
        return UnequipGear
    end)
    HelmetOffDialog.ClassRegistry.UnequipGear = UnequipGear

    local Error = dofile("src/main/Data/Scripts/HelmetOffDialog/utils/Error.lua")
    Error = mock(Error, true)
    Error.new = spy.new(function()
        return Error
    end)
    HelmetOffDialog.ClassRegistry.Error = Error

    factory.HelmetOffDialog = HelmetOffDialog
    factory.script = mock(script, true)
    _G.Script = script
    factory.player = mock(player, true)
    _G.player = player
    factory.itemManager = mock(itemManager, true)
    _G.ItemManager = itemManager

    return factory
end