#pragma once
#define MAX_NUM_EDGES 100
#define T_MAX 1000
#define T_MIN 1

void setInitialPlace(int **P, int numVertices, int gridSize[2]);

int computeScore(int edges[MAX_NUM_EDGES][2], int **P, int numEdges);

int moveRandomVertice(int **P, int gridSize[2], int numVertices);

void swipeTwoVertices(int **P, int numVertices);

void generateNewP(int **P, int gridSize[2], int numVertices);

void copy2DArray(int **Dest, int **Source, int length);

int simulatedAnnealing(int **P, int numVertices, int edges[MAX_NUM_EDGES][2], int numEdges, int gridSize[2], double cooling_rate, unsigned seed);
