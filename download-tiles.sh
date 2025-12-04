#!/bin/sh

echo "=========================================="
echo "Downloading ALL .mbtiles from S3..."
echo "=========================================="

# Configure AWS
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set region "$AWS_REGION"

# List semua .mbtiles files di bucket
echo "Listing files in s3://${S3_BUCKET}/"
FILES=$(aws s3 ls s3://${S3_BUCKET}/ | grep '.mbtiles$' | awk '{print $4}')

# Download semua files
for file in $FILES; do
    echo "Downloading $file..."
    aws s3 cp "s3://${S3_BUCKET}/${file}" "/app/${file}" &
done

# Wait semua selesai
wait

echo "=========================================="
echo "All downloads complete!"
echo "=========================================="
ls -lh /app/*.mbtiles
