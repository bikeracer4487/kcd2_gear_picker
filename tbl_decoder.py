#!/usr/bin/env python3
# tbl_decoder.py
# Recursively finds and decodes all .tbl files in a directory
# Usage: python tbl_decoder.py [PATH]
#     PATH - root directory to search for .tbl files (defaults to current directory)

import struct
import sys
import os
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
        w(f"{indent}File Format Version ... {self.file_format_version}\n")
        w(f"{indent}Descriptors Hash ...... {self.descriptors_hash}\n")
        w(f"{indent}Layout Hash ........... {self.layout_hash}\n")
        w(f"{indent}Table Version ......... {self.table_version}\n")
        w(f"{indent}Line Count ............ {self.line_count}\n")
        w(f"{indent}String Data Size ...... {self.string_data_size}\n")
        w(f"{indent}Unique String Count ... {self.unique_string_count}\n")

        if file_size is not None:
            line_size, remainder = self.calculate_line_size(file_size)
            w(f"{indent}File Size ............. {file_size}\n")
            w(f"{indent}Calculated Line Size .. {line_size} (rem. {remainder})\n")

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
        if self.line_count == 0:
            return 0, line_data_size
        remainder = line_data_size % self.line_count
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
        out.write(f"== {self.file_name}\n")
        out.write("======================================================================\n")
        out.write("Header:\n")
        self.header.print(out, indent="  ", file_size=self.file_size)

        if len(self.string_data) > 0:
            try:
                strings = codecs.decode(self.string_data, 'utf-8', errors='replace').split("\0")[:-1]
                out.write("String Table:\n")
                for i, s in enumerate(strings):
                    out.write(f"  [{i}] {s}\n")
            except Exception as e:
                out.write(f"Error decoding strings: {str(e)}\n")

    def read(self, file_name):
        self.file_name = file_name
        self.file_size = path.getsize(file_name)

        with open(file_name, "rb") as f:
            header_raw = f.read(self.header.size)
            self.header.unpack(header_raw)

            line_size, _ = self.header.calculate_line_size(self.file_size)

            self.row_data = f.read(line_size * self.header.line_count)
            self.string_data = f.read(self.header.string_data_size)

def process_tbl_file(file_path):
    """Process a single TBL file and write its decoded content to a text file"""
    try:
        output_path = f"{file_path}-decoded.txt"
        
        # Check if overwriting existing file
        if os.path.exists(output_path):
            print(f"Overwriting existing file: {output_path}")
        else:
            print(f"Processing: {file_path}")
            
        tbl_file = TBLFile()
        tbl_file.read(file_path)
        
        with open(output_path, 'w', encoding='utf-8') as out:
            tbl_file.print(out)
            
        print(f"Decoded to: {output_path}")
    except Exception as e:
        print(f"Error processing {file_path}: {str(e)}")

def find_and_process_tbl_files(root_dir):
    """Recursively find all .tbl files in root_dir and process them"""
    tbl_files_found = 0
    
    for current_dir, _, files in os.walk(root_dir):
        for file in files:
            if file.lower().endswith('.tbl'):
                file_path = os.path.join(current_dir, file)
                process_tbl_file(file_path)
                tbl_files_found += 1
    
    return tbl_files_found

def main():
    # Get directory to search from command line or use default path
    if len(sys.argv) > 1:
        root_dir = sys.argv[1]
    else:
        root_dir = os.getcwd()
    
    if not os.path.isdir(root_dir):
        print(f"Error: {root_dir} is not a valid directory.")
        sys.exit(1)
    
    print(f"Searching for .tbl files in: {root_dir}")
    tbl_files_count = find_and_process_tbl_files(root_dir)
    
    if tbl_files_count > 0:
        print(f"Successfully processed {tbl_files_count} .tbl files.")
    else:
        print(f"No .tbl files found in {root_dir}")

if __name__ == "__main__":
    main()