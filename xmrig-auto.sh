#!/bin/bash

# This script tries to determine the best number of threads to use based on
# number of cores and available L3 cache.
# Useful when running xmrig on many diverse systems so you don't have to hard-code
# CPU config into your config.json file or remember how many threads to set
# when you have to restart xmrig.

# Run as root to allow MSR changes, etc
# Disable this if you want to set MSR yourself and run as an unprivileged user
if [ $EUID != 0 ]; then
        echo "Running as `whoami`, elevating to root..."
        sudo "$0" "$@"
        exit $?
fi

# Get physical/logical cores and L3 cache
if [ `uname` == "Darwin" ]; then
        # macOS-specific commands
        PHYSCORES=`system_profiler SPHardwareDataType | grep "Total Number of Cores" | awk '{print $5}'`
        LOGCORES=$PHYSCORES
        L3CACHE=`system_profiler SPHardwareDataType | grep "L3 Cache" | awk '{print $3}'`
        # Number of 2MB chunks of L3 cache available
        L3CHUNKS=`echo "scale=4;($L3CACHE/2)" | bc`
else
        # Ubuntu/Debian/generic commands
        PHYSCORES=`lscpu | grep "Core(s) per socket" | awk '{print $NF }'`
        LOGCORES=`nproc`
        L3CACHE=`lscpu | grep L3 | awk '{print $NF}' | sed s/K//g`
        # Number of 2MB chunks of L3 cache available
        L3CHUNKS=`echo "scale=4;($L3CACHE/1000/2)" | bc`
fi

# Number of 2MB chunks rounded up to the nearest integer, ensures best use of L3 cache and CPU
THREADS=`printf "%.0f\n" $L3CHUNKS`

# Never use more threads than logical cores
if [[ $THREADS -gt $LOGCORES ]]; then THREADS=$LOGCORES; fi

echo "PHYSCORES=$PHYSCORES"
echo "LOGCORES=$LOGCORES"
echo "L3CACHE=$L3CACHE"
echo "L3CHUNKS=$L3CHUNKS"
echo "THREADS=$THREADS"

echo "cd ~/xmrig/build/"
cd ~/xmrig/build/
echo "./xmrig -c config.json -t $THREADS"
./xmrig -c config.json -t $THREADS
