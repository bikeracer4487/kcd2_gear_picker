#!/usr/bin/env python3
# ===================================================================================================
# KCD2 PAK Builder Script
# Based on the kcd-pak-builder by Altire (from kcd-toolkit)
# Adapted for use with kcd2_gear_picker mod build process
# ===================================================================================================

import os
import sys
import zipfile
import argparse
import time
import shutil

def build_file_list(target_dir, ignore_paks=True):
    """
    Builds the list of files to include in the PAK
    
    Args:
        target_dir (str): Directory containing files to pack
        ignore_paks (bool): Whether to ignore existing PAK files
    
    Returns:
        list: List of file paths to include in the PAK
    """
    file_list = []
    print(f"Building file list from {target_dir}...")
    for root, dirs, files in os.walk(target_dir):
        for file in files:
            if ignore_paks and file.lower().endswith(".pak"):
                continue
            file_path = os.path.join(root, file)
            file_list.append(file_path)
    
    print(f"Found {len(file_list)} files to pack")
    return file_list

def create_pak(pak_path, target_dir, max_size_mb=500, ignore_paks=True):
    """
    Creates a PAK file from the contents of a directory
    
    Args:
        pak_path (str): Path where the PAK file will be created
        target_dir (str): Directory containing files to pack
        max_size_mb (int): Maximum size of the PAK file in MB
        ignore_paks (bool): Whether to ignore existing PAK files
    
    Returns:
        bool: True if successful, False otherwise
    """
    file_list = build_file_list(target_dir, ignore_paks)
    if not file_list:
        print("Error: No files found to pack!")
        return False
    
    max_size_bytes = int(max_size_mb * 1024 * 1024)
    files_processed = []
    file_idx = 0
    pak_part_no = 0
    total_files = len(file_list)
    
    # Main PAK Builder Loop
    while file_idx < total_files:
        # Build PAK Path
        current_pak_path = pak_path
        if pak_part_no > 0:
            current_pak_path = pak_path.replace(".pak", f"-part{pak_part_no}.pak")
        
        print(f"Creating PAK file: {current_pak_path}")
        
        # Write to PAK
        with zipfile.ZipFile(current_pak_path, 'w', zipfile.ZIP_DEFLATED) as pak_file:
            pak_size = 0
            
            for file in file_list[file_idx:]:
                file_size = os.path.getsize(file)
                pak_size += file_size
                
                relative_path = os.path.relpath(file, target_dir)
                print(f"Adding: {relative_path} ({file_size/1024:.1f} KB)")
                
                pak_file.write(file, relative_path)
                files_processed.append(file)
                file_idx += 1
                
                # Check if size limit reached
                if pak_size > max_size_bytes:
                    print(f"Size limit reached ({max_size_mb} MB). Splitting into multiple PAKs.")
                    break
        
        # If breaking because of size, move file and start pak counter
        if pak_size > max_size_bytes and pak_part_no == 0:
            os.replace(current_pak_path, current_pak_path.replace(".pak", f"-part{pak_part_no}.pak"))
            pak_part_no += 1
    
    processed_count = len(files_processed)
    print(f"PAK creation complete! Processed {processed_count} of {total_files} files.")
    return True

def main():
    """Main entry point for the script when run directly"""
    parser = argparse.ArgumentParser(description='KCD2 PAK Builder')
    parser.add_argument('--source', required=True, help='Source directory to pack')
    parser.add_argument('--output', required=True, help='Output PAK file path')
    parser.add_argument('--max-size', type=int, default=500, help='Maximum PAK size in MB (default: 500)')
    parser.add_argument('--include-paks', action='store_true', help='Include existing PAK files')
    
    args = parser.parse_args()
    
    source_dir = os.path.abspath(args.source)
    output_path = os.path.abspath(args.output)
    
    if not os.path.isdir(source_dir):
        print(f"Error: Source directory '{source_dir}' does not exist!")
        return 1
    
    # Create output directory if it doesn't exist
    output_dir = os.path.dirname(output_path)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Create the PAK file
    success = create_pak(
        output_path,
        source_dir,
        max_size_mb=args.max_size,
        ignore_paks=not args.include_paks
    )
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())