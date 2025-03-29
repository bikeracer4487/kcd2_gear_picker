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
