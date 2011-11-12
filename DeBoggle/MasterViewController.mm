//
//  MasterViewController.m
//  DeBoggle
//
//  Created by Randall Brown on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "boggleSolver.h"
#import "NextableTextField.h"
#import "UIBarButtonItem+Tint.h"
#import "ResultsViewController.h"

@interface MasterViewController()
-(void)hideButtonsShowLabels;
-(void)showButtonsHideLabels;
@end

@implementation MasterViewController
@synthesize leaderboardsButton;

@synthesize detailViewController = _detailViewController;


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
       loadingDictionary = NO;
       self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scrumbledBanner"]] autorelease];
    }
    return self;
}

-(void)start:(id)sender
{
   if( !waitForStart )
   {
      [self generateBoardForSize:4 withBoard:nil];
   }
   else
   {
      for( NextableTextField *letterField in textFields )
      {
         letterField.hidden = NO;
      }
      [self solve:nil];
   }
}
							
- (void)dealloc
{
   [_detailViewController release];
   [spinner release];
   [wordCount release];
   [wordField release];
   [scoreLabel release];
   [timerLabel release];
   [fourByFourButton release];
   [fiveByFiveButton release];
   [achievementsButton release];
   [achievementsButton release];
   [leaderboardsButton release];
   [fourByFourLabel release];
   [fiveByFiveLabel release];
   [selectABoardLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
   
   if( !loadingDictionary )
   {
      wordField.borderStyle = UITextBorderStyleLine;
      loadingDictionary = YES;
      dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
      
      dispatch_async(aQueue, ^{
         if( dictionary.size() <=0 )
         {
            NSString *stringPath = [[NSBundle mainBundle] pathForResource:@"dict" ofType:@"txt"];
            
            NSString* fileContents = [NSString stringWithContentsOfFile:stringPath 
                                                               encoding:NSUTF8StringEncoding error:nil];
            
            NSArray *words = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            
            for( NSString *word in words )
            {
               dictionary.push_back([word UTF8String]);
            }
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
            loadingDictionary = NO;
         });
         
      });
   }
   
   usedWords = [[NSMutableArray alloc] init];
   boardString = [[NSMutableString alloc] init];
   wordsInPuzzle = 0;
   waitForStart = NO;
   textFields = [[NSMutableArray alloc] init];
   
   int fourByFoursPlayed = [[NSUserDefaults standardUserDefaults] integerForKey:@"4x4GamesPlayed"];
   
   NSString *gamesPlural = ( fourByFoursPlayed == 1 )? @"game" : @"games";
   
   fourByFourLabel.text = [NSString stringWithFormat:@"%i %@", fourByFoursPlayed, gamesPlural];
   
   int fiveByFivesPlayed = [[NSUserDefaults standardUserDefaults] integerForKey:@"5x5GamesPlayed"];
   gamesPlural = ( fiveByFivesPlayed == 1 )? @"game" : @"games";
   fiveByFiveLabel.text = [NSString stringWithFormat:@"%i %@", fiveByFivesPlayed,gamesPlural];
   
   GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
   
   if( !localPlayer.isAuthenticated )
   {
      [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
         
      }];
   }
   
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
   [self dismissModalViewControllerAnimated:YES];
}

