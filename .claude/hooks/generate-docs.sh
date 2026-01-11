#!/bin/bash

# Auto-documentation generator
# This script automatically generates documentation from code before commit

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "📚 Auto-generating documentation..."

# Get list of staged JavaScript files
STAGED_JS_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|jsx)$' || true)

if [ -z "$STAGED_JS_FILES" ]; then
    echo -e "${YELLOW}No JavaScript files staged, skipping documentation generation${NC}"
    exit 0
fi

# Create docs directory if it doesn't exist
mkdir -p docs

DOCS_UPDATED=0

# =============================================================================
# 1. Generate API Routes Documentation
# =============================================================================

echo ""
echo -e "${BLUE}📡 Generating API routes documentation...${NC}"

API_ROUTES_FILE="docs/API.md"
ROUTES_DIR="src/server/routes"

if [ -d "$ROUTES_DIR" ] || [ -d "routes" ]; then
    # Try both possible locations
    if [ -d "$ROUTES_DIR" ]; then
        SEARCH_DIR="$ROUTES_DIR"
    else
        SEARCH_DIR="routes"
    fi

    # Generate API documentation header
    cat > "$API_ROUTES_FILE" << 'EOF'
# API Documentation

Auto-generated from route definitions.

> **Last Updated:** $(date '+%Y-%m-%d %H:%M:%S')

## Table of Contents

