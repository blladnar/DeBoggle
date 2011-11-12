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

@implementation ResultsViewController

@synthesize wordsUsed;
@synthesize boardString;
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
         [textController setMessageBody:[NSString stringWithFormat:@"Can you beat my score of %i on this board %@", score,[self boardURL]] isHTML:NO]; 
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
   return [self.wordsUsed count];
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
   
   // Configure the cell.
   cell.textLabel.text = [self.wordsUsed objectAtIndex:indexPath.row];
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   if( !NSClassFromString(@"UIReferenceLibraryViewController") )
   {
      return;
   }
   
   UIReferenceLibraryViewController *dictionaryView = [[[UIReferenceLibraryViewController alloc] initWithTerm:[self.wordsUsed objectAtIndex:indexPath.row]] autorelease];
   [self presentModalViewController:dictionaryView animated:YES];
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
