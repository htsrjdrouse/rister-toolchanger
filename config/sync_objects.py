#!/usr/bin/env python3
"""
Sync Objects from Liquid Handling Extension to Klipper Collision Avoidance

This script reads the Objects Editor JSON config and updates variables.cfg
with collision avoidance object definitions.

Usage:
    python3 sync_objects.py [--config PATH] [--variables PATH] [--dry-run]

Examples:
    # Auto-detect paths (looks for config in standard locations)
    python3 sync_objects.py

    # Specify paths explicitly
    python3 sync_objects.py --config ~/liquid_handling_config.json --variables ~/printer_data/config/variables.cfg

    # Preview changes without writing
    python3 sync_objects.py --dry-run
"""

import json
import re
import os
import sys
import argparse
from pathlib import Path
from datetime import datetime

# Default paths to search for config files
DEFAULT_CONFIG_PATHS = [
    # Extension data directory (Chrome)
    os.path.expanduser("~/.config/google-chrome/Default/Extensions/*/liquid_handling_config*.json"),
    # Local development paths
    "./liquid_handling_config*.json",
    "../liquid-handling-extension-new/liquid_handling_config*.json",
    "../liquid-handling-extension-new/default_config.json",
    # Printer paths
    os.path.expanduser("~/printer_data/config/liquid_handling_config*.json"),
]

DEFAULT_VARIABLES_PATHS = [
    "./variables.cfg",
    os.path.expanduser("~/printer_data/config/variables.cfg"),
]


def find_config_file(search_paths=None):
    """Find the most recent liquid handling config file."""
    import glob
    
    paths = search_paths or DEFAULT_CONFIG_PATHS
    candidates = []
    
    for pattern in paths:
        matches = glob.glob(os.path.expanduser(pattern))
        candidates.extend(matches)
    
    if not candidates:
        return None
    
    # Sort by modification time, newest first
    candidates.sort(key=lambda x: os.path.getmtime(x), reverse=True)
    return candidates[0]


def find_variables_file(search_paths=None):
    """Find the variables.cfg file."""
    paths = search_paths or DEFAULT_VARIABLES_PATHS
    
    for path in paths:
        expanded = os.path.expanduser(path)
        if os.path.exists(expanded):
            return expanded
    
    return None


def parse_object(obj):
    """
    Convert an Objects Editor object to collision avoidance format.
    
    Objects Editor format:
        posx, posy - position (top-left corner)
        X, Y - dimensions (width, height)
        Z - object height
        ztrav - travel clearance
        marginx, marginy - margins (included in position)
        name - object identifier
        status - "on" or "off"
    
    Collision avoidance format:
        x_min, x_max, y_min, y_max - bounding box
        z_height - object height
        z_clearance - clearance above object
        enabled - whether to check collisions
    """
    try:
        name = obj.get('name', '').lower().replace(' ', '_')
        if not name:
            return None
        
        # Parse position and dimensions
        posx = float(obj.get('posx', 0))
        posy = float(obj.get('posy', 0))
        width = float(obj.get('X', 0))
        height = float(obj.get('Y', 0))
        z_height = float(obj.get('Z', 0))
        ztrav = float(obj.get('ztrav', 0))
        status = obj.get('status', 'on')
        
        # Calculate bounding box
        x_min = posx
        x_max = posx + width
        y_min = posy
        y_max = posy + height
        
        # Z clearance: use ztrav if specified, otherwise default based on object type
        if ztrav > 0:
            z_clearance = ztrav
        elif 'dispenser' in name or 'box' in name:
            z_clearance = 15  # Taller objects need more clearance
        elif 'bed' in name:
            z_clearance = 5   # Bed is flat, minimal clearance
        else:
            z_clearance = 10  # Default
        
        return {
            'name': name,
            'x_min': round(x_min, 1),
            'x_max': round(x_max, 1),
            'y_min': round(y_min, 1),
            'y_max': round(y_max, 1),
            'z_height': round(z_height, 1),
            'z_clearance': round(z_clearance, 1),
            'enabled': status.lower() == 'on'
        }
    except (ValueError, TypeError) as e:
        print(f"Warning: Could not parse object {obj.get('name', 'unknown')}: {e}")
        return None


def load_config(config_path):
    """Load and parse the liquid handling config JSON."""
    with open(config_path, 'r') as f:
        config = json.load(f)
    
    objects = config.get('objects', [])
    parsed = []
    
    for obj in objects:
        parsed_obj = parse_object(obj)
        if parsed_obj:
            parsed.append(parsed_obj)
    
    return parsed


