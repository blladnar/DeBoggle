//
//  MasterViewController.h
//  DeBoggle
//
//  Created by Randall Brown on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <vector>
using namespace std;

@class DetailViewController;

@interface MasterViewController : UIViewController<UITextFieldDelegate>
{
   IBOutlet UITextField *row1;
   IBOutlet UITextField *row2;
   IBOutlet UITextField *row3;
   IBOutlet UITextField *row4;

   vector<string> dictionary;
   BOOL loadingDictionary;
   NSMutableArray *textFields;
   IBOutlet UIActivityIndicatorView *spinner;
}
- (IBAction)solve:(id)sender;
- (IBAction)clearBoard:(id)sender;
- (IBAction)changeTo5x5:(id)sender;
- (IBAction)chageTo4x4:(id)sender;

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
