#!/bin/bash
# Intel x86-64 Redis - SYSTEM LEVEL OPTIMIZATIONS

echo "=== REDIS SYSTEM LEVEL INTEL OPTIMIZATIONS ==="
echo "Optimizing for Intel x86-64 at kernel/system level..."

# Clean previous build
make clean

# Build with Intel-specific system optimizations
echo "Compiling with Intel system optimizations..."
make OPTIMIZATION="-O3 -march=native -mtune=intel" \
     CFLAGS="-DDISABLE_INTEL_OPTIMIZATIONS -DENABLE_INTEL_SYSTEM_OPTS" \
     -j$(nproc)

echo ""
echo "=== APPLY THESE RUNTIME OPTIMIZATIONS ON AWS ==="
echo ""
echo "1. CPU Frequency scaling:"
echo "   echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
echo ""
echo "2. IRQ affinity (for network interrupts):"
echo "   echo 2 | sudo tee /proc/irq/24/smp_affinity  # Adjust IRQ number"
echo ""
echo "3. Network buffer tuning:"
echo "   echo 'net.core.rmem_max = 134217728' | sudo tee -a /etc/sysctl.conf"
echo "   echo 'net.core.wmem_max = 134217728' | sudo tee -a /etc/sysctl.conf"
echo "   echo 'net.ipv4.tcp_rmem = 4096 87380 134217728' | sudo tee -a /etc/sysctl.conf"
echo "   echo 'net.ipv4.tcp_wmem = 4096 65536 134217728' | sudo tee -a /etc/sysctl.conf"
echo "   sudo sysctl -p"
echo ""
echo "4. Disable transparent hugepages:"
echo "   echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled"
echo ""
echo "5. Set Redis process priority:"
echo "   sudo renice -10 \$(pgrep redis-server)"
echo ""

if [ $? -eq 0 ]; then
    echo "Build successful! Apply system optimizations above on AWS."
else
    echo "Build failed!"
    exit 1
fi