//
//  configurationTableViewController.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 21/12/11.
//	Eclipse Public License - v 1.0
//
//  THE ACCOMPANYING PROGRAM IS PROVIDED UNDER THE TERMS OF THIS
//	ECLIPSE PUBLIC LICENSE ("AGREEMENT"). ANY USE, REPRODUCTION OR
//	DISTRIBUTION OF THE PROGRAM CONSTITUTES RECIPIENT'S ACCEPTANCE
//	OF THIS AGREEMENT.
//
//	See license.txt for more info

//

#import <UIKit/UIKit.h>
#import "bonjourBrowserDelegate.h"
#import "openhab.h"

@interface configurationTableViewController : UITableViewController <UITextFieldDelegate,bonjourBrowser,openHABprotocol>
{
	NSNetServiceBrowser *serviceBrowser;
	NSNetServiceBrowser *serviceBrowser2;	
}
@property (strong,nonatomic)	NSMutableArray*bonjourAddresses;
@property (strong,nonatomic) bonjourBrowserDelegate*bonjourDelegate;
@property (strong,nonatomic)	NSNetServiceBrowser *serviceBrowser;
@property (strong,nonatomic)	NSNetServiceBrowser *serviceBrowser2;
@property (weak, nonatomic) UITableViewController*lastViewController;
@property (strong,nonatomic) NSString*theField;
@property (strong,nonatomic) NSMutableArray *arrayLasts;
@property (weak, nonatomic) IBOutlet UITextField *theTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sitemapButton;
@property (nonatomic) int lastselected;

- (IBAction)doneButton:(id)sender;
@end
