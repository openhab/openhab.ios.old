//
//  requestQueue.h
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

#import "commLibrary.h"

@protocol requestQueueprotocol;

@interface requestQueue : NSObject <commLibraryprotocol>
{
	NSMutableArray*queue;
	NSMutableArray*longPollingQueue;
	NSInteger operations;
	NSInteger maxOperations;
	NSInteger Allpetitions;
	NSInteger sizeDownloaded;
	NSCondition* theLock;
	id <requestQueueprotocol>delegate;
	
}
@property (atomic,strong)NSMutableArray*queue;
@property (atomic,strong)NSMutableArray*longPollingQueue;
@property (atomic)NSInteger operations;
@property (atomic)NSInteger maxOperations;
@property (atomic)NSInteger Allpetitions;
@property (atomic)NSInteger sizeDownloaded;
@property (atomic)NSInteger SerialNumber;
@property (atomic,strong) NSCondition*theLock;
@property (nonatomic,strong) id <requestQueueprotocol>delegate;


-(void)doGetUrl:(NSURL*)url withTag:(NSInteger)tag;
-(NSInteger)doGetUrlWithOperation:(NSURL*)url withTag:(NSInteger)tag;
// v1.2 Long-polling urls
-(int)doGetLongPollUrl:(NSURL*)url withTag:(NSInteger)tag;
-(void)doPostUrl:(NSURL*)url withValue:(NSString*)value withTag:(NSInteger)tag;
-(void)cancelRequest:(NSInteger)requestSerialNumber;
-(void)cancelRequests;
-(int)operationsInQueue;

@end

@protocol requestQueueprotocol
-(void)requestinQueueFinished:(commLibrary*)com;
-(void)requestinQueueFinishedwithError:(commLibrary*)com error:(NSError*)error;
-(void)allrequestsinQueueFinished;
@end