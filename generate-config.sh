#!/bin/sh

echo "=========================================="
echo "Generating config.json..."
echo "=========================================="

CONFIG_FILE="/app/config.json"

# Start JSON
cat > $CONFIG_FILE << 'EOF'
{
  "options": {
    "paths": {
      "root": "",
      "fonts": "fonts",
      "sprites": "sprites",
      "styles": "styles",
      "mbtiles": "/app"
    },
    "serveAllFonts": false,
    "serveStaticMaps": true
  },
  "styles": {},
  "data": {
EOF

# Add each mbtiles file
FIRST=true
for file in /app/*.mbtiles; do
    if [ -f "$file" ]; then
        # Get filename without path and extension
        BASENAME=$(basename "$file" .mbtiles)
        
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            echo "," >> $CONFIG_FILE
        fi
        
        echo "  Adding: $BASENAME"
        
        cat >> $CONFIG_FILE << EOF
    "$BASENAME": {
      "mbtiles": "$file"
    }
EOF
    fi
done

# Close JSON
cat >> $CONFIG_FILE << 'EOF'

  }
}
EOF

echo "=========================================="
echo "Config generated:"
cat $CONFIG_FILE
echo "=========================================="
