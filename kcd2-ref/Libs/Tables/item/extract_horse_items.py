#!/usr/bin/env python3
"""
Extract horse equipment data from item__horse.xml into CSV files.
Focuses on actual horse-relevant statistics, excluding misleading player-centric stats.
"""

import csv
import logging
from xml.etree import ElementTree
from collections import defaultdict

# Category mappings based on item names
CATEGORY_MAPPINGS = {
    'Saddles': lambda name: ('Saddle' in name and 'Caparison' not in name),
    'Basic Caparisons': lambda name: 'Caparison' in name and not any(x in name for x in ['Noble', 'Padded']),
    'Noble Caparisons': lambda name: 'NobleCaparison' in name,
    'Padded Caparisons': lambda name: 'PaddedCaparison' in name,
    'Chanfrons': lambda name: 'Chanfron' in name,
    'Harnesses': lambda name: 'Harness' in name,
    'Bridles': lambda name: 'Bridle' in name,
    'Horseshoes': lambda name: 'horseshoe' in name or 'HorseShoe' in name
}

def get_item_category(item_name):
    """Determine the category of a horse item based on its name."""
    for category, check_func in CATEGORY_MAPPINGS.items():
        if check_func(item_name):
            return category
    return 'Other'

def extract_horse_items(xml_file):
    """Extract horse items from the XML file."""
    logging.info(f"Reading {xml_file}")
    tree = ElementTree.parse(xml_file)
    root = tree.getroot()
    
    items_by_category = defaultdict(list)
    
    # Find all Armor elements (horse items are stored as Armor)
    for armor in root.findall('.//Armor'):
        item_data = {
            'Name': armor.get('Name', ''),
            'LocalizedName': armor.get('UIName', ''),
            'DefenseStab': int(armor.get('DefenseStab', 0)),
            'DefenseSlash': int(armor.get('DefenseSlash', 0)),
            'DefenseSmash': int(armor.get('DefenseSmash', 0)),
            'MaxStatus': int(armor.get('MaxStatus', 0)),
            'RPGBuffWeight': float(armor.get('RPGBuffWeight', 0)),
            'Weight': float(armor.get('Weight', 0)),
            'Price': int(armor.get('Price', 0)),
            'Id': armor.get('Id', '')
        }
        
        category = get_item_category(item_data['Name'])
        items_by_category[category].append(item_data)
    
    return items_by_category

def write_csv(items, filename, category_name):
    """Write items to a CSV file."""
    if not items:
        logging.warning(f"No items found for category {category_name}")
        return
    
    # Define the columns for horse equipment
    fieldnames = [
        'Category', 'LocalizedName', 'Name', 
        'DefenseStab', 'DefenseSlash', 'DefenseSmash',
        'MaxStatus', 'RPGBuffWeight', 'Weight', 'Price', 'Id'
    ]
    
    logging.info(f"Writing {len(items)} items to {filename}")
    
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        
        for item in sorted(items, key=lambda x: x['Name']):
            row = {'Category': category_name}
            row.update(item)
            writer.writerow(row)

def write_all_items_csv(all_items):
    """Write all items to a single comprehensive CSV file."""
    filename = 'horse_equipment_all.csv'
    fieldnames = [
        'Category', 'LocalizedName', 'Name', 
        'DefenseStab', 'DefenseSlash', 'DefenseSmash',
        'MaxStatus', 'RPGBuffWeight', 'Weight', 'Price', 'Id'
    ]
    
    all_items_flat = []
    for category, items in all_items.items():
        for item in items:
            row = {'Category': category}
            row.update(item)
            all_items_flat.append(row)
    
    logging.info(f"Writing {len(all_items_flat)} total items to {filename}")
    
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        
        # Sort by category then by name
        for item in sorted(all_items_flat, key=lambda x: (x['Category'], x['Name'])):
            writer.writerow(item)

def main():
    """Main function to extract and save horse equipment data."""
    xml_file = 'item__horse.xml'
    
    # Extract items
    items_by_category = extract_horse_items(xml_file)
    
    # File mappings
    file_mappings = {
        'Saddles': 'horse_saddles.csv',
        'Basic Caparisons': 'horse_basic_caparisons.csv',
        'Noble Caparisons': 'horse_noble_caparisons.csv',
        'Padded Caparisons': 'horse_padded_caparisons.csv',
        'Chanfrons': 'horse_chanfrons.csv',
        'Harnesses': 'horse_harnesses.csv',
        'Bridles': 'horse_bridles.csv',
        'Horseshoes': 'horse_horseshoes.csv'
    }
    
    # Write individual category files
    for category, filename in file_mappings.items():
        if category in items_by_category:
            write_csv(items_by_category[category], filename, category)
    
    # Write comprehensive file
    write_all_items_csv(items_by_category)
    
    # Print summary
    print("\nHorse Equipment Summary:")
    print("-" * 40)
    total_items = 0
    for category, items in sorted(items_by_category.items()):
        print(f"{category}: {len(items)} items")
        total_items += len(items)
    print("-" * 40)
    print(f"Total: {total_items} items")

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
    main()