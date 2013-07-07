//
//  CustomStatisticGraphView.m
//  CustomBarGraphics
//
//  Created by Andrés Brun on 7/7/13.
//  Copyright (c) 2013 Andrés Brun. All rights reserved.
//

#import "CustomStatisticGraphView.h"
#import <QuartzCore/QuartzCore.h>

#define TOP_PADDING 0
#define BOTTOM_PADDING 20
#define LEFT_PADDING 20
#define RIGHT_PADDING 20
#define GRID_LINE_WIDTH 0.4
#define MAX_MIN_LINE_WIDTH 0.7

#define COLOR_LINES_GRID [UIColor grayColor]
#define COLOR_LINES_MINMAX [UIColor redColor]

#define LABELS_FONTS [UIFont fontWithName:@"Arial" size:10.0]

#define OBJETIVE_IMAGE @"circle"

#define TIME_STEP 0.005  //Animation framerate
#define PROGRESS_STEP 0.005  //Animation "speed"
#define OBJETIVES_OFFSET 0.05   
#define OBJETIVES_ANIMATION_DURATION 0.2

@interface CustomStatisticGraphView (){
    CGContextRef contextGrid;
    CGContextRef contextGraphs;
    CGContextRef contextLines;
    CGRect graphRect;   //Graph insect rect
    int columns;        //Number of columns
    int rows;           //Number or rows
    float xSpacing;     //cell's grids height
    float ySpacing;     //cell's grids width
    float unitYRatio;   //Relation between frame height and bars values
    
    float progress;
}

/* Draw the background grid */
- (void) drawGrid;
/* Draw the values bars */
- (void) drawBars;
/* Draw the legends labels */
- (void) drawLabels;
/* Draw the mas and min lines */
- (void) drawMinMaxLines;
/* Draw the circles that mark the objetives */
- (void) drawObjectives;
/* Create a label for legend */
- (UILabel *) createLabelWithString: (NSString *) string andRect: (CGRect) rect;
/* Method that transform a value into the graph coordinate system */
- (float) convertIntoGraphCoordenatesValue: (float) value;
@end

@implementation CustomStatisticGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        progress = 0.0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //Get draw data
    graphRect = CGRectMake(LEFT_PADDING,
                           TOP_PADDING,
                           rect.size.width-LEFT_PADDING-RIGHT_PADDING,
                           rect.size.height-TOP_PADDING-BOTTOM_PADDING);
    
    //Get the number of rows and columms
    columns=[self.dataSource numberOfSectionsDataForGraphic:self] * 2;
    rows=graphRect.size.height / (graphRect.size.width/columns);
    
    //Calculate the width and height of every cell's grid
    xSpacing=graphRect.size.width/columns;
    ySpacing=graphRect.size.height/rows;
    
    //Calculate the ratio between values and pixels
    unitYRatio = graphRect.size.height/ [self.dataSource maxValueForGraphic:self];
    
    //Draw the elements
    
    //Draw the bars and line with progress and grid for keep always in front of bars
    [self drawBars];
    [self drawGrid];
    [self drawMinMaxLines];
    
    //If the progress isn't one repaint again and finally draw the objetives
    if (progress<1) {
        [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:TIME_STEP];
        progress+=PROGRESS_STEP;
    }else{
        [self drawObjectives];
        [self drawLabels];
    }
    
}

#pragma mark - Public methods
- (void) redrawGraph
{
    progress=0;
    for (UIView *currentView in self.subviews) {
        [UIView animateWithDuration:0.2 animations:^{
            [currentView setAlpha:0.0];
        }completion:^(BOOL finished) {
            [currentView removeFromSuperview];
        }];
    }
    
    [self setNeedsDisplay];
}

#pragma mark - Private methods
- (void)drawGrid
{
    contextGrid = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(contextGrid, COLOR_LINES_GRID.CGColor);
    CGContextSetLineWidth(contextGrid, GRID_LINE_WIDTH);
    
    //Columns
    for (int i=0; i<=columns; i++) {
        float columnPosition = graphRect.origin.x+i*xSpacing;
        CGContextMoveToPoint(contextGrid, columnPosition, graphRect.origin.y); //start at this point
        CGContextAddLineToPoint(contextGrid, columnPosition, graphRect.origin.y+graphRect.size.height*progress); //draw to this point with progress
    }
    
    //Rows
    for (int j=0; j<=rows; j++) {
        float rowPosition = graphRect.origin.y+j*ySpacing;
        CGContextMoveToPoint(contextGrid, graphRect.origin.x, rowPosition); //start at this point
        CGContextAddLineToPoint(contextGrid, graphRect.origin.x+graphRect.size.width*progress, rowPosition); //draw to this point with progress
    }
    
    // and now draw the Path!
    CGContextStrokePath(contextGrid);
}

- (void)drawBars
{
    contextGraphs = UIGraphicsGetCurrentContext();
    
    //Draw the data
    UIColor *newBarColor = [self.dataSource colorForNewDataForGraphic:self];
    UIColor *oldBarColor = [self.dataSource colorForOldDataForGraphic:self];
    for (int col=0; col<columns; col++) {
        //Draw every bar
        double value =[self.dataSource graph:self valueForColumn:[NSIndexPath indexPathForRow:col%2 inSection:col/2]] * progress;
        UIColor *currentColor = col%2==0?oldBarColor:newBarColor;
        CGRect barRect = CGRectMake(graphRect.origin.x + col*xSpacing,
                                    graphRect.origin.y + graphRect.size.height,
                                    xSpacing,
                                    - value*unitYRatio);
        
        CGContextSetFillColorWithColor(contextGraphs, currentColor.CGColor);
        CGContextFillRect(contextGraphs, barRect);
    }
    
    // and now draw the Path!
    CGContextStrokePath(contextGraphs);
}

