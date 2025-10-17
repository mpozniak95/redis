#!/bin/bash
# Intel x86-64 Redis - AE_EPOLL ONLY OPTIMIZATIONS

echo "=== REDIS AE_EPOLL ONLY OPTIMIZATIONS ==="
echo "Testing only event loop optimizations (ae_epoll.c)..."

# Clean previous build
make clean

# Build with ONLY ae_epoll optimizations enabled
echo "Compiling with ae_epoll optimizations only..."
make OPTIMIZATION="-O3 -march=native -mtune=intel" \
     CFLAGS="-DDISABLE_INTEL_OPTIMIZATIONS -DENABLE_AE_EPOLL_INTEL_OPTS" \
     -j$(nproc)

if [ $? -eq 0 ]; then
    echo "Build successful! ae_epoll Intel optimizations compiled."
    echo "Binary: src/redis-server"
    echo ""
    echo "Test with: ./src/redis-server --port 6379"
else
    echo "Build failed!"
    exit 1
fi