//
//  openhabDetailViewController.m
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

#import "openhabDetailViewController.h"

@interface openhabDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
-(void)enableRefresh;
-(void)disableRefresh;
-(void)initProgressHUD:(NSString*)text;
-(void)setProgress:(float)progress withText:(NSString*)text;
-(void)hideProgressHUD;
-(void)hideLoad;
-(void)longpollDidReceiveData:(commLibrary *)request;
-(void)refreshTableandSitemap;

@end

@implementation openhabDetailViewController
@synthesize theLoadingView;
@synthesize loadingLabel,HUD,progressTimer,alert,refreshTimer,loadingSpinner,myWidgets,myPageId,masterPopoverController = _masterPopoverController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.refreshTimer=nil;
        self.HUD=nil;
        self.alert=nil;
        // CHANGE v1.1 manualRefresh to NOT to show errors to user in auto refresh
        shouldNotifyUser=YES;
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
    // Load openhab
	
    // v1.2 modified. Present alert select sitemap
	if (![openhab sharedOpenHAB].theBaseUrl || ![openhab sharedOpenHAB].theMap)
	{
		UIAlertView*av=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SitemapEmpty", @"SitemapEmpty") message:NSLocalizedString(@"SitemapEmptyText", @"SitemapEmptyText")  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
		[av show];
	}
	else
	{
		if ([openhab sharedOpenHAB].delegate!=self) {
			[[openhab sharedOpenHAB] setDelegate:self];
		}
		
		self.loadingLabel.text=[NSString stringWithFormat:NSLocalizedString(@"LoadingSitemapUrl2", @"LoadingSitemapUrl2"),[openhab sharedOpenHAB].theBaseUrl,[openhab sharedOpenHAB].theMap];
        
		
		// CHANGE v1.1 to get alerts ONLY on manual things
		shouldNotifyUser=YES;
		if (![openhab sharedOpenHAB].serverReachable)
		{
			NSLog(@"ERROR: Server not reacheable");
			
			[self hideLoad];
			if (alert==nil && shouldNotifyUser) {
				alert=[[UIAlertView alloc] initWithTitle:@"Error" message:@"Server not reacheable" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			}
		}
		if (![openhab sharedOpenHAB].sitemapLoaded && [openhab sharedOpenHAB].serverReachable)
		{
			//v1.2 Load title
			[self initProgressHUD:NSLocalizedString(@"Loading",@"Loading")];
			[HUD setDetailsLabelText:NSLocalizedString((NSString*)[configuration readPlist:@"BASE_URL"],@"Locating Server")];
			
			[self.navigationItem setTitle:NSLocalizedString(@"Loading",@"Loading")];
			// v1.2 wait for server to become reacheable
			[self.navigationItem.rightBarButtonItem setEnabled:NO];
			dispatch_async(dispatch_get_global_queue(0, 0),
						   ^(void) {
							   // this goes in background
							
							   while (![openhab sharedOpenHAB].serverReachable) {
								   sleep(1);
							   }
							   dispatch_sync(dispatch_get_main_queue(),
											 ^(void) {
												 
												 // main thread
												 [HUD setDetailsLabelText:NSLocalizedString(@"LoadingItems",@"LoadingItems")];
												 [[openhab sharedOpenHAB] initSitemap];
												 
											 });
							   
						   });
		}
		else
		{
			[self.loadingLabel setHidden:YES];
			[self.loadingSpinner setHidden:YES];
			[self.theLoadingView setHidden:YES];
			
			
		}
	}

}

