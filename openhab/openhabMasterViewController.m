//
//  openhabMasterViewController.m
//  openhab
//
//  Created by Pablo Romeu Guallart on 16/12/11.
//	Eclipse Public License - v 1.0
//
//  THE ACCOMPANYING PROGRAM IS PROVIDED UNDER THE TERMS OF THIS
//	ECLIPSE PUBLIC LICENSE ("AGREEMENT"). ANY USE, REPRODUCTION OR
//	DISTRIBUTION OF THE PROGRAM CONSTITUTES RECIPIENT'S ACCEPTANCE
//	OF THIS AGREEMENT.
//
//	See license.txt for more info

//

#import "openhabMasterViewController.h"
#import "openhabDetailViewController.h"
#import "configurationViewController.h"

@implementation openhabMasterViewController

@synthesize detailViewController = _detailViewController,theButton,thePopover;

- (void)awakeFromNib
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    self.clearsSelectionOnViewWillAppear = NO;
	    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	}
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.detailViewController = (configurationViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
	self.navigationItem.title=NSLocalizedString(@"Master", @"Master");
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
	}

	// Configure title and cells

	

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	NSIndexPath *index=[NSIndexPath indexPathForRow:0 inSection:0];
	// section 0, row 0, OpenHAB
	UITableViewCell*cell=[self.tableView cellForRowAtIndexPath:index];
	cell.textLabel.text=NSLocalizedString(@"OpenHAB", @"OpenHAB");
	// section 1,row0, config
	index=[NSIndexPath indexPathForRow:0 inSection:1];
	cell=[self.tableView cellForRowAtIndexPath:index];
	cell.textLabel.text=NSLocalizedString(@"Configuration", @"Configuration");	
	// section 1, row 1 info
	index=[NSIndexPath indexPathForRow:1 inSection:1];
	cell=[self.tableView cellForRowAtIndexPath:index];
	cell.textLabel.text=NSLocalizedString(@"Info", @"Info");	
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

#pragma mark - Preparar segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	
	UIViewController <splitMultipleDetailViews>*vc;
	
	if ([[segue destinationViewController]isKindOfClass:[UINavigationController class]])
	{
		UINavigationController *nvc = (UINavigationController*)[segue destinationViewController];
		vc = (UIViewController <splitMultipleDetailViews>*)[nvc topViewController];
	}
	else
	{
		vc=[segue destinationViewController];
	}
	if (self.theButton!=nil)
		[vc showButton:theButton pop:thePopover];
	if (self.thePopover != nil) {
        [thePopover dismissPopoverAnimated:YES];
    }

    openhabDetailViewController*dvc=nil;
    if ([vc isKindOfClass:[openhabDetailViewController class]])
    {
        dvc=(openhabDetailViewController*)vc;
		
		// Check if we have changes on maps and urls, and if so, change map
		
		NSString*savedURL=(NSString*)[configuration readPlist:@"BASE_URL"];
		NSString*savedMap=(NSString*)[configuration readPlist:@"map"];	
		
		if (
			(!([[openhab sharedOpenHAB] theBaseUrl]==savedURL) ||
			!([[openhab sharedOpenHAB] theMap]==savedMap)		
			) &&
			[openhab sharedOpenHAB].itemsLoaded){
			[openhab deleteSharedOpenHAB];
			// Start movement
			
		}
		
		
		// Set the widgets and go
		
        [dvc setMyWidgets:[[openhab sharedOpenHAB] sitemap]];
		
		// v1.2 new! Need to put here the linkedPage
		[dvc setMyPageId:savedMap];
		
		//dvc.navigationItem.title=(NSString*)[configuration readPlist:@"map"];
		dvc.navigationItem.title=NSLocalizedString(@"Loading",@"Loading");
        [[openhab sharedOpenHAB]setDelegate:dvc];
		
     }
	self.detailViewController=vc;
}



#pragma mark - splitView events

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    // Hay que mostrar el boton
    
    UIViewController <splitMultipleDetailViews> * destinationView=nil;
    if ([self.detailViewController.navigationController.topViewController isKindOfClass:[openhabDetailViewController class]])
        destinationView = (UIViewController <splitMultipleDetailViews> *)self.detailViewController.navigationController.topViewController;
    else
        destinationView = (UIViewController <splitMultipleDetailViews> *)self.detailViewController;
	
	// PASS the BUTTON AND POPOVER
    self.theButton=barButtonItem;
    self.thePopover=popoverController;
    
    [destinationView showButton:barButtonItem pop:popoverController];
    
	
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    UIViewController <splitMultipleDetailViews> * destinationView=nil;
    if ([self.detailViewController.navigationController.topViewController isKindOfClass:[openhabDetailViewController class]])
        destinationView = (UIViewController <splitMultipleDetailViews> *)self.detailViewController.navigationController.topViewController;
    else
        destinationView = (UIViewController <splitMultipleDetailViews> *)self.detailViewController;
    
    [destinationView hideButton:barButtonItem];
    
    // SET the BUTTON AND POPOVER to NIL?
	self.theButton=nil;
	self.thePopover=nil;
}

// v1.2 Override. iPad should hide the left panel 

-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

@end
