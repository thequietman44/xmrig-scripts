#!/bin/bash

if [ $EUID != 0 ]; then
        echo "Running as `whoami`, elevating to root..."
        # Some version of Ubuntu don't preserve $HOME when using sudo
        # Here we make a note of the original home directory
        echo $HOME > .xmrig-auto-home
        sudo "$0" "$@"
        exit $?
else
        # Read back the original home dir path
        XMRIGHOME=`cat .xmrig-auto-home`
fi

# Get physical/logical cores and L3 cache
if [ `uname` == "Darwin" ]; then
        # macOS-specific commands
        PHYSCORES=`system_profiler SPHardwareDataType | grep "Total Number of Cores" | awk '{print $5}'`
        LOGCORES=$PHYSCORES
        L3CACHE=`system_profiler SPHardwareDataType | grep "L3 Cache" | awk '{print $3}'`
        L3CHUNKS=`echo "scale=4;($L3CACHE/2)" | bc`
else
        # Ubuntu/Debian/generic commands
        RELEASE=`lsb_release -sr | cut -d. -f1`
        PHYSCORES=`lscpu | grep "Core(s) per socket" | awk '{print $NF }'`
        LOGCORES=`nproc`
        # Ubuntu 19.x displays L3 cache in MB
        if [ "$RELEASE" -ge 19 ]; then
                L3CACHE=`lscpu | grep L3 | awk '{print $3}'`
                L3CHUNKS=`echo "scale=4;($L3CACHE/2)" | bc`
        else
                L3CACHE=`lscpu | grep L3 | awk '{print $NF}' | sed s/K//g`
                L3CHUNKS=`echo "scale=4;($L3CACHE/1000/2)" | bc`
        fi
fi

# Number of 2MB chunks rounded up to the nearest integer, ensures best use of L3 cache and CPU
THREADS=`printf "%.0f\n" $L3CHUNKS`

# Never use more threads than logical cores
if [[ $THREADS -gt $LOGCORES ]]; then THREADS=$LOGCORES; fi

# Print values for debugging/reference
echo "PHYSCORES=$PHYSCORES"
echo "LOGCORES=$LOGCORES"
echo "L3CACHE=$L3CACHE"
echo "L3CHUNKS=$L3CHUNKS"
echo "THREADS=$THREADS"

echo "cd $XMRIGHOME/xmrig/build/"
cd $XMRIGHOME/xmrig/build/
echo "./xmrig -c config.json -t $THREADS"
./xmrig -c config.json -t $THREADS
