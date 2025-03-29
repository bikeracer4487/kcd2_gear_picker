it("truthy on production", function()
    local factory = makeFactory({ isProduction = true })
    assert.is_true(factory.config:isProduction())
end)

it("falsy on dev", function()
    local factory = makeFactory({ isProduction = false })
    assert.is_false(factory.config:isProduction())
end)

it("truthy isRanged", function()
    local factory = makeFactory({ isRanged = true })
    assert.is_true(factory.config:isRanged())
end)

it("falsy isRanged", function()
    local factory = makeFactory()
    assert.is_false(factory.config:isRanged())
end)

it("truthy isRandom", function()
    local factory = makeFactory({ isRandom = true })
    assert.is_true(factory.config:isRandom())
end)

it("falsy isRandom", function()
    local factory = makeFactory()
    assert.is_false(factory.config:isRandom())
end)

it("truthy isHelmetOnly", function()
    local factory = makeFactory({ isHelmetOnly = true })
    assert.is_true(factory.config:isHelmetOnly())
end)

it("default falsy isModOff", function()
    local factory = makeFactory()
    assert.is_false(factory.config:isModOff())
end)

it("truthy isModOff", function()
    local factory = makeFactory({ isModOff = true })
    assert.is_true(factory.config:isModOff())
end)

it("falsy isHelmetOnly", function()
    local factory = makeFactory()
    assert.is_false(factory.config:isHelmetOnly())
end)

it("parses a truthy setting value", function()
    local factory = makeFactory()
    assert.is_true(factory.config:_parseSettingValue("= true"))
end)

it("parses a falsy setting value", function()
    local factory = makeFactory()
    assert.is_false(factory.config:_parseSettingValue("= false"))
end)

function makeFactory(args)
    local mockHelmetOffDialog = dofile("tests/main/HelmetOffDialogMock.lua")
    mockHelmetOffDialog(mock, spy)
    local Config = dofile("src/main/Data/Scripts/HelmetOffDialog/Config.lua")
    local environment = args and args.isProduction and "prod" or "dev"
    --- @type Config
    local config = Config:new(environment)
    config:setRanged(args and args.isRanged and "= true" or "= false")
    config:setRandom(args and args.isRandom and "= true" or "= false")
    config:setHelmetOnly(args and args.isHelmetOnly and "= true" or "= false")

    if args and args.isModOff then
        config:setModOff(args.isModOff == true and "= true" or "= false")
    end

    return { config = config }
end