EOF

    # Find all route files
    ROUTE_FILES=$(find "$SEARCH_DIR" -name "*.routes.js" 2>/dev/null || find "$SEARCH_DIR" -name "*routes.js" 2>/dev/null || true)

    if [ ! -z "$ROUTE_FILES" ]; then
        # Process each route file
        for ROUTE_FILE in $ROUTE_FILES; do
            ROUTE_NAME=$(basename "$ROUTE_FILE" .routes.js | sed 's/.routes//')
            ROUTE_NAME=$(echo "$ROUTE_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')

            echo "- [$ROUTE_NAME](#${ROUTE_NAME// /-})" >> "$API_ROUTES_FILE"
        done

        echo "" >> "$API_ROUTES_FILE"

        # Extract routes from each file
        for ROUTE_FILE in $ROUTE_FILES; do
            ROUTE_NAME=$(basename "$ROUTE_FILE" .routes.js | sed 's/.routes//')
            ROUTE_NAME=$(echo "$ROUTE_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')

            echo "## $ROUTE_NAME" >> "$API_ROUTES_FILE"
            echo "" >> "$API_ROUTES_FILE"

            # Extract JSDoc and route definitions
            awk '
                /\/\*\*/ {in_jsdoc=1; jsdoc=""}
                in_jsdoc {jsdoc=jsdoc $0 "\n"}
                /\*\// {in_jsdoc=0}
                /router\.(get|post|put|patch|delete|all)/ {
                    method=toupper(gensub(/.*router\.([a-z]+).*/, "\\1", 1))
                    path=gensub(/.*['\''"]([^'\''"]*)['\''"'].*/, "\\1", 1)

                    # Extract description from JSDoc
                    desc=""
                    if (jsdoc ~ /@description/) {
                        desc=gensub(/.*@description[ \t]+([^\n@]*).*/, "\\1", 1, jsdoc)
                    } else if (jsdoc ~ /\* [A-Z]/) {
                        desc=gensub(/.*\* ([A-Z][^\n]*).*/, "\\1", 1, jsdoc)
                    }

                    # Extract parameters
                    params=""
                    while (match(jsdoc, /@param \{[^}]+\} ([^ ]+) - ([^\n]+)/)) {
                        param_name=substr(jsdoc, RSTART, RLENGTH)
                        gsub(/@param \{[^}]+\} /, "", param_name)
                        params=params "\n  - " param_name
                        jsdoc=substr(jsdoc, RSTART + RLENGTH)
                    }

                    print "### `" method " " path "`"
                    print ""
                    if (desc != "") print desc
                    if (params != "") {
                        print "\n**Parameters:**"
                        print params
                    }
                    print ""

                    jsdoc=""
                }
            ' "$ROUTE_FILE" >> "$API_ROUTES_FILE"

            echo "" >> "$API_ROUTES_FILE"
        done

        # Add timestamp
        sed -i.bak "s/\$(date '+%Y-%m-%d %H:%M:%S')/$(date '+%Y-%m-%d %H:%M:%S')/" "$API_ROUTES_FILE"
        rm -f "${API_ROUTES_FILE}.bak"

        echo -e "${GREEN}✓ Generated API documentation: $API_ROUTES_FILE${NC}"
        git add "$API_ROUTES_FILE" 2>/dev/null || true
        DOCS_UPDATED=$((DOCS_UPDATED + 1))
    else
        echo -e "${YELLOW}⚠️  No route files found in $SEARCH_DIR${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No routes directory found${NC}"
fi

# =============================================================================
# 2. Generate Component Documentation
# =============================================================================

echo ""
echo -e "${BLUE}⚛️  Generating React component documentation...${NC}"

COMPONENTS_FILE="docs/COMPONENTS.md"
COMPONENTS_DIR="src/components"

if [ -d "$COMPONENTS_DIR" ] || [ -d "src/client/components" ] || [ -d "components" ]; then
    # Try multiple possible locations
    for DIR in "$COMPONENTS_DIR" "src/client/components" "components"; do
        if [ -d "$DIR" ]; then
            SEARCH_DIR="$DIR"
            break
        fi
    done

    cat > "$COMPONENTS_FILE" << 'EOF'
# Component Documentation

Auto-generated from React component JSDoc comments.

> **Last Updated:** $(date '+%Y-%m-%d %H:%M:%S')

## Components

EOF

    # Find all component files
    COMPONENT_FILES=$(find "$SEARCH_DIR" -name "*.jsx" 2>/dev/null || true)

    if [ ! -z "$COMPONENT_FILES" ]; then
        for COMPONENT_FILE in $COMPONENT_FILES; do
            COMPONENT_NAME=$(basename "$COMPONENT_FILE" .jsx)

            # Extract JSDoc for the main export
            awk -v comp="$COMPONENT_NAME" '
                /\/\*\*/ {in_jsdoc=1; jsdoc=""}
                in_jsdoc {jsdoc=jsdoc $0 "\n"}
                /\*\// {in_jsdoc=0}
                /export (default )?function '"$COMPONENT_NAME"'|export (const|function) '"$COMPONENT_NAME"'/ {
                    if (jsdoc != "") {
                        print "### " comp
                        print ""

                        # Extract description
                        if (match(jsdoc, /\* ([A-Z][^\n@]*)/)) {
                            desc=substr(jsdoc, RSTART+2, RLENGTH-2)
                            print desc
                            print ""
                        }

                        # Extract props
                        has_props=0
                        while (match(jsdoc, /@param \{[^}]+\} props\.([^ ]+) - ([^\n]+)/)) {
                            if (has_props == 0) {
                                print "**Props:**"
                                print ""
                                has_props=1
                            }
                            prop_line=substr(jsdoc, RSTART, RLENGTH)
                            gsub(/@param \{([^}]+)\} props\.([^ ]+) - (.*)/, "- `\\2` (\\1): \\3", prop_line)
                            print prop_line
                            jsdoc=substr(jsdoc, RSTART + RLENGTH)
                        }

                        # Extract example if present
                        if (match(jsdoc, /@example[\n ]+([^@]*)/)) {
                            print "\n**Example:**"
                            print "```jsx"
                            example=substr(jsdoc, RSTART, RLENGTH)
                            gsub(/@example[\n \*]+/, "", example)
                            gsub(/[ \*]+$/, "", example)
                            print example
                            print "```"
                        }

                        print ""
                    }
                    jsdoc=""
                }
            ' "$COMPONENT_FILE" >> "$COMPONENTS_FILE"
        done

        # Add timestamp
        sed -i.bak "s/\$(date '+%Y-%m-%d %H:%M:%S')/$(date '+%Y-%m-%d %H:%M:%S')/" "$COMPONENTS_FILE"
        rm -f "${COMPONENTS_FILE}.bak"

        echo -e "${GREEN}✓ Generated component documentation: $COMPONENTS_FILE${NC}"
        git add "$COMPONENTS_FILE" 2>/dev/null || true
        DOCS_UPDATED=$((DOCS_UPDATED + 1))
    else
        echo -e "${YELLOW}⚠️  No React components found${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No components directory found${NC}"
fi

# =============================================================================
# 3. Generate Function/Module Documentation
# =============================================================================

echo ""
echo -e "${BLUE}📦 Generating module documentation...${NC}"

MODULES_FILE="docs/MODULES.md"

cat > "$MODULES_FILE" << 'EOF'
# Module Documentation

Auto-generated from JSDoc comments in utility modules and services.

> **Last Updated:** $(date '+%Y-%m-%d %H:%M:%S')

## Modules

EOF

