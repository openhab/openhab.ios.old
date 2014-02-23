//
//  openhabTableViewCellSetpoint.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 18/12/11.
//	Eclipse Public License - v 1.0
//
//  THE ACCOMPANYING PROGRAM IS PROVIDED UNDER THE TERMS OF THIS
//	ECLIPSE PUBLIC LICENSE ("AGREEMENT"). ANY USE, REPRODUCTION OR
//	DISTRIBUTION OF THE PROGRAM CONSTITUTES RECIPIENT'S ACCEPTANCE
//	OF THIS AGREEMENT.
//
//	See license.txt for more info

//

#import "openhabTableViewCellSetpoint.h"

@implementation openhabTableViewCellSetpoint
@synthesize theControl,detailLabel;

-(void)loadWidget:(openhabWidget *)theWidget
{
    [super loadWidget:theWidget];
	self.detailLabel.text=theWidget.data;
	
	[theControl removeAllSegments];
	[theControl setApportionsSegmentWidthsByContent:YES];
	openhabMapping*map;
	
	
	// v1.2
	
	
	/*Get a sorted array*/
	
	NSArray*theSortedKeys=[[theWidget.mappings allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]; // DOWN before UP
	int i=0;
	for (NSString*themapping in theSortedKeys) {
		map=[theWidget.mappings objectForKey:themapping];
		[theControl setContentMode:UIViewContentModeScaleToFill];
		[theControl insertSegmentWithImage:[UIImage imageNamed:map.label] atIndex:i animated:NO];
		i++;
	}
	
	// IF IPAD
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		// Resize if less than 5
		int segmentWidth=60;
		CGRect oldframe=theControl.frame;
		CGFloat x=oldframe.origin.x;
		
		// If we have note resized, resize
		if (theControl.numberOfSegments<6 && (oldframe.size.width/theControl.numberOfSegments)!=segmentWidth)
		{
			int difference=oldframe.size.width-theControl.numberOfSegments*segmentWidth;
			oldframe.size.width=theControl.numberOfSegments*segmentWidth;
			oldframe.origin.x=x+difference;
			theControl.frame=oldframe;
		}
	}
}


-(BOOL)mayBeModified
{
	return YES;
}
-(IBAction)changeValue:(id)sender
{
	
	if ([sender isKindOfClass:[UISegmentedControl class]])
	{
		NSArray*theSortedKeys=[[widget.mappings allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]; // DOWN before UP

		NSString*selection=[theSortedKeys objectAtIndex:[theControl selectedSegmentIndex]];
		openhabMapping*theCommand=[widget.mappings objectForKey:selection];
		// Change the state of the item
		float newValue=[self.widget.item.state floatValue];
		if ([theCommand.label isEqualToString:@"UP"] && widget.maxValue>newValue)
		{
			newValue+=widget.step;
			widget.item.state=[NSString stringWithFormat:@"%f",newValue];
			NSLog(@"Value changed to %@",[NSString stringWithFormat:@"%f",newValue]);
			[[openhab sharedOpenHAB] changeValueofItem:self.widget.item toValue:[NSString stringWithFormat:@"%f",newValue]];
			//[[openhab sharedOpenHAB] refreshSitemap];

		}
		else if ([theCommand.label isEqualToString:@"DOWN"] && widget.minValue<newValue)
		{
			newValue-=widget.step;
			widget.item.state=[NSString stringWithFormat:@"%f",newValue];
			NSLog(@"Value changed to %@",[NSString stringWithFormat:@"%f",newValue]);
			[[openhab sharedOpenHAB] changeValueofItem:self.widget.item toValue:[NSString stringWithFormat:@"%f",newValue]];
			//[[openhab sharedOpenHAB] refreshSitemap];

		}
		else
		{
			NSLog(@"Boundaries reached: Max %f,Min %f,step %f, current: %@",widget.maxValue,widget.minValue,widget.step,widget.item.state);
		}
	}
}

@end
