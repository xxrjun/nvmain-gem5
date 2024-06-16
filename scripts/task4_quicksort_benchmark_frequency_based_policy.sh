#!/bin/bash

# Parameters Definitions
QUICKSORT_FILE=../benchmarks/quicksort.c
QUICKSORT_BINARY=../benchmarks/quicksort
CONFIG_SCRIPT=configs/example/se.py
NVMAIN_CONFIG=../NVmain/Config/PCM_ISSCC_2012_4GB.config
CPU_TYPE=TimingSimpleCPU
L1i_SIZE=32kB
L1d_SIZE=32kB
L2_SIZE=128kB
L3_SIZE=1MB
MEM_TYPE=NVMainMemory
L3_REPLACEMENT_POLICY=LFU

# Compile quicksort
gcc --static $QUICKSORT_FILE -o $QUICKSORT_BINARY

cd ../gem5

# ==============================================================
# 2-way associative
echo "Running 2-way associative cache..."
cmd="./build/X86/gem5.opt $CONFIG_SCRIPT \
        -c $QUICKSORT_BINARY \
        --cpu-type=$CPU_TYPE \
        --caches \
        --l1d_size=$L1d_SIZE --l1i_size=$L1i_SIZE \
        --l2cache --l2_size=$L2_SIZE \
        --l3cache  --l3_size=$L3_SIZE --l3_assoc=2 --l3_replacement_policy=$L3_REPLACEMENT_POLICY \
        --mem-type=$MEM_TYPE \
        --nvmain-config=$NVMAIN_CONFIG
    "
mkdir -p ../out/quicksort-2-way-LFU
eval $cmd > ../out/quicksort-2-way-LFU/log.txt
# Store 2-way commands, config, and stats
echo $cmd > ../out/quicksort-2-way-LFU/cmd.txt
mv m5out/stats.txt ../out/quicksort-2-way-LFU/stats.txt
mv m5out/config.ini ../out/quicksort-2-way-LFU/config.ini

# ==============================================================
# Full-way associative
echo "Running full-way associative cache..."
cmd="./build/X86/gem5.opt $CONFIG_SCRIPT \
        -c $QUICKSORT_BINARY \
        --cpu-type=$CPU_TYPE \
        --caches \
        --l1d_size=$L1d_SIZE --l1i_size=$L1i_SIZE \
        --l2cache --l2_size=$L2_SIZE \
        --l3cache --l3_size=$L3_SIZE --l3_assoc=16 --l3_replacement_policy=$L3_REPLACEMENT_POLICY \
        --mem-type=$MEM_TYPE \
        --nvmain-config=$NVMAIN_CONFIG
    "
mkdir -p ../out/quicksort-full-way-LFU
eval $cmd > ../out/quicksort-full-way-LFU/log.txt
echo $cmd > ../out/quicksort-full-way-LFU/cmd.txt
mv m5out/stats.txt ../out/quicksort-full-way-LFU/stats.txt
mv m5out/config.ini ../out/quicksort-full-way-LFU/config.ini


# ==============================================================
echo "Results for 2-way associative cache:"
grep -e "sim_seconds" -e "sim_ticks" -e "system.l3.overall_hits::total" -e "system.l3.overall_misses::total" -e "system.l3.overall_miss_rate::total" ../out/quicksort-2-way-LFU/stats.txt

echo "Results for full-way associative cache:"
grep -e "sim_seconds" -e "sim_ticks" -e "system.l3.overall_hits::total" -e "system.l3.overall_misses::total" -e "system.l3.overall_miss_rate::total" ../out/quicksort-full-way-LFU/stats.txt
