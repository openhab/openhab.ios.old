//
//  openhab.m
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

#import "openhab.h"
#import "configuration.h"
// Prepare singleton
static openhab *sharedOpenhab = nil;

@interface openhab ()
-(void)updateArrayAndCopyImages:(openhabImage*)image andWidgets:(NSArray*)theWidgets;
@end

@implementation openhab
@synthesize arrayItems,queue,sitemap;
@synthesize itemsLoaded,sitemapName,refreshing,groupsLoaded,sitemapLoaded,delegate,theBaseUrl,theMap,currentlyPolling,currentlyRefreshing,currentPage,pagesDictionary,imagesDictionary,serverReachable;


-(openhab*)init
{
	self = [super init];
    if (self) {
        // Initialization code here.
        self.arrayItems=[[NSMutableArray alloc]init];
		self.queue=[[requestQueue alloc]init];
		self.sitemap=[[NSMutableArray alloc]init];
		self.pagesDictionary=[NSMutableDictionary dictionaryWithCapacity:0];
		self.imagesDictionary=[NSMutableDictionary dictionaryWithCapacity:0];
		self.delegate=nil;
		self.theBaseUrl=nil;
		self.theMap=nil;
		self.sitemapName=nil;
		itemsLoaded=NO;
		refreshing=NO;
		groupsLoaded=NO;
		sitemapLoaded=NO;
		serverReachable=NO;
		currentlyPolling=0;
		currentlyRefreshing=0;
		[self checkForReachability];
		
    }
    return self;
}

#pragma mark Singleton Methods
+ (openhab*)sharedOpenHAB {
    @synchronized(self) {
        if (sharedOpenhab == nil)
            sharedOpenhab = [[self alloc] init];
    }
    return sharedOpenhab;
}

+ (openhab*)deleteSharedOpenHAB {
    @synchronized(self) {
            sharedOpenhab = [[self alloc] init];
    }
    return sharedOpenhab;
}

#pragma mark - address reachability


- (void)handleNetworkChange:(NSNotification *)notice
{
	NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
	if(remoteHostStatus == NotReachable)
	{
		self.serverReachable=NO;
		NSLog(@"Reachability no internet connection");
	}
	else if (remoteHostStatus == ReachableViaWiFi)
	{
		self.serverReachable=YES;
		NSLog(@"Reachability WIFI");
		self.theBaseUrl=(NSString*)[configuration readPlist:@"BASE_URL"];
		theMap=(NSString*)[configuration readPlist:@"map"];
		NSError *error=nil; 
		[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.theBaseUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0] returningResponse:nil error:&error];
		if(error) { 
			NSLog(@"Reachability alternate")
			NSDictionary*alts=(NSDictionary*)[configuration readPlist:@"alternateURLs"];
			theMap=(NSString*)[configuration readPlist:@"alternateMap"];
			self.theBaseUrl=[alts objectForKey:(NSString*)[configuration readPlist:@"BASE_URL"]];
			if (!self.theBaseUrl) {
				NSLog(@"No Alternate configured");
				self.serverReachable=NO;
			}
		}
	}
	else if (remoteHostStatus == ReachableViaWWAN)
	{
		self.serverReachable=YES;
		NSDictionary*alts=(NSDictionary*)[configuration readPlist:@"alternateURLs"];
		theMap=(NSString*)[configuration readPlist:@"alternateMap"];
		self.theBaseUrl=[alts objectForKey:(NSString*)[configuration readPlist:@"BASE_URL"]];
		if (!self.theBaseUrl) {
			NSLog(@"No Alternate configured");
			self.serverReachable=NO;
		}
		NSLog(@"Reachability WWAN");
	}
}

-(void)checkForReachability
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
	reachability = [Reachability reachabilityForInternetConnection];
	[reachability startNotifier];
	[self handleNetworkChange:nil];
}


#pragma mark - initialize items

-(void)initArrayItems
{
	// UPDATE: from version 0.9
	NSURL*fullUrl=[NSURL URLWithString:[theBaseUrl stringByAppendingFormat:@"rest/items?type=json"]];
	[self.queue setDelegate:self];
	//NSLog(@"cargando %@",fullUrl);
	[self.queue doGetUrl:fullUrl withTag:0];
}
#pragma mark - initialize groups

-(void)initArrayGroups:(NSString*)group
{
	if (itemsLoaded)
	{
		// UPDATE: from version 0.9
		NSURL*fullUrl=[NSURL URLWithString:[theBaseUrl stringByAppendingFormat:@"rest/items/%@?type=json",group]];
		[self.queue setDelegate:self];
		[self.queue doGetUrl:fullUrl withTag:1];
	}
    else
    {
        [self initArrayItems];
    }
}

