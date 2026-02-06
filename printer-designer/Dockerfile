# Build stage for React client
FROM node:20-slim AS client-build

WORKDIR /app/client
COPY client/package*.json ./
RUN npm install
COPY client/ ./
RUN npm run build

# Production stage
FROM node:20-bookworm-slim

# Install dependencies for PrusaSlicer and xvfb for headless rendering
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    libgtk-3-0 \
    libgl1-mesa-glx \
    libglu1-mesa \
    xvfb \
    libpng16-16 \
    libjpeg62-turbo \
    libwebp7 \
    libexpat1 \
    && rm -rf /var/lib/apt/lists/*

# Download PrusaSlicer portable version (extracted from AppImage)
# Using a static build approach - download and extract
RUN mkdir -p /opt/prusaslicer && \
    cd /opt/prusaslicer && \
    wget -q "https://github.com/prusa3d/PrusaSlicer/releases/download/version_2.7.4/PrusaSlicer-2.7.4+linux-x64-GTK3-202404050928.tar.bz2" -O prusa.tar.bz2 && \
    tar -xjf prusa.tar.bz2 --strip-components=1 && \
    rm prusa.tar.bz2 && \
    chmod +x /opt/prusaslicer/prusa-slicer

# Create wrapper script to run PrusaSlicer headless
RUN echo '#!/bin/bash\nxvfb-run --auto-servernum --server-args="-screen 0 1024x768x24" /opt/prusaslicer/prusa-slicer "$@"' > /usr/local/bin/prusa-slicer-cli && \
    chmod +x /usr/local/bin/prusa-slicer-cli

# Also create a direct link for local development (when xvfb not needed)
RUN ln -s /opt/prusaslicer/prusa-slicer /usr/local/bin/prusa-slicer

WORKDIR /app

# Copy server files and install production deps + JSCAD CLI
COPY server/package*.json ./
RUN npm install --production

# Install JSCAD CLI globally for shape compilation
RUN npm install -g @jscad/cli

COPY server/ ./

# Copy built React app
COPY --from=client-build /app/client/build ./public

# Create data and temp directories
RUN mkdir -p /app/data /app/temp /app/slicer-profiles /app/data/shapes

# Copy default slicer profile for nanoarray
COPY slicer-profiles/ /app/slicer-profiles/

EXPOSE 3100

CMD ["node", "index.js"]
