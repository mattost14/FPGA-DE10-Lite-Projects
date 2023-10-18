import matplotlib.pyplot as plt

def read_vector_from_file(filename):
    with open(filename, 'r') as file:
        # Read the content of the file and split by spaces or newlines
        vector = [float(num) for num in file.read().split()]
    return vector

def plot_vector(vector):
    # Create a plot
    plt.plot(vector)

    # Add labels and title
    plt.xlabel('Iteration')
    plt.ylabel('Score E')
    plt.title('Solution Quality for: input2.txt')

    # Display the plot
    plt.show()

if __name__ == "__main__":
    filename = 'o_score.txt'
    vector = read_vector_from_file(filename)
    # print('Vector:', vector)
    plot_vector(vector)