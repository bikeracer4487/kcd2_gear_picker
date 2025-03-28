local Log = HelmetOffDialog.Log

--- @class MetaRole
--- @field new fun(self: MetaRole, system: _G.System): MetaRole
--- @field hasBathhouseBooking fun(self, gearCategory: string, entityName: string)
--- @field hasArcheryCompetition fun(self, gearCategory: string, entityName: string)
--- @field system _G.System
--- @field player _G.player
local MetaRole = {
    new = function(self, system, player)
        local instance = { system = system, player = player }
        setmetatable(instance, { __index = self })
        Log.info("MetaRole New instance created")
        return instance
    end,

    --- @field is fun(self: MetaRole, entity: string): boolean
    hasBathhouseBooking = function(self, twinEntity)
        --- @type MetaRole
        local this = self
        Log.info("GetName:", twinEntity:GetName())

        local metaRoleIdKcd1 = "367"
        local metaRoleNameKcd2 = "LAZEBNICE_OBJEDNANI"
        local playerPos = this.player:GetPos()
        local nearbyEntities = this.system.GetEntitiesInSphereByClass(
                playerPos, 3, twinEntity.class
        )

        for _, entity in pairs(nearbyEntities) do
            Log.info("Nearby entity" .. entity:GetName())
            local metaRoles = entity.soul:GetMetaRoles()
            Log.info('GetMetaRoles:', metaRoles)
            for _, rawRole in ipairs(metaRoles) do
                local role = tostring(rawRole)
                if role == metaRoleNameKcd2 or role == metaRoleIdKcd1 then
                    Log.info('Entity serves bath services.')
                    return true
                end
            end
        end

        return false
    end,

    --- @field is fun(self: MetaRole, entityName: string): boolean
    --[[
        This function doesn’t handle KCD1 logic, since Henry can join the
        archery contest without a bow equipped. If there is such a need in the
        future, then it should be refactored to follow the same pattern as the
        hasBathhouseBooking function.
    ]]
    hasArcheryCompetition = function(self, entity)
        local countLinks = entity:CountLinks()
        Log.info("countLinks: ", countLinks)

        for index = 0, (countLinks - 1) do
            local link = entity:GetLink(index)
            Log.info("Link:", index, link)
            if link ~= nil then
                local name = link:GetName()
                if string.find(string.lower(name), "shootingrange") then
                    Log.info("Identified an entity with archery competition.")
                    return true
                end
            end
        end

        return false
    end
}

_G.HelmetOffDialog.ClassRegistry.MetaRole = MetaRole

return MetaRole