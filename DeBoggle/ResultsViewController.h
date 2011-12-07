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
#import <iAd/iAd.h>

@interface ResultsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, GKLeaderboardViewControllerDelegate, ADBannerViewDelegate>
{
   IBOutlet UILabel *scoreLabel;
   IBOutlet UILabel *wordsLabel;
   int score;
   int words;
   
}
- (IBAction)descrumbledInAppStore:(id)sender;

- (IBAction)viewHighScores:(id)sender;
@property (nonatomic, retain) NSArray *wordsUsed;
@property (nonatomic, retain) NSArray *validWords;
@property (nonatomic, retain) NSString *boardString;
@end  
