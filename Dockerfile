# ==========================================
# STAGE 1: Build Environment (Ubuntu)
# ==========================================
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy files (respects .dockerignore)
COPY . .

# Compile the release build profile
RUN mkdir build && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release .. \
    && cmake --build .

# ==========================================
# STAGE 2: Ultra-Lightweight Production Runtime (Distroless)
# ==========================================
FROM gcr.io/distroless/cc-debian12

WORKDIR /app

# Copy your production application binary file directly from the builder
COPY --from=builder /app/build/MyProject /app/MyProject

# Copy your project assets
COPY --from=builder /app/resources /app/resources

# Command to execute when the container starts up
ENTRYPOINT ["./MyProject"]
