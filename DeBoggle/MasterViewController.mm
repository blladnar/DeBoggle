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

@interface MasterViewController()
-(void)generateBoardForSize:(NSInteger)size;
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       loadingDictionary = NO;
      self.title = NSLocalizedString(@"Enter your puzzle!", @"Debuggled");
       self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithTint:[UIColor colorWithRed:0.000 green:0.775 blue:0.187 alpha:1.000] andTitle:@"Solve" andTarget:self andSelector:@selector(solve:)];
    }
    return self;
}
							
- (void)dealloc
{
   [_detailViewController release];
   [row1 release];
   [row2 release];
   [row3 release];
   [row4 release];
   [spinner release];
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
   
   [self generateBoardForSize:4];
   
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)generateBoardForSize:(NSInteger)size
{
   int index = 0;
   textFields = [[NSMutableArray alloc] init];
   float squareSize = 200/size;
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
   [[textFields objectAtIndex:0] becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
   BOOL isDelete = [string length] == 0 && range.length > 0;
   
   if( isDelete && ![[textField text] length])
   {
      [[(NextableTextField*)textField previousTextField] performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
   }
   
   if( !isDelete )
   {
      [[(NextableTextField*)textField nextTextField] performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
   }
   return string.length + textField.text.length == 1 || isDelete;
}

- (void)viewDidUnload
{
   [row1 release];
   row1 = nil;
   [row2 release];
   row2 = nil;
   [row3 release];
   row3 = nil;
   [row4 release];
   row4 = nil;
   [spinner release];
   spinner = nil;
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

- (IBAction)solve:(id)sender 
{
   NSLog(@"Solve");
   [spinner startAnimating];
   if( !loadingDictionary && dictionary.size() > 0 )
   {
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
            DetailViewController *dictionaryView = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
            
            NSArray *words = [self vectorToArray:validStrings];
            
            dictionaryView.words = [words sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
               
               if( [obj1 length] > [obj2 length] )
               {
                  return NSOrderedAscending;
               }
               
               return NSOrderedDescending;
            }];
            
            [spinner stopAnimating];
            [self.navigationController pushViewController:dictionaryView animated:YES];
         });
         
      });
   }
}

- (IBAction)clearBoard:(id)sender {
   for( NextableTextField *textField in textFields)
    {
      textField.text = @"";
    }
   [[textFields objectAtIndex:0] becomeFirstResponder];
}

- (IBAction)changeTo5x5:(id)sender 
{
   for( NextableTextField *textField in textFields )
   {
      [textField removeFromSuperview];
   }
   [textFields removeAllObjects];
   [self generateBoardForSize:5];
}

- (IBAction)chageTo4x4:(id)sender 
{
   for( NextableTextField *textField in textFields )
   {
      [textField removeFromSuperview];
   }
   [textFields removeAllObjects];
   [self generateBoardForSize:4];
}
@end
