//
//  bonjourBrowserDelegate.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 20/08/12.
//
//

#import <Foundation/Foundation.h>
#import "bonjourNetworkResolution.h"

@protocol bonjourBrowser;

@interface bonjourBrowserDelegate : NSObject <NSNetServiceBrowserDelegate,bonjourResolver>
{
    // Keeps track of available services
    NSMutableArray *services;

    // Keeps track of search status
    BOOL searching;
	
	bonjourNetworkResolution *bonjourResolver;
	id <bonjourBrowser> delegate;
}
@property (strong,nonatomic)	id <bonjourBrowser> delegate;
@property (strong,nonatomic)	bonjourNetworkResolution *bonjourResolver;
// NSNetServiceBrowser delegate methods for service browsing
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser;
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser;
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
			 didNotSearch:(NSDictionary *)errorDict;
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
		   didFindService:(NSNetService *)aNetService
			   moreComing:(BOOL)moreComing;
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
		 didRemoveService:(NSNetService *)aNetService
			   moreComing:(BOOL)moreComing;

// Other methods
- (void)handleError:(NSNumber *)error;
- (void)updateUI;
@end

@protocol bonjourBrowser
- (void)updateInterface:(NSArray*)serverList;
@end
