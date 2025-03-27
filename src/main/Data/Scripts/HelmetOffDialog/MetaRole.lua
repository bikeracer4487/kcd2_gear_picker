local Log = HelmetOffDialog.Log

--- @class MetaRole
--- @field new fun(self: MetaRole, system: _G.System): MetaRole
--- @field hasBathhouseBooking fun(self, gearCategory: string, entityName: string)
--- @field hasArcheryCompetition fun(self, gearCategory: string, entityName: string)
--- @field system _G.System
local MetaRole = {
    new = function(self, system)
        local instance = { system = system }
        setmetatable(instance, { __index = self })
        Log.info("MetaRole New instance created")
        return instance
    end,

    --- @field is fun(self: MetaRole, entity: string): boolean
    hasBathhouseBooking = function(self, entityName)
        --- @type MetaRole
        local this = self
        local entity = this.system.GetEntityByName(entityName)

        local metaRoles = entity.soul:GetMetaRoles()
        Log.info('GetMetaRoles:', metaRoles)
        local bathhouseBooking = "LAZEBNICE_OBJEDNANI"

        for _, role in ipairs(metaRoles) do
            if role == bathhouseBooking then
                Log.info('Entity serves bath services.')
                return true
            end
        end

        return false
    end,

    --- @field is fun(self: MetaRole, entityName: string): boolean
    hasArcheryCompetition = function(self, entityName)
        --- @type MetaRole
        local this = self
        local entity = this.system.GetEntityByName(entityName)

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