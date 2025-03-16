## Changelog

### v1.2.0 16-Mar-25
- feat: The previous mod variants have been replaced with optional mods, enabling simultaneous use.
- feat: The main version is now mandatory, while the previous variants have been converted into optional mods.
- feat: Optional takeoff features, including helmet-only, random gear, and ranged weapon takeoffs, can now be loaded on demand via the optional mods.

### v1.1.1 15-Mar-25
- fix: Use the more reliable equipped weight derived status to check for equip status.

### v1.1.0 10-Mar-25 - New Helmet-Only Variant
- feat: New "Helmet-Only" variant that only takes off helmets, leaving head chainmail (KCD 1) or coifs untouched.

### v1.0.3 07-Mar-25 - Random Variant
- fix: Some helmets weren’t recognized as equipped because of how the game handled stat numbers.

### v1.0.2 07-Mar-25 - Random Variant
- fix: Alternate random variant was not being enabled.

### v1.0.1 07-Mar-25
- fix: Remove visibility derived stat check due to false positives when equipped item was fully washed.

### v1.0.0 03-Mar-25
- feat: UnEquip kettle based helmet, head chainmail for KCD 1, and coifs upon dialog start.
- feat: Equip, previously un-equipped items upon dialog end.
- feat: Random variant: Unequips helmets in random dialogues rather than all of them. For instance, it might remove the helmet in one conversation but keep it on in the next.
