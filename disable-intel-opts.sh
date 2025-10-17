#!/bin/bash
# Script to disable Intel optimizations globally

echo "Disabling Intel optimizations in all source files..."

# Replace all Intel optimization ifdefs to include DISABLE_INTEL_OPTIMIZATIONS check
find src/ -name "*.c" -exec sed -i 's/#if defined(__x86_64__) || defined(_M_X64)/#if (defined(__x86_64__) || defined(_M_X64)) \&\& !defined(DISABLE_INTEL_OPTIMIZATIONS)/g' {} \;

echo "✅ All Intel optimizations can now be disabled with -DDISABLE_INTEL_OPTIMIZATIONS"
echo "Files modified:"
find src/ -name "*.c" -exec grep -l "DISABLE_INTEL_OPTIMIZATIONS" {} \;