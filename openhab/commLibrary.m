//
//  commLibrary.m
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
#import "PDKeychainBindings.h"

// v1.2 persist bad username
BOOL badUsernameAndPassword=NO;
NSURLAuthenticationChallenge * challengeGlobal;

@implementation commLibrary

@synthesize responseData,delegate,theUrl,TheConnection,timeout,postValue,tag,cancelled,serial;

-(commLibrary*)init
{	
	self.timeout=15;
	self.tag=0;
	self.serial=0;
	self.postValue=nil;
	self.cancelled=NO;
	return self;
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"url: %@,tag :%i, timeout: %i",theUrl,tag,timeout];
}

#pragma mark - connection functions

-(void)doGet:(NSURL *)url
{
	theUrl=url;
	NSURLRequest* UrlRequest=[NSURLRequest requestWithURL:url
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:timeout];
	// create the connection with the request
	// and start loading the data
	TheConnection=[[NSURLConnection alloc] initWithRequest:UrlRequest delegate:self];

	if (!TheConnection)
	{
		NSLog(@"ERROR: Could not create a connection");
		[delegate requestFinishedWithErrors:self error:nil];
	}
}


-(void)doPost:(NSURL *)url value:(NSString*)value
{
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
	[req setHTTPMethod:@"POST"];
	NSData *dataPayload = [value dataUsingEncoding:NSUTF8StringEncoding];
	[req setHTTPBody:dataPayload];
	[req setValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	self.theUrl=url;
	self.postValue=value;
	
	TheConnection=[[NSURLConnection alloc] initWithRequest:req delegate:self];
	
	if (!TheConnection)
	{
		NSLog(@"ERROR: Could not create a PUT connection");
		[delegate requestFinishedWithErrors:self error:nil];
	}	
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
	
	if ([response respondsToSelector:@selector(statusCode)])
	{
		int statusCode = [((NSHTTPURLResponse *)response) statusCode];
		if (statusCode >= 400 || statusCode== -1001)
		{
			[connection cancel];  // stop connecting; no more delegate messages
			
			// v1.2 Kai asked this to be silent

			
//			NSDictionary *errorInfo
//			= [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
//												  NSLocalizedString(@"Server returned status code %d",@"Server returned status code %d"),
//												  statusCode]
//										  forKey:NSLocalizedDescriptionKey];
			//NSError *statusError
			//= [NSError errorWithDomain:@"HTTP Error"
			//					  code:statusCode
			//				  userInfo:errorInfo];
			
			//[self connection:connection didFailWithError:statusError];
		}
	}

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (!responseData) {
		responseData=[[NSMutableData alloc]init];
	}
	[responseData appendData:data];
}
	
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"%@",[NSString stringWithFormat:@"ERROR: Connection failed: %@", [error description]]);

	if (!self.cancelled)
		[delegate requestFinishedWithErrors:self error:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

//	NSString*response=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//	NSLog(@"%@",response);
	
	if (self.longpoll) {
		[delegate longPollingrequestFinished:self];
	}
	else
	{
		[delegate requestFinished:self];
	}
}

/* v1.2 New! Auth challenges! */

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	NSLog(@"auth required");
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]||[protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic];
}

// V1.2 helper method to get string-cut base url

-(NSString*)baseUrlString:(NSURL*)theUrltostring
{
	NSString*theUrlString=[theUrltostring absoluteString];
	NSScanner*theScanner=[NSScanner scannerWithString:theUrlString];
	NSString*temp;
	NSString*final=@"";
	[theScanner scanUpToString:@"//" intoString:&temp];
	final=[final stringByAppendingString:temp];
	[theScanner scanString:@"//" intoString:&temp];
	final=[final stringByAppendingString:temp];
	[theScanner scanUpToString:@"/" intoString:&temp];
	final=[final stringByAppendingString:temp];
	[theScanner scanString:@"/" intoString:&temp];
	final=[final stringByAppendingString:temp];
	return final;
}

