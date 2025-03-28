describe("hasBathhouseBooking", function()
    it("truthy having a valid role for KCD1", function()
        local factory = makeFactory({ metaRole = "bathhouse_kcd1" })
        local actual = factory.metaRole:hasBathhouseBooking(factory.entity)
        assert.is_true(actual)
    end)
    it("truthy having a valid role for KCD2", function()
        local factory = makeFactory({ metaRole = "bathhouse_kcd2" })
        assert.is_true(factory.metaRole:hasBathhouseBooking(factory.entity))
    end)
    it("falsy having an invalid role", function()
        local factory = makeFactory({ metaRoles = { "invalid" } })
        assert.is_false(factory.metaRole:hasBathhouseBooking(factory.entity))
    end)
end)

describe("hasArcheryCompetition", function()
    it("truthy having a valid linked entity", function()
        local factory = makeFactory({ linkedEntity = { "ShootingRange" } })
        assert.is_true(factory.metaRole:hasArcheryCompetition(factory.entity))
    end)
    it("falsy having no valid linked entity", function()
        local factory = makeFactory({ linkedEntity = { "invalid" } })
        assert.is_false(factory.metaRole:hasArcheryCompetition(factory.entity))
    end)
end)

function makeFactory(args)
    dofile("src/main/Data/Scripts/HelmetOffDialog/utils/dd.lua")

    local factory = {}
    _G.HelmetOffDialog = { ClassRegistry = {}, Log = { info = function()
    end } }
    local mockSystem = dofile("tests/main/SystemMock.lua")

    local bathhouse = args and args.metaRole or nil

    local system = mockSystem(mock, spy, { bathhouse = bathhouse })

    local mockPlayer = dofile("tests/main/PlayerMock.lua")
    local player = mockPlayer(mock, spy, args)

    --- @type MetaRole
    local MetaRole = dofile("src/main/Data/Scripts/HelmetOffDialog/MetaRole.lua")
    factory.metaRole = MetaRole:new(system, player)

    --- @type _G.Entity
    local mockEntity = dofile("tests/main/EntityMock.lua")
    factory.entity = mockEntity(mock, spy, args)

    return factory
end