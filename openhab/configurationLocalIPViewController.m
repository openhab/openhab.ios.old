//
//  configurationLocalIPViewController.m
//  openhab
//
//  Created by Pablo Mª Romeu Guallart on 31/08/12.
//
//


#import "configurationLocalIPViewController.h"
#import "configuration.h"
#import "configurationMapViewController.h"
#import "loginViewController.h"

@implementation configurationLocalIPViewController
@synthesize sitemapButton;
@synthesize theTextField,theField,arrayLasts,lastViewController;
@synthesize serviceBrowser,serviceBrowser2,bonjourDelegate,bonjourAddresses,lastselected;

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

#pragma mark - check for server at list

- (void)selectServerRow
{
	NSString*serverURL=[(NSDictionary*)[configuration readPlist:@"alternateURLs"]
						objectForKey:
						[configuration readPlist:theField]];
	int i=0;
	for (NSString*serv in self.arrayLasts) {
		if ([serv isEqualToString:serverURL])
		{
			break;
		}
		i++;
	}
	if (lastselected>=0 && lastselected!=i)// Deselect
	{
		NSIndexPath*ip=[NSIndexPath indexPathForRow:lastselected inSection:0];
		[self.tableView cellForRowAtIndexPath:ip].accessoryType=UITableViewCellAccessoryNone;
		
	}
	if (i<[self.arrayLasts count])
	{
		NSIndexPath*ip=[NSIndexPath indexPathForRow:i inSection:0];
		[self.tableView cellForRowAtIndexPath:ip].accessoryType=	UITableViewCellAccessoryCheckmark;
		lastselected=i;
	}
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	lastselected=-1;
	self.theTextField.text=[(NSDictionary*)[configuration readPlist:@"alternateURLs"]
							objectForKey:
							[configuration readPlist:theField]];
	self.theTextField.delegate=self;
	self.arrayLasts=[(NSArray*)[configuration readPlist:@"last_BASE_URL"] mutableCopy];
	
	bonjourAddresses=[NSMutableArray new];
	self.sitemapButton.title=NSLocalizedString(@"labelSitemap", @"labelSitemap");
	
	[self selectServerRow];
	
  	/* v1.2 TEST BNJOuR*/
	
		serviceBrowser = [[NSNetServiceBrowser alloc] init];
		serviceBrowser2 = [[NSNetServiceBrowser alloc] init];
		
		bonjourDelegate=[bonjourBrowserDelegate new];
		[bonjourDelegate setDelegate:self];
		[serviceBrowser setDelegate:bonjourDelegate];
		[serviceBrowser2 setDelegate:bonjourDelegate];
		[serviceBrowser searchForServicesOfType:@"_openhab-server._tcp" inDomain:@""];
		[serviceBrowser2 searchForServicesOfType:@"_openhab-server-ssl._tcp" inDomain:@""];
	
}

