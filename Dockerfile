# FROM node:18-alpine
# RUN npm install -g tileserver-gl-light
# WORKDIR /app
# COPY output.mbtiles /app/
# EXPOSE 8080
# CMD ["tileserver-gl-light", "output.mbtiles", "--port", "8080"]
FROM node:18-alpine

RUN apk add --no-cache wget

RUN npm install -g tileserver-gl-light

WORKDIR /app

COPY download-tiles.sh /app/
COPY start-server.sh /app/
RUN chmod +x /app/*.sh

EXPOSE 8080

CMD ["/bin/sh", "-c", "/app/download-tiles.sh && /app/start-server.sh"]
