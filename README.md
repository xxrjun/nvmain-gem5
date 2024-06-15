# NVMain + Gem5

- [NVMain + Gem5](#nvmain--gem5)
  - [Environment Setup](#environment-setup)
  - [Grading Policy](#grading-policy)
  - [References](#references)


## Environment Setup

Please refer to [Environment Setup](docs/EnvironmentSetup.md) for detailed instructions.



## Grading Policy

| Criteria                                                                                                    | Percentage | Details                                                                                                  | Status  |
| ----------------------------------------------------------------------------------------------------------- | ---------- | -------------------------------------------------------------------------------------------------------- | ------- |
| GEM5 + NVMAIN BUILD-UP                                                                                      | 40%        | 參照投影片教學                                                                                           | Pending |
| Enable L3 last level cache in GEM5 + NVMAIN                                                                 | 15%        | -                                                                                                        | Pending |
| Config last level cache to 2-way and full-way associative cache and test performance                        | 15%        | 必須跑benchmark quicksort在 2-way跟 full way                                                             | Pending |
| Modify last level cache policy based on frequency based replacement policy                                  | 15%        | -                                                                                                        | Pending |
| Test the performance of write back and write through policy based on 4-way associative cache with isscc_pcm | 15%        | 必須跑 benchmark multiply 在 write through跟 write back                                                  | Pending |
| Bonus                                                                                                       | 10%        | Design last level cache policy to reduce the energy consumption of pcm_based main memory (Baseline: LRU) | Pending |


## References

- Final project_Ch.pptx