//
//  openhabTableViewCellSlider.m
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

#import "openhabTableViewCellSlider.h"

@implementation openhabTableViewCellSlider
@synthesize detailLabel,theSlider,times,theTimer;


-(void)loadWidget:(openhabWidget *)theWidget
{
    [super loadWidget:theWidget];

	if (!self.sliding)
	{	// V1.2 Do not change the value if refreshing
		[theSlider setValue:[theWidget.item.state floatValue]];
	}

	// v1.2 modified to show data
	
	if (theWidget.data)
	{
		detailLabel.text=theWidget.data;
		[detailLabel setHidden:NO];
	}
	else
		[detailLabel setHidden:YES];
}

-(BOOL)mayBeModified
{
	return YES;
}

-(void)resetTimes
{
	NSLog(@"reset time");
	times=0;
}

-(IBAction)startDragging:(id)sender
{
	[openhab sharedOpenHAB].refreshing=YES;
	[[openhab sharedOpenHAB] cancelPolling];
	self.sliding=YES;
	times=1;
	theTimer=[NSTimer scheduledTimerWithTimeInterval:self.widget.sendFrequency target:self selector:@selector(resetTimes) userInfo:nil repeats:NO];
}
-(IBAction)stopDragging:(id)sender
{
	if ([sender isKindOfClass:[UISlider class]])
    {
		NSString*theStringValue=[NSString stringWithFormat:@"%.0f",[theSlider value]];
		if (theSlider.value==0)
			NSLog(@"!!!!!");
        NSLog(@"Value changed, %@",theStringValue);
		self.widget.item.state=theStringValue;
        [[openhab sharedOpenHAB] changeValueofItem:self.widget.item toValue:theStringValue];
		times=0;
    }
	self.sliding=NO;
	[openhab sharedOpenHAB].refreshing=NO;
	[[openhab sharedOpenHAB] longPollCurrent];
	[[openhab sharedOpenHAB] refreshPage:[openhab sharedOpenHAB].currentPage];
}

-(IBAction)changeValue:(id)sender
{
    if (times==0)
    {
		UISlider *newSlider=(UISlider*)sender;
		NSString*theStringValue=[NSString stringWithFormat:@"%.0f",[newSlider value]];
		self.widget.item.state=theStringValue;
		NSLog(@"Value changed, %@",self.widget.item.state);
        [[openhab sharedOpenHAB] changeValueofItem:self.widget.item toValue:theStringValue];
        times++;
		theTimer=[NSTimer scheduledTimerWithTimeInterval:self.widget.sendFrequency target:self selector:@selector(resetTimes) userInfo:nil repeats:NO];
    }
}

@end
