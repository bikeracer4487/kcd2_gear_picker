function mockUnequipGear(mock, spy, args)
    local UnequipGear = dofile("src/main/Data/Scripts/HelmetOffDialog/UnequipGear.lua")
    local unequipGear = mock(UnequipGear, true)
    unequipGear.takeOff = spy.new(function(self, category, callback)
        if not args then
            return nil
        end

        if args.takeoff_result == 'no_item' then
            return callback(nil)
        end

        if args.takeoff_result == "helmet_item" then
            return callback("mock_helmet")
        end

        if args.takeoff_result == "head_chainmail_item" then
            return callback("mock_head_chainmail")
        end

        if args.takeoff_result == "coif_item" then
            return callback("mock_coif")
        end

        if args.takeoff_result == "first_ranged_item" then
            return callback("mock_first_ranged")
        end

        if args.takeoff_result == "second_ranged_item" then
            return callback("mock_second_ranged")
        end

    end)

    return unequipGear
end

return mockUnequipGear