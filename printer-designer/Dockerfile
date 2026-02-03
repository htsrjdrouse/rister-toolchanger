# Build stage for React client
FROM node:20-alpine AS client-build

WORKDIR /app/client
COPY client/package*.json ./
RUN npm install
COPY client/ ./
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copy server files
COPY server/package*.json ./
RUN npm install --production

COPY server/ ./

# Copy built React app
COPY --from=client-build /app/client/build ./public

# Create data directory
RUN mkdir -p /app/data

EXPOSE 3100

CMD ["node", "index.js"]
