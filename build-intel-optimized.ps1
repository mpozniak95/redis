# Intel x86-64 Redis Optimization - Build and Test Script (Windows)

Write-Host "=== INTEL x86-64 REDIS OPTIMIZATION BUILD ===" -ForegroundColor Cyan
Write-Host "Building optimized Redis for Intel architecture..." -ForegroundColor Yellow

# Clean previous build
Write-Host "Cleaning previous build..." -ForegroundColor Yellow
& make clean

# Build with Intel-specific optimizations (Windows/WSL compatible)
Write-Host "Compiling with Intel-specific flags..." -ForegroundColor Yellow
$env:OPTIMIZATION = "-O3 -march=native -mtune=intel -flto"
$env:CFLAGS = "-D__INTEL_OPTIMIZED__ -msse4.2 -mavx2 -fno-omit-frame-pointer"

& make OPTIMIZATION="$env:OPTIMIZATION" CFLAGS="$env:CFLAGS"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== OPTIMIZATION SUMMARY ===" -ForegroundColor Cyan
    Write-Host "• Event loop batching (64 events max)" -ForegroundColor Green
    Write-Host "• Intel-specific cache prefetching" -ForegroundColor Green
    Write-Host "• Aggressive timeout optimization" -ForegroundColor Green
    Write-Host "• Larger epoll instance hint (8192)" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "=== BENCHMARKING COMMANDS ===" -ForegroundColor Yellow
    Write-Host "For full string decrement test (target workload):"
    Write-Host "  .\src\redis-benchmark.exe -t decr -n 1000000 -c 50 -P 16" -ForegroundColor White
    Write-Host ""
    Write-Host "For baseline comparison:" -ForegroundColor Yellow
    Write-Host "  git checkout unstable"
    Write-Host "  make clean && make"
    Write-Host "  # Run same benchmark for comparison"
    Write-Host "  git checkout 1Mkeys-string-decr-intel-optimize"
    Write-Host ""
    
    Write-Host "=== FILES MODIFIED ===" -ForegroundColor Cyan
    Write-Host "• src/ae_epoll.c - Event loop optimization" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "=== EXPECTED IMPROVEMENTS ===" -ForegroundColor Magenta
    Write-Host "• Event loop efficiency: +20-30%" -ForegroundColor Green
    Write-Host "• Target: 48K ops/s → 60-65K ops/s" -ForegroundColor Green
    Write-Host "• Reduced aeApiPoll CPU usage" -ForegroundColor Green
    
} else {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    Write-Host "Check build errors above." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Ready for testing! 🚀" -ForegroundColor Green