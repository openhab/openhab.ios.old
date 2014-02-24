//
//  bonjourNetworkResolution.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 20/08/12.
//
//

#import <Foundation/Foundation.h>
@protocol bonjourResolver;

@interface bonjourNetworkResolution : NSObject <NSNetServiceDelegate>
{
    // Keeps track of services handled by this delegate
    NSMutableArray *services;
	NSMutableArray *addresses;
	id <bonjourResolver> delegate;
}
@property (strong,nonatomic) id <bonjourResolver> delegate;
// NSNetService delegate methods for publication
- (void)netServiceDidResolveAddress:(NSNetService *)netService;
- (void)netService:(NSNetService *)netService
	 didNotResolve:(NSDictionary *)errorDict;

// Other methods
- (BOOL)addressesComplete:(NSArray *)addresses
		   forServiceType:(NSString *)serviceType;
- (void)handleError:(NSNumber *)error withService:(NSNetService *)service;

@end

@protocol bonjourResolver
-(void)resolvedNetService:(NSArray*)addresses;
@end