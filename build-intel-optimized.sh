#!/bin/bash
# Intel x86-64 Redis Optimization Build and Test Script

echo "=== INTEL x86-64 REDIS OPTIMIZATION BUILD ==="
echo "Building optimized Redis for Intel architecture..."

# Clean previous build
make clean

# Build with Intel-specific optimizations
echo "Compiling with Intel-specific flags..."
make OPTIMIZATION="-O3 -march=native -mtune=intel -flto" \
     CFLAGS="-D__INTEL_OPTIMIZED__ -msse4.2 -mavx2 -fno-omit-frame-pointer" \
     -j$(nproc)

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "=== OPTIMIZATION SUMMARY ==="
    echo "• Event loop batching (64 events max)"
    echo "• Intel-specific cache prefetching"
    echo "• Aggressive timeout optimization"
    echo "• Larger epoll instance hint (8192)"
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
echo "For full string decrement test (target workload):"
echo "  ./src/redis-benchmark -t decr -n 1000000 -c 50 -P 16"
echo ""
echo "For profiling with perf:"
echo "  perf record -a -g ./src/redis-benchmark -t decr -n 1000000 -c 50 -P 16"
echo "  perf script > perf-script-optimized.txt"
echo ""
echo "To compare with baseline:"
echo "  git checkout unstable"
echo "  make clean && make"
echo "  # Run same benchmark"
echo "  git checkout 1Mkeys-string-decr-intel-optimize"