- (void)viewDidUnload
{
	[self setTheTextField:nil];
	[self setTableView:nil];
	[self setArrayLasts:nil];
    [self setSitemapButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[serviceBrowser stop];
	[serviceBrowser2 stop];
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

#pragma mark - Table view data source

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==0)
		return YES;
	else
		return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
	return 2;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	
	if (section==0)
		return [arrayLasts count];
	else
		//return [bonjourBrowserDelegate.addresses count];
		return [self.bonjourAddresses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	if (indexPath.section==0)
	{
		cell.textLabel.text=[arrayLasts objectAtIndex:indexPath.row];
		if (lastselected==indexPath.row && cell.accessoryType==UITableViewCellAccessoryNone)
			cell.accessoryType=UITableViewCellAccessoryCheckmark;
	}
	else
		cell.textLabel.text=[bonjourAddresses objectAtIndex:indexPath.row];
    
    return cell;
}


// Override to support editing the table view.

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section==0) {
        // Delete the row from the data source
		
		[arrayLasts removeObjectAtIndex:indexPath.row];
		
		NSString*theUrl=(NSString*)[configuration readPlist:@"BASE_URL"];
		// V1.2 Add to the list of alternateURLs
		NSDictionary*theAlts=(NSDictionary*)[configuration readPlist:@"alternateURLs"];
		if ([theAlts objectForKey:theUrl]) // exists alternate, delete it
		{
			NSMutableDictionary*themd=[NSMutableDictionary dictionaryWithDictionary:theAlts];
			[themd removeObjectForKey:theUrl];
			[configuration writeToPlist:@"alternateURLs" valor:themd];
		}
		
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


-(void)goBack
{
    [lastViewController viewWillAppear:YES];
    [self dismissModalViewControllerAnimated:YES];
}

-(BOOL)existsOnArray:(NSArray*)theArray theValue:(NSString*)theObject
{
    BOOL result=NO;
    for (NSString*temp in theArray) {
        if ([temp isEqualToString:theObject]) {
            result=YES;
            break;
        }
    }
    return result;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	theTextField.text=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;

	// V1.2 Add to the list of alternateURLs
	
	NSString*theUrl=(NSString*)[configuration readPlist:@"BASE_URL"];
	NSMutableDictionary*theAlts=[(NSDictionary*)[configuration readPlist:@"alternateURLs"] mutableCopy];
	[theAlts removeObjectForKey:theUrl];
	[theAlts setObject:theTextField.text forKey:theUrl];
	[configuration writeToPlist:@"alternateURLs" valor:theAlts];


	if (![self existsOnArray:arrayLasts theValue:theTextField.text])
    {
        [arrayLasts addObject:theTextField.text];
		[configuration writeToPlist:[NSString stringWithFormat:@"last_%@",theField] valor:arrayLasts];
		
    }
	
	// v1.2 get the last map value
	NSDictionary*sitemaps4Servers=(NSDictionary*)[configuration readPlist:@"sitemapForServer"];
	NSString*theKey=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
	NSString*theMap=[sitemaps4Servers objectForKey:theKey];
	
	// v1.2 set the map
	if (theMap) {
		[configuration writeToPlist:@"alternateMap" valor:theMap];
	}
	else
	{
		[self setFirstAvailableSitemapAt:theKey];
	}
	[self selectServerRow];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.tableView reloadData];
    });
}


- (IBAction)deleteAlternate:(id)sender { // v1.2 Delete the alternate url
			
	
	NSString*theUrl=(NSString*)[configuration readPlist:@"BASE_URL"];
	// V1.2 Add to the list of alternateURLs
	NSDictionary*theAlts=(NSDictionary*)[configuration readPlist:@"alternateURLs"];
	if ([theAlts objectForKey:theUrl]) // exists alternate, delete it
	{
		NSMutableDictionary*themd=[NSMutableDictionary dictionaryWithDictionary:theAlts];
		[themd removeObjectForKey:theUrl];
		[configuration writeToPlist:@"alternateURLs" valor:themd];
	}    
	[self goBack];
}

- (IBAction)doneButton:(id)sender {
	if (self.theTextField.text)
	{
		if ([theField isEqualToString:@"BASE_URL"]) // This is a network configuration table
		{
			// v1.2 Check for /
			NSInteger l=[theTextField.text length];
			if ([theTextField.text characterAtIndex:l-1] != '/')
				theTextField.text=[theTextField.text stringByAppendingFormat:@"/"];
		}
		
		NSString*theUrl=(NSString*)[configuration readPlist:@"BASE_URL"];
		// V1.2 Add to the list of alternateURLs
		
		NSMutableDictionary*theAlts=[(NSDictionary*)[configuration readPlist:@"alternateURLs"] mutableCopy];
		[theAlts removeObjectForKey:theUrl];
		[theAlts setObject:theTextField.text forKey:theUrl];
		[configuration writeToPlist:@"alternateURLs" valor:theAlts];
		
		
		if (![self existsOnArray:arrayLasts theValue:theTextField.text])
		{
			[arrayLasts addObject:theTextField.text];
			[configuration writeToPlist:[NSString stringWithFormat:@"last_%@",theField] valor:arrayLasts];
		}
		// v1.2 get the last map value
		NSDictionary*sitemaps4Servers=(NSDictionary*)[configuration readPlist:@"sitemapForServer"];
		NSString*theKey=theTextField.text;
		NSString*theMap=[sitemaps4Servers objectForKey:theKey];
		
		// v1.2 set the map
		if (theMap) {
			[configuration writeToPlist:@"alternateMap" valor:theMap];
		}
	}
	[self goBack];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
	[textField resignFirstResponder];
	[self doneButton:textField];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ([theField isEqualToString:@"BASE_URL"]) // This is a network configuration table
	{
		if (section==0)
			return NSLocalizedString(@"LocalizedFavorites", @"LocalizedFavorites");
		else
			return NSLocalizedString(@"LocalizedBonjour", @"LocalizedBonjour");
	}
	else
		return nil;
}

