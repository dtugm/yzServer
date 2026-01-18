#!/bin/bash

echo "=========================================="
echo "🚀 Starting Background Download Process..."
echo "=========================================="

# Validasi environment variables
if [ -z "$TILES_FILES" ] || [ -z "$S3_BUCKET" ]; then
    echo "❌ ERROR: TILES_FILES or S3_BUCKET not set"
    exit 1
fi

AWS_REGION=${AWS_REGION:-us-east-1}

download_file() {
    local filename=$1
    local filepath="/app/${filename}"

    if [ -f "$filepath" ] && [ -s "$filepath" ]; then
        echo "⏭️  $filename exists, skipping."
        return 0
    fi

    echo "📥 Downloading $filename (Progress hidden to avoid log limit)..."
    
    if [ -n "$S3_PREFIX" ]; then
        FULL_URL="https://${S3_BUCKET}.s3.${AWS_REGION}.amazonaws.com/${S3_PREFIX}${filename}"
    else
        FULL_URL="https://${S3_BUCKET}.s3.${AWS_REGION}.amazonaws.com/${filename}"
    fi
    
    # Gunakan -nv (non-verbose) agar wget hanya mencatat error dan selesai
    # Ini akan menghentikan "Log Flooding" di Railway
    if wget -nv -c -O "$filepath" "$FULL_URL"; then
        FILE_SIZE=$(ls -lh "$filepath" | awk '{print $5}')
        echo "✅ Finished: $filename ($FILE_SIZE)"
        return 0
    else
        echo "❌ Failed to download $filename"
        return 1
    fi
}

# Proses satu per satu agar RAM aman
IFS=',' read -ra ADDR <<< "$TILES_FILES"
for file in "${ADDR[@]}"; do
    file=$(echo "$file" | xargs)
    if [ -n "$file" ]; then
        download_file "$file"
    fi
done

echo "=========================================="
echo "✅ All downloads finished!"
echo "=========================================="