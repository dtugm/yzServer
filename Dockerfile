FROM node:18-alpine

RUN apk add --no-cache wget bash libc6-compat

RUN npm install -g tileserver-gl-light

WORKDIR /app

COPY download-tiles.sh /app/
RUN chmod +x /app/download-tiles.sh

ENV PORT=8080
EXPOSE 8080

# Jalankan download di background
# Gunakan --verbose false pada tileserver jika ingin log lebih sedikit lagi
CMD ["/bin/bash", "-c", "/app/download-tiles.sh & tileserver-gl-light --port 8080"]