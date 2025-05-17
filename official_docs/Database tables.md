KCD2 uses a database of 300+ tables to hold most of the game data - items, buffs, perks, NPCs, etc... (see below for full list). These tables are loaded on startup and can never change during gameplay.  
For organizational purposes, tables can be split into multiple parts, which is then called _tableName\_\_partName.xml_. These table parts are loaded together with the table (order in which they are loaded doesn't matter).  
As all game files, tables, and even table parts, can be overwritten by placing identically named file in the mod. However, since many mods need to modify the same tables, this would create conflicts. Therefore we created a special process for patching a table - surgically modifying only a tiny part of the table.

## Patching tables

Patching tables uses the same file format and naming scheme as table parts., except the table part name is identical to **modid**. Such table part is then reffered to as "table patch". Table patches are loaded after all regular table parts are loaded, and are loaded in exact order - the loading order of mods, specified by mod\_order.txt.  
There is one more difference - normal table parts must contain only new entires, while table patches can contain entries with same primary keys as the original table. When this happens, the entry is not added, but replaces (or changes) the original entry. How exactly this works depends on table type.

## Old tables

Simple table format used in KCD1, still used for many tables that didn't change since then. It has a flat structure - each file has just a list of table rows. Relations between tables are handled by junction tables.  
If patching an old table, the table patch must contain the entire row - all properties, even those that the mod doesn't change.  
![old_database.png](https://warhorse.youtrack.cloud/api/files/496-5?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTV8MURmT21EaEhTcU1EUUZpbG1jU1Q5WVlCdWs3NUc3bmhoZjlZS1BxeTl1RQ0K&updated=1738069417525)

## New tables

These are new tables we changed in KCD2. They allow for more complex data structures (lists, maps) directly in one file, without the need for junction tables. Also it is possible for each row to be of different data type (e.g. weapons and armors in same item table - they have some common properties, and some that are unique for each type).  
When patching new table, the entry only needs to have the primary key, and properties that the mod wishes to change. For whatever properties, that are not specified, the value from base game is used (or previously loaded mod, if multiple mods change same table entry).  
![new_database.png](https://warhorse.youtrack.cloud/api/files/496-6?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTZ8c3RoUDJ2a3EycVFfZUVmWHRCZDNfalRiRUt4djdKbVY4VHdEM1RpNEFjNA0K&updated=1738069417525)

Some tables also contain lists, that can be patched on per-item basis, notably the CharacterComponent table, which defines all clothing and armor in game. When patching such list, the original list is retained and new entires are added to the end of the list.  
![obrazek.png](https://warhorse.youtrack.cloud/api/files/496-546?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTU0Nnx3NWV3cUplXzJyeTQzSzB0QWtzZzBWczlJYUw2Ty1XWUtncElyYmlhdTdZDQo&updated=1738069417525)  
(Existing primary keys in green, new unique primary key in purple)

## Other tables

Some tables don't support patching at all. You can still replace the entire file, but this will clash with any other mods that change the same file. Other tables should not be changed at all - some of their values are hardcored in game, and if values in database differ from the ones in code, it will likely introduce bugs. Finally, some tables are left over from previous game, or cut features, and are not used by game at all.

## Full list of tables and their types

| table name | table type |
| --- | --- |
| action/actor\_action\_fragment\_id\_mapping | old |
| action/actor\_action\_standup | old |
| action/actor\_action\_transition\_to\_combat | old |
| action/actor\_action\_type | do not change |
| action/actor\_action\_type\_group | old |
| action/actor\_anim\_action | old |
| action/actor\_side | do not change |
| action/actor\_state | old |
| action/ActorStanceGroups | new |
| action/dog\_action | old |
| action/hit\_reaction | old |
| action/hit\_reaction\_type | do not change |
| ai/ai\_body | old |
| ai/ai\_body2brain\_sensor | unused |
| ai/ai\_body2npc\_reference\_point | unused |
| ai/ai\_enums | new |
| ai/ai\_types | new |
| ai/ai\_variable\_form | do not change |
| ai/ai\_variable\_sync | do not change |
| ai/AIConceptSignalDatabase | new, supported since 1.2 |
| ai/brain | old |
| ai/brain\_interpreter | unused |
| ai/brain\_interpreter\_type | unused |
| ai/brain\_interpreter2brain\_message\_type | unused |
| ai/brain\_message\_type | unused |
| ai/brain\_sensor | unused |
| ai/brain\_sensor\_type | unused |
| ai/brain\_variable | old |
| ai/brain2brain\_interpreter | unused |
| ai/brain2mailbox | old |
| ai/brain2mainbox | old |
| ai/brain2subbrain | old |
| ai/DecisionLabelDatabase | new |
| ai/DeltaMovementParamsDatabase | new |
| ai/DoorAnimSetDatabase | unsupported, must replace whole |
| ai/EventSet | new |
| ai/mailbox | old |
| ai/mailbox\_action\_type | do not change |
| ai/mailbox\_filter | old |
| ai/mailbox\_group | old |
| ai/mailbox\_group2mailbox | old |
| ai/npc\_reference\_point | unused |
| ai/NPCStateActionDatabase | unsupported, must replace whole |
| ai/NPCStateAnyElementPresetDatabase | new |
| ai/NPCStateStanceAnimDatabase | unsupported, must replace whole |
| ai/NPCStateUnstanceDatabase | new |
| ai/NPCStateUnstanceTransitionDatabase | unsupported, must replace whole |
| ai/positioning\_shape | old |
| ai/positioning\_vertex | old |
| ai/ScriptContext | new |
| ai/ScriptContextPreset | new |
| ai/ScriptParams | new |
| ai/se\_condition\_type | do not change |
| ai/SchedulerAlias | new |
| ai/Signature | new |
| ai/situation | old |
| ai/situation\_frequency | old |
| ai/situation\_global\_condition | old |
| ai/situation\_role | old |
| ai/situation\_role\_behavior | old |
| ai/situation\_role\_condition | old |
| ai/situation\_variant | old |
| ai/subbrain | old |
| ai/subbrain\_behaviour\_tree | old |
| ai/subbrain\_dialog | old |
| ai/subbrain\_situation | old |
| ai/subbrain\_smart\_area | old |
| ai/subbrain\_smart\_object | old |
| ai/subbrain\_switching | old |
| ai/subbrain\_type | do not change |
| ai/smartentity/smartEntity | new |
| animation/ai\_fragment\_exclude | old |
| animation/anim\_fragment | old |
| animation/anim\_fragment\_do\_not\_interrupt | unused |
| animation/anim\_fragment\_events | unsupported, must replace whole |
| animation/FragmentIdleStateDatabase | unsupported, must replace whole |
| animation/jump | old |
| animation/ladder | old |
| animation/picking | old |
| combat/CombatAnimationStep | unsupported, must replace whole |
| combat/CombatCombos | unsupported, must replace whole |
| combat/combat\_action\_fragment\_id\_mapping | old |
| combat/combat\_action\_trigger | old |
| combat/combat\_action\_type | old |
| combat/combat\_action\_type\_group | old |
| combat/combat\_action\_type\_mapping | old |
| combat/combat\_attack\_config | old |
| combat/combat\_attack\_hit\_statistics | old |
| combat/combat\_attack\_type | old |
| combat/combat\_attack\_type\_tag | old |
| combat/combat\_damage\_type\_mapping | old |
| combat/combat\_death\_action\_type\_mapping | unsupported, must replace whole |
| combat/combat\_fragment\_meta | unsupported, must replace whole |
| combat/combat\_guard\_stance | old |
| combat/combat\_guard\_type | old |
| combat/combat\_hit\_origin | old |
| combat/combat\_hit\_type | old |
| combat/combat\_input\_class | old |
| combat/combat\_native\_guard\_zone | unsupported, must replace whole |
| combat/combat\_riposte\_chain | unused |
| combat/combat\_riposte\_chain\_step | unused |
| combat/combat\_side | old |
| combat/combat\_tag | do not change |
| combat/combat\_weapon\_combination | unsupported, must replace whole |
| combat/combat\_weapon\_group | old |
| combat/combat\_weapon\_group\_to\_class | old |
| combat/combat\_zone | do not change |
| combat/combat\_zone\_config | old |
| combat/combat\_zone\_distance | old |
| combat/combat\_zone\_mapping | unsupported, must replace whole |
| combat/combat\_zone\_tag | unsupported, must replace whole |
| ControllerFeedback/TriggerEffects | unsupported, must replace whole |
| GameAudio/SkaldAtlRtpc | unsupported, must replace whole |
| GameAudio/SkaldAtlTrigger | unsupported, must replace whole |
| character/bloodMask | new, supported since 1.2 |
| character/ClothingConfig | new, supported since 1.2 |
| character/ClothingFeature | new |
| character/ClothingHidingGroup | new, supported since 1.2 |
| character/ClothingMaterial | new, supported since 1.2 |
| character/ClothingMorph | new, supported since 1.2 |
| character/CharacterComponent | new |
| character/CharacterUberlod | unsupported, must replace whole |
| item/clothing\_preset | new |
| item/InventoryPreset | new |
| item/item | new |
| item/ItemManipulationType | new |
| item/weapon\_class | new |
| item/weapon\_preset | new |
| item/ammo\_class | do not change |
| item/armor\_archetype | old |
| item/armor\_archetype2body\_subpart | old |
| item/armor\_surface | do not change |
| item/armor\_type | old |
| item/attachment\_slot | old |
| item/body\_layer | old |
| item/body\_layer\_type | do not change |
| item/body\_material2subpart | old |
| item/body\_part | old |
| item/body\_subpart | old |
| item/carry\_item\_piles | unsupported, must replace whole |
| item/crafting\_material\_subtype | old |
| item/crafting\_material\_type | old |
| item/dice\_badge\_subtype | old |
| item/dice\_badge\_type | old |
| item/document\_class | old |
| item/DocumentVisualCategory | do not change |
| item/equipment\_part | old |
| item/equipment\_slot | unsupported, must replace whole |
| item/EquipmentPresetFilter | unsupported, must replace whole |
| item/food\_subtype | old |
| item/food\_type | old |
| item/key\_subtype | unused |
| item/key\_type | unused |
| item/misc\_subtype | old |
| item/misc\_type | old |
| item/npc\_tool\_subtype | old |
| item/npc\_tool\_type | old |
| item/ointment\_item\_subtype | old |
| item/ointment\_item\_type | old |
| item/pickable\_area\_desc | old |
| item/pickable\_area\_material | old |
| item/weapon\_attachment\_slot | do not change |
| item/weapon\_attachment\_slot\_category | do not change |
| item/weapon\_sub\_class | old |
| LEVEL/catwaypoints | new |
| LEVEL/dogpoints | new |
| LEVEL/scheduler | new |
| LEVEL/smartobjectanimations | new |
| LEVEL/weatherprofiles | new |
| minigame/AlchemyCrushableSpecialIngredient | new |
| minigame/AlchemyFeedback | new |
| minigame/AlchemyPotionBase | unsupported, must replace whole |
| minigame/AlchemyRecipe | new |
| minigame/AlchemyRecipeStepType | unsupported, must replace whole |
| minigame/BlacksmithRecipes | new |
| minigame/BlacksmithWorkpieces | new |
| music/blacksmith | unsupported, must replace whole |
| music/music\_address\_keyword | unsupported, must replace whole |
| music/music\_matrix | unsupported, must replace whole |
| music/music\_world\_quantity | unsupported, must replace whole |
| music/music\_world\_state\_toggle | unsupported, must replace whole |
| music/PostProcessPreset | unused |
| prefab/prefab\_phase | old |
| prefab/prefab\_phase\_category | old |
| RandomEvent/RandomEventOption | new |
| RandomEvent/RandomEventOptionSet | new |
| RandomEvent/RandomEventTag | new |
| rpg/angriness\_enum | old |
| rpg/angriness\_flag | old |
| rpg/renown\_flag | old |
| rpg/nervousness\_flag | old |
| rpg/relationship\_flag | old |
| rpg/angriness\_type | do not change |
| rpg/barber\_option | old |
| rpg/buff | old |
| rpg/buff\_ai\_tag | new, supported since 1.2 |
| rpg/buff\_class | old |
| rpg/buff\_exclusivity | do not change |
| rpg/buff\_family | unused |
| rpg/buff\_implementation | do not change |
| rpg/buff\_lifetime | do not change |
| rpg/buff\_ui\_type | unused |
| rpg/buff\_ui\_visibility | do not change |
| rpg/combat\_shout\_type | old |
| rpg/companion\_type | do not change |
| rpg/crime | new, supported since 1.2 |
| rpg/dialogue\_sequence\_type\_reward | old |
| rpg/document\_required\_skill | old |
| rpg/document\_requirement | old |
| rpg/document\_reward | old |
| rpg/document\_reward\_perks | old |
| rpg/DocumentRarities | new, supported since 1.2 |
| rpg/faction\_label | old |
| rpg/FactionTree | new, supported since 1.2 |
| rpg/game\_over | old |
| rpg/game\_over\_type | do not change |
| rpg/gender | do not change |
| rpg/horse\_irritation | old |
| rpg/hunting\_role | do not change |
| rpg/location | old |
| rpg/location\_category | do not change |
| rpg/location2perk | old |
| rpg/metarole | old |
| rpg/money\_change | unsupported, must replace whole |
| rpg/morale\_change | old |
| rpg/perk | old |
| rpg/perk\_buff | old |
| rpg/perk\_buff\_override | old |
| rpg/perk\_codex | old |
| rpg/perk\_combat\_technique | old |
| rpg/perk\_companion | old |
| rpg/perk\_recipe | old |
| rpg/perk\_rpg\_param\_override | old |
| rpg/perk\_script | old |
| rpg/perk\_soul\_ability | old |
| rpg/perk\_visibility | do not change |
| rpg/perk2perk\_exclusivity | old |
| rpg/poi\_type | old |
| rpg/poi\_type2perk | old |
| rpg/race | do not change |
| rpg/reading\_spot\_type | old |
| rpg/relationship\_flag | old |
| rpg/renown\_flag | old |
| rpg/reputation\_condition | old |
| rpg/reputation\_change | old |
| rpg/reputation\_change\_target | unused |
| rpg/role | old |
| rpg/rpg\_context\_tag | old |
| rpg/rpg\_context\_type | old |
| rpg/rpg\_damage\_type | unused |
| rpg/rpg\_movement\_type | unsupported, must replace whole |
| rpg/rpg\_param | old |
| rpg/rpg\_sound | old |
| rpg/skill | old |
| rpg/skill\_category | do not change |
| rpg/skill\_check\_difficulty | old |
| rpg/skill\_lesson\_level | new, supported since 1.2 |
| rpg/skill\_teacher | new, supported since 1.2 |
| rpg/skill2item\_category | old |
| rpg/skiptime\_type | do not change |
| rpg/skirmisheventtypes | new, supported since 1.2 |
| rpg/sleeping\_spot\_type | old |
| rpg/social\_class | old |
| rpg/soul | old |
| rpg/SoulPool | new, supported since 1.2 |
| rpg/SoulStateEffectContext | new, supported since 1.2 |
| rpg/stance | unused |
| rpg/stat | old |
| rpg/statistic | old |
| rpg/statistic\_group | old |
| rpg/statistic\_type | do not change |
| rpg/statistic\_unit | unused |
| rpg/xp\_change | old |
| shop/shop | new |
| ui/cutscene | new |
| ui/skiptime | old |
| ui/achievement\_rule\_action | unused |
| ui/codex\_ui\_layout | unused |
| ui/codex\_ui\_page | unused |
| ui/compass\_mark\_type | unused |
| ui/credit\_layout | old |
| ui/credit\_people | old |
| ui/credit\_role | old |
| ui/credit\_role2language\_excl | old |
| ui/ExtraRewardData | unsupported, must replace whole |
| ui/infotext\_category | unused |
| ui/menu\_buttons | unsupported, must replace whole |
| ui/menu\_confirmations | unsupported, must replace whole |
| ui/menu\_choices | unsupported, must replace whole |
| ui/menu\_pages | unsupported, must replace whole |
| ui/skiptime | old |
| ui/trophy\_group | unused |
| ui/PopupTutorial | unsupported, must replace whole |
| ui/ui\_local\_maps | old |
| ui/ui\_map\_label | old |
| ui/video\_language2audio\_track | old |
| /ContentFilterSubstitution | unsupported, must replace whole |
| /CVarOverride | new, supported since 1.2 |
| /dlc | old |
| /editor\_object | unsupported, must replace whole |
| /editor\_object\_binding | unsupported, must replace whole |
| /game\_mode | old |
| /Level | new, supported since 1.2 |
| /LevelSwitch | new, supported since 1.2 |
| /PlatformActivity | unsupported, must replace whole |
| /player | new, supported since 1.2 |
| /time\_of\_day\_profile | new, supported since 1.2 |