-(void)updateInterface:(NSArray *)serverList
{
	dispatch_async(dispatch_get_main_queue(), ^{
		for (NSString*address in serverList) {
			if (![self.bonjourAddresses containsObject:address])
				[self.bonjourAddresses addObject:address];
		}
		
		[self.tableView reloadData];
	});
}

#pragma mark - prepare for segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	
	UIViewController* dvc=[segue destinationViewController];
	
	if (![dvc isKindOfClass:[UINavigationController class]])
	{
		if ([segue.identifier isEqualToString:@"sitemapConfigurationSegue"])
		{
			configurationMapViewController*ndvc= (configurationMapViewController*)dvc;
			ndvc.navigationItem.title=NSLocalizedString(@"SetSitemap", @"SetSitemap");;
			ndvc.theField=@"map";
			ndvc.lastViewController=self;
			if (lastselected>=0)
				ndvc.theServer=[arrayLasts objectAtIndex:lastselected];
			else
				ndvc.theServer=[arrayLasts objectAtIndex:0];
		}
	}
	else
	{
		loginViewController*ndvc= (loginViewController*)[(UINavigationController*)dvc topViewController];
		if ([segue.identifier isEqualToString:@"loginSegue"])
		{
			if (lastselected>=0)
				ndvc.server=[arrayLasts objectAtIndex:lastselected];
			else
				ndvc.server=[arrayLasts objectAtIndex:0];
		}
	}
}


#pragma mark - set the first sitemap to work

-(void)setFirstAvailableSitemapAt:(NSString*)theServerUrl
{
	[openhab sharedOpenHAB].delegate=self;
	dispatch_async(dispatch_get_global_queue(0, 0),
				   ^(void) {
					   // this goes in background
					   
					   while (![openhab sharedOpenHAB].serverReachable) {
						   sleep(1);
					   }
					   
					   dispatch_sync(dispatch_get_main_queue(),
									 ^(void) {
										 
										 // main thread
										 [[openhab sharedOpenHAB] requestSitemaps:theServerUrl];
										 
									 });
					   
				   });
	
}

#pragma mark - openHAB response
-(void)requestSitemapsResponse:(NSArray *)theSitemaps
{
	if (theSitemaps)
	{
		// v1.2 set the first sitemap
		NSString*theFirstMap=[theSitemaps objectAtIndex:0];
		[configuration writeToPlist:@"alternateMap" valor:theFirstMap];
		
		// v1.2 set the last map value
		
		NSMutableDictionary*sitemaps4Servers=[(NSDictionary*)[configuration readPlist:@"sitemapForServer"] mutableCopy];
		NSDictionary*dict=(NSDictionary*)[configuration readPlist:@"alternateURLs"];
		NSString*theKey=[dict objectForKey:(NSString*)[configuration readPlist:@"BASE_URL"]];
		[sitemaps4Servers setObject:theFirstMap forKey:theKey];
		[configuration writeToPlist:@"sitemapForServer" valor:sitemaps4Servers];
	}
	
}

-(void)requestFailed:(commLibrary *)request withError:(NSError *)error
{
	UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
}

-(void)JSONparseError:(NSString *)parsePhase withError:(NSError *)error
{
	UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
}
-(void)allRequestsFinished
{
	
}


@end

