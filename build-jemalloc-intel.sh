#!/bin/bash
# Redis with Intel-optimized jemalloc

echo "=== REDIS WITH INTEL-OPTIMIZED JEMALLOC ==="
echo "Building Redis with jemalloc optimizations for Intel..."

# Clean previous build
make clean

# Build with jemalloc and Intel optimizations
echo "Compiling with jemalloc and Intel optimizations..."
make MALLOC=jemalloc \
     OPTIMIZATION="-O3 -march=native -mtune=intel" \
     CFLAGS="-DDISABLE_INTEL_OPTIMIZATIONS" \
     -j$(nproc)

echo ""
echo "=== JEMALLOC RUNTIME TUNING ==="
echo "Set these environment variables before running Redis:"
echo ""
echo "export MALLOC_CONF=\"dirty_decay_ms:1000,muzzy_decay_ms:5000,lg_chunk:21\""
echo ""
echo "For Intel-specific tuning:"
echo "export MALLOC_CONF=\"dirty_decay_ms:1000,muzzy_decay_ms:5000,lg_chunk:21,percpu_arena:percpu\""
echo ""

if [ $? -eq 0 ]; then
    echo "Build successful! jemalloc optimizations compiled."
else
    echo "Build failed!"
    exit 1
fi