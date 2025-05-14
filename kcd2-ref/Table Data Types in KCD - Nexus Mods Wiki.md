| Name | Width in TBL file | Name in XML table descriptor |
| --- | --- | --- |
| Int | 32 bit | integer |
| Int64 | 64 bit | bigint |
| Float | 32 bit | real |
| Guid | 128 bit | uuid |
| Bool | 8 bit | boolean |
| String | 32 bit | text, character varying |
| Vec3 | 96 bit (3 \* 32 bit) | vec3 |
| Quat | 128 bit (4 \* 32 bit) | quat |
| QuatT | 224 bit ((4 + 3) \* 32 bit) | quatt |
| Padding | variable |   |

## Notes

-   Strings are stored as 32-bit signed integers pointing into the string table. See [TBL File Format in KCD](https://wiki.nexusmods.com/index.php/TBL_File_Format_in_KCD "TBL File Format in KCD").
-   Most tables do not use any padding. Whether table uses or doesn't use padding is hard-coded in KCD source. KCD data can only tell you that there is some padding somewhere, but not where. To see whether table uses padding, compare table description in XML file with line size in TBL file.

## Example - POI Types Table

| Column | Type | Width |
| --- | --- | --- |
| poi\_type\_id | Guid | 128 bit |
| mark\_type | Int | 32 bit |
| label | String |   |
| discovery\_msg | String |   |
| discovery\_dist | Float | 32 bit |
| compass\_mark\_type\_id | Int | 32 bit |
| associated\_codex\_perk\_id | Guid | 128 bit |
| discovery\_msg\_mode | Int | 32 bit |
| discoverable\_by\_location | Bool | 8 bit |
| ui\_order | Int | 32 bit |