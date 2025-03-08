# Helmet-Off Dialog (Beta)

[![nexus-mods-page](https://img.shields.io/badge/Mod-Helmet–Off%20Dialog%20[KCD1]-bf4848?style=flat-square–=nexusmods)](https://www.nexusmods.com/kingdomcomedeliverance/mods/1909) [![nexus-mods-page](https://img.shields.io/badge/Mod-Helmet–Off%20Dialog%20[KCD2]-bf4848?style=flat-square–=nexusmods)](https://www.nexusmods.com/kingdomcomedeliverance2/mods/1023) [![github-repository](https://img.shields.io/badge/Open-Source-2ea44f?style=flat-square&logo=github)](https://github.com/rdok/kcd2_helmet_off_dialog)

This mod automatically unequips your helmet, and coif when starting a conversation with an NPC, then re-equips them when the dialog ends.

### KCD 2 Showcase

[![Showcase](https://github.com/rdok/kcd2_helmet_off_dialog/blob/main/documentation/kcd2_showcase.gif?raw=true)](https://www.nexusmods.com/kingdomcomedeliverance2/mods/831)

### KCD 1 Showcase

[![Showcase](https://github.com/rdok/kcd2_helmet_off_dialog/blob/main/documentation/kcd1_showcase.gif?raw=true)](https://www.nexusmods.com/kingdomcomedeliverance2/mods/831)

Install this mod using Vortex from Nexus Mods.

---

### Coverage
> If you identify any helmets not listed below, please provide their full names as they appear in-game.
- Helmets: kettle, bascinet, helmet, scullcap (skullcap)
- Head Chainmail (for KCD 1): coifmail, nm_ca_collar, nm_ca_hood
- Coifs: coif, g_hood_
---

### Alternative Versions
> Use either the main version, or one of the following. NOT both.

- Random: The optional files section offers a version that unequips helmets in random dialogues rather than all of them. For instance, it might remove the helmet in one conversation but keep it on in the next. As a player, this reflects my reason for creating this mod—half because I expect I’ll grow tired of Henry’s face, and half because the helmets are really cool to look at, especially when switching between different ones.

---

### Things to Know

- **Charisma Impact**: Unequipping the helmet or coif during dialogue most probably lower charisma, as these items contribute to that stat. I don’t plan to address this, as high charisma is achievable without them, and it’s an acceptable trade-off for the mod’s functionality.
- **Not All Helmets**: I play slowly (still on the first KCD 2 map after a restart), so I haven’t tested every helmet yet. That said, this mod should work with at least 90% of helmets—like kettles, and bascinets. If you find one that doesn’t work, please let me know, so I can address it.
- **Non-Helmet Items**: Gear like hats remains unaffected by this mod.
- **Hack: IsEquipped**: Neither KCD 2 nor KCD 1 provides a Lua API function to retrieve equipped slot items. To address this, this mod uses a hack. It iterates through all helmets and coifs in the player's inventory, taking them off. If the player's conspicuousness changes, the mod identifies that item as the one equipped.
