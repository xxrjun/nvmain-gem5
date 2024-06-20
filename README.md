# NVMain + Gem5

- [NVMain + Gem5](#nvmain--gem5)
  - [Usage](#usage)
  - [Grading Policy](#grading-policy)
  - [Task Implementations](#task-implementations)
    - [Task 1: Build GEM5 + NVMain](#task-1-build-gem5--nvmain)
    - [Task 2: Enable L3 last level cache in GEM5 + NVMain](#task-2-enable-l3-last-level-cache-in-gem5--nvmain)
    - [Task 3: Config last level cache to 2-way and full-way associative cache and test performance](#task-3-config-last-level-cache-to-2-way-and-full-way-associative-cache-and-test-performance)
    - [Task 4: Modify last level cache policy based on frequency based replacement policy](#task-4-modify-last-level-cache-policy-based-on-frequency-based-replacement-policy)
    - [Task 5: Test the performance of write back and write through policy based on 4-way associative cache with isscc\_pcm](#task-5-test-the-performance-of-write-back-and-write-through-policy-based-on-4-way-associative-cache-with-isscc_pcm)
  - [Evaluation](#evaluation)
    - [Energy Consumption](#energy-consumption)
    - [The Number of Read/Write Requests](#the-number-of-readwrite-requests)
  - [References](#references)

## Usage

> [!TIP]
> Make sure you checkout to the `q5-write-through` branch to run the task 5b. which tests the performance of write through policy.

Clone the repository.

```bash
git clone https://github.com/xxrjun/nvmain-gem5.git
cd nvmain-gem5
```

Follow the instructions in [Environment Setup](docs/EnvironmentSetup.md) to build GEM5 + NVMain. Then, run the following scripts to execute the tasks.

```bash
cd scripts

# Task 1: Build GEM5 + NVMain
./task1_mix_compile_gem5.sh

# Task 2: Enable L3 last level cache in GEM5 + NVMain
./task2_hello_with_l3cache.sh

# Task 3: Config last level cache to 2-way and full-way associative cache and test performance
./task3_quicksort_benchmark.sh

# Task 4: Modify last level cache policy based on frequency based replacement policy
./task4_quicksort_benchmark_frequency_based_policy.sh

# Task 5: Test the performance of write back and write through policy based on 4-way associative cache with isscc_pcm
./task5a_multiply_benchmark_writeback.sh

git checkout -b q5-write-through
./task5b_multiply_benchmark_writethrough.sh
```

## Grading Policy

| Criteria                                                                                                    | Percentage | Details                                                                                                  | Status  |
| ----------------------------------------------------------------------------------------------------------- | :--------: | -------------------------------------------------------------------------------------------------------- | :-----: |
| GEM5 + NVMAIN BUILD-UP                                                                                      |    40%     | 參照投影片教學                                                                                           |   ✅    |
| Enable L3 last level cache in GEM5 + NVMAIN                                                                 |    15%     | -                                                                                                        |   ✅    |
| Config last level cache to 2-way and full-way associative cache and test performance                        |    15%     | 必須跑 benchmark quicksort 在 2-way 跟 full way                                                          |   ✅    |
| Modify last level cache policy based on frequency based replacement policy                                  |    15%     | -                                                                                                        |   ✅    |
| Test the performance of write back and write through policy based on 4-way associative cache with isscc_pcm |    15%     | 必須跑 benchmark multiply 在 write through 跟 write back                                                 | ✅ |
| Bonus                                                                                                       |    10%     | Design last level cache policy to reduce the energy consumption of pcm_based main memory (Baseline: LRU) | Pending |

## Task Implementations

### Task 1: Build GEM5 + NVMain

> [!TIP]
> You can see the count of cache hits in `gem5/m5out/stats.txt`.

Follow the instructions in [Environment Setup](docs/EnvironmentSetup.md) to build GEM5 + NVMain.

### Task 2: Enable L3 last level cache in GEM5 + NVMain

Reference

- [gem5-stable 添加 l3 cache](https://blog.csdn.net/tristan_tian/article/details/79851063)
- [Adding cache to the configuration script](https://www.gem5.org/documentation/learning_gem5/part1/cache_config/)

Modify the following files in `gem5/`

#### `Options.py`

> gem5/configs/common/Options.py

Add the `--l3cache` option.

```python
parser.add_option("--l3cache", action="store_true")
```

#### `Caches.py`

> gem5/configs/common/Caches.py

Add the `L3Cache` class.

```python
class L3Cache(Cache):
    assoc = 32
    tag_latency = 32
    data_latency = 32
    response_latency = 32
    mshrs = 20
    tgts_per_mshr = 12
    write_buffers =16
```

- **Associativity (assoc)**: Determines the number of ways in the set associative cache.
- **Tag Latency (tag_latency)**: Cycles to access the tag array.
- **Data Latency (data_latency)**: Cycles to access the data array.
- **Response Latency (response_latency)**: Cycles to respond to a cache request.
- **MSHRs (mshrs)**: Number of Miss Status Holding Registers.
- **Targets per MSHR (tgts_per_mshr)**: Number of requests each MSHR can handle.
- **Write Buffers**: Number of write buffers.

#### `Xbar.py`

> gem5/src/mem/Xbar.py

Add the `L3XBar` class. This file is primarily used to define and configure memory crossbars in the GEM5 simulator. A crosssbar is crucial connection component used to tranfer data between different memory modules and processor cores.

```python
# We use a coherent crossbar to connect multiple masters to the L3
# caches. Normally this crossbar would be part of the cache itself.
class L3XBar(CoherentXBar):
    # 256-bit crossbar by default
    width = 32

    # Assume that most of this is covered by the cache latencies, with
    # no more than a single pipeline stage for any packet.
    frontend_latency = 1
    forward_latency = 0
    response_latency = 1
    snoop_response_latency = 1

    # Use a snoop-filter by default, and set the latency to zero as
    # the lookup is assumed to overlap with the frontend latency of
    # the crossbar
    snoop_filter = SnoopFilter(lookup_latency = 0)

    # This specialisation of the coherent crossbar is to be considered
    # the point of unification, it connects the dcache and the icache
    # to the first level of unified cache.
    point_of_unification = True
```

#### `BaseCPU.py`

> gem5/src/cpu/BaseCPU.py

```python
from XBar import L3XBar

def addThreeLevelCacheHierarchy(self, ic, dc, l2c, l3c, iwc=None, dwc=None,
                                xbar=None):
    self.addPrivateSplitL1Caches(ic, dc, iwc, dwc)
    self.toL3Bus = xbar if xbar else L3XBar()
    self.connectCachedPorts(self.toL3Bus)
    self.l3cache = l3c
    self.toL3Bus.master = self.l3cache.cpu_side
    self._cached_ports = ['l3cache.mem_side']
```

#### `CacheConfig.py`

> gem5/configs/common/CacheConfig.py

Add L3 cache configuration.

```python
if options.cpu_type == "O3_ARM_v7a_3":
    try:
        from cores.arm.O3_ARM_v7a import *
    except:
        print("O3_ARM_v7a_3 is unavailable. Did you compile the O3 model?")
        sys.exit(1)

    dcache_class, icache_class, l2_cache_class, walk_cache_class = \
        O3_ARM_v7a_DCache, O3_ARM_v7a_ICache, O3_ARM_v7aL2, \
        O3_ARM_v7aWalkCache
else:
    # NOTE: Add L3 cache here
    dcache_class, icache_class, l2_cache_class, l3_cache_class, walk_cache_class = \
        L1_DCache, L1_ICache, L2Cache, L3Cache, None
```

Note that L3 cache is only enabled when L2 cache is enabled, so we have two cases:

- L2 and L3
- L2 but no L3

```python
if options.l3cache and options.l2cache: # L2 and L3

    system.l2 = l2_cache_class(clk_domain=system.cpu_clk_domain,
                        size=options.l2_size,
                        assoc=options.l2_assoc)
    system.l3 = l3_cache_class(clk_domain=system.cpu_clk_domain,
                        size=options.l3_size,
                        assoc=options.l3_assoc)

    system.tol2bus = L2XBar(clk_domain = system.cpu_clk_domain)
    system.tol3bus = L3XBar(clk_domain = system.cpu_clk_domain)

    system.l2.cpu_side = system.tol2bus.master
    system.l2.mem_side = system.tol3bus.slave

    system.l3.cpu_side = system.tol3bus.master
    system.l3.mem_side = system.membus.slave
elif options.l2cache: # L2 but no L3
    # Provide a clock for the L2 and the L1-to-L2 bus here as they
    # are not connected using addTwoLevelCacheHierarchy. Use the
    # same clock as the CPUs.
    system.l2 = l2_cache_class(clk_domain=system.cpu_clk_domain,
                                size=options.l2_size,
                                assoc=options.l2_assoc)

    system.tol2bus = L2XBar(clk_domain = system.cpu_clk_domain)
    system.l2.cpu_side = system.tol2bus.master
    system.l2.mem_side = system.membus.slave
```

### Task 3: Config last level cache to 2-way and full-way associative cache and test performance

Download the benchmark file provided by TAs. Then execute the scripts [scripts/task3_quicksort_benchmark.sh](scripts/task3_quicksort_benchmark.sh) to run the benchmark.

### Task 4: Modify last level cache policy based on frequency based replacement policy

Reference: [Replacement Policies](https://www.gem5.org/documentation/general_docs/memory_system/replacement_policies/)

> [!TIP]
> Refer to [gem5/src/mem/cache/replacement_policies/ReplacementPolicies.py](gem5/src/mem/cache/replacement_policies/ReplacementPolicies.py) for all replacement policies.

In this part, I modified two files

- [gem5/configs/common/Options.py](gem5/configs/common/Options.py)

  ```python
  parser.add_option("--l3_replacement_policy", type="string", default="LRU")
  ```

- [gem5/configs/common/CacheConfig.py](gem5/configs/common/CacheConfig.py)

  ```python
  # Task 4: Modify last level cache policy based on frequency based replacement policy
  if options.l3_replacement_policy == "LFU":
      system.l3.replacement_policy = LFURP()
  else:
      system.l3.replacement_policy = LRURP() # default policy
  ```

### Task 5: Test the performance of write back and write through policy based on 4-way associative cache with isscc_pcm

> Run benchmark multiply in write through and write back policy. (In GEM5, the default policy is write back, we can judge the policy by the number of write requests.)

> [!TIP] 
> [`gem5/src/mem/cache/base.cc`](gem5/src/mem/cache/base.cc) and [`gem5/src/mem/cache/cache.cc`](gem5/src/mem/cache/cache.cc) are the files that define the cache policy. We can check the number of _total requests_ and _write requests_ to determine the policy.

```cpp
// ...
} else if (blk && (pkt->needsWritable() ? blk->isWritable() :
                    blk->isReadable())) {
    // OK to satisfy access
    incHitCount(pkt);
    satisfyRequest(pkt, blk);
    maintainClusivity(pkt->fromCache(), blk);

    // Add this part to the code
    // Write back the block if it is writable when we are doing a normal read/write request
    // This has the same effect as write through policy
    if (blk->isWritable()) {
        PacketPtr writeclean_pkt = writecleanBlk(blk, pkt->req->getDest(), pkt->id);
        writebacks.push_back(writeclean_pkt);
    }

    return true;
}

// ...
```

#### Write Back

- Write Request -> If hit, write to cache block
- When a dirty block is evicted, write back to memory.
- Note that in this policy, read misses would cause write backs.

#### Write Through

- Write Request -> If hit, write to cache block

## Evaluation

> [!TIP]
> You can use [utils/extract.py](utils/extract_stats.py) to get an integrated [out/output_stats.csv](out/output_stats.csv).

The following metrics are extracted from the `stats.txt` and `log.txt` files.

- `sim_seconds`
- `sim_ticks`
- `system.l3.overall_hits::total`
- `system.l3.overall_misses::total`
- `system.l3.overall_miss_rate::total`

### Energy Consumption

- `system.mem_ctrls.pwrStateResidencyTicks::UNDEFINED`
- `system.pwrStateResidencyTicks::UNDEFINED`

Above are in `stats.txt`. Below are in `log.txt`.

### The Number of Read/Write Requests

- `i0.defaultMemory.totalReadRequests`
- `i0.defaultMemory.totalWriteRequests`

## References

- Final project_Ch.pptx
- [The gem5 Memory System](https://www.gem5.org/documentation/general_docs/memory_system/gem5_memory_system/)
- [[2022 種子教師培訓 (4/5)] Gem5 實作流程 (詳細介紹與實作)](https://www.youtube.com/watch?v=W5JXM3wIdcY)
- MSHR
    - [Miss Status Holding Registers(MSHR)](https://miaochenlu.github.io/2020/10/29/MSHR/)
- Crossbar
    - [Interconnection Network](https://www.gem5.org/documentation/general_docs/ruby/interconnection-network/)
    - [Classic Caches](https://www.gem5.org/documentation/general_docs/memory_system/classic_caches/)