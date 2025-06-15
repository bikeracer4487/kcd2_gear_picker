Script.ReloadScript( "Scripts/Entities/WH/UsableItem.lua")

ForgeBuilderTrigger =
{
	Properties =
	{
	},

	Editor =
	{
		Icon = "animobject.bmp",
	},

	bUseTrigger = true
}

-- =============================================================================
function ForgeBuilderTrigger:GetActions(user, firstFast)
	output = {}

	if ForgeBuilder.CanUse(user.id, self.id) == 1 and not user.soul:HasScriptContext("minigame_disabledForgeBuilder") then
		local canUseMinigame = Minigame.CanUseMinigame(user.id);
		AddInteractorAction( output, firstFast, Action():hint( "ui_start_forge_builder" ):action( "use" ):interaction( inr_forgeBuilder ):func( ForgeBuilderTrigger.OnUsed ):enabled(canUseMinigame) )
	end

	return output
end

-- =============================================================================
function ForgeBuilderTrigger:OnUsed( user, slot )
	ForgeBuilder.StartMinigame(user.id, self.id);
end

-- =============================================================================
-- Compose entity
-- =============================================================================
EntityCommon.DeriveOverride(ForgeBuilderTrigger, UsableItem);