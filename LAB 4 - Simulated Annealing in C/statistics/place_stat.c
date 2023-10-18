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
   // FILE *outFile;
   int gridSize[2]; 
   // char ch;
   int numVertices;
   int numEdges = 0;
   int edges[MAX_NUM_EDGES][2];
   int **P;
   clock_t t;
   
   int numCoolingRate = 4;
   double cooling_rate[] = {.99, .999, .9999, .99999};
   int N;
   int **E;
   float **Time;

   // Parse Inputs
   if( argc == 3 ) {
      // Read input file
      printf("Input file is %s\n", argv[1]);
      inputFile = fopen(argv[1], "r");
      // Open output file
      N = atoi(argv[2]);
      printf("Number of runs is %d\n", N);     
      if(inputFile == NULL) {
         printf("Not able to open the file!\n");
         exit(1);
      }
   }
   else if( argc > 3 ) {
      printf("Too many arguments supplied.\n");
      exit(1);
   }
   else {
      printf("Two argument expected: <input file> <N>.\n");
      exit(1);
   }

   // Parse Inputs File
   parseInputFile(inputFile, &P, gridSize, &numVertices, &numEdges, edges);

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

   // Allocate Memory to E array and Time array
   E = calloc(N , sizeof(int*));
   Time = calloc(N , sizeof(float*));
   for(int i = 0; i < N; ++i) {
      E[i] = (int *) calloc(numCoolingRate, sizeof(int));
      Time[i] = (float *) calloc(numCoolingRate, sizeof(float));
   }  
   


   // Run N times to collect Final Score and Execution Time
   unsigned int seed = time(NULL);
   printf("\n\n"); 
   for(int j=0; j<numCoolingRate; j++){
      printf("Testing Cooling Rate = %f\n",cooling_rate[j]); 
      for (int i=0; i<N; i++){
         t = clock();
         E[i][j] = simulatedAnnealing(P, numVertices, edges, numEdges, gridSize, cooling_rate[j], seed + i);
         t = clock()-t;
         Time[i][j] = ((float)t)/CLOCKS_PER_SEC;
      }
   }

   // Print Results
   FILE *outFile = fopen("E.txt","w");
   printf("Printing Score Results \n");
   for(int i=0; i<N; i++){
      fprintf(outFile, "%d %d %d %d\n", E[i][0], E[i][1], E[i][2], E[i][3]);
   }

   // Print Results
   FILE *outFile2 = fopen("Time.txt","w");
   printf("Printing Time Results \n");
   for(int i=0; i<N; i++){
      fprintf(outFile2, "%f %f %f %f\n", Time[i][0], Time[i][1], Time[i][2], Time[i][3]);
   }

   // // Compute Initial Score
   // printf("Initial Score E = %d\n", computeScore(edges, P, numEdges));

   // // Run Simulated Annealing and acquire execution time
   // printf("\n*** Start Simulated Annealing ***\n");
   // t = clock();
   // simulatedAnnealing(P, numVertices, edges, numEdges, gridSize);
   // t = clock()-t;
   // printf(" Execution time: %f sec\n", ((double)t)/CLOCKS_PER_SEC);
   // printf("\n*** End Simulated Annealing ***\n");

   // // Display Final Place and Edges
   // printf("\nFinal Place:\n");
   // for(int n=0; n<numVertices; n++){
   //    printf("Node %d placed at (%d, %d)\n", n, P[n][0], P[n][1]);
   // }
   // for(int i=0; i<numEdges; i++){
   //    printf("Edge from %d to %d has length %d\n", edges[i][0], edges[i][1], abs(P[edges[i][1]][0]-P[edges[i][0]][0])+abs(P[edges[i][1]][1]-P[edges[i][0]][1]));
   // }

   // // Write output file
   // outFile = fopen(argv[2], "w");
   // for(int n=0; n<numVertices; n++){
   //    fprintf(outFile, "Node %d placed at (%d, %d)\n", n, P[n][0], P[n][1]);
   // }
   // for(int i=0; i<numEdges; i++){
   //    fprintf(outFile, "Edge from %d to %d has length %d\n", edges[i][0], edges[i][1], abs(P[edges[i][1]][0]-P[edges[i][0]][0])+abs(P[edges[i][1]][1]-P[edges[i][0]][1]));
   // }

   // Close the files
   fclose(inputFile);
   fclose(outFile);
   fclose(outFile2);
   // Free Dynamic Memory
   free(P);
   free(E);

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