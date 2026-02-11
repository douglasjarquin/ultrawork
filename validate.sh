#!/bin/bash
# Validate YAML frontmatter in all agent markdown files

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Validating YAML frontmatter in all markdown files..."

# Check if yamllint is installed
if ! command -v yamllint &> /dev/null; then
    echo -e "${RED}✖ yamllint is not installed. Install with: brew install yamllint${NC}"
    exit 1
fi

FAILED=0
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Find all markdown files (excluding README.md)
MD_FILES=$(find . -maxdepth 1 \( -name "*.md" -o -name "*.agent.md" \) ! -name "README.md" -print)

for FILE in $MD_FILES; do
    # Extract YAML frontmatter
    if grep -q "^---$" "$FILE"; then
        TEMP_YAML="$TEMP_DIR/$(basename $FILE .md).yaml"
        awk '/^---$/{flag=!flag; if(flag==0 && NR>1) exit; next} flag' "$FILE" > "$TEMP_YAML"

        if [ -s "$TEMP_YAML" ]; then
            echo -n "Checking $FILE... "
            if yamllint -c .yamllint "$TEMP_YAML" 2>&1 | grep -v "^$TEMP_YAML$" > /dev/null; then
                echo -e "${RED}✖ FAILED${NC}"
                echo -e "${YELLOW}Errors:${NC}"
                yamllint -c .yamllint "$TEMP_YAML" 2>&1 | grep -v "^$TEMP_YAML$" | sed "s|$TEMP_YAML|$FILE|g"
                FAILED=1
            else
                echo -e "${GREEN}✓ OK${NC}"
            fi
        fi
    else
        echo -e "$FILE: ${YELLOW}⚠ No frontmatter${NC}"
    fi
done

if [ $FAILED -eq 1 ]; then
    echo -e "\n${RED}✖ Validation failed${NC}"
    exit 1
fi

echo -e "\n${GREEN}✓ All YAML frontmatter is valid${NC}"
exit 0
