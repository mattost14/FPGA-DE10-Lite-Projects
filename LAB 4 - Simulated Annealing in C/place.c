#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>
#include <time.h>
#include "annealing.h"

void parseInputFile(FILE *inputFile, int ***P, int gridSize[2], int *numVertices, int *numEdges, int edges[MAX_NUM_EDGES][2]);

int main( int argc, char *argv[] )  {
   FILE *inputFile;
   FILE *outFile;
   int gridSize[2]; 
   // char ch;
   int numVertices;
   int numEdges = 0;
   int edges[MAX_NUM_EDGES][2];
   int **P;
   clock_t t;

   // Parse Inputs
   if( argc == 3 ) {
      // Read input file
      printf("Input file is %s\n", argv[1]);
      inputFile = fopen(argv[1], "r");
      // Open output file
      printf("Output file is %s\n", argv[2]);
      if(inputFile == NULL) {
         printf("Not able to open the file!\n");
         exit(1);
      }
      else {
         parseInputFile(inputFile, &P, gridSize, &numVertices, &numEdges, edges);
      }
   }
   else if( argc > 3 ) {
      printf("Too many arguments supplied.\n");
      exit(1);
   }
   else {
      printf("Two argument expected: <input file> <output file>.\n");
      exit(1);
   }

   // Initialize Placement
   setInitialPlace(P, numVertices, gridSize);

   // Print in console the Initial Place and Edges
   printf("\nInitial Place:\n");
   for(int n=0; n<numVertices; n++){
      printf("Node %d placed at (%d, %d)\n", n, P[n][0], P[n][1]);
   }
   for(int i=0; i<numEdges; i++){
      printf("Edge from %d to %d has length %d\n", edges[i][0], edges[i][1], abs(P[edges[i][1]][0]-P[edges[i][0]][0])+abs(P[edges[i][1]][1]-P[edges[i][0]][1]));
   }

   // Compute Initial Score
   printf("Initial Score E = %d\n", computeScore(edges, P, numEdges));

   // Run Simulated Annealing and acquire execution time
   printf("\n*** Start Simulated Annealing ***\n");
   t = clock();
   simulatedAnnealing(P, numVertices, edges, numEdges, gridSize);
   t = clock()-t;
   printf(" Execution time: %f sec\n", ((double)t)/CLOCKS_PER_SEC);
   printf("\n*** End Simulated Annealing ***\n");

   // Display Final Place and Edges
   printf("\nFinal Place:\n");
   for(int n=0; n<numVertices; n++){
      printf("Node %d placed at (%d, %d)\n", n, P[n][0], P[n][1]);
   }
   for(int i=0; i<numEdges; i++){
      printf("Edge from %d to %d has length %d\n", edges[i][0], edges[i][1], abs(P[edges[i][1]][0]-P[edges[i][0]][0])+abs(P[edges[i][1]][1]-P[edges[i][0]][1]));
   }

   // Write output file
   outFile = fopen(argv[2], "w");
   for(int n=0; n<numVertices; n++){
      fprintf(outFile, "Node %d placed at (%d, %d)\n", n, P[n][0], P[n][1]);
   }
   for(int i=0; i<numEdges; i++){
      fprintf(outFile, "Edge from %d to %d has length %d\n", edges[i][0], edges[i][1], abs(P[edges[i][1]][0]-P[edges[i][0]][0])+abs(P[edges[i][1]][1]-P[edges[i][0]][1]));
   }

   // Close the files
   fclose(inputFile);
   fclose(outFile);
   // Free Dynamic Memory
   free(P);

   return 0;
}

void parseInputFile(FILE *inputFile, int ***P, int gridSize[2], int *numVertices, int *numEdges, int edges[MAX_NUM_EDGES][2]){
   char ch[2];
   // Parse Header Inputs
   fscanf(inputFile, "%s %d %d", ch, &gridSize[0], &gridSize[1]);
   if(ch[0] == 'g')
      printf("Grid Size = %d x %d \n", gridSize[0], gridSize[1]);
   fscanf(inputFile, "%s %d", ch, numVertices);
   if(ch[0] == 'v')
      printf("Number of Vertices = %d \n", *numVertices);

   // Allocate Placement Array
   *P = calloc(*numVertices , sizeof(int*));
   for(int i = 0; i < *numVertices; i++) {
      (*P)[i] = (int *) calloc(2, sizeof(int));
   }     

   // Read Edges Values
   int i=0;
   int flag = 2;
   while (flag == 2){
      if(i<MAX_NUM_EDGES){
         flag = fscanf(inputFile, "%*s %d %d",  &edges[i][0], &edges[i][1]);
         i++;
      }
      else{
         printf("Warning: the input file contains more edges than the maximum allowed. Only the first %d will be computed.\n", MAX_NUM_EDGES);
         break;
      }
   }
   *numEdges = i-1;
   printf("Number of edges: %d\n", *numEdges);
}