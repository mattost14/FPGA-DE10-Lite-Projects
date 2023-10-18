import numpy as np
import matplotlib.pyplot as plt

def plotScoreStats(data):
    column_averages = np.mean(data, axis=0)  # Compute column averages
    column_min = np.min(data, axis=0)  # Compute minimum for each column
    column_max = np.max(data, axis=0)  # Compute maximum for each column

    x = np.arange(len(column_averages))
    # plt.bar(x, column_averages, label='Average', align='center')
    plt.errorbar(x, column_averages, yerr=[column_averages - column_min, column_max - column_averages], fmt='o', color='red')

    custom_xticks = [f'{x_val:.5f}' for x_val in [0.99, 0.999, 0.9999, 0.99999]]
    plt.xticks([0, 1, 2, 3], custom_xticks)  # Set custom x-tick labels
    plt.xlabel('Cooling Rate')
    plt.ylabel('Solution Score')
    plt.title('Average and Range of Final Solution Score')
    plt.grid(True)  # Add a grid
    # plt.suptitle('file: input3.txt, N = 500 runs each case')  # Add a subtitle

    for i, avg in enumerate(column_averages):
        plt.text(i, avg, f'{avg:.0f}', ha='left', va='bottom')

    plt.show()

def plotTimeStats(data):
    column_averages = np.mean(data, axis=0)  # Compute column averages
    column_min = np.min(data, axis=0)  # Compute minimum for each column
    column_max = np.max(data, axis=0)  # Compute maximum for each column

    x = np.arange(len(column_averages))
    # plt.bar(x, column_averages, label='Average', align='center')
    plt.errorbar(x, column_averages, yerr=[column_averages - column_min, column_max - column_averages], fmt='o', color='red')

    custom_xticks = [f'{x_val:.5f}' for x_val in [0.99, 0.999, 0.9999, 0.99999]]
    plt.xticks([0, 1, 2, 3], custom_xticks)  # Set custom x-tick labels
    plt.xlabel('Cooling Rate')
    plt.ylabel('Execution Time (s)')
    plt.title('Average and Range of Final Solution Score')
    plt.grid(True)  # Add a grid
    # plt.suptitle('file: input3.txt, N = 500 runs each case')  # Add a subtitle

    for i, avg in enumerate(column_averages):
        plt.text(i, avg, f'{avg:.3f}', ha='left', va='bottom')
    
    plt.show()

def read_data_from_file(file_path):
    # Assuming the data is in tabular format with spaces as delimiter
    data = np.loadtxt(file_path)
    return data

if __name__ == "__main__":
    file_path = 'E.txt'  # Update with your file path
    Edata = read_data_from_file('E.txt')
    TimeData = read_data_from_file('Time.txt')
    plotScoreStats(Edata)
    plotTimeStats(TimeData)
