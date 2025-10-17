#!/bin/bash
# Apply Intel system optimizations - TEMPORARY (reverts after reboot)

echo "=== APPLYING INTEL SYSTEM OPTIMIZATIONS (TEMPORARY) ==="
echo ""

echo "1. Setting CPU frequency scaling to performance..."
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
echo "✓ CPU frequency scaling set to performance"
echo ""

echo "2. Optimizing network buffers..."
sudo sysctl -w net.core.rmem_max=134217728
sudo sysctl -w net.core.wmem_max=134217728  
sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728"
sudo sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728"
echo "✓ Network buffers optimized"
echo ""

echo "3. Disabling transparent hugepages..."
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag
echo "✓ Transparent hugepages disabled"
echo ""

echo "4. Optimizing I/O scheduler (if using SSD)..."
for disk in /sys/block/nvme*n1/queue/scheduler; do
    if [ -f "$disk" ]; then
        echo none | sudo tee "$disk" 2>/dev/null || echo "Could not set scheduler for $disk"
    fi
done
echo "✓ I/O scheduler optimized for NVMe"
echo ""

echo "5. Setting process limits..."
echo "* soft nofile 65535" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65535" | sudo tee -a /etc/security/limits.conf
echo "✓ File descriptor limits increased"
echo ""

echo "6. Checking NUMA topology..."
if command -v numactl &> /dev/null; then
    echo "NUMA nodes available:"
    numactl --hardware | grep "available:" 
    echo ""
    echo "To run Redis with NUMA optimization:"
    echo "  numactl --cpunodebind=0 --membind=0 ./src/redis-server redis-intel.conf"
else
    echo "numactl not available - install with: sudo yum install numactl -y"
fi
echo ""

echo "7. Finding network IRQ numbers..."
echo "Network IRQ information:"
grep -E "(eth|ens|ena)" /proc/interrupts | head -5
echo ""
echo "To set IRQ affinity manually:"
echo "  echo 2 | sudo tee /proc/irq/[IRQ_NUMBER]/smp_affinity"
echo ""

echo "=== ALL OPTIMIZATIONS APPLIED ==="
echo "These settings are TEMPORARY and will revert after reboot."
echo "Start Redis with: numactl --cpunodebind=0 --membind=0 ./src/redis-server redis-intel.conf"