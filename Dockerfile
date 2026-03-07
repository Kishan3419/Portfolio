# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm ci --save-dev postcss postcss-cli autoprefixer cssnano tailwindcss

# Copy project files
COPY . .

# Build CSS
RUN npm run css -- --env production

# Production stage
FROM nginx:alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy built files from builder stage
COPY --from=builder /app/index.html ./
COPY --from=builder /app/post.html ./
COPY --from=builder /app/assets ./assets

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
