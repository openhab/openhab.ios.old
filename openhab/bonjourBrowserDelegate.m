//
//  bonjourBrowserDelegate.m
//  openhab
//
//  Created by Pablo Romeu Guallart on 20/08/12.
//
//

#import "bonjourBrowserDelegate.h"

@implementation bonjourBrowserDelegate
@synthesize bonjourResolver,delegate;
- (id)init
{
    self = [super init];
    if (self) {
        services = [[NSMutableArray alloc] init];
		bonjourResolver=[bonjourNetworkResolution new];
		[bonjourResolver setDelegate:self];
        searching = NO;
    }
    return self;
}

// Sent when browsing begins
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
	NSLog(@"Started bonjour");
    searching = YES;
    [self updateUI];
}

// Sent when browsing stops
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    searching = NO;
    [self updateUI];
}

// Sent if browsing fails
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
			 didNotSearch:(NSDictionary *)errorDict
{
    searching = NO;
    [self handleError:[errorDict objectForKey:NSNetServicesErrorCode]];
}

// Sent when a service appears
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
		   didFindService:(NSNetService *)aNetService
			   moreComing:(BOOL)moreComing
{
	[aNetService setDelegate:bonjourResolver];
	[aNetService resolveWithTimeout:5.0];
    [services addObject:aNetService];
    if(!moreComing)
    {
        [self updateUI];
    }
}

// Sent when a service disappears
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
		 didRemoveService:(NSNetService *)aNetService
			   moreComing:(BOOL)moreComing
{
    [services removeObject:aNetService];
	
    if(!moreComing)
    {
        [self updateUI];
    }
}

// Error handling code
- (void)handleError:(NSNumber *)error
{
    NSLog(@"An error occurred. Error code = %d", [error intValue]);
    // Handle error here
}

// UI update code
- (void)updateUI
{
    if(searching)
    {
        // Update the user interface to indicate searching
        // Also update any UI that lists available services
		NSLog(@"UPDATE bonjour browsing: %@",services);
    }
    else
    {
        // Update the user interface to indicate not searching
		NSLog(@"UPDATE bonjour NoT browsing: %@",services);
    }
}

-(void)resolvedNetService:(NSArray*)addresses
{
	[self.delegate updateInterface:addresses];
}

@end