#pragma mark - initialize widgets

-(void)initSitemap
{

	if (itemsLoaded && groupsLoaded)
	{
		NSLog(@"Sitemap requested");
		// UPDATE: from version 0.9
		NSURL*fullUrl=[NSURL URLWithString:[theBaseUrl stringByAppendingFormat:@"rest/sitemaps/%@?type=json",theMap]];
		[self.queue setDelegate:self];
		[self.queue doGetUrl:fullUrl withTag:2];
	}
    else
    {
        [self initArrayItems];
    }
}

#pragma mark - Request sitemaps for ip
-(void)requestSitemaps:(NSString*)fromServer
{
	NSURL*fullUrl=[NSURL URLWithString:
				   [fromServer
					stringByAppendingFormat:@"rest/sitemaps?type=json"]];
	[self.queue setDelegate:self];
	[self.queue doGetUrl:fullUrl withTag:10];
}

#pragma mark - convenience method to get an item by its name

-(openhabItem*)getItembyName:(NSString*)name
{
	for (openhabItem*temp in arrayItems) {
		if ([temp.name isEqualToString:name]) {
			return temp;
		}
	}
	return nil;
}

#pragma mark - change value of item

-(void)changeValueofItem:(openhabItem*)item toValue:(NSString*)value
{
	if (self.sitemapLoaded)
	{
		NSURL*fullUrl=[NSURL URLWithString:item.link];
		[self.queue setDelegate:self];
		[self.queue doPostUrl:fullUrl withValue:value withTag:3];
	}
}

#pragma mark - refresh

-(void)refreshItems
{
	if (self.itemsLoaded && self.groupsLoaded)
	{
		self.refreshing=YES;
		// UPDATE: from version 0.9
		NSURL*fullUrl=[NSURL URLWithString:[theBaseUrl stringByAppendingFormat:@"rest/items?type=json"]];
		[self.queue setDelegate:self];
		[self.queue doGetUrl:fullUrl withTag:4];
	}
}
-(void)refreshSitemap
{
	if (self.sitemapLoaded)
	{
		self.refreshing=YES;
		// UPDATE: from version 0.9
		NSURL*fullUrl=[NSURL URLWithString:[theBaseUrl stringByAppendingFormat:@"rest/sitemaps/%@?type=json",theMap]];
		[self.queue setDelegate:self];
		[self.queue doGetUrl:fullUrl withTag:5];
	}
}

//v1.2 Long poll page
-(void)longPollSitemap:(NSString*)page
{
	if (self.sitemapLoaded && page)
	{
		self.longPolling=YES;
		NSURL*fullUrl=[NSURL URLWithString:[theBaseUrl stringByAppendingFormat:@"rest/sitemaps/%@/%@",theMap,page]];
		[self.queue setDelegate:self];
		currentPage=page;
		currentlyPolling=[self.queue doGetLongPollUrl:fullUrl withTag:8];
	}
}

-(void)longPollCurrent
{
	[self longPollSitemap:self.currentPage];
}
-(void)refreshPage:(NSString*)page
{
	if (self.sitemapLoaded && page && !refreshing)
	{
		self.refreshing=YES;
		NSURL*fullUrl=[NSURL URLWithString:[theBaseUrl stringByAppendingFormat:@"rest/sitemaps/%@/%@",theMap,page]];
		[self.queue setDelegate:self];
		currentlyRefreshing=[self.queue doGetUrlWithOperation:fullUrl withTag:9];
	}
}

-(void)cancelPolling
{
	NSLog(@"Cancelling long-poll %i",currentlyPolling);
	self.longPolling=NO;
	[self.queue cancelRequest:currentlyPolling];
}

-(void)cancelRefresh
{
	NSLog(@"Cancelling refresh %i",currentlyRefreshing);
	self.refreshing=NO;
	[self.queue cancelRequest:currentlyRefreshing];
}

#pragma mark - get icons and images

// v1.2 new with dictionary

-(openhabImage*)getOpenHABImageinDictionary:(NSString*)name
{
	return [imagesDictionary objectForKey:name];
}


// v1.2 New version using dictionary

-(BOOL)getNameinImageinDictionary:(NSString*)name
{
	if ([imagesDictionary objectForKey:name])
		return YES;
	else
		return NO;
}



