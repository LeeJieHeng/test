# ========================================
# Base dependencies stage
# ========================================
FROM node:lts-alpine AS build-deps
WORKDIR /usr/src/app

# Install dependencies
COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm install --silent
COPY . .

# ========================================
# Production Stage
# ========================================
FROM node:lts-alpine AS production
ENV NODE_ENV=production
WORKDIR /usr/src/app

# Copy only needed files from build-deps
COPY --from=build-deps /usr/src/app ./

# Install only production dependencies
RUN npm ci --omit=dev && \
    chown -R node /usr/src/app

USER node
EXPOSE 3000
CMD ["npm", "start"]

# ========================================
# Test Stage
# ========================================
FROM build-deps AS test
ENV NODE_ENV=test \
    CI=true

# Run tests
CMD ["npm", "run", "test:coverage"]
