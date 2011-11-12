//
//  ResultsViewController.h
//  DeBoggle
//
//  Created by Randall Brown on 11/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <GameKit/GameKit.h>

@interface ResultsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, GKLeaderboardViewControllerDelegate>
{
   IBOutlet UILabel *scoreLabel;
   IBOutlet UILabel *wordsLabel;
   int score;
   int words;
   
}

- (IBAction)viewHighScores:(id)sender;
@property (nonatomic, retain) NSArray *wordsUsed;
@property (nonatomic, retain) NSString *boardString;
@end  
