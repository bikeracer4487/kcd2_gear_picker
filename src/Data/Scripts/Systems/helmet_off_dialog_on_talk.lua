--
-- TODO: It is unclear actually if the following is required.
-- Need to test if having another mod that uses this action will still be working
--local original_BasicAIActions_onTalk = BasicAIActions.OnTalk;

function BasicAIActions:OnTalk(...)
    local log = HelmetOffDialog:log()
    log:info("BasicAIActions:OnTalk")
    local error = HelmetOffDialog:error()

    error:catch(function()
        local event = HelmetOffDialog:onTalkEvent()
        event:handle()
    end)
    --return original_BasicAIActions_onTalk(self, ...)
end
