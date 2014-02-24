//
//  requestQueue.m
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
#import "configuration.h"

@implementation requestQueue
@synthesize queue,longPollingQueue,operations,Allpetitions,sizeDownloaded,SerialNumber,maxOperations,delegate,theLock;

-(requestQueue*)init
{
	if (!self.queue)
		self.queue=[NSMutableArray new];
	if (!self.longPollingQueue)
		self.longPollingQueue=[NSMutableArray new];

	if (!self.theLock)
		self.theLock=[NSCondition new];
	operations=0;
	Allpetitions=0;
	sizeDownloaded=0;
	SerialNumber=0;
	maxOperations=[(NSNumber*)[configuration readPlist:@"maxConnections"] intValue];
	NSLog(@"Ops: %i",maxOperations);
	return self;
}

-(int)operationsInQueue
{
    return [self.queue count];
}
-(void)doGetUrl:(NSURL*)url withTag:(NSInteger)tag
{
	commLibrary*c=[commLibrary new];
	[c setDelegate:self];
	[c setTag:tag];
	[c setLongpoll:NO];
	if (tag==11 ||tag==12)
		[c setTimeout:5]; // address reachable timeout
	
	if (operations < maxOperations)
	{
		operations++;
		Allpetitions++;
		[c doGet:url];
	}
	else
	{
		// TOO MUCH CONCURRENT OPERATIONS, save te url and wait
		[c setTheUrl:url];
		[queue addObject:c];
	}
}

// v1.2 modified: poll urls WITH operationqueue
-(NSInteger)doGetUrlWithOperation:(NSURL*)url withTag:(NSInteger)tag
{
	commLibrary*c=[commLibrary new];
	[c setDelegate:self];
	[c setTag:tag];
	[c setLongpoll:NO];
	[c setTimeout:20];
	SerialNumber++;
	[c setSerial:SerialNumber];
	[queue addObject:c];
	[c doGetOperation:url];
	return SerialNumber;
}

// v1.2 modified: longpolling urls
-(NSInteger)doGetLongPollUrl:(NSURL *)url withTag:(NSInteger)tag
{
	commLibrary*c=[commLibrary new];
	[c setDelegate:self];
	[c setTag:tag];
	[c setLongpoll:YES];
	[c setTimeout:3600];
	SerialNumber++;
	[c setSerial:SerialNumber];
	[longPollingQueue addObject:c];
	[c doGetLongPolling:url];
	return SerialNumber;
}

// v1.2 cancell long poll
-(void)cancelRequest:(NSInteger)requestSerialNumber
{
	for (commLibrary*c in self.longPollingQueue) {
		if (c.serial==requestSerialNumber)
		{
			c.cancelled=YES;
			[longPollingQueue removeObject:c];
			[c.TheConnection cancel];
		}
	}
	for (commLibrary*c in self.queue) {
		if (c.serial==requestSerialNumber)
		{
			c.cancelled=YES;
			[queue removeObject:c];
			[c.TheConnection cancel];
		}
	}
}

// v1.2 cancell all requests
-(void)cancelRequests
{
	for (commLibrary*c in self.longPollingQueue) {
			c.cancelled=YES;
			[longPollingQueue removeObject:c];
			[c.TheConnection cancel];
	}
	for (commLibrary*c in self.queue) {
			c.cancelled=YES;
			[queue removeObject:c];
			[c.TheConnection cancel];
	}
}


-(void)doPostUrl:(NSURL*)url withValue:(NSString*)value withTag:(NSInteger)tag
{
	commLibrary*c=[commLibrary new];
	[c setDelegate:self];
	[c setTag:tag];
	
	if (operations < maxOperations)
	{
		operations++;
		Allpetitions++;
		[c doPost:url value:value];
	}
	else
	{
		// TOO MUCH CONCURRENT OPERATIONS, save te url, the put value and wait
		[c setTheUrl:url];
		[c setPostValue:value];
		[queue addObject:c];
	}
}


-(void)continueOperations
{
	// Do not enter if it is the last one
	
	// Get an object
	commLibrary*c=[self.queue objectAtIndex:0];
	operations++;
		
	if (c.postValue)
	{
		Allpetitions++;
		[c doPost:c.theUrl value:c.postValue];
	}
	else
	{
		Allpetitions++;
		[c doGet:c.theUrl];
	}
	
	[self.queue removeObject:c];
	
}

#pragma mark - delegate commLibrary


-(void)longPollingrequestFinished:(commLibrary*)com
{
	// Save the size
	
	sizeDownloaded+=com.responseData.length;
	// Delete from queue
	[longPollingQueue removeObject:com];
	// Tell the delegate that the requestFinished
	[self.delegate requestinQueueFinished:com];

}
-
(void)operationRequestFinished:(commLibrary *)com
{
	// Save the size
	
	sizeDownloaded+=com.responseData.length;
	// Delete from queue
	[queue removeObject:com];
	// Tell the delegate that the requestFinished
	[self.delegate requestinQueueFinished:com];
	
}


-(void)requestFinished:(commLibrary*)com
{
	//NSString*response=[[NSString alloc] initWithData:com.responseData encoding:NSUTF8StringEncoding];
	//NSLog(@"Llamado %@ con %@: \n\n %@\n-----",com.theUrl,com.theUrlRequest,response);
		
	// Acquire the lock
	[theLock lock];
	
	// Reduce operations
	operations--;
	// Wait for operations to finish
	while (operations>=maxOperations) {
		[theLock wait];
	}
	
	
	if ([self.queue count]>0)
		[self continueOperations];
	
	// Save the size
	
	sizeDownloaded+=com.responseData.length;
	
	// Tell the delegate that the requestFinished
	[self.delegate requestinQueueFinished:com];
	
	// If we are done with the queue, tell the delegate
	if ([self.queue count]+operations==0)
		[self.delegate allrequestsinQueueFinished];
	
	// We unlocked one, signal next
	[theLock signal];
	[theLock unlock];
}

-(void)requestFinishedWithErrors:(commLibrary*)com error:(NSError*)error
{
	NSLog(@"%@\n-----",error);
	
	// Acquire the lock
	[theLock lock];	
	// Reduce operations
	operations--;
	// Wait for operations to finish
	while (operations>=maxOperations) {
		[theLock wait];
	}
	if ([self.queue count]>0)
		[self continueOperations];
	
	// Save the size
	
	sizeDownloaded+=com.responseData.length;
	
	// Tell the delegate that the requestFinished
	
	// v1.2 Kai asked to be silent at timeouts
	if ([error code] != -1001)
		[self.delegate requestinQueueFinishedwithError:com error:error];
	
	// If we are done with the queue, tell the delegate
	if ([self.queue count]+operations==0)
		[self.delegate allrequestsinQueueFinished];
	
	// We unlocked one, signal next
	[theLock signal];
	[theLock unlock];		
}

@end
