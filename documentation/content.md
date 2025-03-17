## Mod Overview
- **Main Version (Required):** Takes off the helmet, head chainmail (KCD 1), and coif at the start of every dialogue and puts them back on when the conversation ends.
  - Install this base mod to enable the core takeoff functionality.
- **Optional Mods:** Enhance the main version with additional takeoff features, which can be loaded on demand. Install any combination of the following optional mods *after* the main version to ensure proper loading (otherwise, you’ll need to manually adjust your `mod_order.txt`):
  - **Helmet-Only:** Takes off only the helmet at the start of every dialogue and puts it back on when the conversation ends, leaving head chainmail (KCD 1) and coif unchanged.
  - **Random:** Takes off the helmet, head chainmail (KCD 1), and coif in random dialogues (e.g., gear might come off in one conversation but stay on in the next).
    - *Player Note:* This reflects my reason for creating this mod—half because I expect I’ll tire of seeing Henry’s face, and half because the helmets are cool to look at, especially when switching between them.
  - **Ranged:** Takes off ranged weapons at the start of dialogues and puts them back on when the conversation ends (requires the main version for gear context).

***

## Coverage

> If you identify any head armour not listed below, please provide their full names as they appear in-game.

- Helmets: `kettle`, `bascinet`, `helmet`, `skullcap`
- Head Chainmail (for KCD 1): `coifmail`, `nm_ca_collar`, `nm_ca_hood`
- Coifs: coif, `coif`, `g_hood_`
- Ranged weapons: `bow_`, `crossbow`


## Caveats

- **Charisma Impact**: Taking off the helmet or coif during dialogue will probably lower charisma, as these items contribute to that stat. I don’t plan to address this, as high charisma is achievable without them, and it’s an acceptable trade-off for the mod’s functionality.
- **Not All Helmets**: I play slowly (still on the first KCD 2 map after a restart), so I haven’t tested every helmet yet. That said, this mod should work with at least 90% of helmets—like kettles and bascinets. If you find one that doesn’t work, please let me know, so I can address it.
- **Non-Helmet Items**: Head armour like hats remains unaffected by this mod.
- **Hack: IsEquipped**: Neither KCD 2 nor KCD 1 provides a Lua API function to retrieve equipped slot items. To address this, the mod uses a hack. It iterates through all helmets and coifs in the player's inventory, taking them off. If the player's equipped weight changes, the mod identifies that item as the one equipped.
