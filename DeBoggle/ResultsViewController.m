//
//  ResultsViewController.m
//  DeBoggle
//
//  Created by Randall Brown on 11/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ResultsViewController.h"
#import "UIBarButtonItem+Tint.h"
#import <Twitter/Twitter.h>
#import <QuartzCore/QuartzCore.h>

@implementation ResultsViewController

@synthesize wordsUsed;
@synthesize boardString;
@synthesize validWords;
-(int)scoreForWord:(NSString*)word
{
   int length = word.length;
   if( length == 3 || length == 4 )
   {
      return 1;
   }
   else if( length == 5 )
   {
      return 2;
   }
   else if( length == 6 )
   {
      return 3;
   }
   else if( length == 7 )
   {
      return 5;
   }
   else if( length > 8 )
   {
      return 11;
   }
   
   return 0;
}

-(void)reportAchievement:(NSString*)achievementID percent:(float)percent
{
   GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: achievementID] autorelease];
   if (achievement)
   {
      achievement.percentComplete = percent;
      achievement.showsCompletionBanner = YES;
      [achievement reportAchievementWithCompletionHandler:^(NSError *error)
       {
          if (error != nil)
          {
             NSLog(@"%@",error);
          }
       }];
   }
}

-(void)handleAchievements
{
   if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"descrumbled://board/"]] )
   {
      [self reportAchievement:@"Cheater" percent:100.0];
   }
   
   BOOL playedGo = YES;
   BOOL playedBlue = YES;
   
   int numberOfOver10Words = [[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfOver10Words"];
   
   int size = sqrt( [self.boardString length] );

   if( [self.validWords count] == 0 )
   {
      [self reportAchievement:@"NoWords" percent:100.0];
   }
   
   for( NSString *word in self.wordsUsed )
   {
      if( [word isEqualToString:@"go"] )
      {
         playedGo = YES;
      }
      else if( [word isEqualToString:@"blue"] )
      {
         playedBlue = YES;
      }
      
      int perfectLength = size*size;
      if( word.length == perfectLength )
      {
         if( size == 4 )
         {
            [self reportAchievement:@"Perfect4x4" percent:100.0];
         }
         else if( size == 5 )
         {
            [self reportAchievement:@"Perfect5x5" percent:100.0];
         }
      }
      
      if( word.length >= 10 )
      {
         numberOfOver10Words++;
      }
         
      
   }
   
   [[NSUserDefaults standardUserDefaults] setInteger:numberOfOver10Words forKey:@"numberOfOver10Words"];
   [[NSUserDefaults standardUserDefaults] synchronize];
   [self reportAchievement:@"5Over10" percent:(float)numberOfOver10Words/5.0];
   
   if( playedGo && playedBlue )
   {
      [self reportAchievement:@"GoBlue" percent:100.0];
   }
   
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"How'd you do?";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)share:(id)sender
{
   UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"Share Your Score" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Text", @"Email",@"Twitter", nil];
   shareSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
   [shareSheet showInView:self.view];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
   [self dismissModalViewControllerAnimated:YES];
   
   
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
   [self dismissModalViewControllerAnimated:YES];
}

-(NSString*)boardURL 
{
   return [NSString stringWithFormat:@"scrumbled://board/%@",boardString];
}

-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
   if( buttonIndex == 0 )
   {
      NSLog(@"Text");
      if( [MFMessageComposeViewController canSendText] )
      {
         MFMessageComposeViewController *textController = [[[MFMessageComposeViewController alloc] init] autorelease];
         textController.messageComposeDelegate = self;
         textController.body = [NSString stringWithFormat:@"Can you beat my score of %i on this board? %@",score, [self boardURL]];
         [self presentModalViewController:textController animated:YES];
      }
   }
   
   else if( buttonIndex == 1 )
   {
      NSLog(@"Email");
      NSLog(@"Text");
      if( [MFMailComposeViewController canSendMail] )
      {
         MFMailComposeViewController *textController = [[[MFMailComposeViewController alloc] init] autorelease];
         textController.mailComposeDelegate = self;
         [textController setMessageBody:[NSString stringWithFormat:@"Can you beat my score of %i on this board? %@", score,[self boardURL]] isHTML:NO]; 
         [self presentModalViewController:textController animated:YES];
      }
      
   }
   
   else if( buttonIndex == 2 )
   {
      if( NSClassFromString(@"TWTweetComposeViewController") )
      {
         if( [TWTweetComposeViewController canSendTweet] )
         {
            TWTweetComposeViewController *controller = [[[TWTweetComposeViewController alloc] init] autorelease];
            [controller setInitialText:[NSString stringWithFormat:@"Can you beat my score of %i on this board? %@", score,[self boardURL]]];
            
            controller.completionHandler = ^(TWTweetComposeViewControllerResult result){
               [self dismissModalViewControllerAnimated:YES];
            }; 
            [self presentModalViewController:controller animated:YES];
         }
      }
   }
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   score = 0;
   words = self.wordsUsed.count;
   for( NSString *word in self.wordsUsed )
   {
      score+= [self scoreForWord:word];
   }
   

   if( score > 100 )
   {
      [self reportAchievement:@"Over100" percent:100.0];
   }
   else if( score > 50 )
   {
      [self reportAchievement:@"Over50" percent:100.0];
   }
   else if( score > 20 )
   {
      [self reportAchievement:@"Over20" percent:100.0];
   }
   
   scoreLabel.text = [NSString stringWithFormat:@"%i",score];
   wordsLabel.text = [NSString stringWithFormat:@"%i", words];
   
   
   GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];

      if (localPlayer.isAuthenticated)
      {
         int boardSize = sqrt([self.boardString length]);
         if( boardSize == 4 )
         {
            GKScore *gScore = [[GKScore alloc] initWithCategory:@"4x4HighScore"];
            gScore.value = score;
            [gScore reportScoreWithCompletionHandler:^(NSError* error){
               NSLog(@"%@",error);
            }];
            
         }
         else if( boardSize == 5 )
         {
            GKScore *gScore = [[GKScore alloc] initWithCategory:@"5x5HighScore"];
            gScore.value = score;
            [gScore reportScoreWithCompletionHandler:^(NSError* error){
               NSLog(@"%@",error);
            }];
         }
      }
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithTint:[UIColor colorWithRed:0.216 green:0.471 blue:0.933 alpha:1.000] andTitle:@"Share" andTarget:self andSelector:@selector(share:)];
}

