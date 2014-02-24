//
//  configurationMapViewController.m
//  openhab
//
//  Created by Pablo Mª Romeu Guallart on 31/08/12.
//
//


#import "configurationMapViewController.h"
#import "configuration.h"

@implementation configurationMapViewController
@synthesize theField,lastViewController;
@synthesize arrayDetected,theServer,lastselected;

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

- (void)selectRow
{
	NSString*selectedText=(NSString*)[configuration readPlist:theField];
	int i=0;
	for (NSString*serv in self.arrayDetected) {
		
		if ([serv isEqualToString:selectedText])
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
	if (i<[self.arrayDetected count])
	{
		NSIndexPath*ip=[NSIndexPath indexPathForRow:i inSection:0];
		[self.tableView cellForRowAtIndexPath:ip].accessoryType=UITableViewCellAccessoryCheckmark;
		lastselected=i;
	}
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	lastselected=-1;
	//self.arrayLasts=[(NSArray*)[configuration readPlist:[NSStringstringWithFormat:@"last_%@",theField]] mutableCopy];
	
	
	//self.theServer=(NSString*)[configuration readPlist:@"BASE_URL"];
	
	[self selectRow];
	
}

- (void)viewDidUnload
{
	[self setTableView:nil];
	[self setArrayDetected:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[openhab sharedOpenHAB].delegate=self;
	[[openhab sharedOpenHAB].queue cancelRequests];
	dispatch_async(dispatch_get_global_queue(0, 0),
				   ^(void) {
					   // this goes in background

					   
                       
					   
					   dispatch_sync(dispatch_get_main_queue(),
									 ^(void) {
										 NSLog(@"Got it! Asking for sitemap to %@",theServer);
										 // main thread
										 [[openhab sharedOpenHAB] requestSitemaps:theServer];
										 
									 });
					   
				   });
	
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[openhab sharedOpenHAB].delegate=nil;
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	return [arrayDetected count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	cell.textLabel.text=[arrayDetected objectAtIndex:indexPath.row];
	if (lastselected==indexPath.row && cell.accessoryType==UITableViewCellAccessoryNone)
		cell.accessoryType=UITableViewCellAccessoryCheckmark;    
    return cell;
}


// Override to support editing the table view.

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section==0) {
//        // Delete the row from the data source
//		
//		[arrayLasts removeObjectAtIndex:indexPath.row];
//		[configuration writeToPlist:[NSString stringWithFormat:@"last_%@",theField] valor:arrayLasts];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
}


-(void)goBack
{
    [lastViewController viewWillAppear:YES];
    [self.navigationController popViewControllerAnimated:YES];
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
    // Navigation logic may go here. Create and push another view controller.

	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSString*newVal=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
	[configuration writeToPlist:theField valor:newVal];
			
	// v1.2 set the last map value
	
	NSMutableDictionary*sitemaps4Servers=[(NSDictionary*)[configuration readPlist:@"sitemapForServer"] mutableCopy];
	[sitemaps4Servers setObject:[tableView cellForRowAtIndexPath:indexPath].textLabel.text forKey:theServer];
	[configuration writeToPlist:@"sitemapForServer" valor:sitemaps4Servers];
	[self selectRow];
	[self.tableView reloadData];
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//	if (section==0)
//		return NSLocalizedString(@"LocalizedFavorites", @"LocalizedFavorites");
//	else
//	{
		return [NSString stringWithFormat:NSLocalizedString(@"LocalizedAvailableMaps1", @"LocalizedAvailableMaps1"),self.theServer];
//	}
}

#pragma mark - openHAB response
-(void)requestSitemapsResponse:(NSArray *)theSitemaps
{
	self.arrayDetected=[theSitemaps copy];
	[self selectRow];
	[self.tableView reloadData];
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
