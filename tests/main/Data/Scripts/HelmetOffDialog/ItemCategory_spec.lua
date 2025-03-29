describe("Helmet", function()
    local test_cases = {
        { name = "lorem-kettle_ipsum", keyword = "kettle" },
        { name = "lorem-bascinet_ipsum", keyword = "bascinet" },
        { name = "lorem-helmet_ipsum", keyword = "helmet" },
        { name = "lorem-skullcap_ipsum", keyword = "skullcap" },
    }

    for _, case in ipairs(test_cases) do
        it("truthy for: " .. case.keyword, function()
            local factory = makeFactory({ name = case.name })
            local actual = factory.itemCategory:is("Helmet", factory.item)
            assert.is_true(actual)
        end)
    end
end)

describe("HeadChainmail", function()
    local test_cases = {
        { name = "lorem-coifmail_ipsum", keyword = "coifmail" },
        { name = "lorem-nm_ca_collar_ipsum", keyword = "nm_ca_collar" },
        { name = "lorem-nm_ca_hood_ipsum", keyword = "nm_ca_hood" },
    }

    for _, case in ipairs(test_cases) do
        it("truthy for: " .. case.keyword, function()
            local factory = makeFactory({ name = case.name })
            local actual = factory.itemCategory:is("HeadChainmail", factory.item)
            assert.is_true(actual)
        end)
    end
end)

describe("Coif", function()
    local test_cases = {
        { name = "lorem-coif_ipsum", keyword = "coif" },
        { name = "lorem-g_hood_ipsum", keyword = "g_hood" },
    }

    for _, case in ipairs(test_cases) do
        it("truthy for: " .. case.keyword, function()
            local factory = makeFactory({ name = case.name })
            local actual = factory.itemCategory:is("Coif", factory.item)
            assert.is_true(actual)
        end)
    end
end)

function makeFactory(args)
    dofile("tests/main/HelmetOffDialogMock.lua")(mock, spy)
    local itemManager = dofile("tests/main/ItemManagerMock.lua")(mock, spy, args)

    local factory = {}
    --- @type ItemCategory
    local ItemCategory = dofile("src/main/Data/Scripts/HelmetOffDialog/ItemCategory.lua")
    factory.itemCategory = ItemCategory:new(itemManager)
    factory.item = item

    return factory
end
