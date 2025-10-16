# Redis Intel x86-64 Performance Optimizations

## 🎯 Overview

This branch contains **performance optimizations specifically for Intel x86-64 architectures** based on detailed flamegraph analysis comparing Redis performance between:

- **Intel x86-64 (M8I.4xlarge)**: 48,085 ops/s baseline
- **ARM64 Graviton3 (M8G.4xlarge)**: 218,015 ops/s (4.5x faster)

## 📊 Problem Analysis

Flamegraph analysis revealed that **aeApiPoll()** consumed **6.1 billion samples** (21.1% CPU) on Intel vs only 12.1% on ARM64 for the same workload (`memtier_benchmark-1Mkeys-string-decr`).

### Key Bottlenecks Identified:
- **Event Loop**: aeApiPoll inefficiency (6.1B samples)
- **Syscall Overhead**: 75.8% CPU in syscalls vs 66.1% on ARM64  
- **Memory Management**: 2.3x less efficient per CPU percent
- **Socket I/O**: 3x less efficient per operation

## ⚡ Optimizations Implemented

### 1. Event Loop Optimization (`src/ae_epoll.c`)

**Changes:**
- Reduced epoll batch size from unlimited → **64 events** for better Intel cache efficiency
- Added **Intel-specific prefetching** with `__builtin_prefetch()` for cache optimization
- **Aggressive timeout tuning** (max 1ms) for lower latency on Intel
- Increased `epoll_create()` hint from 1024 → **8192** for better kernel scalability

**Expected Impact:** +20-30% throughput

### 2. Architecture Detection

All optimizations are conditionally compiled with:
```c
#ifdef __x86_64__
    // Intel-specific optimizations
#else
    // Original code for ARM64 and other architectures
#endif
```

## 🛠️ Building and Testing

### Quick Start:
```bash
# Linux/WSL
./build-intel-optimized.sh

# Windows PowerShell  
.\build-intel-optimized.ps1
```

### Manual Build:
```bash
make clean
make OPTIMIZATION="-O3 -march=native -mtune=intel -flto" \
     CFLAGS="-D__INTEL_OPTIMIZED__ -msse4.2 -mavx2" \
     -j$(nproc)
```

### Benchmark Testing:
```bash
# Target workload (string decrement)
./src/redis-benchmark -t decr -n 1000000 -c 50 -P 16

# Compare with baseline
git checkout unstable
make clean && make  
# Run benchmark for comparison
git checkout 1Mkeys-string-decr-intel-optimize
```

### Performance Profiling:
```bash
# Generate new flamegraph
perf record -a -g ./src/redis-benchmark -t decr -n 1000000 -c 50 -P 16
perf script > perf-script-optimized.txt
```

## 📈 Expected Results

| Metric | Baseline (Intel) | Target (Optimized) | Improvement |
|--------|------------------|-------------------|-------------|
| **Throughput** | 48,085 ops/s | 60,000-65,000 ops/s | +25-35% |
| **aeApiPoll CPU** | 21.1% | 15-17% | -20-30% |
| **Syscall Efficiency** | 75.8% overhead | 65-70% overhead | -10-15% |

## 🔬 Validation Methodology

1. **Baseline Measurement**: Test current unstable branch performance
2. **Optimized Measurement**: Test this branch with same workload
3. **Flamegraph Comparison**: Verify aeApiPoll sample reduction
4. **Regression Testing**: Ensure no performance degradation on other workloads

## 📋 Implementation Status

- ✅ **Event Loop Optimization** - Complete
- 🔄 **Socket I/O Optimization** - Planned next
- 🔄 **Memory Allocation Optimization** - Planned
- 🔄 **Command-Specific Optimization** - Planned

## 🚀 Usage on AWS

### Deploy on Intel Instance:
```bash
# Launch M8I.4xlarge instance
git clone https://github.com/your-fork/redis.git
cd redis
git checkout 1Mkeys-string-decr-intel-optimize
./build-intel-optimized.sh

# Run optimized Redis
./src/redis-server redis.conf
```

### Benchmark Comparison:
```bash
# Test with memtier_benchmark
memtier_benchmark -s localhost -p 6379 -t 4 -c 50 \
  --command="DECR key_1000" --key-minimum=1 --key-maximum=1000000 \
  --test-time=60 --data-size=100
```

## 🎯 Next Steps

1. **Socket I/O optimization** (`src/connection.c`)
2. **Memory allocation tuning** (`src/zmalloc.c`, `src/sds.c`)  
3. **DECR command fast path** (`src/t_string.c`)
4. **Additional syscall optimizations**

Target: **Reduce 4.5x performance gap to ~2x** (100K+ ops/s on Intel)

---

*Based on flamegraph analysis of memtier_benchmark-1Mkeys-string-decr workload*  
*Branch: `1Mkeys-string-decr-intel-optimize`*