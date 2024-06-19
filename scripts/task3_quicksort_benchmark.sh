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
        --l3cache --l3_size=$L3_SIZE --l3_assoc=2 \
        --mem-type=$MEM_TYPE \
        --nvmain-config=$NVMAIN_CONFIG
    "
mkdir -p ../out/quicksort-2-way
eval $cmd > ../out/quicksort-2-way/log.txt
# Store 2-way commands, config, and stats
echo $cmd > ../out/quicksort-2-way/cmd.txt
mv m5out/stats.txt ../out/quicksort-2-way/stats.txt
mv m5out/config.ini ../out/quicksort-2-way/config.ini

# ==============================================================
# Full-way associative
echo "Running full-way associative cache..."
cmd="./build/X86/gem5.opt $CONFIG_SCRIPT \
        -c $QUICKSORT_BINARY \
        --cpu-type=$CPU_TYPE \
        --caches \
        --l1d_size=$L1d_SIZE --l1i_size=$L1i_SIZE \
        --l2cache --l2_size=$L2_SIZE \
        --l3cache --l3_size=$L3_SIZE --l3_assoc=16 \
        --mem-type=$MEM_TYPE \
        --nvmain-config=$NVMAIN_CONFIG
    "
mkdir -p ../out/quicksort-full-way
eval $cmd > ../out/quicksort-full-way/log.txt
echo $cmd > ../out/quicksort-full-way/cmd.txt
mv m5out/stats.txt ../out/quicksort-full-way/stats.txt
mv m5out/config.ini ../out/quicksort-full-way/config.ini

# ==============================================================
# 2-way associative with smaller L3 cache size: 128kB
echo "Running 2-way associative cache with smaller L3 cache size..."
cmd="./build/X86/gem5.opt $CONFIG_SCRIPT \
        -c $QUICKSORT_BINARY \
        --cpu-type=$CPU_TYPE \
        --caches \
        --l1d_size=$L1d_SIZE --l1i_size=$L1i_SIZE \
        --l2cache --l2_size=$L2_SIZE \
        --l3cache --l3_size=128kB --l3_assoc=2 \
        --mem-type=$MEM_TYPE \
        --nvmain-config=$NVMAIN_CONFIG
    "
mkdir -p ../out/quicksort-2-way-small-l3-128kB
eval $cmd > ../out/quicksort-2-way-small-l3-128kB/log.txt
echo $cmd > ../out/quicksort-2-way-small-l3-128kB/cmd.txt
mv m5out/stats.txt ../out/quicksort-2-way-small-l3-128kB/stats.txt
mv m5out/config.ini ../out/quicksort-2-way-small-l3-128kB/config.ini

# ==============================================================
# Full-way associative with smaller L3 cache size: 128kB
echo "Running full-way associative cache with smaller L3 cache size..."
cmd="./build/X86/gem5.opt $CONFIG_SCRIPT \
        -c $QUICKSORT_BINARY \
        --cpu-type=$CPU_TYPE \
        --caches \
        --l1d_size=$L1d_SIZE --l1i_size=$L1i_SIZE \
        --l2cache --l2_size=$L2_SIZE \
        --l3cache --l3_size=128kB --l3_assoc=16 \
        --mem-type=$MEM_TYPE \
        --nvmain-config=$NVMAIN_CONFIG
    "

mkdir -p ../out/quicksort-full-way-small-l3-128kB
eval $cmd > ../out/quicksort-full-way-small-l3-128kB/log.txt
echo $cmd > ../out/quicksort-full-way-small-l3-128kB/cmd.txt
mv m5out/stats.txt ../out/quicksort-full-way-small-l3-128kB/stats.txt
mv m5out/config.ini ../out/quicksort-full-way-small-l3-128kB/config.ini

# ==============================================================
# 2-way associative with smaller L3 cache size, replacement policy: FIFO
echo "Running 2-way associative cache with smaller L3 cache size and FIFO replacement policy..."
cmd="./build/X86/gem5.opt $CONFIG_SCRIPT \
        -c $QUICKSORT_BINARY \
        --cpu-type=$CPU_TYPE \
        --caches \
        --l1d_size=$L1d_SIZE --l1i_size=$L1i_SIZE \
        --l2cache --l2_size=$L2_SIZE \
        --l3cache --l3_size=128kB --l3_assoc=2 --l3_replacement_policy=FIFO \
        --mem-type=$MEM_TYPE \
        --nvmain-config=$NVMAIN_CONFIG
    "
mkdir -p ../out/quicksort-2-way-small-l3-128kB-FIFO
eval $cmd > ../out/quicksort-2-way-small-l3-128kB-FIFO/log.txt
echo $cmd > ../out/quicksort-2-way-small-l3-128kB-FIFO/cmd.txt
mv m5out/stats.txt ../out/quicksort-2-way-small-l3-128kB-FIFO/stats.txt
mv m5out/config.ini ../out/quicksort-2-way-small-l3-128kB-FIFO/config.ini

# ==============================================================
# Full-way associative with smaller L3 cache size, replacement policy: FIFO
echo "Running full-way associative cache with smaller L3 cache size and FIFO replacement policy..."
cmd="./build/X86/gem5.opt $CONFIG_SCRIPT \
        -c $QUICKSORT_BINARY \
        --cpu-type=$CPU_TYPE \
        --caches \
        --l1d_size=$L1d_SIZE --l1i_size=$L1i_SIZE \
        --l2cache --l2_size=$L2_SIZE \
        --l3cache --l3_size=128kB --l3_assoc=16 --l3_replacement_policy=FIFO \
        --mem-type=$MEM_TYPE \
        --nvmain-config=$NVMAIN_CONFIG
    "

