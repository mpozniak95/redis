#!/bin/bash
# Redis Baseline Build Script - NO INTEL OPTIMIZATIONS

echo "=== REDIS BASELINE BUILD ==="
echo "Building Redis without Intel optimizations..."

# Clean previous build
make clean

# Build with default settings
echo "Compiling with default settings..."
make -j$(nproc)

if [ $? -eq 0 ]; then
    echo "✅ Baseline build successful!"
    echo ""
    echo "=== BASELINE BUILD SUMMARY ==="
    echo "• NO Intel-specific optimizations"
    echo "• Default compiler flags"
    echo "• Standard Redis configuration"
    echo ""
    
    echo "=== QUICK TEST ==="
    echo "Starting Redis server for basic test..."
    
    # Start Redis in background
    ./src/redis-server --daemonize yes --port 6379 --logfile redis-baseline.log
    sleep 2
    
    if pgrep -f "redis-server.*6379" > /dev/null; then
        echo "✅ Redis server started on port 6379"
        
        # Quick benchmark test
        echo "Running quick benchmark test..."
        ./src/redis-benchmark -p 6379 -t set,get -n 10000 -q
        
        # Stop Redis
        ./src/redis-cli -p 6379 shutdown
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
echo "  ./src/redis-benchmark -p 6379 -t decr -n 1000000 -c 50 -P 16"