# ==========================================
# STAGE 1: Build Environment (Ubuntu - Keeps your compilation safe)
# ==========================================
FROM ubuntu:22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y build-essential cmake git \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . .
RUN mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release .. \
    && cmake --build .

# ==========================================
# STAGE 2: Ultra-Lightweight Shell Environment (Alpine)
# ==========================================
FROM alpine:3.19

WORKDIR /app

# Copy your statically linked production binary and assets
COPY --from=builder /app/build/MyProject /app/MyProject
COPY --from=builder /app/resources /app/resources

# Make the container drop directly into the shell by default
ENTRYPOINT ["/bin/sh"]
