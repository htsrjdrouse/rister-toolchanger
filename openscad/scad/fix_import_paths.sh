#!/bin/bash
# Script to fix import paths in OpenSCAD files
# Converts absolute and relative paths to simple filenames (assumes STLs are in same directory)

SCAD_FILE="$1"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if file is provided
if [ -z "$SCAD_FILE" ]; then
    echo -e "${RED}Error: No OpenSCAD file specified${NC}"
    echo "Usage: $0 <openscad_file.scad>"
    echo "Example: $0 carriage_v2_3dify.scad"
    exit 1
fi

# Check if file exists
if [ ! -f "$SCAD_FILE" ]; then
    echo -e "${RED}Error: File '$SCAD_FILE' not found${NC}"
    exit 1
fi

echo "=========================================="
echo "OpenSCAD Import Path Fixer"
echo "=========================================="
echo "File: $SCAD_FILE"
echo ""

# Create backup
BACKUP_FILE="${SCAD_FILE}.backup"
cp "$SCAD_FILE" "$BACKUP_FILE"
echo -e "${GREEN}✓${NC} Created backup: $BACKUP_FILE"
echo ""

# Find all import statements
echo "Finding import statements..."
IMPORTS=$(grep -n 'import.*\.stl' "$SCAD_FILE")

if [ -z "$IMPORTS" ]; then
    echo -e "${YELLOW}No STL imports found${NC}"
    rm "$BACKUP_FILE"
    exit 0
fi

echo -e "${BLUE}Current imports:${NC}"
echo "$IMPORTS"
echo ""

# Count changes
CHANGE_COUNT=0

# Process the file with sed
# This will match import statements and extract just the basename
# Handles:
# - import("path/to/file.stl") -> import("file.stl")
# - import("/absolute/path/file.stl") -> import("file.stl")
# - import('path/to/file.stl') -> import("file.stl")

echo "Fixing import paths..."
echo ""

# Use perl for more powerful regex
perl -i -pe 's{import\s*\(\s*["\047]([^"'\'']*/)([^/"'\'']+\.stl)["\047]\s*\)}{
    my $path = $1;
    my $file = $2;
    print STDERR "  Changed: " . $path . $file . " -> " . $file . "\n";
    $ENV{CHANGE_COUNT}++;
    "import(\"" . $file . "\")"
}ge' "$SCAD_FILE" 2>&1 | while read -r line; do
    if [[ $line == *"Changed:"* ]]; then
        echo -e "${GREEN}✓${NC} $line"
        CHANGE_COUNT=$((CHANGE_COUNT + 1))
    fi
done

# Count actual changes by comparing files
if diff -q "$SCAD_FILE" "$BACKUP_FILE" > /dev/null; then
    echo -e "${YELLOW}No changes needed - all imports already use simple filenames${NC}"
    rm "$BACKUP_FILE"
else
    # Show diff
    echo ""
    echo "=========================================="
    echo "Changes made:"
    echo "=========================================="
    diff "$BACKUP_FILE" "$SCAD_FILE" | grep "^[<>]" | head -20
    
    if [ $(diff "$BACKUP_FILE" "$SCAD_FILE" | grep "^[<>]" | wc -l) -gt 20 ]; then
        echo "... (more changes)"
    fi
    
    echo ""
    echo "=========================================="
    echo -e "${GREEN}✓ Import paths fixed!${NC}"
    echo "Backup saved as: $BACKUP_FILE"
    echo ""
    echo "To restore original:"
    echo "  mv $BACKUP_FILE $SCAD_FILE"
    echo ""
    echo "To delete backup:"
    echo "  rm $BACKUP_FILE"
    echo "=========================================="
fi

echo ""
echo "Done!"
