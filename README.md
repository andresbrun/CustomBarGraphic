CustomBarGraphic
================

Component made thinking in show a graphic base in bars. Compares pairs of values.

In order to use you only have to copy the GraphComponent folder to your project, create a new CustomStatisticGraphView in yor view controller and use the fallowing dataSource methods:

Define the number of section or value's pairs

	(int)numberOfSectionsDataForGraphic:(id)graph

Define the max vertical value for graphic

	(int)maxValueForGraphic:(id)graph

Define the colour for left bar data

	(UIColor *)colorForNewDataForGraphic:(id)graph

Define the colour for right bar data

	(UIColor *)colorForOldDataForGraphic:(id)graph

Define the label for every column pair

	(NSString *)graph:(id)graph labelForColumn:(int)column

Define the value for every section. index will have so many sections as value's pair and 2 row for every one of them.

	(int)graph:(id)graph valueForColumn:(NSIndexPath *)index
	
##Example

![alt tag](http://imageshack.us/a/img703/3590/36og.png)

