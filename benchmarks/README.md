# Benchmarks

## Chinese

使用 gcc 編譯成執行檔，需要加入 `--static` 讓 complier 連結 `lib.c` 編入執行檔。
範例:
```bash
gcc --static qicksort.c -o quicksort
```
這樣就會產生 quicksort 執行檔，接著就可以用 gem5 來跑。

gem5 跑 benchmark 時 cache size 規定

- L1i -> 32kB
- L1d -> 32kB
- L2 -> 128kB
- L3 -> 1MB

## English

To compile into an executable file using gcc, you need to add `--static` to let the compiler link `lib.c` and compile it into the executable file. Example:
```bash
gcc --static qicksort.c -o quicksort
```
This will generate the quicksort executable, which can then be run with gem5.

Cache size regulation when gem5 runs benchmark

- L1i -> 32kB
- L1d -> 32kB
- L2 -> 128kB
- L3 -> 1MB