-(void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"Auth challenge");
	[self trustProcedure:connection forChallenge:challenge];
}

// http://www.solati.se/blog/ios-basic-authentication
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"Asking for auth challenge %@ to %@",[challenge proposedCredential],[[connection originalRequest] URL]);
	[self trustProcedure:connection forChallenge:challenge];
}

-(void)trustProcedure:(NSURLConnection *)connection forChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
		//		if ([trustedHosts containsObject:challenge.protectionSpace.host])
	{
		[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
		NSLog(@"Trusted server");
	}
	else
		if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic])
		{
			
			PDKeychainBindings*bindings=[PDKeychainBindings sharedKeychainBindings];
			NSString*user=[bindings stringForKey:[[self baseUrlString:theUrl]
												  stringByAppendingString:@"user"]];
			NSString*password=[bindings stringForKey:[[self baseUrlString:theUrl]
													  stringByAppendingString:@"password"]];
			if ([challenge previousFailureCount] == 0) {
				NSURLCredential *newCredential;
				newCredential = [NSURLCredential credentialWithUser:user
														   password:password
														persistence:NSURLCredentialPersistenceForSession];
				[[challenge sender] useCredential:newCredential
					   forAuthenticationChallenge:challenge];
				NSLog(@"Using HTTP Auth");
			}
			else
			{
				// The credentials were NOT accepted show to user
				
				NSString*alertMessage=[NSString stringWithFormat:NSLocalizedString(@"dialogAuthFailedLocalized", @"dialogAuthFailedLocalized"),[self baseUrlString:theUrl],user];
				UIAlertView*uia=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AuthFailedLocalized",@"AuthFailedLocalized")
														   message:alertMessage
														  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[uia show];
				[delegate requestFinishedWithErrors:self error:nil];
			}
		}
		else {
			[[challenge sender] cancelAuthenticationChallenge:challenge];
			NSLog(@"Auth Failed");
			// inform the user that the user name and password
			// in the preferences are incorrect
			//[self showPreferencesCredentialsAreIncorrectPanel:self];
			UIAlertView*uia=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnkAuthFailedLocalized",@"UnkAuthFailedLocalized")
													   message:NSLocalizedString(@"UnkdialogAuthFailedLocalized",@"UnkdialogAuthFailedLocalized")
													  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[uia show];
			[delegate requestFinishedWithErrors:self error:nil];
		}
}

#pragma mark - v1.2 Long-poll requests

-(void)doGetLongPolling:(NSURL*)url{
	// To test: curl -H "X-Atmosphere-Transport: long-polling" http://demo.openhab.org:8080/rest/sitemaps/demo/FF_Bath
	theUrl=url;
	TheConnection=nil;

	// timeout long enough to not fail connection...
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3600];


	// Adding the athmosphere header if long poll
	
	[request setValue:@"long-polling" forHTTPHeaderField:@"X-Atmosphere-Transport"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

	
	//send the request (will block until a response comes back)
	NSLog(@"Starting long-poll at %@",url);
	TheConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (!TheConnection)
	{
		NSLog(@"ERROR: Could not create a connection");
		[delegate requestFinishedWithErrors:self error:nil];
	}
}

-(void)doGetOperation:(NSURL *)url
{
	// To test: curl -H "X-Atmosphere-Transport: long-polling" http://demo.openhab.org:8080/rest/sitemaps/demo/FF_Bath

	TheConnection=nil;
	//compose the request
	
	NSString* jsonAdded=[NSString stringWithFormat:@"%@?type=json",url];
	url=[NSURL URLWithString:jsonAdded];
	theUrl=url;
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeout];
	
	
	// Adding the athmosphere header if long poll
	
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	
	//send the request (will block until a response comes back)
	NSLog(@"Starting request at %@",url);
	
	TheConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (!TheConnection)
	{
		NSLog(@"ERROR: Could not create a connection");
		[delegate requestFinishedWithErrors:self error:nil];
	}
}
@end