-(void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
   [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showAchievements:(id)sender 
{
   GKAchievementViewController *achievementController = [[GKAchievementViewController alloc] init];
   if( achievementController )
   {
      achievementController.achievementDelegate = self;
      [self presentModalViewController:achievementController animated:YES];
   }
}

- (IBAction)showLeaderboards:(id)sender 
{
   GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
   if (leaderboardController != nil)
   {
      leaderboardController.leaderboardDelegate = self;
      [self presentModalViewController: leaderboardController animated: YES];
   }
}

-(void)generateBoardForSize:(NSInteger)size withBoard:(NSString*)newBoard
{
   int index = 0;
   for( NextableTextField *textField in textFields )
   {
      [textField removeFromSuperview];
   }
   [textFields removeAllObjects];
   
   NSString *letters = @"abcdefghijklmnopqrstuvwxyz";
   
   float squareSize = 170/size;
   for( int i= 0; i < size; i++ )
   {
      for( int j=0; j < size; j++ )
      {
         NextableTextField *letterField = [[[NextableTextField alloc] initWithFrame:CGRectMake(j*squareSize, i*squareSize, squareSize, squareSize)] autorelease];
         letterField.autocorrectionType = UITextAutocorrectionTypeNo;
         letterField.autocapitalizationType = UITextAutocapitalizationTypeNone;
         letterField.borderStyle = UITextBorderStyleLine;
         letterField.delegate = self;
         letterField.font = [UIFont systemFontOfSize:squareSize/1.4];
         letterField.backgroundColor = [UIColor whiteColor];
         letterField.textAlignment = UITextAlignmentCenter;
         letterField.keyboardAppearance = UIKeyboardAppearanceAlert;
         letterField.enabled = NO;

         if( [newBoard length] == 0 )
         {
            int randomNumber = arc4random() % 26;
            letterField.text = [letters substringWithRange:NSMakeRange(randomNumber, 1)];
            [boardString appendString:[letters substringWithRange:NSMakeRange(randomNumber, 1)]];
         }
         else
         {
            letterField.text = [newBoard substringWithRange:NSMakeRange(i*j+j, 1)];
            letterField.hidden = YES;
            [boardString appendString:[newBoard substringWithRange:NSMakeRange(i*j+j, 1)]];
         }
         
         [textFields addObject:letterField];
         
         if( index > 0 )
         {
            [(NextableTextField*)[textFields objectAtIndex:index-1]setNextTextField: letterField];
            letterField.previousTextField = [textFields objectAtIndex:index-1];
         }
         
         index++;
         [self.view addSubview:letterField];
         
      }
   }
   
   waitForStart = [newBoard length] !=0;
   if( !waitForStart )
   {
      [self solve:nil];
   }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
   NSLog(@"%@",textField.text);
   for( NSString *word in usedWords )
   {
      if( [textField.text isEqualToString:word] )
      {
         textField.text = @"";
         return YES;
      }
   }
   
   for( NSString *word in validWords )
   {
      if( [word isEqualToString:textField.text] )
      {
         [usedWords addObject:word];
         wordsInPuzzle++;
         score += [self scoreForWord:word];
         scoreLabel.text = [NSString stringWithFormat:@"Score: %i", score];
         wordCount.text = [NSString stringWithFormat:@"Words: %i",wordsInPuzzle];
         break;
      }
   }
   
   
   textField.text = @"";
   return YES;
}

- (void)viewDidUnload
{
   [spinner release];
   spinner = nil;
   [wordCount release];
   wordCount = nil;
   [wordField release];
   wordField = nil;
   [scoreLabel release];
   scoreLabel = nil;
   [timerLabel release];
   timerLabel = nil;
   [fourByFourButton release];
   fourByFourButton = nil;
   [fiveByFiveButton release];
   fiveByFiveButton = nil;
   [achievementsButton release];
   achievementsButton = nil;
   [achievementsButton release];
   achievementsButton = nil;
   [self setLeaderboardsButton:nil];
   [fourByFourLabel release];
   fourByFourLabel = nil;
   [fiveByFiveLabel release];
   fiveByFiveLabel = nil;
   [selectABoardLabel release];
   selectABoardLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
   [wordField resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSArray*)vectorToArray:(vector<string>)theVector
{
   NSMutableArray *array = [[[NSMutableArray alloc] initWithCapacity:theVector.size()] autorelease];
   for( int i=0; i < theVector.size(); i++ )
   {
      [array addObject:[NSString stringWithUTF8String:theVector[i].c_str()]];
   }
   
   return array;
}

-(void)resetGame
{
   [usedWords removeAllObjects];
   wordsInPuzzle = 0;
   score = 0;
   waitForStart = NO;
}

-(void)finishGame
{
   if( gameTime == 120.0 )
   {
      int fourByFoursPlayed = [[NSUserDefaults standardUserDefaults] integerForKey:@"4x4GamesPlayed"];
      fourByFoursPlayed++;
      [[NSUserDefaults standardUserDefaults] setInteger:fourByFoursPlayed forKey:@"4x4GamesPlayed"];
      fourByFourLabel.text = [NSString stringWithFormat:@"%i games", fourByFoursPlayed];
   }
   else if( gameTime == 180.0 )
   {
      int fiveByFivesPlayed = [[NSUserDefaults standardUserDefaults] integerForKey:@"5x5GamesPlayed"];
      fiveByFivesPlayed++;
      [[NSUserDefaults standardUserDefaults] setInteger:fiveByFivesPlayed forKey:@"5x5GamesPlayed"];
      fiveByFiveLabel.text = [NSString stringWithFormat:@"%i games",fiveByFivesPlayed];
   }
   
   ResultsViewController *controller = [[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil];
   controller.wordsUsed = usedWords;
   controller.boardString = boardString;
   [self.navigationController pushViewController:controller animated:YES];
   
   [self performSelectorOnMainThread:@selector(showButtonsHideLabels) withObject:nil waitUntilDone:YES];
   [updater invalidate];
   updater = nil;
}

-(void)updateTimer
{
   NSTimeInterval timeLeft = gameTime + [startTime timeIntervalSinceNow];

   timerLabel.text = [NSString stringWithFormat:@"%.0f",timeLeft];
   
   if( timeLeft <= 0 )
   {
      [self finishGame];
   }
}

- (IBAction)solve:(id)sender 
{
   NSLog(@"Solve");
   waitForStart = NO;

   if( !loadingDictionary && dictionary.size() > 0 )
   {
      [spinner startAnimating];
      char board[100][100];
      float size = sqrtf([textFields count]);
      
      for(int i=0; i < [textFields count]; i++ )
      {
         int x= i / size;
         int y = i - x*size;
         if( ![[[textFields objectAtIndex:i]text] length] )
         {
            [[[[UIAlertView alloc] initWithTitle:@"Hold up!" message:@"Your board doesn't look finished. Fill it out before solving" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease] show];
            [spinner stopAnimating];
            return;
         }
         
         board[y][x] = [[[textFields objectAtIndex:i] text] UTF8String][0];
      }
      __block BoggleSolver solver(size, board, dictionary, size-1);
      
      dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
      
      dispatch_async(aQueue, ^{
         
         vector<string> validStrings = solver.solve();
         NSLog(@"%i",(int)validStrings.size());
         for( int i = 0; i < validStrings.size(); i++ )
         {
            printf("%s\n",validStrings[i].c_str());
         }
         
         
         dispatch_async(dispatch_get_main_queue(), ^{
            
            validWords = [[self vectorToArray:validStrings] retain];
            wordsInPuzzle = 0;
            score = 0;
            startTime = [[NSDate date] retain];
            updater = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
            [spinner stopAnimating];
         });
         
      });
   }
}

-(void)done:(id)sender
{
   [self finishGame];
}

-(void)hideButtonsShowLabels
{
   fiveByFiveButton.hidden = YES;
   fourByFourButton.hidden = YES;
   achievementsButton.hidden = YES;
   leaderboardsButton.hidden = YES;
   fiveByFiveLabel.hidden = YES;
   fourByFourLabel.hidden = YES;
   selectABoardLabel.hidden = YES;
   
   wordField.text = @"";
   wordField.hidden = NO;
   wordCount.hidden = NO;
   scoreLabel.hidden = NO;
   timerLabel.hidden = NO;
   [wordField becomeFirstResponder];
   [wordCount setText:[NSString stringWithFormat:@"Words: %i",wordsInPuzzle]];
   [scoreLabel setText:[NSString stringWithFormat:@"Score: %i",score]];
   
   self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithTint:[UIColor colorWithRed:0.216 green:0.471 blue:0.933 alpha:1.000] andTitle:@"Done" andTarget:self andSelector:@selector(done:)];
}

-(void)showButtonsHideLabels
{
   self.navigationItem.rightBarButtonItem = nil;
   for( NextableTextField *textField in textFields)
   {
      [textField removeFromSuperview];
   }
   [textFields removeAllObjects];
   [wordField resignFirstResponder];
   achievementsButton.hidden = NO;
   leaderboardsButton.hidden = NO;
   fiveByFiveButton.hidden = NO;
   fourByFourButton.hidden = NO;
   fiveByFiveLabel.hidden = NO;
   fourByFourLabel.hidden = NO;
   selectABoardLabel.hidden = NO;
   
   
   wordField.hidden = YES;
   wordCount.hidden = YES;
   scoreLabel.hidden = YES;
   timerLabel.hidden = YES;
}

- (IBAction)changeTo5x5:(id)sender 
{
   gameTime = 180.0;
   [self resetGame];
   [self hideButtonsShowLabels];
   [self generateBoardForSize:5 withBoard:nil];
}

- (IBAction)chageTo4x4:(id)sender 
{
   gameTime = 120.0;
   [self resetGame];
   [self hideButtonsShowLabels];
   [self generateBoardForSize:4 withBoard:nil];
}
@end