-(void)getImage:(NSString*)theImageName
{
	// If name is not there, put it there
	
	if (![self getNameinImageinDictionary:theImageName])
	{
		openhabImage*img=[[openhabImage alloc] initWithName:theImageName];
		[imagesDictionary setObject:img forKey:theImageName];
		// Ask for the image to the server
		NSURL*fullUrl=[NSURL URLWithString:[theBaseUrl stringByAppendingFormat:@"images/%@.png",theImageName]];
		[self.queue setDelegate:self];
		[self.queue doGetUrl:fullUrl withTag:6];

	}
	else
	{
		// The image's name  is in the array
		openhabImage*theImage=[self getOpenHABImageinDictionary:theImageName];
		
		// If it is already downloaded, update
		if (theImage.image!=nil)
		{
			//NSLog(@"Got image %@, do not download!",theImageName);
			[self updateArrayAndCopyImages:theImage andWidgets:sitemap];
			[delegate imagesRefreshed];
		}
	}	
}


-(void)getImageWithURL:(NSString *)theImageName
{
	// If name is not there, put it there
	
	if (![self getNameinImageinDictionary:theImageName])
	{
        openhabImage*img=[[openhabImage alloc] initWithName:theImageName];
		[imagesDictionary setObject:img forKey:theImageName];
		// Ask for the image to the server
		NSURL*fullUrl=[NSURL URLWithString:theImageName];
		[self.queue setDelegate:self];
		[self.queue doGetUrl:fullUrl withTag:7];
		
	}
	else
	{
		// The image's name  is in the array
		openhabImage*theImage=[self getOpenHABImageinDictionary:theImageName];
		
		// If it is already downloaded, update
		if (theImage.image!=nil)
		{
			NSLog(@"Got image %@, do not download!",theImageName);
			[self updateArrayAndCopyImages:theImage andWidgets:sitemap];
			[delegate imagesRefreshed];
		}
	}	
}

#pragma mark - process responses

