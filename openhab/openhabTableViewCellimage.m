//
//  openhabTableViewCellimage.m
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

#import "openhabTableViewCellimage.h"

@implementation openhabTableViewCellimage
@synthesize bigImage,theTimer;


// v1.2 Refresh of image

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
    
    if (theWidget.Image!=nil)
    {
        self.bigImage.image=theWidget.Image;
        [self.theSpinner stopAnimating];
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
		[self.theSpinner startAnimating];
		[self.label setHidden:NO];
        // lets look for the image and download it
        [[openhab sharedOpenHAB] getImageWithURL:theWidget.imageURL];
    }
}
@end
