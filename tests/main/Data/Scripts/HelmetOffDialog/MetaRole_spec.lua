describe("hasBathhouseBooking", function()
    it("truthy having a valid role", function()
        local factory = makeFactory({ metaRoles = { "LAZEBNICE_OBJEDNANI" } })
        assert.is_true(factory.metaRole:hasBathhouseBooking(factory.entityName))
    end)
    it("falsy having an invalid role", function()
        local factory = makeFactory({ metaRoles = { "invalid" } })
        assert.is_false(factory.metaRole:hasBathhouseBooking(factory.entityName))
    end)
end)

describe("hasArcheryCompetition", function()
    it("truthy having a valid linked entity", function()
        local factory = makeFactory({ linkedEntity = { "ShootingRange" } })
        assert.is_true(factory.metaRole:hasArcheryCompetition(factory.entityName))
    end)
    it("falsy having no valid linked entity", function()
        local factory = makeFactory({ linkedEntity = { "invalid" } })
        assert.is_false(factory.metaRole:hasArcheryCompetition(factory.entityName))
    end)
end)

function makeFactory(args)
    dofile("src/main/Data/Scripts/HelmetOffDialog/utils/dd.lua")

    local factory = {}
    _G.HelmetOffDialog = { ClassRegistry = {}, Log = { info = function()
    end } }
    local mockSystem = dofile("tests/main/SystemMock.lua")
    local system = mockSystem(mock, spy, args)

    --- @type MetaRole
    local MetaRole = dofile("src/main/Data/Scripts/HelmetOffDialog/MetaRole.lua")
    factory.metaRole = MetaRole:new(system)
    factory.entityName = "lorem-ipsum"

    return factory
end