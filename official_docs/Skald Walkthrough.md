Skald is a tool for modifying quests, dialogues and localization

## Projects

### Create/Open a project

Click the PAKs button to open/edit a project from game PAKs

Select the root directory of your game

Your root directory should contain

-   Data/ folder with Developer,GameData,Script and tables.pak (and/or IPL\_ variants).
-   Localization folder with language.pak (voiceovers) and language\_xml.pak (texts)
-   Mods

![image1.png](https://warhorse.youtrack.cloud/api/files/496-53?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTUzfFN1R1FYRGFsTmJaUFVfZ2lIdXdRNGNYVGVQNEc3UlJGaExuZEpsd0szSDQNCg&updated=1736845779815)

### Create a new mod

Just select **New mod** and fill **Name** and **Modid**

![image2.png](https://warhorse.youtrack.cloud/api/files/496-54?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTU0fEZsblhSalVxdmhKLUtvZ0ZxYmYzbHMwVzJTd1BEZ1FySXYzTjN1YlFTOTgNCg&updated=1736845779815)

### Create new project

Select your **mod** and **Empty/New** button, then create **New mod project**

Your project will be saved to _root\\mods\\modid\\data\\Quests\\modid.xml_

![image3.png](https://warhorse.youtrack.cloud/api/files/496-55?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTU1fFJUT2xNb0Z6T2NBVzNkRFdIUHZNY203WTIxa21uNzF1TlY1S3pZbjdPaXcNCg&updated=1736845779815)

**Modify base game**

Select **script.pak** project and click **Mod base game** button

Changed and new xml files will be saved to _root\\mods\\tmodid\\data\\Quests\\final\\Barbora_...

![image4.png](https://warhorse.youtrack.cloud/api/files/496-56?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTU2fGp5ekRoTm5UVTIzdkNQS3BLLThOcURkYUZVaUoxU0k4QWJDaVFpZEkzRGsNCg&updated=1736845779815)

## Localization

### **Disabled**

all translations are saved in quest XML, Skald read and write it, but the game can load **Text** (WHS) attributes only.

![image7.png](https://warhorse.youtrack.cloud/api/files/496-62?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTYyfDNHUnIxV2swWlQ3a21Yem1SUXhuUWtfcVpIZWVNMTd0UlQzYnRpNXV0MGMNCg&updated=1736845779815)

### **PAKs**

translations are saved to separated XMLs per language, each localized string has its own unique **StringName** attribute

_root\\mods\\modid\\localization\\language\_xml.pak_

![image11.png](https://warhorse.youtrack.cloud/api/files/496-69?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTY5fGpneGRYcm9oWUNZcGE4T2p1aDB2bk9EUHBaSm9vV09yVGhVN0Q2QUpOYTgNCg&updated=1736845779815)

### Translation

can be done in the **Translation panel,** or you can change the language of responses globally in **Languages** combobox

![image12.png](https://warhorse.youtrack.cloud/api/files/496-70?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTcwfEE0NjI3UTlDd3htUE5jQlduaEpFTGlLSzVOUDg1Y1dXMWpTbmFiLVk1ZUkNCg&updated=1736845779815)

### WHS

primary language, used in **Text attribute**, in our case it's a mix of **uncorrected** Czech and English, then corrected and translated to published languages (ENG,GER,CZE etc...)

![image10.png](https://warhorse.youtrack.cloud/api/files/496-68?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTY4fDhMY2R0M2tlSUx4X2RUWVprSktIcmlrTHNfVWFjT1hVQXFUd0FGWU44ejANCg&updated=1736845779815)

### Other languages

You can use Skald to translate, or you can take base WHS xmls, translate them manually to a target language and save them with another language name (_eg. you can take whs\_xml.pak, translate content and save it as english\_xml.pak, so both skald and game now load it as English localization)_

Format is following

`<Row>`

`<Cell>StringName</Cell>`

`<Cell>SourceLanguage (WHS) - optional, not loaded</Cell>`

`<Cell>TargetLanguage (CZE)</Cell>`

`</Row>`

![image13.png](https://warhorse.youtrack.cloud/api/files/496-74?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTc0fFJJNHhCcFBhZWkxeklDSE1IVnh2T3VnQmlYVU9DdlZNUF9XdG45LTJBeW8NCg&updated=1736845779815)