//
//  openhabTableViewCellList.m
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

#import "openhabTableViewCellList.h"

@implementation openhabTableViewCellList
@synthesize theControl,longPressStarted,detailLabel;

// v1.2 Long-press


-(void) handleLongPress : (id)sender
{
	//Long Press Clicked
	if (!longPressStarted) {
		NSLog(@"Long-Press detected, calling stop at touch up");
		longPressStarted=YES;
		[[openhab sharedOpenHAB] cancelPolling];
	}
	else
	{
		NSLog(@"Calling stop");
		[[openhab sharedOpenHAB] longPollCurrent];
		[[openhab sharedOpenHAB] changeValueofItem:self.widget.item toValue:@"STOP"];
	}
}

-(void)loadWidget:(openhabWidget *)theWidget
{
    [super loadWidget:theWidget];
	
	if (theWidget.data)
	{
		self.detailLabel.text=theWidget.data;
		[self.detailLabel setHidden:NO];
	}
	else
		[self.detailLabel setHidden:YES];
	
	[theControl removeAllSegments];
	[theControl setApportionsSegmentWidthsByContent:YES];
	openhabMapping*map;
	
	NSArray*theSortedKeys=[[widget.mappings allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]; // DOWN before UP
	if ([theWidget.item.type isEqualToString:@"RollershutterItem"]) {
		//v1.2 changed
		
		
		
		int i=0;
		for (NSString*themap in theSortedKeys) {
			map=[theWidget.mappings objectForKey:themap];
			[theControl setContentMode:UIViewContentModeScaleToFill];
			[theControl insertSegmentWithImage:[UIImage imageNamed:map.label] atIndex:i animated:NO];
			i++;
		}
		
		// v1.2 long-press
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
												   initWithTarget:self action:@selector(handleLongPress:)];
		longPress.minimumPressDuration = 0.3; //seconds
		longPress.delegate = self;
		[theControl addGestureRecognizer:longPress];
	
	}
	else
	{

		//v1.2 changed
		int i=0;
		for (NSString*themap in theSortedKeys) {
			map=[theWidget.mappings objectForKey:themap];
			[theControl insertSegmentWithTitle:map.label atIndex:i animated:NO];
			i++;
		}
		
		if ([theControl numberOfSegments]!=1 && ![theWidget.item.type
												  isEqualToString:@"RollershutterItem"])
		{
			
			// v1.2
			int i =0;
			for (NSString*themap in theSortedKeys) {
				map=[theWidget.mappings objectForKey:themap];
				if (widget.item && [widget.item.state isEqualToString:map.command])
					[theControl setSelectedSegmentIndex:i];
				i++;
			}
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
//				// v1.2 move the detailLabel
				CGRect detailFrame=detailLabel.frame;
				detailFrame.origin.x=detailFrame.origin.x+difference;
				detailLabel.frame=detailFrame;
			}
		}
		else //V1.2 iphone
		{
			// Resize if less than 3
			int segmentWidth=44;
			CGRect oldframe=theControl.frame;
			CGFloat x=oldframe.origin.x;
			
			// If we have note resized, resize
			if (theControl.numberOfSegments<3 && (oldframe.size.width/theControl.numberOfSegments)!=segmentWidth)
			{
				int difference=oldframe.size.width-theControl.numberOfSegments*segmentWidth;
				oldframe.size.width=theControl.numberOfSegments*segmentWidth;
				oldframe.origin.x=x+difference;
				theControl.frame=oldframe;
				//				// v1.2 move the detailLabel
				CGRect detailFrame=detailLabel.frame;
				detailFrame.origin.x=detailFrame.origin.x+difference;
				detailLabel.frame=detailFrame;
			}

		}
	}
}

-(BOOL)mayBeModified
{
	return YES;
}
-(IBAction)changeValue:(id)sender
{

	// v1.2 Initially no long press
	longPressStarted=NO;

	NSArray*theSortedKeys=[[widget.mappings allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]; // DOWN before UP
	
	if ([sender isKindOfClass:[UISegmentedControl class]])
	{
		// v1.2 modified
		NSString*selection=[theSortedKeys objectAtIndex:[theControl selectedSegmentIndex]];
		openhabMapping*theCommand=[widget.mappings objectForKey:selection];
		// Change the state of the item
		if ([theControl numberOfSegments]!=1 && ![widget.item.type
												  isEqualToString:@"RollershutterItem"])
			[widget.item setState:theCommand.command];
		NSLog(@"Value changed to %@",theCommand.label);
		[[openhab sharedOpenHAB] changeValueofItem:self.widget.item toValue:theCommand.command];
		//[[openhab sharedOpenHAB] refreshSitemap];
	}
}

@end
