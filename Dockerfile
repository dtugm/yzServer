# FROM node:18-alpine
# RUN npm install -g tileserver-gl-light
# WORKDIR /app
# COPY output.mbtiles /app/
# EXPOSE 8080
# CMD ["tileserver-gl-light", "output.mbtiles", "--port", "8080"]
# FROM node:18-alpine

# RUN apk add --no-cache wget

# RUN npm install -g tileserver-gl-light

# WORKDIR /app

# COPY download-tiles.sh /app/
# COPY start-server.sh /app/
# RUN chmod +x /app/*.sh

# EXPOSE 8080

# CMD ["/bin/sh", "-c", "/app/download-tiles.sh && /app/start-server.sh"]


FROM node:18-alpine

# 1. Install dependencies sistem (libc6-compat wajib untuk mapbox-gl-native)
RUN apk add --no-cache wget bash libc6-compat

WORKDIR /app

# 2. Install tileserver secara lokal (lebih aman dari masalah PATH)
RUN npm install tileserver-gl-light

# 3. Copy script download
COPY download-tiles.sh /app/
RUN chmod +x /app/download-tiles.sh

# 4. Set Environment
ENV PORT=8080
EXPOSE 8080

# 5. Eksekusi menggunakan path binari lokal (node_modules/.bin/...)
# Kita arahkan langsung ke file binari agar tidak ada lagi 'command not found'
CMD ["/bin/bash", "-c", "/app/download-tiles.sh & ./node_modules/.bin/tileserver-gl-light --port 8080"]