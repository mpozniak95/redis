#!/bin/bash
# Intel x86-64 Redis Optimization Build Script - CONSERVATIVE VERSION

echo "=== INTEL x86-64 REDIS OPTIMIZATION BUILD (CONSERVATIVE) ==="
echo "Building Redis with conservative Intel optimizations..."

# Clean previous build
make clean

# Build with less aggressive Intel-specific optimizations
echo "Compiling with conservative Intel-specific flags..."

make OPTIMIZATION="-O3 -march=native -mtune=intel" \
     CFLAGS="-D__INTEL_OPTIMIZED__ -DDEBUG_INTEL_OPT" \
     -j$(nproc)

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "=== CONSERVATIVE INTEL OPTIMIZATION SUMMARY ==="
    echo "• EVENT LOOP: Moderate batching and timeouts (10ms instead of 1ms)"
    echo "• SOCKET I/O: Basic TCP optimizations without excessive prefetching"
    echo "• COMPILER: -O3 -march=native -mtune=intel (no LTO for now)"
    echo ""
    echo "This version reduces aggressive optimizations that may have hurt performance"
    echo ""
    
    echo "=== QUICK TEST ==="
    echo "Starting Redis server for basic test..."
    
    # Start Redis in background
    ./src/redis-server --daemonize yes --port 6380 --logfile redis-opt.log
    sleep 2
    
    if pgrep -f "redis-server.*6380" > /dev/null; then
        echo "✅ Redis server started on port 6380"
        
        # Quick benchmark test
        echo "Running quick benchmark test..."
        ./src/redis-benchmark -p 6380 -t set,get -n 10000 -q
        
        # Stop Redis
        ./src/redis-cli -p 6380 shutdown
        echo "✅ Test completed"
    else
        echo "❌ Failed to start Redis server"
    fi
else
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "=== BENCHMARKING COMMANDS ==="
echo "For string decrement test:"
echo "  ./src/redis-benchmark -t decr -n 1000000 -c 50 -P 16"
echo ""
echo "Debug output should show: 'DEBUG: Intel x86-64 optimizations ACTIVE'"