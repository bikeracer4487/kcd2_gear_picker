
## Changelog

### 1.3.4 26-march-25
- fix: Gear is now equipped when the trading menu is opened
- fix: Gear take off is skipped when interacting with NPCs offering bathhouse services
- fix: Ranged weapons take off is skipped when interacting with NPCs offering archery competition.

### 1.3.3 22-march-25
- fix: Wait until after Henry some equipped gear before attempting to put back on previously take off gear.

### 1.3.2 19-march-25
- fix: Resolved issue in "Easy Riders" quest where progress was blocked due to helmet being removed; helmet now remains equipped, enabling uninterrupted sparring with Hans.

### 1.3.1 17-march-25
- fix: Crossbow are properly detected, allowing the player to use them.
- fix: Compatability with Steam Workshop, NexusMods, and KCD 1.
- fix: Improve probability of random mod to disable the equipment takes offs. 
 
### 1.3.0 16-Mar-25
- feat: Added support for helmet removal during cutscenes and dialogues initiated by NPCs.
- feat: Added support for helmet removal when talking to Mutt in KCD 1.

### 1.2.2 16-Mar-25
- fix: Fixed an issue where the mod was not ready to handle the on talk events.
 
### 1.2.1 16-Mar-25
- feat: Support for KCD 1 & Steam Workshop for the new structure supporting multiple optional mods.

### 1.2.0 16-Mar-25
- feat: The previous mod variants have been replaced with optional mods, enabling simultaneous use.
- feat: The main version is now mandatory, while the previous variants have been converted into optional mods.
- feat: Optional takeoff features, including helmet-only, random gear, and ranged weapon takeoffs, can now be loaded on demand via the optional mods.

### 1.1.1 15-Mar-25
- fix: Use the more reliable equipped weight derived status to check for equip status.

### 1.1.0 10-Mar-25 - New Helmet-Only Variant
- feat: New "Helmet-Only" variant that only takes off helmets, leaving head chainmail (KCD 1) or coifs untouched.

### 1.0.3 07-Mar-25 - Random Variant
- fix: Some helmets weren’t recognized as equipped because of how the game handled stat numbers.

### 1.0.2 07-Mar-25 - Random Variant
- fix: Alternate random variant was not being enabled.

### 1.0.1 07-Mar-25
- fix: Remove visibility derived stat check due to false positives when equipped item was fully washed.

### 1.0.0 03-Mar-25
- feat: UnEquip kettle based helmet, head chainmail for KCD 1, and coifs upon dialog start.
- feat: Equip, previously un-equipped items upon dialog end.
- feat: Random variant: Unequips helmets in random dialogues rather than all of them. For instance, it might remove the helmet in one conversation but keep it on in the next.
