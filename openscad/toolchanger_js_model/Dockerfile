FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source
COPY . .

# Build the app
RUN npm run build

# Generate list.json for STL files
RUN ls public/models/ | sort > public/models/list.json

# Install serve for production
RUN npm install -g serve

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000 || exit 1

# Start the server
CMD ["serve", "-s", "dist", "-l", "3000"]
