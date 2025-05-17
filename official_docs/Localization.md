Any text displayed in game (hud descriptions, quests, item names, dialogue, etc...) is a localized string, meaning it needs to be specified in a localization file for each language.

For ingame localization, all text needs to be localized for each language. Mods default to english localization, if user selects a language that the users doesn't have.

## References in data

Some fields in some tables are **stringIds**, which in game are replaced by corresponding localized text (For example, UIName property in item table). Some **stringIds** are prefixed with **ui\_**, which is just a optional convention, it is not actually a requirement.

## Localization files

Mods localization files are placed in **Localization/** folder in the mod directory. It needs to contain PAK files in the format _language_\_xml.pak for text and _language_.pak for voiceovers.

### Text localization

Inside text paks, any number of localization files can be placed, all named _anything_\__modid_.xml , with following structure:

```xml
<Table> <Row><Cell>buff_against_all_odds</Cell><Cell>Against All Odds</Cell><Cell>Against All Odds</Cell></Row> </Table>
```

XML

First cell is the **stringId**, second cell is irrelevant, last cell is the actual translation used in game.

If the filename is in a different format, it will still be loaded, however it will be loaded at a wrong time and will spam the log with "hash clash" errors.  
Before patch 1.3, only text\_\__modid_.xml is loaded correctly, all other files are loaded in random order