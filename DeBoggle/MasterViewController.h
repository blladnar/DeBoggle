//
//  MasterViewController.h
//  DeBoggle
//
//  Created by Randall Brown on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <vector>
#include <GameKit/GameKit.h>
using namespace std;

@class DetailViewController;

@interface MasterViewController : UIViewController<UITextFieldDelegate,GKLeaderboardViewControllerDelegate,GKAchievementViewControllerDelegate>
{
   vector<string> dictionary;
   BOOL loadingDictionary;
   NSMutableArray *textFields;
   IBOutlet UIActivityIndicatorView *spinner;
   IBOutlet UILabel *wordCount;
   IBOutlet UITextField *wordField;
   IBOutlet UILabel *scoreLabel;
   IBOutlet UILabel *timerLabel;
   NSArray *validWords;
   NSMutableArray *usedWords;
   int wordsInPuzzle;
   int score;
   NSDate *startTime;
   NSTimer *updater;
   NSMutableString *boardString;
   BOOL waitForStart;
   IBOutlet UIButton *fourByFourButton;
   IBOutlet UIButton *fiveByFiveButton;
   IBOutlet UIButton *achievementsButton;
   double gameTime;
   IBOutlet UILabel *fourByFourLabel;
   IBOutlet UILabel *fiveByFiveLabel;
   IBOutlet UILabel *selectABoardLabel;
}
@property (retain, nonatomic) IBOutlet UIButton *leaderboardsButton;
- (IBAction)solve:(id)sender;
- (IBAction)clearBoard:(id)sender;
- (IBAction)changeTo5x5:(id)sender;
- (IBAction)chageTo4x4:(id)sender;
- (IBAction)showAchievements:(id)sender;
- (IBAction)showLeaderboards:(id)sender;

-(void)generateBoardForSize:(NSInteger)size withBoard:(NSString*)newBoard;

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
