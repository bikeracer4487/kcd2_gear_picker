-   [1 Top-Level File Format](https://wiki.nexusmods.com/index.php/TBL_File_Format_in_KCD#Top-Level_File_Format)
    -   [1.1 Notes](https://wiki.nexusmods.com/index.php/TBL_File_Format_in_KCD#Notes)
-   [2 Header Format](https://wiki.nexusmods.com/index.php/TBL_File_Format_in_KCD#Header_Format)
-   [3 Python Script For Decoding TBL File](https://wiki.nexusmods.com/index.php/TBL_File_Format_in_KCD#Python_Script_For_Decoding_TBL_File)

## Top-Level File Format

| Offset | Name | Type |
| --- | --- | --- |
| `0` | Header | Header |
| `28` | Rows | Type Depends On Table Structure, count is `Line Count` in `Header` |
| `28 + line size * line count` | String Data |

### Notes

-   Line size can be calculated as `(file size - header size - string data size) / line count`.
-   For more info about table data types, see [Table Data Types in KCD](https://wiki.nexusmods.com/index.php/Table_Data_Types_in_KCD "Table Data Types in KCD")

| Offset | Name | Type |
| --- | --- | --- |
| 0 | File Format Version | 32-bit signed int |
| 4 | Descriptors Hash | 32-bit unsigned int |
| 8 | Layout Hash | 32-bit unsigned int |
| 12 | Table Version | 32-bit signed int |
| 16 | Line Count | 32-bit signed int |
| 20 | String Data Size | 32-bit signed int |
| 24 | Unique String Count | 32-bit signed int |

## Python Script For Decoding TBL File

Example output:

```
python tblfile.py poi_type.tbl
======================================================================
== C:\WH\kcd_mod_kit\poi_type.tbl
======================================================================
Header:
  File Format Version ... 3
  Descriptors Hash ...... 1537641125
  Layout Hash ........... 2716330613
  Table Version ......... 1
  Line Count ............ 54
  String Data Size ...... 1241
  Unique String Count ... 55
  File Size ............. 5589
  Calculated Line Size .. 80 (rem. 0)
String Table:
  [0] ui_maplegend_carpenter
  [1] ui_maplegend_armourer
  [2] ui_maplegend_shoemaker
  ...
  [54] ui_maplegend_henhouse
```

Source:

```
# tblfile.py
# Usage: tblfile.py FILE [ FILE [...] ]
#        FILE - path to a TBL file (extracted, not in pak)

import struct
import sys
import os.path as path
import codecs


class TBLFileHeader:
    FORMAT = struct.Struct("iIIiiii")

    def __init__(self):
        self.file_format_version = None
        self.descriptors_hash = None
        self.layout_hash = None
        self.table_version = None
        self.line_count = None
        self.string_data_size = None
        self.unique_string_count = None

    def print(self, out, indent="", file_size=None):
        w = out.write
        w(indent)
        w("File Format Version ... {self.file_format_version}\n".format(self=self))
        w(indent)
        w("Descriptors Hash ...... {self.descriptors_hash}\n".format(self=self))
        w(indent)
        w("Layout Hash ........... {self.layout_hash}\n".format(self=self))
        w(indent)
        w("Table Version ......... {self.table_version}\n".format(self=self))
        w(indent)
        w("Line Count ............ {self.line_count}\n".format(self=self))
        w(indent)
        w("String Data Size ...... {self.string_data_size}\n".format(self=self))
        w(indent)
        w("Unique String Count ... {self.unique_string_count}\n".format(self=self))

        if not file_size is None:
            line_size, remainder = self.calculate_line_size(file_size)
            w(indent)
            w("File Size ............. {file_size}\n".format(file_size=file_size))
            w(indent)
            w("Calculated Line Size .. {line_size} (rem. {remainder})\n".format(line_size=line_size, remainder=remainder))

    @property
    def size(self):
        return self.FORMAT.size
    
    def unpack(self, buffer):
        t = self.FORMAT.unpack(buffer)
        (
            self.file_format_version,
            self.descriptors_hash,
            self.layout_hash,
            self.table_version,
            self.line_count,
            self.string_data_size,
            self.unique_string_count,
        ) = t
        return self

    def calculate_line_size(self, file_size):
        line_data_size = file_size - self.size - self.string_data_size
        remainder = line_data_size&nbsp;% self.line_count
        return int(line_data_size / self.line_count), remainder


class TBLFile:
    def __init__(self):
        self.header = TBLFileHeader()
        self.file_name = None
        self.file_size = None
        self.row_data = None
        self.string_data = None

    def print(self, out):
        out.write("======================================================================\n")
        out.write("== {}\n".format(self.file_name))
        out.write("======================================================================\n")
        out.write("Header:\n")
        self.header.print(out, indent="  ", file_size=self.file_size)

        if len(self.string_data) &gt; 0:
            try:
                strings = codecs.decode(self.string_data).split("\0")[:-1]
                out.write("String Table:\n")
                for i, str in enumerate(strings):
                    out.write("  [{}] {}\n".format(i, str))
            except Exception as e:
                out.write(str(e))

    def read(self, file_name):
        self.file_name = file_name
        self.file_size = path.getsize(file_name)

        with open(file_name, "rb") as f:
            header_raw = f.read(self.header.size)
            self.header.unpack(header_raw)

            line_size, _ = self.header.calculate_line_size(self.file_size)

            self.row_data = f.read(line_size * self.header.line_count)
            self.string_data = f.read(self.header.string_data_size)


def main():
    for file_name in sys.argv[1:]:
        if not path.isfile(file_name):
            print("File {} doesn't exist!".format(file_name))
            continue

        header = TBLFileHeader()

        with open(file_name, "rb") as f:
            tbl_file = TBLFile()
            tbl_file.read(file_name)
            tbl_file.print(sys.stdout)
            print()


if __name__ == "__main__":
    main()
```