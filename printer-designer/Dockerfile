# Build stage for React client
FROM node:20-slim AS client-build

WORKDIR /app/client
COPY client/package*.json ./
RUN npm install
COPY client/ ./
RUN npm run build

# Production stage
FROM node:20-slim

WORKDIR /app

# Copy server files and install production deps
COPY server/package*.json ./
RUN npm install --production

COPY server/ ./

# Copy built React app
COPY --from=client-build /app/client/build ./public

# Create data directory
RUN mkdir -p /app/data

EXPOSE 3100

CMD ["node", "index.js"]
