//
//  openhabTableViewCellChart.m
//  openhab
//
//  Created by Pablo Romeu Guallart on 06/09/12.
//
//

#import "openhabTableViewCellChart.h"

@implementation openhabTableViewCellChart
@synthesize bigImage,theTimer;


-(void)launchDeletion
{
	self.widget.Image=nil;
	
	[[openhab sharedOpenHAB] deleteImage:self.widget.imageURL];
	// lets look for the image and download it
	[[openhab sharedOpenHAB] getImageWithURL:self.widget.imageURL];
}
-(void)loadWidget:(openhabWidget *)theWidget
{
    [super loadWidget:theWidget];
	//    self.bigImage;
	// Set the widget, the label and the image
    // Ask for the image
    
    if (self.widget.Image!=nil)
    {
        self.bigImage.image=self.widget.Image;
        [self.theSpinner stopAnimating];
		[self.theImage setHidden:YES];
		[self.label setHidden:YES];

		// v1.2 Schedule refresh
		if (self.widget.refresh>0 && !theTimer)
		{
			NSInteger refreshtime=self.widget.refresh/1000;
			theTimer=[NSTimer scheduledTimerWithTimeInterval:refreshtime target:self selector:@selector(launchDeletion) userInfo:nil repeats:YES];
		}
    }
    else
    {
		[self.theImage setHidden:NO];
		 [self.theSpinner startAnimating];
        // lets look for the image and download it
        [[openhab sharedOpenHAB] getImageWithURL:self.widget.imageURL];
    }
}

@end
