it("truthy on production", function()
    local factory = makeFactory({ isProduction = true })
    assert.is_true(factory.config:isProduction())
end)

it("falsy on dev", function()
    local factory = makeFactory({ isProduction = false })
    assert.is_false(factory.config:isProduction())
end)

function makeFactory(args)
    local mockHelmetOffDialog = dofile("tests/main/HelmetOffDialogMock.lua")
    mockHelmetOffDialog(mock, spy)
    --- @type Config
    local Config = dofile("src/main/Data/Scripts/HelmetOffDialog/Config.lua")
    local environment = args and args.isProduction and "prod" or "dev"
    local config = Config:new(environment)

    return { config = config }
end