//
//  openhabAppDelegate.m
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

#import "openhabAppDelegate.h"
#import "openhab.h"
#import "configuration.h"



@implementation openhabAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	
	// Override point for customization after application launch. if IPAD
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        // This is changed, the MASTER controlls the button.
        UINavigationController *navigationController = [splitViewController.viewControllers objectAtIndex:0];
        splitViewController.delegate = (id)navigationController.topViewController;
		
		// v1.2 THis lets us do the swipe. If not, iOS opens the left panel
		
		NSString *osVersion = @"5.1";
		NSString *currOsVersion = [[UIDevice currentDevice] systemVersion];
		if ([currOsVersion compare:osVersion options:NSNumericSearch] == NSOrderedSame ||
			[currOsVersion compare:osVersion options:NSNumericSearch] == NSOrderedDescending )
			splitViewController.presentsWithGesture=NO;

    }
	
	
	
	
	return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
	[[openhab sharedOpenHAB].queue cancelRequests];
	[[openhab sharedOpenHAB] cancelPolling];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
	[[openhab sharedOpenHAB] refreshPage:[openhab sharedOpenHAB].currentPage];
	[[openhab sharedOpenHAB] longPollCurrent];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

@end