-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
   [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [scoreLabel release];
    scoreLabel = nil;
    [wordsLabel release];
    wordsLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [scoreLabel release];
    [wordsLabel release];
   self.wordsUsed = nil;
    [super dealloc];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if( section == 0 )
      return [self.wordsUsed count];
   
   if( section == 1 )
      return [self.validWords count];
   
   return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"Cell";
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   }
   
   if( indexPath.section == 0 )
   {
      cell.textLabel.text = [self.wordsUsed objectAtIndex:indexPath.row];
   }
   else if( indexPath.section == 1 )
   {
      cell.textLabel.text = [self.validWords objectAtIndex:indexPath.row];
   }
   return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   if( section == 0 )
   {
      return @"Words you played";
   }
   
   if( section == 1 )
   {
      return [NSString stringWithFormat:@"Words in puzzle (%i)",[self.validWords count]];
   }
   return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   if( !NSClassFromString(@"UIReferenceLibraryViewController") )
   {
      return;
   }
   
   NSString *term;
   if( indexPath.section == 0 )
   {
      term = [self.wordsUsed objectAtIndex:indexPath.row];
   }
   else if( indexPath.section == 1 )
   {
      term = [self.validWords objectAtIndex:indexPath.row];
   }
   
   UIReferenceLibraryViewController *dictionaryView = [[[UIReferenceLibraryViewController alloc] initWithTerm:term] autorelease];
   [self presentModalViewController:dictionaryView animated:YES];
}

-(void)bannerViewWillLoadAd:(ADBannerView *)banner
{
   banner.hidden = NO;
   [UIView animateWithDuration:0.5 animations:^{
      banner.layer.opacity = 1.0;
   }];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
   NSLog(@"%@",error);
   [UIView animateWithDuration:0.5 animations:^{
      banner.layer.opacity = 0.0;
   }];
}
- (IBAction)descrumbledInAppStore:(id)sender 
{
   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/descrumbled/id478640010?ls=1&mt=8"]];
}

- (IBAction)viewHighScores:(id)sender 
{
   GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
   if (leaderboardRequest != nil)
   {
      leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
      leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
      leaderboardRequest.range = NSMakeRange(1,10);
      [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
         if (error != nil)
         {
            // handle the error.
         }
         if (scores != nil)
         {
            NSLog(@"%@",scores);
         }
      }];
   }
   
   
   GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
   if (leaderboardController != nil)
   {
      leaderboardController.leaderboardDelegate = self;
      [self presentModalViewController: leaderboardController animated: YES];
   }
}
@end
