## Frequently Asked Questions

### Is the mod (KCD2) on Steam Workshop?
Yes, it’s uploaded.

### How do I install it?
Use Steam Workshop, Vortex Mod Manager or manually extract the contents of the mod into the `{Game}\Mods` folder.

### Gear Coming Off When It Shouldn’t
While the mod keeps your gear on for most scenarios requiring it, some cases aren’t yet covered. To address this, press `~` to open the in-game console, type `helmet_off_dialog__set_mod_off true`, and hit enter to disable it, keeping your gear on as needed; to re-enable it, type `helmet_off_dialog__set_mod_off false` and hit enter.

### Can I experiment with the optional features?
Use the in game console to run:
```
helmet_off_dialog__set_ranged true
helmet_off_dialog__set_random true
helmet_off_dialog__set_helmet_only true
helmet_off_dialog__set_mod_off true
```

###  Can I bind a key to toggle the mod?
This mod doesn’t include keybinds to avoid conflicts with your existing setup. You can add your own—like F3 to disable and F4 to enable—by appending this to your user.cfg file. See [Unlimited Saves Without Schnapps](https://www.nexusmods.com/kingdomcomedeliverance2/mods/52) for user.cfg setup and [Key Names](https://www.cryengine.com/docs/static/engines/cryengine-3/categories/1638401/pages/1933340#list-of-key-names)
```
bind f3 helmet_off_dialog__set_mod_off true
bind f4 helmet_off_dialog__set_mod_off false
```

### "Easy Riders" Quest Now Unblocked in KCD2
In the "Easy Riders" quest, players can now progress seamlessly. As of version 1.3.2 (March 19, 2025), the update fixes the previous issue where helmets or was removed, preventing you from sparring with Hans.

### Why aren’t some helmets detected?
Early versions struggled with helmet detection. Improved in 1.0.3, and the version 1.1.1 (March 15, 2025) uses a better method for equipped gear identification.

### Can it remove crossbows/bows instead?
Yes, this is now supported in version 1.2.0 (March 16, 2025).

### Can it remove just the helmet, not the coif?
Yes, the optional "Helmet Only" mod removes only the helmet.

### Why no helmet removal in scripted talks?
As of version 1.3.0 (16-Mar-25), helmet removal in scripted dialogues is now supported.

### Why no helmet removal in cutscenes talks?
As of version 1.3.0 (16-Mar-25), helmet removal in cutscenes should be supported. *Update*: There has been a few reports from players suggesting this might actually not work. Pending investigation.

### What about when speaking to Mutt (KCD 1)?
As of version 1.3.0 (16-Mar-25), helmet removal when speaking to Mutt is now supported.

### Why doesn’t my gear get taken off when speaking to people nearby offering bathhouse services?
As of version 1.3.4, the mod skips gear take-off when interacting with bathhouse NPCs within 3 meters. This avoids the issue where headgear taken off during the interaction isn’t washed.

### Why doesn’t my gear get taken off when speaking to people nearby offering archery competitions?
As of version 1.3.4, the mod no longer removes gear when interacting with archery competition NPCs within 3 meters. This prevents a bug that could stop the competition from starting.

### Unstable Ranged Behavior
When putting away ranged weapons like bows or crossbows, the equipped weight stat—used by this mod to track equipped items—doesn’t update consistently. This issue is likely a flaw in the base game; I am pretty certain because the same code works in KCD1. Despite this, the unequip function still works, and the game automatically puts on your ranged weapons after exiting the dialog. However, this quirk means you’ll need to draw your ranged weapon again (or re-equip it), when preparing to join an archery competition.
