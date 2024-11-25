# Base image
FROM node:16-bullseye as builder

WORKDIR /app

# Copy files and install dependencies
COPY ./package.json ./
COPY ./yarn.lock ./
RUN yarn install

# Copy application files
COPY . ./

# Add the API key as a build argument
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

# Build the application
RUN yarn build

# Second stage for running the app
FROM debian:bullseye-slim
WORKDIR /usr/share/nginx/html

RUN apt-get update && apt-get install -y nginx strace curl && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/dist .

EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
