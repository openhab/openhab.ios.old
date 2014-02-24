//
//  openhabTableViewCellWebView.m
//  openhab
//
//  Created by Pablo Romeu Guallart on 30/08/12.
//
//

#import "openhabTableViewCellWebView.h"

@implementation openhabTableViewCellWebView
@synthesize theWebView,loaded;

-(void)loadWidget:(openhabWidget *)theWidget
{
    [super loadWidget:theWidget];
	//
	// Set the widget
    // Ask for the webView
	
    if (!loaded)
	{
		
		if (theWidget.theWidgetUrl && !theWebView.loading)
		{
			[theSpinner startAnimating];
			theWebView.delegate=self;
			[theWebView setScalesPageToFit:YES];
			[theWebView loadRequest:[NSURLRequest requestWithURL:theWidget.theWidgetUrl]];
		}
	}
	else
	{
		[theSpinner stopAnimating];
		//[theWebView reload];
	}
}

#pragma mark - webview delegate
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self.theSpinner stopAnimating];
	[self.label setHidden:YES];
	self.loaded=YES;
}

@end
