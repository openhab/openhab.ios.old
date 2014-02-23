//
//  openhabTableViewCellVideo.m
//  openhab
//
//  Created by Pablo Romeu Guallart on 05/09/12.
//
//

/*Sample 
 
 MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:url]];
 player.view.frame = CGRectMake(184, 200, 400, 300);
 [self.view addSubview:player.view];
 [player play];*/

#import "openhabTableViewCellVideo.h"

@implementation openhabTableViewCellVideo
@synthesize loaded,player;

-(void)loadWidget:(openhabWidget *)theWidget
{
    [super loadWidget:theWidget];
	//
	// Set the widget
    // Ask for the video
	
    if (!loaded)
	{
		
		if (theWidget.theWidgetUrl)
		{
			player.view.autoresizingMask=UIViewAutoresizingNone;
			player = [[MPMoviePlayerController alloc] initWithContentURL:theWidget.theWidgetUrl];
			player.view.frame = self.contentView.bounds;
			
			[self.contentView addSubview:player.view];
			[player play];
			[self setLoaded:YES];
		}
	}
	else
	{
		[theSpinner stopAnimating];
		[self.theImage setHidden:YES];
		

		player.view.frame=self.contentView.bounds;

		//[theWebView reload];
	}

}


@end
