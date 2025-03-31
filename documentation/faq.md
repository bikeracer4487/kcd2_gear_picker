## Frequently Asked Questions

### Is the Mod (KCD2) Available on Steam Workshop?
Yes, it’s available on Steam Workshop.

### How Do I Install the Mod?
You can install it via Steam Workshop, Vortex Mod Manager, or by manually extracting the mod files into the `{Game}\Mods` folder.

### Why Is the Barber Not Working?
This mod is fully compatible with the barber system. However, certain mods, like older versions of Autohide that override `HUD.xml`, can interfere, causing issues such as the hair list GUI not displaying properly.

### Why Is My Gear Coming Off When It Shouldn’t?
The mod keeps gear on in most scenarios where it’s needed, but some situations may not be fully covered. To override this behavior, open the in-game console with `~`, type `helmet_off_dialog__set_mod_off true`, and press Enter to disable gear removal. To re-enable it, use `helmet_off_dialog__set_mod_off false` and press Enter.

### Why Was My Gear Taken Off, or Not Taken Off?
The mod’s behavior is explained in other sections (e.g., specific scenarios like bathhouse NPCs or archery competitions). For detailed insight into why gear was removed or left on in a particular case, enable debug mode to access mod logs. Open the in-game console with `~` and enter: `helmet_off_dialog__set_debug true`.

### What Commands Can I Use?
The mod includes optional features through the optional mods that automatically handle these settings for a better user experience, so you typically won’t need to run commands manually. However, for experimentation or curiosity, here’s the full list of console commands you can try:
- `helmet_off_dialog__set_ranged true` — Enables ranged weapon removal
- `helmet_off_dialog__set_random true` — Randomizes gear removal
- `helmet_off_dialog__set_helmet_only` — Limits removal to helmets only
- `helmet_off_dialog__set_mod_off true` — Disables gear removal entirely
- `helmet_off_dialog__set_debug true` — Activates debug logs

### Can I Bind a Key to Toggle the Mod?
This mod avoids built-in keybinds to prevent conflicts with your setup. To add custom keybinds (e.g., F3 to disable, F4 to enable), append these lines to your `user.cfg` file:
- `bind f3 helmet_off_dialog__set_mod_off true`
- `bind f4 helmet_off_dialog__set_mod_off false`  
  See [Unlimited Saves Without Schnapps](https://www.nexusmods.com/kingdomcomedeliverance2/mods/52) for `user.cfg` setup instructions and [Key Names](https://www.cryengine.com/docs/static/engines/cryengine-3/categories/1638401/pages/1933340#list-of-key-names) for key options.

### Can I Progress the "Easy Riders" Quest Now?
As of version 1.3.2 (March 19, 2025), the "Easy Riders" quest works seamlessly. The update fixes a prior issue where gear removal blocked sparring with Hans.

### Can It Remove Bows or Crossbows Too?
Yes. Enable this feature by installing the optional "Ranged" mod.

### Can It Remove Just the Helmet, Not the Coif?
Yes. Enable this feature by installing the optional "Helmet Only" mod.

### Why No Helmet Removal in Scripted Dialogues or Cutscenes?
As of version 1.3.0 (March 16, 2025), helmet removal is supported in both scripted dialogues and cutscenes. *Note*: Some players report cutscene removal may not work consistently—under investigation.

### Why No Helmet Removal When Speaking to Mutt (KCD1)?
Helmet removal when talking to Mutt is supported as of version 1.3.0 (March 16, 2025).

### Why Doesn’t Gear Remove Near Bathhouse NPCs?
Since version 1.3.4, gear stays on when interacting with bathhouse NPCs within 3 meters, preventing issues with unwashed headgear after removal.

### Why Doesn’t Gear Remove Near Archery Competition NPCs?
As of version 1.3.4, gear remains equipped when interacting with archery competition NPCs within 3 meters, avoiding a bug that could halt the competition.

### Why Is Ranged Weapon Behavior Unstable?
When stowing ranged weapons (bows or crossbows), the game’s equipped weight stat—used by this mod to track items—doesn’t update reliably. This appears to be a KCD2 issue, as the same code works correctly in KCD1. The unequip function still operates, and ranged weapons auto-re-equip after dialogues, but you may need to manually redraw or re-equip them for archery competitions due to this quirk.