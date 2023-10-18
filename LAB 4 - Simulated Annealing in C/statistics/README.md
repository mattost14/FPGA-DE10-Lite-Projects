# Statistics Analysis of Simulated Annealing Algorithm for different cooling rate

## How to build
Inside the root folder run:
$ make

## How to run

$ ./place_stat <input.txt> <N>

Where N is the number of runs.

The input file has the grid size, number of vertices, and edges definition. It should follow the structure of input.txt file.
The output file will have the optimal vertices placement and the list of edges.

## Plot Statistics  (using Python)
Python package required: matplotlib

$ python plotStats.py

After running the place_stat program, the files E.txt and Time.txt will be created with solution score, and time of execution for each of the cooling rate tested.








