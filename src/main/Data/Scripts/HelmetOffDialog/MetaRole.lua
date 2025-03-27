local Log = HelmetOffDialog.Log

--- @class MetaRole
--- @field new fun(self: MetaRole, helmetOffDialog: HelmetOffDialog): MetaRole
--- @field hasBathhouseBooking fun(self, gearCategory: string, entityName: string)
--- @field hasArcheryCompetition fun(self, gearCategory: string, entityName: string)
local MetaRole = {
    new = function(self, helmetOffDialog)
        if helmetOffDialog.__factories.MetaRole then
            return helmetOffDialog.__factories.MetaRole
        end
        local instance = {
            helmetOffDialog = helmetOffDialog
        }
        setmetatable(instance, { __index = self })
        helmetOffDialog.__factories.MetaRole = instance
        Log.info("MetaRole New instance created")
        return instance
    end,

    --- @field is fun(self: MetaRole, entity: string): boolean
    hasBathhouseBooking = function(self, entityName)
        local entity = System.GetEntityByName(entityName)

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
        local entity = System.GetEntityByName(entityName)

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