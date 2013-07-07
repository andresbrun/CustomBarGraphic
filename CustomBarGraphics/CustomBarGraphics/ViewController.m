//
//  ViewController.m
//  CustomBarGraphics
//
//  Created by Andrés Brun on 7/7/13.
//  Copyright (c) 2013 Andrés Brun. All rights reserved.
//

#import "ViewController.h"

#define COLOR_BAR_OLD [UIColor colorWithWhite:0.5 alpha:0.6]
#define COLOR_BAR_NEW [UIColor colorWithWhite:1.0 alpha:0.9]

@interface ViewController ()

@property (nonatomic, assign) int maxValue;
@property (nonatomic, assign) int numberOfColumns;
@property (nonatomic, assign) int maxLineValue;
@property (nonatomic, assign) int minLineValue;
@property (nonatomic, strong) NSMutableArray *oldValuesArray;
@property (nonatomic, strong) NSMutableArray *currentValuesArray;

@end

@implementation ViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.numberOfColumns=7;
        [self generateRandomValues];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
- (void) generateRandomValues
{
    self.maxValue = arc4random()%30+20;
    self.maxLineValue = arc4random()%self.maxValue;
    self.minLineValue = arc4random()%self.maxValue;
    
    self.oldValuesArray = [[NSMutableArray alloc] initWithCapacity:1];
    self.currentValuesArray = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i=0; i<self.numberOfColumns; i++) {
        [self.oldValuesArray addObject:[NSNumber numberWithInt:arc4random()%self.maxValue]];
        [self.currentValuesArray addObject:[NSNumber numberWithInt:arc4random()%self.maxValue]];
    }
}

#pragma mark - CustomStatisticGraphView DataSource
-(int)numberOfSectionsDataForGraphic:(id)graph
{
    return self.numberOfColumns;
}

-(int)maxValueForGraphic:(id)graph
{
    return self.maxValue;
}

- (UIColor *)colorForNewDataForGraphic:(id)graph
{
    return COLOR_BAR_NEW;
}

-(UIColor *)colorForOldDataForGraphic:(id)graph
{
    return COLOR_BAR_OLD;
}

- (NSString *)graph:(id)graph labelForColumn:(int)column
{
    return [NSString stringWithFormat:@"%.2d",column+1];
}

- (int)graph:(id)graph valueForColumn:(NSIndexPath *)index
{
    switch (index.row) {
        case 0:
            return [[self.oldValuesArray objectAtIndex:index.section] intValue];
            break;
        case 1:
            return [[self.currentValuesArray objectAtIndex:index.section] intValue];
            break;
            
        default:
            return 0;
            break;
    }
}

- (int)valueForMaxHorizontalLineInGraphic:(id)graph
{
    return self.maxLineValue;
}

-(int)valueForMinHorizontalLineInGraphic:(id)graph
{
    return self.minLineValue;
}

-(int)graph:(id)graph objectiveForColumn:(NSIndexPath *)index
{
    return arc4random()%self.maxValue*0.3 + self.maxValue*0.5;
}


- (IBAction)refreshGraphicButtonPressed:(id)sender
{
    [self.numberOfColumnsTxtFld resignFirstResponder];
    if (![self.numberOfColumnsTxtFld.text isEqualToString:@""]) {
        [self setNumberOfColumns:[self.numberOfColumnsTxtFld.text intValue]];
        [self generateRandomValues];
        [self.graphView redrawGraph];
    }else{
        //alert
    }
}
@end
