//
//  NextableTextField.h
//  DeBoggle
//
//  Created by Randall Brown on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NextableTextField : UITextField

@property (nonatomic, retain) NextableTextField *nextTextField;
@property (nonatomic, retain) NextableTextField *previousTextField;
@end
