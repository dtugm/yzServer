#!/bin/sh

echo "=========================================="
echo "Starting download from S3..."
echo "=========================================="

# Validasi environment variables
if [ -z "$TILES_FILES" ]; then
    echo "❌ ERROR: TILES_FILES not set"
    exit 1
fi

if [ -z "$S3_BUCKET" ]; then
    echo "❌ ERROR: S3_BUCKET not set"
    exit 1
fi

# Default AWS_REGION jika tidak diset
AWS_REGION=${AWS_REGION:-us-east-1}

echo "Files to download: $TILES_FILES"
echo "S3 Bucket: $S3_BUCKET"
echo "Region: $AWS_REGION"
echo "Prefix: ${S3_PREFIX:-none}"
echo "=========================================="

download_file() {
    local filename=$1
    echo "📥 Downloading $filename..."
    
    if [ -n "$S3_PREFIX" ]; then
        FULL_URL="https://${S3_BUCKET}.s3.${AWS_REGION}.amazonaws.com/${S3_PREFIX}${filename}"
    else
        FULL_URL="https://${S3_BUCKET}.s3.${AWS_REGION}.amazonaws.com/${filename}"
    fi
    
    echo "   URL: $FULL_URL"
    
    # Download dengan retry
    MAX_RETRIES=3
    RETRY_COUNT=0
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        wget -q --show-progress -O "/app/${filename}" "$FULL_URL"
        
        if [ $? -eq 0 ]; then
            FILE_SIZE=$(ls -lh "/app/$filename" | awk '{print $5}')
            echo "   ✅ $filename downloaded ($FILE_SIZE)"
            return 0
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))
            echo "   ⚠️  Retry $RETRY_COUNT/$MAX_RETRIES..."
            sleep 2
        fi
    done
    
    echo "   ❌ Failed to download $filename after $MAX_RETRIES attempts"
    return 1
}

# Track failures
FAILED_DOWNLOADS=""

# Download files
IFS=','
for file in $TILES_FILES; do
    file=$(echo "$file" | tr -d ' ')
    if [ -n "$file" ]; then
        download_file "$file" &
        PIDS="$PIDS $!"
    fi
done
unset IFS

# Wait and check exit codes
for pid in $PIDS; do
    wait $pid
    if [ $? -ne 0 ]; then
        FAILED_DOWNLOADS="$FAILED_DOWNLOADS $pid"
    fi
done

echo "=========================================="

if [ -n "$FAILED_DOWNLOADS" ]; then
    echo "❌ Some downloads failed!"
    exit 1
fi

echo "✅ All downloads complete!"
echo "=========================================="
echo "Downloaded files:"
ls -lh /app/*.mbtiles 2>/dev/null || echo "⚠️  No .mbtiles files found!"
echo "=========================================="