- (void)viewDidUnload
{
    theLoadingView = nil;
    self.refreshTimer=nil;
    self.HUD=nil;
    [self setTheLoadingView:nil];
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

	// If it is not loaded, move
	if (![openhab sharedOpenHAB].sitemapLoaded) {

		[self.loadingLabel setHidden:NO];
		[self.loadingSpinner setHidden:NO];
		[self.theLoadingView setHidden:NO];
	}
    
    // If sitemap is loaded, set the refresh
    
    if ([openhab sharedOpenHAB].sitemap && self.refreshTimer==nil)
        [self enableRefresh];
	if ([openhab sharedOpenHAB].delegate!=self)
	{
		[[openhab sharedOpenHAB] setDelegate:self];
	}
	//v1.2 long-poll sitemap if not doing already
	if ([openhab sharedOpenHAB].sitemap && ![openhab sharedOpenHAB].longPolling && self.myPageId)
	{
		
		[[openhab sharedOpenHAB] longPollSitemap:self.myPageId];
	}
	// v1.2 should update sitemap ONLY if it is not already refreshing
	if ([openhab sharedOpenHAB].sitemapLoaded && ![openhab sharedOpenHAB].refreshing)
	{
		[self refreshTableandSitemap];
	}
	else
	{
		[self.navigationItem.rightBarButtonItem setEnabled:YES];
		NSLog(@"Not refreshin, already doing");
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Disable the refresh whan we will disappear
    [self disableRefresh];
	// V1.2 disable polling and refresh:
	[[openhab sharedOpenHAB] cancelPolling];
	[[openhab sharedOpenHAB] cancelRefresh];
	
	// Cancelling anything
	NSLog(@"Cancell all requests NOW!");
	[[openhab sharedOpenHAB].queue cancelRequests];
	
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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadData];
	[self.tableView.window.rootViewController.view setNeedsLayout];
}

#pragma mark - tableview methods


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Count the number of sections. They are "frame" widgets
    NSInteger i=0;
    for (openhabWidget*w in self.myWidgets) {
        if ([w widgetType]==8)
            i++;
    }
    if (i==0)
        i++;
    return i;
}


- (NSArray*)WidgetsInSection:(NSUInteger)section
{
    NSUInteger i = 0;
    NSArray *wtemp=nil;
    for (openhabWidget*w in self.myWidgets) {
        if ([w widgetType]==8)
        {
            if (i==section)
                wtemp=w.widgets;
            i++;
        }
    }
    if (i==0)
	{
		return self.myWidgets;
	}
    return wtemp;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self WidgetsInSection:section] count];
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Contar el numero de frames
    NSUInteger i = 0;
    NSString*val=@"";
    for (openhabWidget*w in self.myWidgets) {
        if ([w widgetType]==8)
            if (i==section)
                val=w.label;
		i++;
    }
	
    return val;
}