# Find utility and service files
for DIR in "src/utils" "src/services" "src/helpers" "utils" "services" "helpers" "lib"; do
    if [ -d "$DIR" ]; then
        MODULE_FILES=$(find "$DIR" -name "*.js" -not -name "*.test.js" -not -name "*.spec.js" 2>/dev/null || true)

        for MODULE_FILE in $MODULE_FILES; do
            MODULE_NAME=$(basename "$MODULE_FILE" .js)
            MODULE_PATH=$(dirname "$MODULE_FILE")

            echo "### $MODULE_NAME" >> "$MODULES_FILE"
            echo "" >> "$MODULES_FILE"
            echo "*Location:* \`$MODULE_FILE\`" >> "$MODULES_FILE"
            echo "" >> "$MODULES_FILE"

            # Extract all exported functions with JSDoc
            awk '
                /\/\*\*/ {in_jsdoc=1; jsdoc=""}
                in_jsdoc {jsdoc=jsdoc $0 "\n"}
                /\*\// {in_jsdoc=0}
                /export (async )?function|export const .* = (async )?\(|^(async )?function/ {
                    if (jsdoc != "") {
                        # Extract function name
                        if (match($0, /function ([a-zA-Z0-9_]+)/)) {
                            func_name=substr($0, RSTART+9, RLENGTH-9)
                        } else if (match($0, /const ([a-zA-Z0-9_]+)/)) {
                            func_name=substr($0, RSTART+6, RLENGTH-6)
                        }

                        print "#### `" func_name "()`"
                        print ""

                        # Extract description
                        if (match(jsdoc, /\* ([A-Z][^\n@]*)/)) {
                            desc=substr(jsdoc, RSTART+2, RLENGTH-2)
                            print desc
                            print ""
                        }

                        # Extract parameters
                        has_params=0
                        temp_jsdoc=jsdoc
                        while (match(temp_jsdoc, /@param \{([^}]+)\} ([^ ]+) - ([^\n]+)/)) {
                            if (has_params == 0) {
                                print "**Parameters:**\n"
                                has_params=1
                            }
                            param_line=substr(temp_jsdoc, RSTART, RLENGTH)
                            gsub(/@param \{([^}]+)\} ([^ ]+) - (.*)/, "- `\\2` (\\1): \\3", param_line)
                            print param_line
                            temp_jsdoc=substr(temp_jsdoc, RSTART + RLENGTH)
                        }

                        # Extract return value
                        if (match(jsdoc, /@returns \{([^}]+)\} ([^\n]+)/)) {
                            return_line=substr(jsdoc, RSTART, RLENGTH)
                            gsub(/@returns \{([^}]+)\} (.*)/, "\n**Returns:** \\1 - \\2", return_line)
                            print return_line
                        }

                        print "\n---\n"
                    }
                    jsdoc=""
                }
            ' "$MODULE_FILE" >> "$MODULES_FILE"
        done
    fi
done

# Add timestamp
sed -i.bak "s/\$(date '+%Y-%m-%d %H:%M:%S')/$(date '+%Y-%m-%d %H:%M:%S')/" "$MODULES_FILE"
rm -f "${MODULES_FILE}.bak"

echo -e "${GREEN}✓ Generated module documentation: $MODULES_FILE${NC}"
git add "$MODULES_FILE" 2>/dev/null || true
DOCS_UPDATED=$((DOCS_UPDATED + 1))

# =============================================================================
# 4. Update README with documentation links
# =============================================================================

if [ -f "README.md" ] && [ $DOCS_UPDATED -gt 0 ]; then
    echo ""
    echo -e "${BLUE}📝 Updating README.md with documentation links...${NC}"

    # Check if documentation section exists
    if ! grep -q "## Documentation" README.md; then
        # Add documentation section before License or at the end
        if grep -q "## License" README.md; then
            # Insert before License
            sed -i.bak '/## License/i\
## Documentation\
\
- [API Documentation](docs/API.md) - REST API endpoints\
- [Component Documentation](docs/COMPONENTS.md) - React components\
- [Module Documentation](docs/MODULES.md) - Utility functions and services\
\
' README.md
        else
            # Append at the end
            cat >> README.md << 'EOF'

## Documentation

- [API Documentation](docs/API.md) - REST API endpoints
- [Component Documentation](docs/COMPONENTS.md) - React components
- [Module Documentation](docs/MODULES.md) - Utility functions and services

EOF
        fi

        rm -f README.md.bak
        echo -e "${GREEN}✓ Added documentation section to README.md${NC}"
        git add README.md 2>/dev/null || true
    else
        echo -e "${GREEN}✓ Documentation section already exists in README.md${NC}"
    fi
fi

# =============================================================================
# Summary
# =============================================================================

echo ""
echo "========================================"
if [ $DOCS_UPDATED -gt 0 ]; then
    echo -e "${GREEN}✓ Successfully generated $DOCS_UPDATED documentation file(s)${NC}"
    echo ""
    echo "Generated documentation:"
    [ -f "$API_ROUTES_FILE" ] && echo "  • $API_ROUTES_FILE"
    [ -f "$COMPONENTS_FILE" ] && echo "  • $COMPONENTS_FILE"
    [ -f "$MODULES_FILE" ] && echo "  • $MODULES_FILE"
    echo ""
    echo "Documentation files have been staged for commit."
else
    echo -e "${YELLOW}⚠️  No documentation generated${NC}"
fi
echo "========================================"
echo ""