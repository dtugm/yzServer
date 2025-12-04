#!/bin/sh

echo "=========================================="
echo "Starting download from S3..."
echo "=========================================="

# Configure AWS (jika pakai private bucket)
if [ -n "$AWS_ACCESS_KEY_ID" ]; then
    echo "Configuring AWS credentials..."
    aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
    aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
    aws configure set region "$AWS_REGION"
fi

# Function download dengan progress
download_file() {
    local filename=$1
    local s3_path=$2
    
    echo "Downloading $filename..."
    
    if [ -n "$AWS_ACCESS_KEY_ID" ]; then
        # Pakai AWS CLI (private bucket)
        aws s3 cp "$s3_path" "/app/$filename"
    else
        # Pakai wget (public bucket)
        wget -O "/app/$filename" "$s3_path"
    fi
    
    if [ $? -eq 0 ]; then
        echo "✓ $filename downloaded successfully"
        ls -lh "/app/$filename"
    else
        echo "✗ Failed to download $filename"
        exit 1
    fi
}

# Download semua files (parallel untuk lebih cepat)
download_file "indonesia.mbtiles" "s3://${S3_BUCKET}/indonesia.mbtiles" &
download_file "provinsi.mbtiles" "s3://${S3_BUCKET}/provinsi.mbtiles" &
download_file "kabupaten.mbtiles" "s3://${S3_BUCKET}/kabupaten.mbtiles" &
download_file "kecamatan.mbtiles" "s3://${S3_BUCKET}/kecamatan.mbtiles" &

# Wait semua download selesai
wait

echo "=========================================="
echo "All downloads complete!"
echo "=========================================="
ls -lh /app/*.mbtiles