- (void)drawMinMaxLines
{
    //Draw min and max
    contextLines = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(contextLines, COLOR_LINES_MINMAX.CGColor);
    CGContextSetLineWidth(contextLines, MAX_MIN_LINE_WIDTH);
    
    //Min lines
    if ([self.dataSource respondsToSelector:@selector(valueForMinHorizontalLineInGraphic:)]) {
        float minLinePosition = [self convertIntoGraphCoordenatesValue: [self.dataSource valueForMinHorizontalLineInGraphic:self]] /progress;
        NSLog(@"%f - %d * %f * %f = %f", graphRect.origin.y + graphRect.size.height, [self.dataSource valueForMinHorizontalLineInGraphic:self], unitYRatio, progress, minLinePosition);
        CGContextMoveToPoint(contextLines, graphRect.origin.x, minLinePosition); //start at this point
        CGContextAddLineToPoint(contextLines, graphRect.origin.x+graphRect.size.width, minLinePosition); //draw to this point
    }
    
    //Max line
    if ([self.dataSource respondsToSelector:@selector(valueForMaxHorizontalLineInGraphic:)]) {
        float maxLinePosition = [self convertIntoGraphCoordenatesValue: [self.dataSource valueForMaxHorizontalLineInGraphic:self]] /progress;
        CGContextMoveToPoint(contextLines, graphRect.origin.x, maxLinePosition); //start at this point
        CGContextAddLineToPoint(contextLines, graphRect.origin.x+graphRect.size.width, maxLinePosition); //draw to this point
    }
    
    CGContextStrokePath(contextLines);
}

- (void)drawObjectives
{
    if ([self.dataSource respondsToSelector:@selector(graph:objectiveForColumn:)]) {
        for (int col=0; col<columns; col++) {
            //Draw every objetive with in animation
            int value =[self.dataSource graph:self objectiveForColumn:[NSIndexPath indexPathForRow:col%2 inSection:col/2]];
            float graphValue = [self convertIntoGraphCoordenatesValue:value];
            UIImageView *currentObj = [[UIImageView alloc] initWithImage:[UIImage imageNamed:OBJETIVE_IMAGE]];
            [currentObj setFrame:CGRectMake(graphRect.origin.x+col*xSpacing,
                                            graphValue - ySpacing/2.0,
                                            xSpacing,
                                            ySpacing)];
            [currentObj setContentMode:UIViewContentModeScaleAspectFill];
            [currentObj setAlpha:0.0];
            [self addSubview:currentObj];
            [UIView animateWithDuration:OBJETIVES_ANIMATION_DURATION delay:col*OBJETIVES_OFFSET options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [currentObj setAlpha:1.0];
            } completion:^(BOOL finished) {
                //Nothing
            }];
        }
    }
}

- (void)drawLabels
{
    //Columns
    float labelSpacingUnit = xSpacing * 2;
    for (int col=0; col<columns; col+=2) {
        UILabel *currentLabel = [self createLabelWithString:[self.dataSource graph:self labelForColumn:col/2]
                                                    andRect:CGRectMake(LEFT_PADDING+(col/2)*labelSpacingUnit,
                                                                       graphRect.origin.y+graphRect.size.height,
                                                                       labelSpacingUnit,
                                                                       BOTTOM_PADDING)];
        [currentLabel setAlpha:0.0];
        [self addSubview:currentLabel];
        [UIView animateWithDuration:OBJETIVES_ANIMATION_DURATION delay:col*OBJETIVES_OFFSET options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [currentLabel setAlpha:1.0];
        } completion:^(BOOL finished) {
            //Nothing
        }];
    }
    //Rows
    int numberGap = ceil([self.dataSource maxValueForGraphic:self]/(rows*1.0));
    for (int row=1; row<=rows; row++) {
        UILabel *currentLabel = [self createLabelWithString:[NSString stringWithFormat:row==rows?@"%d+":@"%d", row*numberGap]
                                                    andRect:CGRectMake(graphRect.origin.x,
                                                                       graphRect.origin.y+(rows-row)*ySpacing,
                                                                       xSpacing,
                                                                       ySpacing)];
        [currentLabel setAlpha:0.0];
        [self addSubview:currentLabel];
        [UIView animateWithDuration:OBJETIVES_ANIMATION_DURATION delay:row*OBJETIVES_OFFSET options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [currentLabel setAlpha:1.0];
        } completion:^(BOOL finished) {
            //Nothing
        }];
    }
}

#pragma mark - Auxiliar methods
/**
 Method that create a label for graph legend
 */
- (UILabel *) createLabelWithString: (NSString *) string andRect: (CGRect) rect
{
    UILabel *currentLabel = [[UILabel alloc] initWithFrame:rect];
    [currentLabel setFont:LABELS_FONTS];
    [currentLabel setBackgroundColor:[UIColor clearColor]];
    [currentLabel setTextAlignment:NSTextAlignmentCenter];
    [currentLabel setTextColor:COLOR_LINES_GRID];
    [currentLabel setText:string];
    [currentLabel setAdjustsFontSizeToFitWidth:YES];
    
    return currentLabel;
}

- (float) convertIntoGraphCoordenatesValue: (float) value
{
    float revertValue = [self.dataSource maxValueForGraphic:self] - value;
    return revertValue * unitYRatio + graphRect.origin.y;
}
@end
