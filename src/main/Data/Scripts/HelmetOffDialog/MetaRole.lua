--- @class MetaRole
--- @field new fun(self: MetaRole, helmetOffDialog: HelmetOffDialog, log: Log): MetaRole
--- @field is hasBathhouseBooking(self, gearCategory: string, inventoryItem: userdata)
--- @field log Log
local MetaRole = {
    new = function(self, helmetOffDialog, log)
        if helmetOffDialog.__factories.MetaRole then
            return helmetOffDialog.__factories.MetaRole
        end
        local instance = {
            log = log,
            helmetOffDialog = helmetOffDialog
        }
        setmetatable(instance, { __index = self })
        helmetOffDialog.__factories.MetaRole = instance
        log:info("MetaRole New instance created")
        return instance
    end,

    --- @field is fun(self: MetaRole, entity: string): boolean
    hasBathhouseBooking = function(self, entityName)
        --- @type MetaRole
        local this = self
        local log = this.log

        local entity = System.GetEntityByName(entityName)

        local metaRoles = entity.soul:GetMetaRoles()
        log:info('GetMetaRoles:', metaRoles)
        local bathhouseBooking = "LAZEBNICE_OBJEDNANI"

        for _, role in ipairs(metaRoles) do
            if role == bathhouseBooking then
                log:info('Entity serves bath services.')
                return true
            end
        end

        return false
    end
}

_G.HelmetOffDialog.ClassRegistry.MetaRole = MetaRole

return MetaRole