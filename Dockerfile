FROM node:18-alpine

# 1. Install dependencies sistem
# bash: untuk shell execution yang lebih stabil dibanding sh
# wget: untuk download
# libc6-compat: PENTING untuk tileserver (mapbox-gl-native) di Alpine agar tidak crash
RUN apk add --no-cache wget bash libc6-compat

# 2. Install tileserver
RUN npm install -g tileserver-gl-light

WORKDIR /app

# 3. Copy scripts
COPY download-tiles.sh /app/
COPY start-server.sh /app/
RUN chmod +x /app/*.sh

# 4. Set Environment Variable
ENV PORT=8080

EXPOSE 8080

# 5. Jalankan dengan Bash
# Pastikan script download sukses dulu (&&), baru start server
CMD ["/bin/bash", "-c", "./download-tiles.sh && ./start-server.sh"]