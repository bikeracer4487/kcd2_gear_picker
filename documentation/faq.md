### Frequently Asked Questions

#### Is the mod (KCD2) on Steam Workshop?
Yes, it’s uploaded.

#### How do I install it?
Use Vortex Mod Manager or extract the contents of the mod into the `{Game}\Mods` folder.

#### Why does it remove helmets in quests, blocking progress (KCD2) ?
Helmets or ranged weapons are removed during a particular quest (e.g., sparring with Hans), halting progression when the quest requires them to remain equipped. As of game version 1.2 (March 13, 2025), the unexposed QuestSystem prevents direct fixes. A potential solution is in progress, possibly linked to how the game handles equipment requirements for this quest, though this is still under review.

#### Why aren’t some helmets detected?
Early versions struggled with helmet detection. Improved in 1.0.3, and the version 1.1.1 (March 15, 2025) uses a better method for head armor identification.

#### Why isn’t my helmet cleaned at baths?
Bathmaids skip helmets since they’re removed. A potential fix is close at hand, involving a check for the NPC name to disable this behavior specifically for bathmaids, with implementation still under final review.

#### Can it remove crossbows/bows instead?
Yes, this is now supported in version 1.2.0 (March 16, 2025).

#### Can it remove just the helmet, not the coif?
Yes, the "Helmet Only" variant (requested by Anders00n and AestheticAdvocate) removes only the helmet.

#### Can I toggle helmet removal in-game?
A hotkey toggle (suggested by 1lllrjsghll1) isn’t available yet due to time constraints but is planned.

#### Why no helmet removal in cutscenes/scripted talks?
As of version 1.3.0 (16-Mar-25), helmet removal in cutscenes or scripted dialogues is now supported.

#### Could you make a mod to keep visor position in cutscenes/dialogues?
Many users have suggested a variant where the visor stays in its manually set position (up or down) during cutscenes and dialogues. This isn’t possible yet, as no relevant API functions exist to control visor state.

#### What about when speaking to Mutt (KCD 1)?
As of version 1.3.0 (16-Mar-25), helmet removal when speaking to Mutt is now supported.