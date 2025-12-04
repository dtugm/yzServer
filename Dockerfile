# FROM node:18-alpine
# RUN npm install -g tileserver-gl-light
# WORKDIR /app
# COPY output.mbtiles /app/
# EXPOSE 8080
# CMD ["tileserver-gl-light", "output.mbtiles", "--port", "8080"]
FROM node:18-alpine

# Install dependencies
RUN apk add --no-cache aws-cli wget

# Install tileserver-gl-light
RUN npm install -g tileserver-gl-light

# Set working directory
WORKDIR /app

# Copy download script
COPY download-tiles.sh /app/
RUN chmod +x /app/download-tiles.sh

# Expose port
EXPOSE 8080

# Download tiles then start server
CMD ["/bin/sh", "-c", "/app/download-tiles.sh && tileserver-gl-light *.mbtiles --port 8080"]
