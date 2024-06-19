import os
import pandas as pd

# Define the stats to extract
STATS_TO_EXTRACT = {
    'sim_seconds': 'sim_seconds',
    'sim_ticks': 'sim_ticks',
    'system.l3.overall_hits::total': 'system.l3.overall_hits::total',
    'system.l3.overall_misses::total': 'system.l3.overall_misses::total',
    'system.l3.overall_miss_rate::total': 'system.l3.overall_miss_rate::total',
    'system.mem_ctrls.pwrStateResidencyTicks::UNDEFINED': 'system.mem_ctrls.pwrStateResidencyTicks::UNDEFINED',
    'system.pwrStateResidencyTicks::UNDEFINED': 'system.pwrStateResidencyTicks::UNDEFINED'
}

header_list = ['Name', 'sim_seconds', 'sim_ticks', 'system.l3.overall_hits::total', 'system.l3.overall_misses::total', 'system.l3.overall_miss_rate::total', 'system.mem_ctrls.pwrStateResidencyTicks::UNDEFINED', 'system.pwrStateResidencyTicks::UNDEFINED']

# Function to extract stats from a file
def extract_stats(file_path):
    stats = {}
    with open(file_path, 'r') as file:
        for line in file:
            for key in STATS_TO_EXTRACT:
                if line.startswith(key):
                    stats[STATS_TO_EXTRACT[key]] = line.split()[1]
    return stats

# Main function to read folders and compile stats
def main():
    data = []
    base_path = "../out"
    
    for folder_name in os.listdir(base_path):
        folder_path = os.path.join(base_path, folder_name)
        if os.path.isdir(folder_path):
            stats_file_path = os.path.join(folder_path, 'stats.txt')
            if os.path.isfile(stats_file_path):
                stats = extract_stats(stats_file_path)
                stats['Name'] = folder_name
                data.append(stats)
    
    # Define the order of columns for the CSV
    # Create a DataFrame and save it to CSV
    df = pd.DataFrame(data, columns=header_list)
    df.to_csv('../out/output_stats.csv', index=False)

if __name__ == '__main__':
    main()
