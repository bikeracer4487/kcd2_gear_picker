local Log = HelmetOffDialog.Log

--- @class Error
--- @field new fun(self: Error): Error
--- @field catch fun(self: Error, func: function, ...): boolean, any
local Error = {
    new = function(self)
        if HelmetOffDialog.__factories.error then
            return HelmetOffDialog.__factories.error
        end
        local instance = {}
        setmetatable(instance, { __index = self })
        HelmetOffDialog.__factories.error = instance
        return instance
    end,
    catch = function(self, func, ...)
        local success, result = pcall(func, ...)
        if not success then
            local stackTrace = debug.traceback(tostring(result))
            Log.error(tostring(stackTrace))
        end
        return success, result
    end
}

_G.HelmetOffDialog.ClassRegistry.Error = Error

return Error