//
//  ViewController.h
//  CustomBarGraphics
//
//  Created by Andrés Brun on 7/7/13.
//  Copyright (c) 2013 Andrés Brun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomStatisticGraphView.h"

@interface ViewController : UIViewController <CustomStatisticGraphViewDataSource>

@property (weak, nonatomic) IBOutlet CustomStatisticGraphView *graphView;

@property (weak, nonatomic) IBOutlet UITextField *numberOfColumnsTxtFld;

- (IBAction)refreshGraphicButtonPressed:(id)sender;

@end
