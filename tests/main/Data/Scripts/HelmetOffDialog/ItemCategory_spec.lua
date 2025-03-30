describe("Helmet", function()
    local category = "Helmet"
    local test_cases = {
        { name = "lorem-kettle_ipsum", keyword = "kettle" },
        { name = "lorem-bascinet_ipsum", keyword = "bascinet" },
        { name = "lorem-helmet_ipsum", keyword = "helmet" },
        { name = "lorem-skullcap_ipsum", keyword = "skullcap" },
    }

    for _, case in ipairs(test_cases) do
        it("truthy for: " .. case.keyword, function()
            local factory = makeFactory({ name = case.name })
            local actual = factory.itemCategory:is(category, factory.item)
            assert.is_true(actual)
        end)
    end

    it("falsy for invalid items", function()
        local factory = makeFactory({ name = "invalid" })
        local actual = factory.itemCategory:is(category, factory.item)
        assert.is_false(actual)
    end)
end)

describe("HeadChainmail", function()
    local category = "HeadChainmail"
    local test_cases = {
        { name = "lorem-coifmail_ipsum", keyword = "coifmail" },
        { name = "lorem-nm_ca_collar_ipsum", keyword = "nm_ca_collar" },
        { name = "lorem-nm_ca_hood_ipsum", keyword = "nm_ca_hood" },
    }

    for _, case in ipairs(test_cases) do
        it("truthy for: " .. case.keyword, function()
            local factory = makeFactory({ name = case.name })
            local actual = factory.itemCategory:is(category, factory.item)
            assert.is_true(actual)
        end)
    end

    it("falsy for invalid items", function()
        local factory = makeFactory({ name = "invalid" })
        local actual = factory.itemCategory:is(category, factory.item)
        assert.is_false(actual)
    end)
end)

describe("Coif", function()
    local category = "Coif"
    local test_cases = {
        { name = "lorem-coif_ipsum", keyword = "coif" },
        { name = "lorem-g_hood_ipsum", keyword = "g_hood" },
    }

    for _, case in ipairs(test_cases) do
        it("truthy for: " .. case.keyword, function()
            local factory = makeFactory({ name = case.name })
            local actual = factory.itemCategory:is(category, factory.item)
            assert.is_true(actual)
        end)
    end

    it("falsy for invalid items", function()
        local factory = makeFactory({ name = "invalid" })
        local actual = factory.itemCategory:is(category, factory.item)
        assert.is_false(actual)
    end)
end)

describe("RangedWeapon", function()
    local category = "RangedWeapon"
    local test_cases = {
        { name = "lorem-bow__ipsum", keyword = "bow_" },
        { name = "lorem-crossbow_ipsum", keyword = "crossbow" },
    }

    for _, case in ipairs(test_cases) do
        it("truthy for: " .. case.keyword, function()
            local factory = makeFactory({ name = case.name })
            local actual = factory.itemCategory:is(category, factory.item)
            assert.is_true(actual)
        end)
    end

    it("falsy for invalid items", function()
        local factory = makeFactory({ name = "invalid" })
        local actual = factory.itemCategory:is(category, factory.item)
        assert.is_false(actual)
    end)
end)

it("falsy for unknown categories", function()
    local factory = makeFactory({ GetItem = "invalid", name = "helmet" })
    local actual = factory.itemCategory:is("invalid", factory.item)
    assert.is_false(actual)
end)

function makeFactory(args)
    dofile("tests/main/HelmetOffDialogMock.lua")(mock, spy)
    local itemManagerArgs = {}
    if args and args.name ~= nil then
        itemManagerArgs.GetItem = true
        itemManagerArgs.GetItemName = args.name
        itemManagerArgs.GetItemUIName = args.name
    end
    local itemManager = dofile("tests/main/ItemManagerMock.lua")(mock, spy, itemManagerArgs)

    local factory = {}
    --- @type ItemCategory
    local ItemCategory = dofile("src/main/Data/Scripts/HelmetOffDialog/ItemCategory.lua")
    factory.itemCategory = ItemCategory:new(itemManager)

    return factory
end
