//
//  CustomStatisticGraphView.h
//  uSpeak
//
//  Created by Andrés Brun on 7/1/13.
//  Copyright (c) 2013 uSpeak Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomStatisticGraphViewDataSource <NSObject>

- (int) numberOfSectionsDataForGraphic: (id)graph;
- (int) maxValueForGraphic: (id)graph;
- (int) graph: (id)graph valueForColumn: (NSIndexPath *)index;

//Design
- (UIColor *) colorForOldDataForGraphic: (id)graph;
- (UIColor *) colorForNewDataForGraphic: (id)graph;

//Aux
- (NSString *) graph: (id)graph labelForColumn: (int)column;

@optional
- (int) valueForMinHorizontalLineInGraphic: (id)graph;
- (int) valueForMaxHorizontalLineInGraphic: (id)graph;
- (int) graph: (id)graph objectiveForColumn: (NSIndexPath *)index;

@end

@interface CustomStatisticGraphView : UIView

@property (nonatomic, assign) IBOutlet id<CustomStatisticGraphViewDataSource> dataSource;

- (void) redrawGraph;

@end
