#!/bin/bash
# Check NUMA topology and optimize Redis for Intel NUMA

echo "=== INTEL NUMA OPTIMIZATION SCRIPT ==="
echo ""

echo "1. Check NUMA topology:"
echo "   numactl --hardware"
echo ""

echo "2. Check current NUMA policy:"
echo "   numactl --show"
echo ""

echo "3. Pin Redis to specific NUMA node (usually node 0):"
echo "   numactl --cpunodebind=0 --membind=0 ./src/redis-server redis.conf"
echo ""

echo "4. Alternative: Use interleaved memory policy:"
echo "   numactl --interleave=all ./src/redis-server redis.conf"
echo ""

echo "5. Check memory placement after start:"
echo "   cat /proc/\$(pgrep redis-server)/numa_maps | head -20"
echo ""

echo "6. Monitor NUMA stats during test:"
echo "   numastat -p \$(pgrep redis-server)"
echo ""

echo "Test both options and see which gives better performance!"