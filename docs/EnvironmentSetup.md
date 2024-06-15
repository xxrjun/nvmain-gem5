# Environment Setup

- [Environment Setup](#environment-setup)
  - [Install Ubuntu 18.04](#install-ubuntu-1804)
  - [Install Compiled Tools](#install-compiled-tools)
  - [Install GEM5](#install-gem5)
    - [Compile GEM5](#compile-gem5)
  - [Install NVMain](#install-nvmain)
    - [Compile NVMain](#compile-nvmain)
  - [Modify GEM5 and NVMain](#modify-gem5-and-nvmain)
  - [Test with Hello World](#test-with-hello-world)

## Install Ubuntu 18.04

1. **選擇虛擬機軟件**

   首先選擇一款虛擬機軟件。常用的有 VMware Workstation、Oracle VM VirtualBox 等。這裡我們以 [**VirtualBox**](https://www.virtualbox.org/wiki/Downloads) 為例。

2. **下載 Ubuntu 18.04 ISO 文件**

   前往 [**Ubuntu 官方網站下載 Ubuntu 18.04 LTS**](https://releases.ubuntu.com/18.04/) 的 ISO 映像文件。選擇適合您的架構（通常是 64 位）的版本。這邊下載 [**64-bit PC (AMD64) server install image**](https://releases.ubuntu.com/18.04/ubuntu-18.04.6-live-server-amd64.iso) 而不是帶有 GUI 的桌面版。

3. **創建新的虛擬機**

   - 打開 VirtualBox，點擊**新增**
   - 選取剛剛下載的 Ubuntu 18.04 ISO 檔案
   - 分配足夠的硬體資源
     - 記憶體：4GB
     - 硬碟：20GB
   - （可選，但推薦）安裝 **VirtualBox Guest Additions**。可參考：[**Guest Additions**](https://www.virtualbox.org/manual/ch04.html)

4. **安裝 Ubuntu 18.04**：

   - 確認後關閉設置，選擇虛擬機並點擊**啟動**。
   - 跟隨安裝指南完成 Ubuntu 的安裝。在安裝過程中，您可以選擇語言、時間、鍵盤布局、安裝類型（通常選擇標準安裝），以及創建用戶帳戶等。
   - 安裝完成後重啟虛擬機。

> [!TIP]
> 接下來的步驟可以使用 [**../scripts/setup.sh**](../scripts/setup.sh) 來完成

## Install Compiled Tools

```bash
sudo apt install build-essential git m4 scons zlib1g zlib1g-dev libprotobuf-dev protobuf-compiler libprotoc-dev libgoogle-perftools-dev python3-dev python3-six python libboost-all-dev pkg-config
```

## Install GEM5

> [!WARNING]
> 根據助教提供的資料，不推薦下載最新版的GEM5，後面編譯會出問題

```bash
wget https://gem5.googlesource.com/public/gem5/+archive/525ce650e1a5bbe71c39d4b15598d6c003cc9f9e.tar.gz

mkdir gem5

# unzip the file
tar -xvf 525ce650e1a5bbe71c39d4b15598d6c003cc9f9e.tar.gz -C ~/gem5
```

### Compile GEM5

> [!TIP]
> 這邊的 `-j <number of threads>` 可以採用 Multithreading 的方式加速編譯速度，通常可以設定為 CPU 核心數的兩倍，使用 `nproc` 指令可以查看 CPU 核心數。

```bash
cd gem5
scons build/X86/gem5.opt -j <number of threads>
```

舉例來說，如果 CPU 有 2 個核心，可以使用以下指令：

```bash
scons build/X86/gem5.opt -j 4
```


## Install NVMain

在跟 gem5 的根目錄下，執行以下指令：

```bash
git clone https://github.com/SEAL-UCSB/NVmain
```

進入 `Nvmain` 資料夾，點開 `SConscript` 把 36 行的 `from gem5_scons import Transform` 註解掉

```bash
cd NVmain
vim SConscript
```

```python
# from gem5_scons import Transform
```

### Compile NVMain

```bash
scons --build-type=fast
```

## Modify GEM5 and NVMain

在 `gem5/configs/common/Options.py` 中第 133 行加入下段程式

```python
cd ~/gem5
vim configs/common/Options.py
```

```python
for arg in sys.argv:
   if arg[:9] == "--nvmain-":
      parser.add_option(arg, type="string", default="NULL", help="Set NVMain configuration value for a parameter")
```

還原前面註解掉的 `from gem5_scons import Transform`

```bash
cd ~/NVmain
vim SConscript
```

```python
from gem5_scons import Transform
```

最後，在 `gem5` 的根目錄下混合 NVMAIN 編譯 GEM5

```bash
scons EXTRAS=../NVmain build/X86/gem5.opt
```

## Test with Hello World

```bash
# In ./gem5
./build/X86/gem5.opt configs/example/se.py -c tests/test-progs/hello/bin/x86/linux/hello --cpu-type=TimingSimpleCPU --caches --l2cache --mem-type=NVMainMemory --nvmain-config=../NVmain/Config/PCM_ISSCC_2012_4GB.config
```

輸出中看到 `Hello world!`，代表成功執行：
   
```bash
...
117 NVMain: the address mapping order is
118     Sub-Array 1
119     Row 6
120     Column 2
121     Bank 4
122     Rank 5
123     Channel 3
124 defaultMemory.channel0.FRFCFS-WQF capacity is 4096 MB.
125 Creating 4 command queues.
126 **** REAL SIMULATION ****
127 Hello world!                
128 Exiting @ tick 77407500 because exiting with last active thread context
129 i0.defaultMemory.channel0.FRFCFS-WQF.channel0.rank0.bank0.subarray0.subArrayEnergy 4.33674nJ
130 i0.defaultMemory.channel0.FRFCFS-WQF.channel0.rank0.bank0.subarray0.activeEnergy 4.1412nJ
...
```