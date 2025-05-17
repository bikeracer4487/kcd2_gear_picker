When your mod works in the development build, there are a couple extra step that you need to take.

## Packing loose files

The published version of the game does not load loose files - it only loads files from PAKs. There are only two exceptions to this - mod.manifest file and mod.cfg file. You will need to pack all files in `data/` folder in one or more PAKs. The same needs to be done for localization/ folder (if your mod requires localization).  
PAKs are technically just a ZIP archive without any compression, they can be created by most zipping tools - Total Commander and Windows Explorer on Windows 10 are verified to work. **ZIP archives created by 7zip don't work** (7zip creates the archives in a slightly different format, which the game cannot load). The published game splits game data into several different PAKs, however that is not necessary - you can put all of your files into a single PAK, or split them however you want.

How to create a mod .pak with Windows Explorer (only works on Windows 10)

1.  We have our modded data inside `<modid>/data`
2.  Select all the data inside this folder \> right-click \> send to \> compressed (zipped) folder
    1.  ![image.png](https://warhorse.youtrack.cloud/api/files/496-558?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTU1OHxwWnRKMnZkY2otY3hiajA2VzZ3UlpNaXlkenNYQXoyVEpsM3RUbFhjaE93DQo&updated=1742804061301)
3.  This will create a .zip file, and rename it to `<whatever>.pak` , I prefer `<mod>Data.pak`
    1.  ![image1.png](https://warhorse.youtrack.cloud/api/files/496-559?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTU1OXxRSlhpZHpORGJ1dlo4SXhYMjEyN0JwdlJqZ1NieFBHbTh6cW44eElMU1pNDQo&updated=1742804061301)
    2.  ![image2.png](https://warhorse.youtrack.cloud/api/files/496-557?sign=MTc0NzYxMjgwMDAwMHwyLTB8NDk2LTU1N3xmS0xsenNNclRaSHRQOG5NWWdKZzRLdzM3NmQ3ZGF3d0diWmc1TUxzNF9rDQo&updated=1742804061301)
4.  Paks created this way should be placed in `<modid>/data` folder

## Folder structure and uploading

After packing the mod, the folder should look like this.

```clike
mod_folder ├ mod.manifest ├ mod.cfg ├ data │ ├ data1.pak │ ├ data2.pak │ └ ... └ localization ├ english_xml.pak ├ whs_xml.pak └ ...
```

C detected

This folder can then be uploaded with SteamWorkshopUploader (select the mod\_folder as the folder to upload), or on any other mod distribution site.

## Using Paks in Development version

Development version of the game, by default, uses both loose files and files from paks (with loose files having priority). You can change this beahavior using the sys\_pakPriority cvar. This cvar has to be set before the engine launches, so we have to insert it into user.cfg in the workspace's root (create an empty one if none is found).

-   `sys_pakPriority 0` - `files > paks`\- this it the default, game loads both paks and files, files outside of paks have priority
-   `sys_pakPriority 1` - `paks > files`, game still loads both, but files inside paks have priority over files outside
-   `sys_pakPriority 2` - only paks, loose files are ignored (this is the default and only possible behavior for the published version of the game)