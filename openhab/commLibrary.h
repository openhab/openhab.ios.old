//
//  commLibrary.h
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


@protocol commLibraryprotocol;
@interface commLibrary : NSObject <NSURLConnectionDelegate>
{
	NSURL* theUrl;
	NSURLConnection* TheConnection;
	NSMutableData*responseData;
	NSString* postValue;
	NSInteger timeout;
	NSInteger tag;
	NSInteger serial;
	// v1.2 Do not return anything if cancelled
	BOOL cancelled;
	__strong id <commLibraryprotocol>delegate;
}
@property (nonatomic,strong) NSMutableData*responseData;
@property (nonatomic,strong) NSURL *theUrl;
@property (nonatomic,strong) NSURLConnection *TheConnection;
@property (nonatomic,strong) NSString* postValue;
@property (nonatomic) 	NSInteger timeout;
@property (nonatomic) 	NSInteger tag;
@property (nonatomic)	NSInteger serial;
@property (nonatomic)	BOOL cancelled;
@property (nonatomic,strong) id<commLibraryprotocol>delegate;
@property (nonatomic) BOOL longpoll;

-(commLibrary*)init;
-(void)doGet:(NSURL*)url;
// v1.2 Long-polling
-(void)doGetLongPolling:(NSURL*)url;
-(void)doGetOperation:(NSURL*)url;
-(void)doPost:(NSURL *)url value:(NSString*)value;
@end

@protocol commLibraryprotocol
// v1.2 Long-polling
-(void)longPollingrequestFinished:(commLibrary*)com;
-(void)operationRequestFinished:(commLibrary*)com;
-(void)requestFinished:(commLibrary*)com;
-(void)requestFinishedWithErrors:(commLibrary*)com error:(NSError*)error;
@end