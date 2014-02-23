//
//  infoViewController.m
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

#import "infoViewController.h"

@interface infoViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation infoViewController
@synthesize toBeLocalizedSomeStats = _toBeLocalizedSomeStats;
@synthesize theTextView = _theTextView;
@synthesize donateButton = _donateButton;

@synthesize masterPopoverController = _masterPopoverController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSString*version=(NSString*)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	self.donateButton.title=NSLocalizedString(@"Donations", @"Donations");
	self.navigationItem.title=NSLocalizedString(@"Info", @"Info");
	self.theTextView.text=[NSString stringWithFormat:NSLocalizedString(@"InfoText1", @"InfoText1"),version];
	
	float size=[[openhab sharedOpenHAB].queue sizeDownloaded]/1024.0;
	
	self.toBeLocalizedSomeStats.text=[NSString stringWithFormat:NSLocalizedString(@"Stats3", @"Stats3"),[[openhab sharedOpenHAB].queue Allpetitions],size,[[[openhab sharedOpenHAB].imagesDictionary allKeys] count]];
}

- (void)viewDidUnload
{
	[self setTheTextView:nil];
	[self setToBeLocalizedSomeStats:nil];
    [self setDonateButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    } 
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


#pragma mark - Multiple Split view delegate

-(void)showButton:(UIBarButtonItem *)button pop:(UIPopoverController *)popover
{
    button.title = NSLocalizedString(@"Menu", @"Menu");
    [self.navigationItem setLeftBarButtonItem:button animated:YES];
    self.masterPopoverController = popover;
}

- (void)hideButton:(UIBarButtonItem *)button
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