-(openhabTableViewCell*)recycleCell:(NSString*)type withWidget:(openhabWidget*)widget
{
    // itemTypes: 1 Switch | 2 Selection | 3 Slider | 4 List | 11 setpoint | 12 Webview |14 Video | 16 Chart
    //groupWidgettypes itemTypes: 5 Text | 6 Group | 7 Image | 8 Frame | 17 Color
    
    openhabTableViewCell *cell= [self.tableView dequeueReusableCellWithIdentifier:type];
    
    switch ([widget widgetType]) {
        case 1:
            if (cell == nil) {
                cell = [[openhabTableViewCellSwitch alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
            }
            
            break;
        case 2:
            if (cell == nil) {
                cell = [[openhabTableViewCellSelection alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
            }
            break;
        case 3:
            if (cell == nil) {
                cell = [[openhabTableViewCellSlider alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
            }
            break;
        case 4:
            if (cell == nil) {
                cell = [[openhabTableViewCellList alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
            }
            break;
        case 5 | 9:
            if (cell == nil) {
                cell = [[openhabTableViewCelltext alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
            }
            break;
        case 6:
            if (cell == nil) {
                cell = [[openhabTableViewCellgroup alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
            }
            break;
        case 7 | 10:
            if (cell == nil) {
                cell = [[openhabTableViewCellimage alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
            }
            break;
        case 8:
            break;
		case 11:
            if (cell == nil) {
                cell = [[openhabTableViewCellSetpoint alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
            }
		case 12:
			if (cell == nil) {
                cell = [[openhabTableViewCellWebView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
            }
            break;
		case 14:
			if (cell == nil) {
                cell = [[openhabTableViewCellVideo alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
            }
            break;
		case 16:
			if (cell == nil) {
                cell = [[openhabTableViewCellChart alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
            }
            break;
		case 17:
			if (cell == nil) {
                cell = [[openhabTableViewCellColor alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
            }
            break;
        default:
            if (cell == nil) {
                cell = [[openhabTableViewCelltext alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:type];
            }
            break;
 
    }
    [cell loadWidget:widget];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	openhabWidget*widget=[[self WidgetsInSection:indexPath.section] objectAtIndex:indexPath.row];
	CGFloat theHeight=44; // Standard cell height

	if (widget.Image!=nil) // This is an image. We should check What is bigger in image
	{
		float aspectRatio=widget.Image.size.height/widget.Image.size.width;
		CGFloat theWidth;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
		{
			if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
				theWidth=300;
			}
			else
			{
				theWidth=460;
			}
		}
		else
		if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
				theWidth=678;
		}
		else
		{
			theWidth=934;
		}

		//theHeight=theWidth*[widget.Image size].height/[widget.Image size].width;
		//if ([widget.Image size].height>theHeight)
		//	theHeight=[widget.Image size].height;
		theHeight=theWidth*aspectRatio;
	}
	else if (widget.widgetType==12 || widget.widgetType==14 ) // V1.2 this is a webview or video
	{

		CGFloat theWidth;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		{
			if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
				theWidth=300;
				if (widget.height==0) // Size 4:3 by default
					widget.height=3*theWidth/(4*44);
			}
			else
			{
				theWidth=460;
				if (widget.height==0) // Size 4:3 by default
					widget.height=10*theWidth/(16*44);
			}
		}
		else if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
			theWidth=678;
			if (widget.height==0) // Size 4:3 by default
				widget.height=10*theWidth/(16*44);
		}
		else
		{
			theWidth=934;
			if (widget.height==0) // Size 4:3 by default
				widget.height=10*theWidth/(16*44);
		}
		
		theHeight=widget.height*44;
	}
	return theHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // itemTypes: 1 Switch | 2 Selection | 3 Slider | 4 List | 11 setpoint | 12 webview |14 video | 16 chart
    //groupWidgettypes itemTypes: 5 Text | 6 Group | 7 Image | 8 Frame
    
    openhabTableViewCell *cell;
    openhabWidget*widget=[[self WidgetsInSection:indexPath.section] objectAtIndex:indexPath.row];
    
	/*
	 "- Then, when I find a switch widget, I must check if it has mappings  to show a (short) number of buttons instead of a switch that will  send commands.
	 - and also, If it is a switch, check if it is a rollershutter to  show a three button widget?
	 - And, On the other hand, Dimmer and Rollershutters can come on  "slider" widgets?
	 - List widget will have mappings
	 - Selection widget will have mappings"
	 */
	
    switch ([widget widgetType]) {
        case 1:
            cell=[self recycleCell:@"cellSwitch" withWidget:widget];
            break;
        case 2:
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone &&
				UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
				cell=[self recycleCell:@"cellSelectionH" withWidget:widget];
			else
				cell=[self recycleCell:@"cellSelection" withWidget:widget];
            break;
        case 3:
            cell=[self recycleCell:@"cellSlider" withWidget:widget];
            break;
        case 4:
            cell=[self recycleCell:@"cellList" withWidget:widget];
            break;
        case 5:
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone &&
				(UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ||
				 [widget.data isEqualToString:@""]|| widget.data==nil))
				cell=[self recycleCell:@"cellTextH" withWidget:widget];
			else
				cell=[self recycleCell:@"cellText" withWidget:widget];
            break;
        case 6:
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone &&
				(UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ||
				[widget.data isEqualToString:@""] || widget.data==nil))
				cell=[self recycleCell:@"cellGroupH" withWidget:widget];
			else
				cell=[self recycleCell:@"cellGroup" withWidget:widget];
            break;
        case 7:
            cell=[self recycleCell:@"cellImage" withWidget:widget];
            break;
        case 8:
            NSLog(@"ERROR: A frame is not a cell,%@",widget);
			widget.label=NSLocalizedString(@"ErrorSitemapConfig", @"ErrorSitemapConfig");
			cell=[self recycleCell:@"cellTextNoChildren" withWidget:widget];
            break;
		case 9:
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone &&
				UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
				cell=[self recycleCell:@"cellTextNoChildrenH" withWidget:widget];
			else
				cell=[self recycleCell:@"cellTextNoChildren" withWidget:widget];
            break;
		case 10:
			cell=[self recycleCell:@"cellImageNoChildren" withWidget:widget];
            break;
		case 11:
			cell=[self recycleCell:@"cellSetpoint" withWidget:widget];
			break;
		case 12:
			cell=[self recycleCell:@"cellWebView" withWidget:widget];
			break;
		case 14:
			cell=[self recycleCell:@"cellVideo" withWidget:widget];
			break;
		case 16:
			cell=[self recycleCell:@"cellChart" withWidget:widget];
			break;
		case 17:
			cell=[self recycleCell:@"cellColor" withWidget:widget];
			break;

        default:
            NSLog(@"ERROR: Unknown type of widget,%@",widget);
            cell=[self recycleCell:@"cellText" withWidget:widget];
            break;
    }
	return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue destinationViewController] isKindOfClass:[openhabDetailViewController class]])
	{
		openhabDetailViewController*dvc=[segue destinationViewController];
		openhabTableViewCell*selectedCell=(openhabTableViewCell*)sender;
		dvc.myWidgets=selectedCell.widget.widgets;
		// v1.2 Add the linkedPage
		dvc.myPageId=selectedCell.widget.linkedPage;

		openhab* sharedOH=[openhab sharedOpenHAB];
		[sharedOH setDelegate:dvc];
		dvc.navigationItem.title=[[selectedCell label] text];
	}
	// v1.2 changed to a push segue
	else if ([[segue destinationViewController] isKindOfClass:[openhabTebleViewCellSelectionDetail class]])
	{
		openhabTebleViewCellSelectionDetail*dvc=(openhabTebleViewCellSelectionDetail*)[segue destinationViewController];
		dvc.lastTableView=self.tableView;
		openhabTableViewCell*selectedCell=(openhabTableViewCell*)sender;
		dvc.widget=selectedCell.widget;
		dvc.navigationItem.title=[[selectedCell label] text];
	}
	else if ([[segue destinationViewController] isKindOfClass:[openhabTableViewCellColorPicker class]])
	{
		openhabTableViewCellColorPicker*dvc=(openhabTableViewCellColorPicker*)[segue destinationViewController];
		dvc.lastTableView=self.tableView;
		openhabTableViewCell*selectedCell=(openhabTableViewCell*)sender;
		dvc.widget=selectedCell.widget;
		dvc.navigationItem.title=[[selectedCell label] text];
	}
	else
	{
		// Do nothin
	}
}
#pragma mark - Refresh the sitemap



-(void)refreshTableandSitemap
{
	if ([openhab sharedOpenHAB].sitemapLoaded && ![openhab sharedOpenHAB].refreshing)
	{
        shouldNotifyUser=NO;
		// CHANGE v1.1
        //self.navigationItem.title=[self.navigationItem.title stringByAppendingFormat:@"...%@",NSLocalizedString(@"Refreshing", @"Refreshing")];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
		if (!self.myPageId)
		{
			[[openhab sharedOpenHAB] refreshItems];
			[[openhab sharedOpenHAB] refreshSitemap];
		}
		else
		{
			NSLog(@"Refreshing page: %@",self.myPageId);
			[[openhab sharedOpenHAB] refreshPage:self.myPageId];
		}
	}
}

-(IBAction)refreshTableandSitemap:(id)sender
{
	if (![openhab sharedOpenHAB].refreshing)
	{
        // CHANGE v1.1 manualRefresh to NOT to show errors to user in auto refresh
        shouldNotifyUser=YES;
		[self initProgressHUD:NSLocalizedString(@"Refreshing", @"Refreshing")];
		[self refreshTableandSitemap];
	}
}

-(void)enableRefresh
{
    double ref=[(NSNumber*)[configuration readPlist:@"refresh"] doubleValue];
    if (ref>0)
        self.refreshTimer=[NSTimer scheduledTimerWithTimeInterval:ref target:self selector:@selector(refreshTableandSitemap) userInfo:nil repeats:YES];
}
-(void)disableRefresh
{
    if (self.refreshTimer)
        [self.refreshTimer invalidate];
    self.refreshTimer=nil;
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

#pragma mark - openHABProtocol
-(void)itemsLoaded
{
    NSLog(@"Items loaded");
    [self setProgress:(1.0/3.0) withText:NSLocalizedString(@"LoadingGroups",@"LoadingGroups")];
}
-(void)groupsLoaded
{
    NSLog(@"Groups loaded");
    [self setProgress:(2.0/3.0) withText:NSLocalizedString(@"LoadingSitemap",@"LoadingSitemap")];

}
-(void)sitemapLoaded
{
    NSLog(@"Sitemap loaded");
    [self.loadingLabel setHidden:YES];
    [self.loadingSpinner setHidden:YES];
    [self.theLoadingView setHidden:YES];
    
	// v1.2 We should then add linkedpage to this to main page
    if (self.myWidgets==nil)
	{

		self.myWidgets=[[openhab sharedOpenHAB] sitemap];
		self.myPageId=[[openhab sharedOpenHAB] theMap];
	}
	
    [self setProgress:(3.0/3.0) withText:NSLocalizedString(@"SitemapLoaded",@"SitemapLoaded")];
	
	// NEW: CHANGE TITLE
	if ([self.navigationItem.title isEqualToString:NSLocalizedString(@"Loading",@"Loading")])
	{
		self.navigationItem.title = [openhab sharedOpenHAB].sitemapName;
	}
	
    [self.tableView reloadData];
    if (HUD!=nil && ([[openhab sharedOpenHAB].queue operations]+[[openhab sharedOpenHAB].queue operationsInQueue])<=0)
	{
        [self hideProgressHUD];
	}

}
-(void)valueOfItemChangeRequested:(openhabItem*)theItem
{
    NSLog(@"Value of %@ changed to %@!",theItem.name,theItem.state);
}
-(void)itemsRefreshed
{
    NSLog(@"Items refreshed");
    [self setProgress:(1.0/2.0) withText:NSLocalizedString(@"ItemsRefreshed",@"ItemsRefreshed")];
    
}
-(void)sitemapRefreshed
{
    NSLog(@"Sitemap refreshed");
    
    // IF we have not yet set the refresh, set it now
    if ([openhab sharedOpenHAB].sitemap && self.refreshTimer==nil)
        [self enableRefresh];
    [self setProgress:(2.0/2.0) withText:@"Sitemap Refreshed"];
    
    // CHANGE v1.1 no refresh in title but enable refresh button
    
//	NSArray*temp=[self.navigationItem.title componentsSeparatedByString:@"."];
//	if ([temp count]>1)
//	{
//		self.navigationItem.title=[temp objectAtIndex:0];
//	}
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
	if (HUD!=nil && ([[openhab sharedOpenHAB].queue operations]+[[openhab sharedOpenHAB].queue operationsInQueue])<=0)
        [self hideProgressHUD];
    [self.tableView reloadData];
    // CHANGE v1.1 Should notify
    shouldNotifyUser=YES;
}
-(void)imagesRefreshed
{
    
    float a=[[openhab sharedOpenHAB].queue operations];
    a+=[[openhab sharedOpenHAB].queue operationsInQueue];
    if (a==0)
        a++;
    [self setProgress:(1/a) withText:[NSString stringWithFormat:NSLocalizedString(@"ImageRefreshed1",@"ItemsRefreshed"),a]];
	//NSLog(@"Images refreshed, left %.0f",a);
    [self.tableView reloadData];
}

// v1.2 Start again long polling
-(void)longpollDidReceiveData:(commLibrary *)request
{
	NSLog(@"received data. Longpoll Again");
	[self.tableView reloadData];
	//v1.2 long-poll sitemap if not doing already
	if ([openhab sharedOpenHAB].sitemap && ![openhab sharedOpenHAB].longPolling && self.myPageId)
	{
		
		[[openhab sharedOpenHAB] longPollSitemap:self.myPageId];
	}
}

// v1.2 Start again long polling
-(void)pageRefreshed:(commLibrary *)page
{
	NSLog(@"received data from refresh");
	[self.navigationItem.rightBarButtonItem setEnabled:YES];
	if (HUD!=nil)
        [self hideProgressHUD];
    [self.tableView reloadData];
    shouldNotifyUser=YES;
}

-(void)requestFailed:(commLibrary*)request withError:(NSError*)error
{
    NSLog(@"ERROR: Request %@ failed with error: %@",request,error);
	
	[self hideLoad];
    if (alert==nil && shouldNotifyUser) {
        alert=[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)JSONparseError:(NSString*)parsePhase withError:(NSError*)error
{
	
	[self hideLoad];
    NSLog(@"ERROR: JSON parse %@ failed with error: %@",parsePhase,error);
    if (alert==nil && shouldNotifyUser) {
        alert=[[UIAlertView alloc] initWithTitle:@"Error parsing Response" message:[NSString stringWithFormat:NSLocalizedString(@"ParserFormat2",@"ParserFormat2"),parsePhase,error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)allRequestsFinished
{
    if ([openhab sharedOpenHAB].sitemapLoaded && HUD!=nil && ([[openhab sharedOpenHAB].queue operations]+[[openhab sharedOpenHAB].queue operationsInQueue])<=0)
        [self hideProgressHUD];
    NSLog(@"Request queue empty");

	//v1.2 long-poll sitemap if not doing already
	if ([openhab sharedOpenHAB].sitemap && ![openhab sharedOpenHAB].longPolling && self.myPageId)
	{
		
		[[openhab sharedOpenHAB] longPollSitemap:self.myPageId];
	}
}

#pragma mark - progresshud



-(void)hideLoad
{
	[self.loadingLabel setHidden:YES];
	[self.loadingSpinner setHidden:YES];
	[self.theLoadingView setHidden:YES];
    
    // CHANGE v1.1 no refresh in title and enable button
//    NSArray*temp=[self.navigationItem.title componentsSeparatedByString:@"."];
//	if ([temp count]>1)
//	{
//		self.navigationItem.title=[temp objectAtIndex:0];
//	}
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    [self hideProgressHUD];
}

-(void)goProgress
{
	double p=[HUD progress];
	if (p>=1)
		p=0;
	[HUD setProgress:p+0.005];
}

-(void)initProgressHUD:(NSString*)text
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [HUD setProgress:0];
    [HUD setMode:MBProgressHUDModeIndeterminate];
    [HUD setLabelText:text];
	[HUD setTaskInProgress:YES];
	[HUD setGraceTime:0.5];
    [self.navigationController.view addSubview:HUD];
	self.progressTimer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(goProgress) userInfo:nil repeats:YES];
    [HUD show:YES];
	// v1.2 Hide after 30 seconds for sure
	[HUD hide:YES afterDelay:30.0];
}


-(void)setProgress:(float)progress withText:(NSString*)text
{
    if (HUD!=nil)
    {
        [HUD setMode:MBProgressHUDModeDeterminate];
        [HUD setProgress:progress];
        [HUD setDetailsLabelText:text];
    }
}

-(void)reallyHideProgressHUD
{
	if (HUD!=nil)
    {
		[HUD setTaskInProgress:NO];
        [HUD hide:YES afterDelay:1.0];
		[self.progressTimer invalidate];
		self.progressTimer=nil;
    }
}

-(void)hideProgressHUD
{
    if (HUD!=nil)
	{
		[HUD setMode:MBProgressHUDModeIndeterminate];
		[HUD setLabelText:NSLocalizedString(@"Alldone",@"Alldone")];
		[HUD setDetailsLabelText:NSLocalizedString(@"BuildingInterface",@"BuildingInterface")];
		[self reallyHideProgressHUD];
	}
}

@end
