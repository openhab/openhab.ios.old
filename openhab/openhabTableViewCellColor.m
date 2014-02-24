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

#import "openhabTableViewCellColor.h"

@interface openhabTableViewCellColor()
	@property (nonatomic) NSInteger selected;
@end
@implementation openhabTableViewCellColor
@synthesize theControl,longPressStarted,selected,theTimer;

// v1.2 Long-press

-(void)sendIncreaseDecrease
{
	if (selected)
	{
		NSLog(@"Value changed to INCREASE");
		[[openhab sharedOpenHAB] changeValueofItem:self.widget.item toValue:@"INCREASE"];
	}
	else
	{
		NSLog(@"Value changed to DECREASE");
		[[openhab sharedOpenHAB] changeValueofItem:self.widget.item toValue:@"DECREASE"];
	}
}

-(void) handleLongPress : (id)sender
{
	//Long Press Clicked
	if (!longPressStarted) {
		NSLog(@"Long-Press detected");
		longPressStarted=YES;
		theTimer=[NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(sendIncreaseDecrease) userInfo:nil repeats:YES];
	}
	else
	{
		[theTimer invalidate];
		NSLog(@"Stop");
	}
}

-(void)loadWidget:(openhabWidget *)theWidget
{

    [super loadWidget:theWidget];
	[theControl removeAllSegments];
	[theControl setApportionsSegmentWidthsByContent:YES];
	selected=[theControl selectedSegmentIndex];
	openhabMapping*map;
	theTimer=nil;
	
	NSArray*theSortedKeys=[[widget.mappings allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]; // DOWN before UP
	if ([theWidget.item.type isEqualToString:@"ColorItem"]) {
		//v1.2 changed
		
		int i=0;
		for (NSString*themap in theSortedKeys) {
			map=[theWidget.mappings objectForKey:themap];
			[theControl setContentMode:UIViewContentModeScaleToFill];
			[theControl insertSegmentWithImage:[UIImage imageNamed:map.label] atIndex:i animated:NO];
			i++;
		}
		
		// v1.2 long-press and tap
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
												   initWithTarget:self action:@selector(handleLongPress:)];
		longPress.minimumPressDuration = 0.3; //seconds
		longPress.delegate = self;
		[theControl addGestureRecognizer:longPress];
		
	}
	else
	{
		NSLog(@"ERROR: This should not occur");
	}
}

-(BOOL)mayBeModified
{
	return YES;
}

-(IBAction)changeValue:(id)sender
{
	selected=[theControl selectedSegmentIndex]; // this goes away in few secs
	// v1.2 Initially no long press
	longPressStarted=NO;
	NSLog(@"Value changed");
	NSLog(@"Tap called");
	double delayInSeconds = 0.5;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		if (!longPressStarted)
		{
			NSArray*theSortedKeys=[[widget.mappings allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]; // DOWN before UP
			
			
			// v1.2 modified
			NSString*selection=[theSortedKeys objectAtIndex:selected];
			openhabMapping*theCommand=[widget.mappings objectForKey:selection];
			
			if (selected)
			{
				theCommand.command=@"ON";
			}
			else
			{
				theCommand.command=@"OFF";
			}
			NSLog(@"Value changed to %@",theCommand.command);
			[[openhab sharedOpenHAB] changeValueofItem:self.widget.item toValue:theCommand.command];
			
		}
	});
}

@end
