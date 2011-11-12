//
//  boggleSolver.cpp
//  BungieStuff
//
//  Created by Randall Brown on 10/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include <iostream>

#include "boggleSolver.h"

using namespace std;

BoggleSolver::BoggleSolver( int newSize, char newBoard[][100], vector<string> newDictionary, int newMinWordSize /*=4*/ )
{
   minWordSize = newMinWordSize;
   size = newSize;
   for( int i= 0; i < size; i++ )
   {
      for( int j = 0; j < size; j++ )
      {
         board[i][j] = newBoard[i][j];
      }
   }
   
//   for(vector<string>::iterator it = newDictionary.begin(); it != newDictionary.end(); ++it) 
//   {
//      (*it)[0] = tolower((*it)[0]);
//      dictionary.push_back(*it);
//   }
   dictionary = newDictionary;
}

int BoggleSolver::indexForRowCol(int x, int y)
{
   return x*size + y;
}

bool BoggleSolver::shouldWeLookHere(int x, int y )
{
   int index = indexForRowCol( x, y );
   vector<int>::iterator locationSpot = find( visitedLocations.begin(), visitedLocations.end(), index );
   bool retVal =  x >= 0 && y >= 0 && x < size && y < size && locationSpot == visitedLocations.end();
   return retVal;
}

void BoggleSolver::insertIfUnique( string insertString )
{
   if ( find(validStrings.begin(), validStrings.end(), insertString) == validStrings.end()) 
   {
      validStrings.push_back(insertString);
   }
}

bool BoggleSolver::prefixSearch( string stringToCheck )
{
   int size = (int)dictionary.size()/2;
   int max = (int)dictionary.size();
   int compareResult = stringToCheck.compare(dictionary[size].substr(0, stringToCheck.size()));
   int lastSize = 0;
   
   while( compareResult != 0 && lastSize != size )
   {
      lastSize = size;
      if( compareResult < 0 )
      {
         max = size;
         size = size/2;
      }
      else if( compareResult > 0 )
      {
         size+= (max-size)/2; 
      }
      
      compareResult = stringToCheck.compare(dictionary[size].substr(0,stringToCheck.size()));

   }
   
   return compareResult == 0;
}


bool BoggleSolver::stringIsInDictionary( string stringToCheck, bool &prefixMatch )
{
   prefixMatch = prefixSearch(stringToCheck);
   
   int size = (int)dictionary.size()/2;
   int max = (int)dictionary.size();
   int compareResult = stringToCheck.compare(dictionary[size]);
   int lastSize = 0;
   
   while( compareResult != 0 && lastSize != size )
   {
      lastSize = size;
      if( compareResult < 0 )
      {
         max = size;
         size = size/2;
      }
      else if( compareResult > 0 )
      {
         size+= (max-size)/2; 
      }
      compareResult = stringToCheck.compare(dictionary[size]);
                                            
   }
   
   return compareResult == 0;
}

void BoggleSolver::checkString(string currentString, int x, int y)
{
   int index = indexForRowCol(x, y);
      visitedLocations.push_back(index);
   
   string stringToCheck = currentString + board[x][y];
   
   bool prefixMatch;
   
   bool stringFound = stringIsInDictionary( stringToCheck, prefixMatch );
   if(  stringFound && stringToCheck.length() >= minWordSize )      
   {
      insertIfUnique(stringToCheck);
   }
   
   if( !prefixMatch && !stringFound )
   {
      visitedLocations.pop_back();
      return;
   }

   if( shouldWeLookHere( x+1, y ) )
   {
      checkString(stringToCheck, x+1, y);
   }
   
   if( shouldWeLookHere( x, y+1 ) )
   {
      checkString(stringToCheck, x, y+1);
   }

   if( shouldWeLookHere( x-1, y ) )
   {
      checkString(stringToCheck, x-1, y); 
   }

   if( shouldWeLookHere( x, y-1 ) )
   {
      checkString(stringToCheck, x, y-1); 
   }
   
   if( shouldWeLookHere( x-1, y-1 ) )
   {
      checkString(stringToCheck, x-1, y-1); 
   }
   
   if( shouldWeLookHere( x+1, y+1 ) )
   {
      checkString(stringToCheck, x+1, y+1); 
   }
   
   if( shouldWeLookHere( x+1, y-1 ) )
   {
      checkString(stringToCheck, x+1, y-1); 
   }
   
   if( shouldWeLookHere( x-1, y+1 ) )
   {
      checkString(stringToCheck, x-1, y+1); 
   }

   visitedLocations.pop_back();

}

void BoggleSolver::clearVisitedLocations()
{
   visitedLocations.clear();
}

vector<string> BoggleSolver::solve()
{
   for( int y = 0; y < size; y++ )
   {
      for( int x = 0; x < size; x++ )
      {
         string startString = "";
         checkString(startString, x, y);
      }
   }
   
   return validStrings;
}


