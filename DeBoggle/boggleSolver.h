//
//  boggleSolver.h
//  BungieStuff
//
//  Created by Randall Brown on 10/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef BungieStuff_boggleSolver_h
#define BungieStuff_boggleSolver_h
#include <string>
#include <vector>

using namespace std;

class BoggleSolver
{
private:
   char board[100][100];
   vector<int> visitedLocations;
   vector<string> validStrings;
   vector<string> dictionary;
   int size;
   
   int currentX;
   int currentY;
   int minWordSize;
   
   void checkString( string currentString, int x, int y );
   int indexForRowCol(int x, int y);
   bool shouldWeLookHere( int x, int y );
   void clearVisitedLocations();
   bool stringIsInDictionary( string stringToCheck, bool &prefixMatch );
   void insertIfUnique( string insertString );
   bool prefixSearch( string stringToCheck );

   
public:
   BoggleSolver( int newSize, char newBoard[][100], vector<string> newDictionary, int newMinWordSize = 3 );
   vector<string> solve();
   
   
};

#endif