-(void)initArrayItemsResponse:(NSData*)data
{
	NSError*error;
	id JSONdata=[NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (error)
	{
		//NSLog(@"ERROR: error parsing JSON %@ with data:%@",error,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]); 
		[delegate JSONparseError:@"items" withError:error];
	}
	else
	{
		// We get de value of the item entry in the JSON
		NSDictionary*dict=(NSDictionary*)JSONdata;
		NSArray*itemsList=(NSArray*)[dict objectForKey:@"item"];
		for (NSDictionary*dictionaryItem in itemsList) {
			openhabItem*item = [[openhabItem alloc]initWithDictionary:dictionaryItem] ;
			[self.arrayItems addObject:item];
		}
		//NSLog(@"array de items %@",arrayItems);
		// items Loaded, now the groups
		
		self.itemsLoaded=YES;
        [self.delegate itemsLoaded];
		for (openhabItem*item in arrayItems)
		{
				if([item.type isEqualToString:@"GroupItem"])
					[self initArrayGroups:item.name];
		}
	}
}



-(void)initArrayGroupsResponse:(NSData*)data
{
	NSError*error;
	id JSONdata=[NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (error)
	{
		NSString*corrupted=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSLog(@"ERROR: error parsing JSON %@ as a string \n%@",error,corrupted); 
		[delegate JSONparseError:@"groups" withError:error];
	}
	else
	{
		NSDictionary*dict=(NSDictionary*)JSONdata;
		NSString*group=(NSString*)[dict objectForKey:@"name"];
		id members=[dict objectForKey:@"members"];
		NSArray*itemsInGroup;
		
		if ([members isKindOfClass:[NSDictionary class]])
		{
			itemsInGroup=[NSArray arrayWithObject:members];
		}
		else
		{
			itemsInGroup=(NSArray*)members;
		}
		// Get the group item
		openhabItem*theGroup;
		for (openhabItem*temp in arrayItems) {
			if ([temp.name isEqualToString:group])
				theGroup=temp;
		}
		// Assign to members. BEWARE!! WE ONLY ASSIGN DIRECT GROUPS, NOT INHERITED!
		
		for (NSDictionary*itemDict in itemsInGroup) {
			for (openhabItem*temp in arrayItems) {
				if ([temp.name isEqualToString:[itemDict objectForKey:@"name"]]) {
					[temp.groups addObject:theGroup];
					//NSLog(@"Item: %@ group %@",temp.name, temp.groups);
				}
			}
		}
	}
}

#pragma mark - init Sitemap response

// Used to validate image urls
- (BOOL) validateUrl: (NSString *) url {
	NSURL *candidateURL = [NSURL URLWithString:url];
	// WARNING > "test" is an URL according to RFCs, being just a path
	// so you still should check scheme and all other NSURL attributes you need
	if (candidateURL && candidateURL.scheme && candidateURL.host) {
		// candidate is a well-formed url with:
		//  - a scheme (like http://)
		//  - a host (like stackoverflow.com)
		return YES;
	}
	else
		return NO;
}

// v1.2 modified, now we have an update bool, so we update or replace items in widgets
-(openhabWidget*)buildWidgetTree:(NSDictionary*)w update:(BOOL)shouldUpdateItems
{
	// initialize widget
	
	openhabWidget*theWidget=[[openhabWidget alloc]initWithDictionary:w];
	
	openhabItem*itemInWidget=[[openhabItem alloc]initWithDictionary:[w objectForKey:@"item"]];
	
	// v1.2 modified, should UPDATE widget sometimes
	theWidget.item=itemInWidget;
	if (itemInWidget!=nil && !shouldUpdateItems)
	{
		for (openhabItem*temp in arrayItems) {
			if ([temp.name isEqualToString:itemInWidget.name])
				theWidget.item=temp;
		}
	}
    
	// Check if there are more widgets 	
	id hasWidget=[w objectForKey:@"widget"];
	if (hasWidget)
	{
		if ([[w objectForKey:@"widget"] isKindOfClass:[NSDictionary class]])
		{
			// Just one sibling
			[theWidget.widgets addObject:[self buildWidgetTree:[w objectForKey:@"widget"] update:shouldUpdateItems]];
		}
		else
		{
			for (NSDictionary*sibling in [w objectForKey:@"widget"]) {
			[theWidget.widgets addObject:[self buildWidgetTree:sibling update:shouldUpdateItems]];
			}
		}
	}

	
	// Check if there ar more widgets in LinkedPage
	hasWidget=[[w objectForKey:@"linkedPage"] objectForKey:@"widget"];
	if (hasWidget)
	{
		if ([hasWidget isKindOfClass:[NSDictionary class]])
		{
			// Just one sibling
			[theWidget.widgets addObject:[self buildWidgetTree:hasWidget update:shouldUpdateItems]];
		}
		else
		{
			for (NSDictionary*sibling in [[w objectForKey:@"linkedPage"]objectForKey:@"widget"]) {
			[theWidget.widgets addObject:[self buildWidgetTree:sibling update:shouldUpdateItems]];
		}
		}
	}
	// UPDATE: Check for mappings
	
	hasWidget=[w objectForKey:@"mapping"];
	if (hasWidget)
	{
		openhabMapping*theMapping;
		if ([hasWidget isKindOfClass:[NSDictionary class]])
		{
			// Just one mapping
			theMapping=[[openhabMapping alloc] initWithDictionary:hasWidget];
			[theWidget.mappings setObject:theMapping forKey:theMapping.command];
		}
		else {
			
			for (NSDictionary*children in [w objectForKey:@"mapping"]) {
				theMapping=[[openhabMapping alloc] initWithDictionary:children];
				[theWidget.mappings setObject:theMapping forKey:theMapping.command];
			}
		}
	}
	// UPDATE: Check for url
	
	if ([theWidget widgetType]==7 || [theWidget widgetType]==10 ) {
        
        // CHANGE v1.1: check validity of url
        
		theWidget.imageURL=[w objectForKey:@"url"];
        if (![self validateUrl:theWidget.imageURL])
        {
            theWidget.imageURL=[theBaseUrl stringByAppendingFormat:@"%@",theWidget.imageURL];
        }
		
		// v1.2 get refresh time
		NSString*theString=[w objectForKey:@"refresh"];
		theWidget.refresh=[theString integerValue];
	}
	
	// v1.2 update: check for time interval at sliders
	if ([theWidget widgetType]==3) {
                
		theWidget.sendFrequency=[[w objectForKey:@"sendFrequency"] floatValue];
		if (!theWidget.sendFrequency)
		{
			theWidget.sendFrequency=0.5;
		}
	}
	// v1.2 update: Setpoint widget
	if ([theWidget widgetType]==11) {
		
		//NSLog(@"Values %@,%@,%@",[w objectForKey:@"minValue"],[w objectForKey:@"maxValue"],[w objectForKey:@"step"]);
		theWidget.minValue=[[w objectForKey:@"minValue"] floatValue];
		if (!theWidget.minValue)
		{
			theWidget.minValue=0;
		}
		theWidget.maxValue=[[w objectForKey:@"maxValue"] floatValue];
		if (!theWidget.maxValue)
		{
			theWidget.maxValue=0;
		}
		theWidget.step=[[w objectForKey:@"step"] floatValue];
		if (!theWidget.step)
		{
			theWidget.step=0;
		}
		//NSLog(@"Values %f,%f,%f",theWidget.minValue,theWidget.maxValue,theWidget.step);
	}
	// v1.2 update: Webview widget
	if ([theWidget widgetType]==12) {
		//NSLog(@"Height %@, URL: %@",[w objectForKey:@"height"],[w objectForKey:@"url"]);
		NSString*theString=[w objectForKey:@"height"];
		theWidget.height=[theString integerValue];
		theWidget.theWidgetUrl=[NSURL URLWithString:[w objectForKey:@"url"]];
	}
	// v1.2 update: Video widget
	if ([theWidget widgetType]==14) {
		theWidget.theWidgetUrl=[NSURL URLWithString:[w objectForKey:@"url"]];
	}
	
	// v1.2 update: Charting widget: build the url
	if ([theWidget widgetType]==16) {
		NSString*theString=[w objectForKey:@"refresh"];
		theWidget.refresh=[theString integerValue];
		[theWidget buildChartingURLString:self.theBaseUrl];
	}
	// v1.2 Save the widget in dictionary
	
	if (theWidget.linkedPage && !shouldUpdateItems)
	{
		//NSLog(@"adding page %@. Widget: %@",theWidget.linkedPage,theWidget);
		[self.pagesDictionary setObject:theWidget forKey:theWidget.linkedPage];
	}
	
	return theWidget;
}


-(void)initSitemapResponse:(NSData*)data
{
	NSError*error;
	id JSONdata=[NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (error)
	{
		NSLog(@"ERROR: error parsing JSON, the parser said :%@\n",error); 
		[delegate JSONparseError:@"sitemap" withError:error];
	}
	else
	{
		/*Structure of sitemap is:
		 
		 <sitemap>
			<name>sml2010</name>
			<link>...</link>
			<homepage>
			<id>sml2010</id>
			<link>.... </link>
			<widget>...</widget>
			<widget>...</widget>
			<widget>...</widget>
			<widget>...</widget>
			</homepage>
		 </sitemap>
		 
		 Then, each widget may contain a linkedPage*/
		

		NSDictionary*dict=(NSDictionary*)JSONdata;
		NSDictionary*homepage=(NSDictionary*)[dict objectForKey:@"homepage"];
		
		self.sitemapName=[homepage objectForKey:@"title"];
		// Check if more than one widget or just one
		if ([[homepage objectForKey:@"widget"] isKindOfClass:[NSDictionary class]])
			[self.sitemap addObject:[self buildWidgetTree:[homepage objectForKey:@"widget"] update:NO]];
		else for (NSDictionary*w in [homepage objectForKey:@"widget"]) {
			[self.sitemap addObject:[self buildWidgetTree:w update:NO]];
		}		// Build each branch of the tree and add to the sitemap

		self.sitemapLoaded=YES;
        [self.delegate sitemapLoaded];
	}
}

#pragma mark - request sitemap response
-(void)requestSitemapResponse:(commLibrary*)com
{
	NSError*error;
	NSMutableArray*response=nil;
	id JSONdata=[NSJSONSerialization JSONObjectWithData:com.responseData options:0 error:&error];
	if (error)
	{
		NSLog(@"ERROR: error parsing JSON, the parser said :%@\n",error);
		[delegate JSONparseError:@"sitemap" withError:error];
	}
	else
	{
		/*Structure of sitemap is:
		 
		{"sitemap":
			{
				"name":"demo",
				"link":"http://demo.openhab.org:8080/rest/sitemaps/demo",
				"homepage":{"link":"http://demo.openhab.org:8080/rest/sitemaps/demo/demo"}
			}
		 }
		 
		 or
		 
		 {"sitemap":
			[	{
					"name":"demo",
					"link":"http://demo.openhab.org:8080/rest/sitemaps/demo",
					"homepage":{"link":"http://demo.openhab.org:8080/rest/sitemaps/demo/demo"}
				},
				{
					"name":"demo",
					"link":"http://demo.openhab.org:8080/rest/sitemaps/demo",
					"homepage":{"link":"http://demo.openhab.org:8080/rest/sitemaps/demo/demo"}
				},....
		 }
		 
		 */
		NSDictionary*dict=(NSDictionary*)JSONdata; // get the data
		id sitemaps=[dict objectForKey:@"sitemap"];
		response=[NSMutableArray arrayWithCapacity:0];
		
		
		if ([sitemaps isKindOfClass:[NSDictionary class]])
		{
			[response addObject:[sitemaps objectForKey:@"name"]];
		}
		else
		{
			for (NSDictionary*temp in sitemaps) {
				[response addObject:[temp objectForKey:@"name"]];
			}
		}
	}
	[delegate requestSitemapsResponse:response];
}

#pragma mark - convenience method to search&update item and sitemap

-(void)searchAndRefreshItem:(openhabItem*)theItem
{
	for (openhabItem*temp in arrayItems) {
		if ([temp.name isEqualToString:theItem.name])
		{
			temp.state=theItem.state;
		}
	}
}

-(void)searchAndRefreshWidget:(openhabWidget*)theWidgets theBranch:(openhabWidget*)theBranch
{
	//NSLog(@"Refreshed %@:%@ with %@:%@",theBranch.label,theBranch.data,theWidgets.label,theBranch.data);
    
	theBranch.label=theWidgets.label;
	
    
    // There is a problem here, we MUST ask for the image later because if not, the image is NOT updated
	
	BOOL shouldUpdateImage=NO;
	if (![theBranch.icon isEqualToString:theWidgets.icon]) {
		shouldUpdateImage=YES;
	}
        
    theBranch.icon=theWidgets.icon;
	theBranch.data=theWidgets.data;
	
	if (theWidgets.item)
	{
		theBranch.item.state=theWidgets.item.state;
	}
	
	if (shouldUpdateImage)
		[self getImage:theWidgets.icon];
	for (int i=0; i<[theWidgets.widgets count]; i++) {
		[self searchAndRefreshWidget:(openhabWidget*)[theWidgets.widgets objectAtIndex:i] theBranch:(openhabWidget*)[theBranch.widgets objectAtIndex:i]];
	}
}

// V1.2 Refresh returned widgets from long-polling
-(void)searchAndRefreshWidgetLongPolling:(NSArray*)received theBranch:(NSArray*)original
{
    
	// v1.2 update all widgets in the widgets array
	for (int i=0;i<[received count];i++) {

		openhabWidget* originalWidget=[original objectAtIndex:i];
		openhabWidget* receivedWidget=[received objectAtIndex:i];
		
		// There is a problem here, we MUST ask for the image later because if not, the image is NOT updated
		
		BOOL shouldUpdateImage=NO;
		if (![receivedWidget.icon isEqualToString:originalWidget.icon]) {
			shouldUpdateImage=YES;
		}
		// v1.2 update the data
		originalWidget.icon=receivedWidget.icon;
		originalWidget.data=receivedWidget.data;
		
		// v1.2 update the item
		if (receivedWidget.item)
		{
			originalWidget.item.state=receivedWidget.item.state;
		}
		// v1.2 get the image if needed
		if (shouldUpdateImage)
			[self getImage:receivedWidget.icon];

		// v1.2 update the widgets in the received widget.
		[self searchAndRefreshWidgetLongPolling:receivedWidget.widgets theBranch:originalWidget.widgets];
	}
}

-(void)updateArrayAndCopyImages:(openhabImage*)image andWidgets:(NSArray*)theWidgets
{
	// Save the image to the array
	openhabImage*theImage=[self getOpenHABImageinDictionary:image.name];
	if (theImage.image == nil)
		theImage.image =image.image;
	
	// get the image
	
	for (openhabWidget*w in theWidgets) {
        if ([w.icon isEqualToString:image.name]) {
            w.iconImage=theImage.image;
			[delegate imagesRefreshed];
        }
		// Updated: IMAGES LOADED HERE
		if ([w.imageURL isEqualToString:image.name]) {
            w.Image=theImage.image;
			[delegate imagesRefreshed];
		}
		if ([w.widgets count]>0)
		{
			[self updateArrayAndCopyImages:theImage andWidgets:w.widgets];
		}
    }
    
}

#pragma mark - change value of item response

-(void)changeValueofItemResponse:(commLibrary*)request
{
    // For example: http://localhost:8080/rest/items/Light_Outdoor_Terrace/state
    // Copy the name of the item
    NSArray *temp=[[NSString stringWithFormat:@"%@",request.theUrl] componentsSeparatedByString:@"/"];
    NSString *theItemName=[[temp objectAtIndex:5]copy];
    openhabItem*theItem=nil;
    for (openhabItem* itemTemp in self.arrayItems) {
        if ([itemTemp.name isEqualToString:theItemName])
        {
            theItem=itemTemp;
			break;
        }
    }
	
    [delegate valueOfItemChangeRequested:theItem];
}

#pragma mark - refresh responses

-(void)refreshItemsResponse:(NSData*)data
{
	NSLog(@"Refreshing items");
	NSError*error;
	id JSONdata=[NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (error)
	{
		NSLog(@"ERROR: error parsing JSON %@",error);
		[delegate JSONparseError:@"refreshitems" withError:error];
	}
	else
	{
		// We get de value of the item entry in the JSON
		NSDictionary*dict=(NSDictionary*)JSONdata;
		NSArray*itemsList=(NSArray*)[dict objectForKey:@"item"];
		for (NSDictionary*dictionaryItem in itemsList) {
			openhabItem*item = [[openhabItem alloc]initWithDictionary:dictionaryItem] ;
			[self searchAndRefreshItem:item];
		}
	}
	self.refreshing=NO;
    [delegate itemsRefreshed];
}

-(void)refreshSitemapResponse:(NSData*)data
{
	NSError*error;
	id JSONdata=[NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (error)
	{
		NSString*corrupted=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSLog(@"ERROR: error parsing JSON %@ as a string \n%@",error,corrupted); 
		[delegate JSONparseError:@"refreshsitemap" withError:error];
	}
	else
	{
		NSDictionary*dict=(NSDictionary*)JSONdata;
		NSDictionary*homepage=(NSDictionary*)[dict objectForKey:@"homepage"];
		//v1.2 long-poll needs
		if (!homepage)
			homepage=dict;
		// Check if more than one widget or just one
		NSMutableArray*theWidgets=[[NSMutableArray alloc]initWithCapacity:0];
		if ([[homepage objectForKey:@"widget"] isKindOfClass:[NSDictionary class]]){
			[theWidgets addObject:[self buildWidgetTree:[homepage objectForKey:@"widget"] update:YES]];
		}
		else for (NSDictionary*w in [homepage objectForKey:@"widget"]) {
			[theWidgets addObject:[self buildWidgetTree:w update:YES]];
		}

		for (int i=0; i<[sitemap count]; i++) {
			[self searchAndRefreshWidget:(openhabWidget*)[theWidgets objectAtIndex:i] theBranch:(openhabWidget*)[sitemap objectAtIndex:i]];
		}
	}
	self.refreshing=NO;
    [delegate sitemapRefreshed];
}

// v1.2 Get the widget of the page
-(openhabWidget*)getWidgetofPage:(NSString*)thePage
{
	//NSLog(@"Widget %@",[self.pagesDictionary objectForKey:thePage]);
	return [self.pagesDictionary objectForKey:thePage];
}
// v1.2 Refresh the page

-(void)refreshLongPollPage:(commLibrary*)com
{
	NSData*data=com.responseData;
	NSString*page=[com.theUrl.pathComponents lastObject];
	NSLog(@"Refreshing page %@",page);
	NSError*error;
	id JSONdata;
	if (data)
		JSONdata=[NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (error)
	{
		NSString*corrupted=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSLog(@"ERROR: error parsing JSON longpoll response: %@ as a string \n%@",error,corrupted);
		[delegate JSONparseError:@"refreshsitemap" withError:error];
	}
	else if (data)
	{
		NSDictionary*dict=(NSDictionary*)JSONdata;
		NSDictionary*homepage=(NSDictionary*)[dict objectForKey:@"homepage"];
		//v1.2 long-poll needs
		if (!homepage)
			homepage=dict;
		// Check if more than one widget or just one
		NSMutableArray*theWidgets=[[NSMutableArray alloc]initWithCapacity:0];
		if ([[homepage objectForKey:@"widget"] isKindOfClass:[NSDictionary class]]){
			[theWidgets addObject:[self buildWidgetTree:[homepage objectForKey:@"widget"] update:YES]];
		}
		else for (NSDictionary*w in [homepage objectForKey:@"widget"]) {
			[theWidgets addObject:[self buildWidgetTree:w update:YES]];
		}
		openhabWidget*thePageWidget=nil;
		
		// v1.2 If Main page get it, if not, go get it
		if ([page isEqualToString:self.theMap])
		{
			thePageWidget=[openhabWidget new];
			thePageWidget.widgets=self.sitemap;
		}
		else
		{
			thePageWidget=[self getWidgetofPage:page];
		}
		// v1.2 update the page widgets
		if (!thePageWidget)
		{
			NSLog(@"ERROR: Not found page %@ at sitemap",page);
		}
		else
		{
			// v1.2 update
			[self searchAndRefreshWidgetLongPolling:theWidgets theBranch:thePageWidget.widgets];
		}
	}
}

-(void)getImageResponse:(commLibrary*)com
{
    // Copy the name of the image without the .png
    NSArray* temp=[[NSString stringWithFormat:@"%@",com.theUrl] componentsSeparatedByString:@"/"];
    NSString*theImageName=[[temp lastObject]copy];
    temp=[theImageName componentsSeparatedByString:@"."];
	theImageName=[[temp objectAtIndex:0]copy];
    
    // Update the whole tree

	UIImage*theImage=[UIImage imageWithData:com.responseData];
	openhabImage*image=[[openhabImage alloc] initWithImage:theImage andName:theImageName];
    [self updateArrayAndCopyImages:image andWidgets:sitemap];
    //[delegate imagesRefreshed];
}

-(void)getImageResponseURL:(commLibrary*)com
{
    // Copy the name of the image
	NSString* theImageName=[NSString stringWithFormat:@"%@",com.theUrl];
    
    // Update the whole tree
	
	UIImage*theImage=[UIImage imageWithData:com.responseData];
	openhabImage*image=[[openhabImage alloc] initWithImage:theImage andName:theImageName];
    [self updateArrayAndCopyImages:image andWidgets:sitemap];
    //[delegate imagesRefreshed];
}

//v1.2 Should delete image urls to let charts refresh
-(void)deleteImage:(NSString*)theImageName
{
	[imagesDictionary removeObjectForKey:theImageName];
}

//v1.2 tag 8 longpoll url

-(void)longpollUrlReceivedData:(commLibrary*)com
{
	//v1.2 Long-polling if not yet polling
	self.longPolling=NO;
	// Try to get updates no more than once per second
	[self refreshLongPollPage:com];
	[delegate longpollDidReceiveData:com];
}

//v1.2 tag 9 refresh page

-(void)PageRefreshReceivedData:(commLibrary*)com
{
	//v1.2 refresh finished
	self.refreshing=NO;
	// Try to get updates no more than once per second
	[self refreshLongPollPage:com];
	[delegate pageRefreshed:com];
}

#pragma mark - protocol requestQueue

-(void)requestinQueueFinished:(commLibrary*)com
{
	//Check who replies
	
	switch (com.tag) {
		case 0:
			[self initArrayItemsResponse:com.responseData];
			break;
		case 1:
			[self initArrayGroupsResponse:com.responseData];
			break;
		case 2:
			[self initSitemapResponse:com.responseData];
			break;
		case 3:
            [self changeValueofItemResponse:com];
			break;
        case 4:
			[self refreshItemsResponse:com.responseData];
			break;
		case 5:
			[self refreshSitemapResponse:com.responseData];
			break;
        case 6:
            [self getImageResponse:com];
            break;
		case 7:
            [self getImageResponseURL:com];
            break;
		case 8: // V1.2 long-polling
			[self performSelectorOnMainThread:@selector(longpollUrlReceivedData:) withObject:com waitUntilDone:NO];
			break;
		case 9:// V1.2 refresh page
			[self performSelectorOnMainThread:@selector(PageRefreshReceivedData:) withObject:com waitUntilDone:NO];
			break;
		case 10: // v1.2 request sitemaps
			[self requestSitemapResponse:com];
			break;
		case 11: // v1.2 main address reacheable
			NSLog(@"Main address reacheable, do nothing");
			self.serverReachable=YES;
			break;
		case 12: // v1.2 alternate address reacheable
			NSLog(@"Alternate address reacheable, do nothing");
			self.serverReachable=YES;
			break;
		default:
			NSLog(@"ERROR: Unknown request response %@",com);
			[delegate requestFailed:com withError:nil];
			break;
	}
}
-(void)requestinQueueFinishedwithError:(commLibrary*)com error:(NSError*)error
{
	if (com.tag==11)
	{
		NSDictionary*alts=(NSDictionary*)[configuration readPlist:@"alternateURLs"];
		theMap=(NSString*)[configuration readPlist:@"alternateMap"];
		self.theBaseUrl=[alts objectForKey:(NSString*)[configuration readPlist:@"BASE_URL"]];
//		if (self.theBaseUrl)
//			[self alternateIsReacheable]; // v1.2 check if alternate
//		else
			[delegate requestFailed:com withError:error];
	}
	else
	{
		NSLog(@"ERROR: request %@ finished with error: %@",com,error);
		[delegate requestFailed:com withError:error];
	}
}
-(void)allrequestsinQueueFinished
{

	if (!self.itemsLoaded)
	{
		NSLog(@"\n-----Items request finished-----\n\n");		
	}
	else if	(self.itemsLoaded && !self.groupsLoaded)
	{
		NSLog(@"\n-----Groups request finished-----\n\n");
		self.groupsLoaded=YES;
        [self.delegate groupsLoaded];
		// LOAD THE SITEMAP
		[self initSitemap];
	}
	else if (self.groupsLoaded && !self.sitemapLoaded)
	{
		NSLog(@"\n-----Sitemap request finished-----\n\n");	
	}
	else
	{
		NSLog(@"\n-----All requests finished----- petitions: %i Downloaded size: %i bytes\n\n\n",[queue Allpetitions],[queue sizeDownloaded]);
	}
    [delegate allRequestsFinished];
}
@end