mkdir -p ../out/quicksort-full-way-small-l3-128kB-FIFO
eval $cmd > ../out/quicksort-full-way-small-l3-128kB-FIFO/log.txt
echo $cmd > ../out/quicksort-full-way-small-l3-128kB-FIFO/cmd.txt
mv m5out/stats.txt ../out/quicksort-full-way-small-l3-128kB-FIFO/stats.txt
mv m5out/config.ini ../out/quicksort-full-way-small-l3-128kB-FIFO/config.ini

# ==============================================================
# 2-way associative with much smaller L3 cache size: 4kB, replacement policy: default(LRU)
echo "Running 2-way associative cache with much smaller L3 cache size and default replacement policy..."
cmd="./build/X86/gem5.opt $CONFIG_SCRIPT \
        -c $QUICKSORT_BINARY \
        --cpu-type=$CPU_TYPE \
        --caches \
        --l1d_size=$L1d_SIZE --l1i_size=$L1i_SIZE \
        --l2cache --l2_size=$L2_SIZE \
        --l3cache --l3_size=4kB --l3_assoc=2 \
        --mem-type=$MEM_TYPE \
        --nvmain-config=$NVMAIN_CONFIG
    "

mkdir -p ../out/quicksort-2-way-small-l3-4kB
eval $cmd > ../out/quicksort-2-way-small-l3-4kB/log.txt
echo $cmd > ../out/quicksort-2-way-small-l3-4kB/cmd.txt
mv m5out/stats.txt ../out/quicksort-2-way-small-l3-4kB/stats.txt
mv m5out/config.ini ../out/quicksort-2-way-small-l3-4kB/config.ini

# ==============================================================
# Full-way associative with much smaller L3 cache size: 4kB, replacement policy: default(LRU)
echo "Running full-way associative cache with much smaller L3 cache size and default replacement policy..."
cmd="./build/X86/gem5.opt $CONFIG_SCRIPT \
        -c $QUICKSORT_BINARY \
        --cpu-type=$CPU_TYPE \
        --caches \
        --l1d_size=$L1d_SIZE --l1i_size=$L1i_SIZE \
        --l2cache --l2_size=$L2_SIZE \
        --l3cache --l3_size=4kB --l3_assoc=16 \
        --mem-type=$MEM_TYPE \
        --nvmain-config=$NVMAIN_CONFIG
    "

mkdir -p ../out/quicksort-full-way-small-l3-4kB
eval $cmd > ../out/quicksort-full-way-small-l3-4kB/log.txt
echo $cmd > ../out/quicksort-full-way-small-l3-4kB/cmd.txt
mv m5out/stats.txt ../out/quicksort-full-way-small-l3-4kB/stats.txt
mv m5out/config.ini ../out/quicksort-full-way-small-l3-4kB/config.ini

# ==============================================================
echo "Results for 2-way associative cache:"
grep -e "sim_seconds" -e "sim_ticks" -e "system.l3.overall_hits::total" -e "system.l3.overall_misses::total" -e "system.l3.overall_miss_rate::total" ../out/quicksort-2-way/stats.txt

echo "Results for full-way associative cache:"
grep -e "sim_seconds" -e "sim_ticks" -e "system.l3.overall_hits::total" -e "system.l3.overall_misses::total" -e "system.l3.overall_miss_rate::total" ../out/quicksort-full-way/stats.txt

echo "Results for 2-way associative cache with smaller L3 cache size:"
grep -e "sim_seconds" -e "sim_ticks" -e "system.l3.overall_hits::total" -e "system.l3.overall_misses::total" -e "system.l3.overall_miss_rate::total" ../out/quicksort-2-way-small-l3-128kB/stats.txt

echo "Results for full-way associative cache with smaller L3 cache size:"
grep -e "sim_seconds" -e "sim_ticks" -e "system.l3.overall_hits::total" -e "system.l3.overall_misses::total" -e "system.l3.overall_miss_rate::total" ../out/quicksort-full-way-small-l3-128kB/stats.txt

echo "Results for 2-way associative cache with smaller L3 cache size and FIFO replacement policy:"
grep -e "sim_seconds" -e "sim_ticks" -e "system.l3.overall_hits::total" -e "system.l3.overall_misses::total" -e "system.l3.overall_miss_rate::total" ../out/quicksort-2-way-small-l3-128kB-FIFO/stats.txt

echo "Results for full-way associative cache with smaller L3 cache size and FIFO replacement policy:"
grep -e "sim_seconds" -e "sim_ticks" -e "system.l3.overall_hits::total" -e "system.l3.overall_misses::total" -e "system.l3.overall_miss_rate::total" ../out/quicksort-full-way-small-l3-128kB-FIFO/stats.txt

echo "Results for 2-way associative cache with much smaller L3 cache size and default replacement policy:"
grep -e "sim_seconds" -e "sim_ticks" -e "system.l3.overall_hits::total" -e "system.l3.overall_misses::total" -e "system.l3.overall_miss_rate::total" ../out/quicksort-2-way-small-l3-4kB/stats.txt

echo "Results for full-way associative cache with much smaller L3 cache size and default replacement policy:"
grep -e "sim_seconds" -e "sim_ticks" -e "system.l3.overall_hits::total" -e "system.l3.overall_misses::total" -e "system.l3.overall_miss_rate::total" ../out/quicksort-full-way-small-l3-4kB/stats.txt
