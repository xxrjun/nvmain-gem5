#!/bin/bash

cd ../gem5

./build/X86/gem5.opt configs/example/se.py \
    -c tests/test-progs/hello/bin/x86/linux/hello \
    --cpu-type=TimingSimpleCPU \
    --caches \
    --l2cache \
    --l3cache \
    --mem-type=NVMainMemory \
    --nvmain-config=../NVmain/Config/PCM_ISSCC_2012_4GB.config