def generate_variables_block(objects):
    """Generate the variables.cfg block for collision objects."""
    lines = [
        "",
        "# ===== COLLISION AVOIDANCE OBJECTS =====",
        f"# Auto-synced from Objects Editor on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "# Format: obj_NAME_property = value",
        "# Run SYNC_COLLISION_OBJECTS in Klipper console after updating",
        "",
    ]
    
    for obj in objects:
        name = obj['name']
        lines.append(f"# {name.replace('_', ' ').title()}")
        lines.append(f"obj_{name}_enabled = '{'true' if obj['enabled'] else 'false'}'")
        lines.append(f"obj_{name}_x_min = {obj['x_min']}")
        lines.append(f"obj_{name}_x_max = {obj['x_max']}")
        lines.append(f"obj_{name}_y_min = {obj['y_min']}")
        lines.append(f"obj_{name}_y_max = {obj['y_max']}")
        lines.append(f"obj_{name}_z_height = {obj['z_height']}")
        lines.append(f"obj_{name}_z_clearance = {obj['z_clearance']}")
        lines.append("")
    
    return '\n'.join(lines)


def update_variables_file(variables_path, objects_block):
    """
    Update variables.cfg with the new objects block.
    
    Replaces existing collision objects section or appends if not found.
    """
    with open(variables_path, 'r') as f:
        content = f.read()
    
    # Pattern to match existing collision objects section
    pattern = r'\n# ===== COLLISION AVOIDANCE OBJECTS =====.*?(?=\n# =====|\n\[|\Z)'
    
    if re.search(pattern, content, re.DOTALL):
        # Replace existing section
        new_content = re.sub(pattern, objects_block, content, flags=re.DOTALL)
    else:
        # Append to end (before any trailing whitespace)
        new_content = content.rstrip() + objects_block
    
    return new_content


def main():
    parser = argparse.ArgumentParser(
        description='Sync Objects Editor config to Klipper collision avoidance',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument('--config', '-c', help='Path to liquid handling config JSON')
    parser.add_argument('--variables', '-v', help='Path to variables.cfg')
    parser.add_argument('--dry-run', '-n', action='store_true', help='Preview changes without writing')
    parser.add_argument('--verbose', action='store_true', help='Show detailed output')
    
    args = parser.parse_args()
    
    # Find config file
    config_path = args.config
    if not config_path:
        config_path = find_config_file()
        if not config_path:
            print("Error: Could not find liquid handling config file.")
            print("Specify path with --config or place config in a standard location.")
            sys.exit(1)
    
    if not os.path.exists(config_path):
        print(f"Error: Config file not found: {config_path}")
        sys.exit(1)
    
    print(f"📂 Config: {config_path}")
    
    # Find variables file
    variables_path = args.variables
    if not variables_path:
        variables_path = find_variables_file()
        if not variables_path:
            print("Error: Could not find variables.cfg file.")
            print("Specify path with --variables")
            sys.exit(1)
    
    if not os.path.exists(variables_path):
        print(f"Error: Variables file not found: {variables_path}")
        sys.exit(1)
    
    print(f"📂 Variables: {variables_path}")
    
    # Load and parse objects
    try:
        objects = load_config(config_path)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in config file: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error loading config: {e}")
        sys.exit(1)
    
    if not objects:
        print("Warning: No objects found in config file.")
        sys.exit(0)
    
    print(f"\n🔍 Found {len(objects)} objects:")
    for obj in objects:
        status = "✓" if obj['enabled'] else "✗"
        print(f"  {status} {obj['name']}: X[{obj['x_min']}-{obj['x_max']}] Y[{obj['y_min']}-{obj['y_max']}] Z={obj['z_height']}mm")
    
    # Generate new variables block
    objects_block = generate_variables_block(objects)
    
    if args.verbose or args.dry_run:
        print("\n📝 Generated variables block:")
        print("-" * 50)
        print(objects_block)
        print("-" * 50)
    
    # Update variables file
    try:
        new_content = update_variables_file(variables_path, objects_block)
    except Exception as e:
        print(f"Error updating variables: {e}")
        sys.exit(1)
    
    if args.dry_run:
        print("\n🔍 Dry run - no changes written.")
        print("Run without --dry-run to apply changes.")
    else:
        # Backup original file
        backup_path = f"{variables_path}.backup"
        try:
            with open(variables_path, 'r') as f:
                backup_content = f.read()
            with open(backup_path, 'w') as f:
                f.write(backup_content)
            print(f"\n💾 Backup saved to: {backup_path}")
        except Exception as e:
            print(f"Warning: Could not create backup: {e}")
        
        # Write updated content
        try:
            with open(variables_path, 'w') as f:
                f.write(new_content)
            print(f"✅ Updated: {variables_path}")
            print("\n⚠️  Remember to run SYNC_COLLISION_OBJECTS in Klipper console!")
        except Exception as e:
            print(f"Error writing variables file: {e}")
            sys.exit(1)


if __name__ == '__main__':
    main()
