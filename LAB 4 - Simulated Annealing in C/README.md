# Simulated Annealing for Optimum Vertices Placement on a Grid

## How to build
Inside the root folder run:

$ make

## How to run
$ ./place <input.txt> <output.txt>

The input file has the grid size, number of vertices, and edges definition. It should follow the structure of input.txt file.
The output file will have the optimal vertices placement and the list of edges.

## Plot Solution Score (using Python)
Python package required: matplotlib

$ python plotScore.py

After running the place program, the file o_score.txt will be created with the solution score of each iteration.








