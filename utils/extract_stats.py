import os
import pandas as pd

# Define the stats to extract
header_list = ['Name', 'sim_seconds', 'sim_ticks', 
                'system.mem_ctrls.num_reads::total', 'system.mem_ctrls.num_writes::writebacks', 'system.mem_ctrls.num_writes::total',
                'system.l3.overall_hits::total', 'system.l3.overall_misses::total', 'system.l3.overall_miss_rate::total', 
                'system.mem_ctrls.pwrStateResidencyTicks::UNDEFINED', 'system.pwrStateResidencyTicks::UNDEFINED',
                'i0.defaultMemory.totalReadRequests', 'i0.defaultMemory.totalWriteRequests']

# Function to extract stats from a list of files
def extract_stats(file_paths):
    stats = {}
    for file_path in file_paths:
        with open(file_path, 'r') as file:
            for line in file:
                for val in header_list:
                    if line.startswith(val):
                        stats[val] = line.split()[1]
    return stats

# Main function to read folders and compile stats
def main():
    data = []
    base_path = "../out"
    
    for folder_name in os.listdir(base_path):
        folder_path = os.path.join(base_path, folder_name)
        if os.path.isdir(folder_path):
            stats_file_path = os.path.join(folder_path, 'stats.txt')
            log_file_path = os.path.join(folder_path, 'log.txt')
            if os.path.isfile(stats_file_path) and os.path.isfile(log_file_path):
                stats = extract_stats([stats_file_path, log_file_path])
                stats['Name'] = folder_name
                data.append(stats)
    
    # Define the order of columns for the CSV
    # Create a DataFrame and save it to CSV
    df = pd.DataFrame(data, columns=header_list)
    df.to_csv('../out/output_stats.csv', index=False)

if __name__ == '__main__':
    main()
