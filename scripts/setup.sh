#!/bin/bash

# WARNING: This script is not tested yet and may not work as expected.

# Exit immediately if a command exits with a non-zero status.
set -e

# Update and install necessary packages
sudo apt update
sudo apt install -y build-essential git m4 scons zlib1g zlib1g-dev \
    libprotobuf-dev protobuf-compiler libprotoc-dev libgoogle-perftools-dev \
    python3-dev python3-six python libboost-all-dev pkg-config

# Install specific version of GEM5
echo "Downloading GEM5..."
wget https://gem5.googlesource.com/public/gem5/+archive/525ce650e1a5bbe71c39d4b15598d6c003cc9f9e.tar.gz
mkdir -p ~/gem5
tar -xzf 525ce650e1a5bbe71c39d4b15598d6c003cc9f9e.tar.gz -C ~/gem5

# Compile GEM5
echo "Compiling GEM5..."
cd ~/gem5
num_threads=$(nproc)
let "num_threads *= 2"  # Use double the number of CPU cores
scons build/X86/gem5.opt -j ${num_threads}

# Install NVMain
echo "Cloning NVMain..."
cd ~  # Ensure you are in the home directory or adjust path accordingly
git clone https://github.com/SEAL-UCSB/NVmain
cd ~/NVmain
sed -i 's/from gem5_scons import Transform/# from gem5_scons import Transform/' SConscript

# Compile NVMain
echo "Compiling NVMain..."
scons --build-type=fast

# Modify GEM5 and NVMain configuration
echo "Modifying GEM5 and NVMain configuration..."
cd ~/gem5
sed -i '133i for arg in sys.argv:\n   if arg[:9] == "--nvmain-":\n      parser.add_option(arg, type="string", default="NULL", help="Set NVMain configuration value for a parameter")' configs/common/Options.py
cd ~/NVmain
sed -i 's/# from gem5_scons import Transform/from gem5_scons import Transform/' SConscript

# Mix NVMain compilation with GEM5
echo "Mixing NVMain compilation with GEM5..."
cd ~/gem5
scons EXTRAS=../NVmain build/X86/gem5.opt

# Test with Hello World
echo "Running Hello World test..."
./build/X86/gem5.opt configs/example/se.py -c tests/test-progs/hello/bin/x86/linux/hello \
    --cpu-type=TimingSimpleCPU --caches --l2cache --mem-type=NVMainMemory \
    --nvmain-config=../NVmain/Config/PCM_ISSCC_2012_4GB.config \
    > m5out/test_output.txt

# Check whether the output includes "Hello world!"
if grep -q "Hello world!" m5out/test_output.txt; then
    echo "Hello World test passed!"
    echo "Setup completed successfully!"
else
    echo "Hello World test failed!"
    echo "Setup failed!"
fi

rm m5out/test_output.txt

