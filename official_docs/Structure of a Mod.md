Mod is a collection of files placed in an appropriate folder. KCD2 loads all folders from mods/ folder in game root. Also, when using Steam version, subscribed mods will be loaded (they are downloaded by Steam to some other location).  
If a mod\_order.txt file is present in mods/, it is used to select which mods and in which order they are loaded. If not, mods from Steam are loaded first, in arbitrary order, and then all mods from mods/ folder are loaded, in alphabetical order.  
Each mod is identified by a unique **modid** (**must** contain only **lowercase** letters and **underscore**). This modid is then used to identify the mod in mod\_order.txt, and also some special files are expected to have modid in name. Some modids cannot be used, see [Reserved ModIds](chrome-extension://pcmpcfapbekmbjjkdalcgopdkipoggdi/articles/KM-A-35/Reserved-ModIds "KM-A-35: Reserved ModIds").

### Integration

Mods can override any of the game's data files, by placing a file with identical name in appropriate location within the mod folder (see Folder structure). If several mods would modify the same file, the game uses the file from the mod which was loaded latest.  
Several files, such as data tables, are likely to be modified by many mods. There are several file formats, which allow for precise changes within these files, without outright replacing the entire file. It is recommended to use these special file formats, to ensure compatibility with other mods.

### Folder structure

|  |  |
| --- | --- |
| mod.manifest | XML file with basic information about the mod. Template: [mod.manifest](https://warhorse.youtrack.cloud/api/files/496-1?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTF8MjZyWDVjNUlraVBJaGVVZllLb3RPN2E5Y2R6VnNGeVFTRzFPRWlLX0lIRQ0K&updated=1737461201469&forceDownload=true) |
| mod.cfg | File with variable setting |
| data/\*.pak | Archive with game data files. Files inside are expected to mirror the folder structure of data/ folder of main game. It a zip file, renamed to .pak, with 0 compression. |
| Localization/language.pak |  |

### Inside paks

Pak archives have indentical internal structure as those found in KCD2/data/\*.paks. A file needs to be placed in identical path to override a file from the base game.  
There are some special files that can be used:

|  |  |
| --- | --- |
| scripts/mods/_modid_.lua | A script that is loaded and executed right after scripts/main.lua |
| data/libs/tables/.../_tablename_\_\__modid_.xml | A patch for a table. Allows modification of a single entry in table |
| data/quests/_modid_.xml | Concept graph that will be loaded for trosecko and kutnorsko, alongside main game graph |
| data/libs/Storm/storm\_\__modid_.xml | Storm root file that is going to be merged into game's storm root file |

### Sub-articles<sup>3</sup>