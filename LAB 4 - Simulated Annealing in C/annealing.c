#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>
#include <time.h>
#include "annealing.h"

//Set initial position of vertices by placing them in a compact square-like factor 
void setInitialPlace(int **P, int numVertices, int gridSize[2]){
   int squareHeight, squareWidth;

   squareHeight = ceil(sqrt(numVertices));
   squareWidth = squareHeight;

   int n=0;
   for(int row=0; row<squareHeight; row++){
      for(int col=0; col<squareWidth; col++){
         P[n][0] = row;
         P[n][1] = col;
         n++;
         if(n>= numVertices){
            break;
         }
      }
   }
}

// This function computes the sum of the squares of all edges length 
int computeScore(int edges[MAX_NUM_EDGES][2], int **P, int numEdges){
   int score = 0, x0, y0, x1, y1, edgeLength;

   for(int i=0; i<numEdges; i++){
      x0 = P[edges[i][0]][0];
      y0 = P[edges[i][0]][1];
      x1 = P[edges[i][1]][0];
      y1 = P[edges[i][1]][1];
      edgeLength = abs(x1-x0)+abs(y1-y0);
      score = score + (int)pow((double)edgeLength,2);
   }
   return score;
}

// Move a random vertice by one step in the grid
int moveRandomVertice(int **P, int gridSize[2], int numVertices){
   int idx0, deltaY, deltaX, xnew, ynew;
   bool isPositionValid, isPositionAvailable;
      do{
         // Randomly select the element to move
         idx0 = rand() % (numVertices);  
         xnew = P[idx0][0];
         ynew = P[idx0][1];

         // Randomly select the direction of the move
         deltaY = rand() % (3) - 1;       // options = {-1, 0, 1}
         deltaX = rand() % (3) - 1;       // options = {-1, 0, 1}

         isPositionValid = true;
         // Check if movement is violate the grid dimensions
         if(P[idx0][1] + deltaY <0 || P[idx0][1] + deltaY >= gridSize[1] || P[idx0][0] + deltaX <0 || P[idx0][0] + deltaX >= gridSize[0]){
            isPositionValid = false;
         }
         else {
            xnew = P[idx0][0] + deltaX;
            ynew = P[idx0][1] + deltaY;
         }
      } while(isPositionValid == false || (deltaY!=0 || deltaX!=0) != true);

      // If position is valid, check if position is available if 
      isPositionAvailable = true;
      for(int i=0; i< numVertices; i++){
         if(P[i][0] == xnew && P[i][1] == ynew){
            isPositionAvailable = false;
            break;
         }
      }
      // Since, position is valid and available, change to new position
      if(isPositionAvailable){
         P[idx0][0] = xnew;
         P[idx0][1] = ynew;
         return 1; // Returns one if vertice was moved
      }     
      return 0;   // Returns zero if vertice was not moved
}

// Swipe two random vertices 
void swipeTwoVertices(int **P, int numVertices){
   int idx0, idx1, temp[2];
   idx0 = rand() % (numVertices);
   idx1 = rand() % (numVertices);

   do{
      idx1 = rand() % (numVertices);
   }while(idx0 == idx1);

   if(idx0 != idx1){
      // Store temporarly the position of the first element
      temp[0] = P[idx0][0];
      temp[1] = P[idx0][1];
      // Replace first element by second element
      P[idx0][0] = P[idx1][0];
      P[idx0][1] = P[idx1][1];
      // Replace second by the first element
      P[idx1][0] = temp[0];
      P[idx1][1] = temp[1];
   }
}

// Generate new place P by swiping and moving vertices
void generateNewP(int **P, int gridSize[2], int numVertices){
   // Random mode selection: 0 - Move, 1 - Swipe, 2 - Swipe and Move
   int mode = rand() % (3);
   int movedFlag = 1;
   mode = 0;

   switch (mode){
      case 0:
      movedFlag = moveRandomVertice(P, gridSize, numVertices);
      break;
      case 1:
      swipeTwoVertices(P, numVertices);
      break;
      case 2:
      moveRandomVertice(P, gridSize, numVertices);
      swipeTwoVertices(P, numVertices);
      break;
   }
  // If Mode was 0, but it could not move any vertice, then swipe two random vertices
   if(movedFlag == false && mode == 0){
      swipeTwoVertices(P, numVertices);
   }
}

// Copy content from Source to Dest 2D array
void copy2DArray(int **Dest, int **Source, int length){
   for(int i=0; i<length; i++){
      Dest[i][0] = Source[i][0];
      Dest[i][1] = Source[i][1];
   }
}

// Run simulated annealing
void simulatedAnnealing(int **P, int numVertices, int edges[MAX_NUM_EDGES][2], int numEdges, int gridSize[2]){
   int E, E_new, E_best, i=0, deltaE;
   int **P_new, **P_best;
   double acceptanceProp, randomP, T;
   unsigned int seed = time(NULL);
   FILE *Ehist;

   // File to Store score E
   Ehist = fopen("o_score.txt","w");

   // Set the random generator seed
   srand(seed);

   // Present Simulation Paremeters
   printf(" Random seed = %d \n",seed);
   printf(" T_max = %d \n",T_MAX);
   printf(" T_min = %d \n",T_MIN);
   printf(" Cooling Rate = %f \n\n",COOLING_RATE);

   // Allocate memory for temporary 2D arrays: P_new, P_best
   P_new = calloc(numVertices , sizeof(int*));
   P_best = calloc(numVertices , sizeof(int*));
   for(int i = 0; i < numVertices; ++i) {
      P_new[i] = (int *) calloc(2, sizeof(int));
      P_best[i] = (int *) calloc(2, sizeof(int));
   }  

   // Initiate
   E = computeScore(edges, P, numEdges);
   E_best = E;
   copy2DArray(P_best, P, numVertices);
   copy2DArray(P_new, P, numVertices);
   T = T_MAX;

   while(T > T_MIN){
      // Generate New Place
      generateNewP(P_new, gridSize, numVertices);
      // Compute New Score
      E_new = computeScore(edges, P_new, numEdges);
      // Write score E to file
      fprintf(Ehist, "%d\n", E);

      // Check if E is lower than E_best
      if(E_new < E){
         E = E_new;
         copy2DArray(P, P_new, numVertices); // Copy P_new content to P
         if(E_new < E_best){  // Stores the best ever found solution and score
            E_best =  E_new;
            copy2DArray(P_best, P_new, numVertices);
         }
      }
      else{
         deltaE = abs(E_new - E);
         acceptanceProp = exp(-deltaE/T);
         randomP =  ((double)rand()/ RAND_MAX);   // Random Number from 0-1
         if(randomP <= acceptanceProp){
            copy2DArray(P, P_new, numVertices);  // Copy P_new content to P
            E = E_new;
         }
         else {
            copy2DArray(P_new, P, numVertices);  // Copy P content to P_new
         }
      }

      i++;
      T = T * COOLING_RATE;
   }

   // Set P as the Best P
   copy2DArray(P, P_best, numVertices); 

   // Print Final Result
   printf(" Final Score E = %d\n", E_best);
   printf(" Number of iterations: %d\n", i);

   // Free Dynamic Memory
   free(P_new);
   free(P_best);

   // Close files
   fclose(Ehist);
}