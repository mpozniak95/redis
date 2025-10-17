#!/bin/bash
# Intel x86-64 Redis - AGGRESSIVE COMPILER OPTIMIZATIONS

echo "=== REDIS AGGRESSIVE INTEL COMPILER OPTIMIZATIONS ==="
echo "Using Intel-specific aggressive compiler flags..."

# Clean previous build
make clean

# Build with aggressive Intel optimizations
echo "Compiling with aggressive Intel optimizations..."
make OPTIMIZATION="-O3 -march=native -mtune=intel -mavx2 -mfma -mbmi2 -mpopcnt" \
     CFLAGS="-DDISABLE_INTEL_OPTIMIZATIONS -flto -funroll-loops -fprefetch-loop-arrays -finline-functions -fomit-frame-pointer" \
     LDFLAGS="-flto" \
     -j$(nproc)

if [ $? -eq 0 ]; then
    echo "Build successful! Aggressive Intel optimizations compiled."
    echo "Binary: src/redis-server"
    echo ""
    echo "Optimizations used:"
    echo "- AVX2 vectorization"
    echo "- FMA (Fused Multiply-Add)"
    echo "- BMI2 (Bit Manipulation)"
    echo "- POPCNT instruction"
    echo "- Link Time Optimization (LTO)"
    echo "- Loop unrolling"
    echo "- Prefetch loop arrays"
else
    echo "Build failed!"
    exit 1
fi