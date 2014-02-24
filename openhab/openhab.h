//
//  openhab.h
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

#import "requestQueue.h"
#import "openhabItem.h"
#import "openhabWidget.h"
#import "openhabImage.h"
#import "Reachability.h"

@protocol openHABprotocol;

@interface openhab : NSObject <requestQueueprotocol>
{
	NSString*theBaseUrl;
	NSString*theMap;
	NSMutableArray*arrayItems;
	NSMutableArray*sitemap;
	NSString*sitemapName;
	NSMutableDictionary*pagesDictionary,*imagesDictionary;
	requestQueue* queue;
	BOOL itemsLoaded,groupsLoaded,sitemapLoaded,refreshing,serverReachable;
	NSInteger currentlyPolling,currentlyRefreshing;
	NSString*currentPage;
	Reachability* reachability;
	id<openHABprotocol> delegate;
}
@property (nonatomic,strong) NSString*theBaseUrl;
@property (nonatomic,strong) NSString*theMap;
@property (nonatomic,strong) NSString*sitemapName;
@property (nonatomic,strong) NSMutableArray*arrayItems;
@property (nonatomic,strong) requestQueue*queue;
@property (nonatomic,strong) NSMutableArray*sitemap;
@property (nonatomic,strong) NSMutableDictionary*pagesDictionary,*imagesDictionary;
@property (atomic) BOOL itemsLoaded,groupsLoaded,refreshing,sitemapLoaded,longPolling,serverReachable;
@property (atomic) NSInteger currentlyPolling,currentlyRefreshing;
@property (nonatomic,strong) NSString*currentPage;
@property (nonatomic,strong) id<openHABprotocol> delegate;


// Public Methods

+ (openhab*)sharedOpenHAB;
+ (openhab*)deleteSharedOpenHAB;
//-(void)addressIsReacheable;
-(void)initArrayItems;
-(void)initSitemap;
-(void)requestSitemaps:(NSString*)fromServer;// v1.2 get the sitemaps
-(openhabItem*)getItembyName:(NSString*)name;
-(void)changeValueofItem:(openhabItem*)item toValue:(NSString*)value;
-(void)refreshItems;
-(void)refreshSitemap;
-(void)refreshPage:(NSString*)page;
-(void)longPollSitemap:(NSString*)page;
-(void)cancelPolling;
-(void)longPollCurrent;
-(void)cancelRefresh;
-(void)getImage:(NSString*)theImageName;
-(void)getImageWithURL:(NSString*)theImageName;
// v1.2 delete image for charts
-(void)deleteImage:(NSString*)theImageName;
- (void)handleNetworkChange:(NSNotification *)notice;
@end

@protocol openHABprotocol
@optional
-(void)itemsLoaded;
-(void)groupsLoaded;
-(void)sitemapLoaded;
-(void)requestSitemapsResponse:(NSArray*)theSitemaps; //V1.2 return the sitemaps.
-(void)valueOfItemChangeRequested:(openhabItem*)theItem;
-(void)itemsRefreshed;
-(void)sitemapRefreshed;
-(void)imagesRefreshed;
-(void)pageRefreshed:(commLibrary*)page;
-(void)longpollDidReceiveData:(commLibrary*)request;
-(void)requestFailed:(commLibrary*)request withError:(NSError*)error;
-(void)JSONparseError:(NSString*)parsePhase withError:(NSError*)error;
-(void)allRequestsFinished;
@end
