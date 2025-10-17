#!/bin/bash
# Intel x86-64 Redis - MINIMAL SAFE OPTIMIZATIONS

echo "=== REDIS MINIMAL INTEL OPTIMIZATIONS ==="
echo "Reverting harmful optimizations, keeping only safe compiler flags..."

# Clean previous build
make clean

# Build with ONLY safe compiler optimizations - no code changes
echo "Compiling with safe Intel compiler flags only..."
make OPTIMIZATION="-O3 -march=native -mtune=intel" \
     CFLAGS="-DDISABLE_INTEL_OPTIMIZATIONS" \
     -j$(nproc)

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "=== MINIMAL OPTIMIZATION SUMMARY ==="
    echo "• ONLY compiler flags: -O3 -march=native -mtune=intel"
    echo "• ALL code optimizations DISABLED"
    echo "• No prefetching, no timeout changes, no socket mods"
    echo "• Pure Intel CPU instruction optimization only"
    echo ""
    
    echo "=== QUICK TEST ==="
    ./src/redis-server --daemonize yes --port 6381 --logfile redis-minimal.log
    sleep 2
    
    if pgrep -f "redis-server.*6381" > /dev/null; then
        echo "✅ Redis server started on port 6381"
        echo "Running quick benchmark test..."
        ./src/redis-benchmark -p 6381 -t set,get -n 10000 -q
        ./src/redis-cli -p 6381 shutdown
        echo "✅ Test completed"
    fi
else
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "=== BENCHMARKING COMMANDS ==="
echo "For string decrement test:"
echo "  ./src/redis-benchmark -p 6381 -t decr -n 1000000 -c 50 -P 16"
echo ""
echo "This should perform better than baseline if Intel CPU optimization works"