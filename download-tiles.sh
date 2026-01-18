#!/bin/bash

echo "=========================================="
echo "🚀 Starting Background Download Process..."
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

AWS_REGION=${AWS_REGION:-us-east-1}

download_file() {
    local filename=$1
    local filepath="/app/${filename}"

    # Cek jika file sudah ada untuk menghemat kuota S3 & bandwidth
    if [ -f "$filepath" ] && [ -s "$filepath" ]; then
        echo "⏭️  $filename already exists, skipping."
        return 0
    fi

    echo "📥 Downloading $filename..."
    
    if [ -n "$S3_PREFIX" ]; then
        FULL_URL="https://${S3_BUCKET}.s3.${AWS_REGION}.amazonaws.com/${S3_PREFIX}${filename}"
    else
        FULL_URL="https://${S3_BUCKET}.s3.${AWS_REGION}.amazonaws.com/${filename}"
    fi
    
    # Download dengan retry (Sequential)
    MAX_RETRIES=3
    RETRY_COUNT=0
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        # -c agar jika terputus bisa resume, -q untuk clean log
        wget -q --show-progress -c -O "$filepath" "$FULL_URL"
        
        if [ $? -eq 0 ]; then
            FILE_SIZE=$(ls -lh "$filepath" | awk '{print $5}')
            echo "   ✅ $filename downloaded ($FILE_SIZE)"
            return 0
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))
            echo "   ⚠️  Retry $RETRY_COUNT/$MAX_RETRIES..."
            sleep 5
        fi
    done
    
    echo "   ❌ Failed to download $filename"
    return 1
}

# Download files secara SEQUENTIAL (Satu per satu)
# Menggunakan bash array agar lebih aman dibanding IFS lama
IFS=',' read -ra ADDR <<< "$TILES_FILES"
for file in "${ADDR[@]}"; do
    file=$(echo "$file" | xargs) # trim whitespace
    if [ -n "$file" ]; then
        download_file "$file"
        # Kita tidak pakai '&' di sini agar RAM Railway tidak penuh
    fi
done

echo "=========================================="
echo "✅ Background download tasks finished!"
echo "=========================================="