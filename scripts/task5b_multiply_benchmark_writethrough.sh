#!/bin/bash

# Parameters Definitions
MULTIPLY_FILE=../benchmarks/multiply.c
MULTIPLY_BINARY=../benchmarks/multiply
CONFIG_SCRIPT=configs/example/se.py
NVMAIN_CONFIG=../NVmain/Config/PCM_ISSCC_2012_4GB.config
CPU_TYPE=TimingSimpleCPU
L1i_SIZE=32kB
L1d_SIZE=32kB
L2_SIZE=128kB
L3_SIZE=1MB
MEM_TYPE=NVMainMemory

# Compile multiply
gcc --static $MULTIPLY_FILE -o $MULTIPLY_BINARY

cd ../gem5

# ==============================================================
# 4-way associative
echo "Running 2-way associative cache..."
cmd="./build/X86/gem5.opt $CONFIG_SCRIPT \
        -c $MULTIPLY_BINARY \
        --cpu-type=$CPU_TYPE \
        --caches \
        --l1d_size=$L1d_SIZE --l1i_size=$L1i_SIZE \
        --l2cache --l2_size=$L2_SIZE \
        --l3cache  --l3_size=$L3_SIZE --l3_assoc=4 \
        --mem-type=$MEM_TYPE \
        --nvmain-config=$NVMAIN_CONFIG
    "
mkdir -p ../out/multiply-4-way-through
eval $cmd > ../out/multiply-4-way-through/log.txt
# Store 2-way commands, config, and stats
echo $cmd > ../out/multiply-4-way-through/cmd.txt
mv m5out/stats.txt ../out/multiply-4-way-through/stats.txt
mv m5out/config.ini ../out/multiply-4-way-through/config.ini


# ==============================================================
echo "Results for 4-way associative cache:"
grep -e "sim_seconds" -e "sim_ticks" -e "system.l3.overall_hits::total" -e "system.l3.overall_misses::total" -e "system.l3.overall_miss_rate::total" ../out/multiply-4-way-through/stats.txt

