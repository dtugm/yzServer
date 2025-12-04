#!/bin/sh

echo "=========================================="
echo "Starting TileServer GL Light..."
echo "=========================================="

# Generate config dynamically
cat > /app/config.json << 'CONFIGSTART'
{
  "options": {
    "paths": {
      "root": "",
      "mbtiles": "/app"
    }
  },
  "data": {
CONFIGSTART

# Add all mbtiles files to config
FIRST=true
for file in /app/*.mbtiles; do
    if [ -f "$file" ]; then
        BASENAME=$(basename "$file" .mbtiles)
        
        if [ "$FIRST" = false ]; then
            echo "," >> /app/config.json
        fi
        FIRST=false
        
        echo "    \"$BASENAME\": {" >> /app/config.json
        echo "      \"mbtiles\": \"$file\"" >> /app/config.json
        echo -n "    }" >> /app/config.json
        
        echo "📍 Added: $BASENAME"
    fi
done

# Close config
cat >> /app/config.json << 'CONFIGEND'

  }
}
CONFIGEND

echo "=========================================="
echo "Generated config:"
cat /app/config.json
echo "=========================================="

# Start server
exec tileserver-gl-light --port 8080 --config /app/config.json
