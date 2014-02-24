//
//  configurationLocalIPViewController.h
//  openhab
//
//  Created by Pablo Mª Romeu Guallart on 31/08/12.
//
//

#import <UIKit/UIKit.h>
#import "bonjourBrowserDelegate.h"
#import "openhab.h"


@interface configurationLocalIPViewController : UITableViewController <UITextFieldDelegate,bonjourBrowser,openHABprotocol>
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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sitemapButton;
@property (weak, nonatomic) IBOutlet UITextField *theTextField;
@property (nonatomic) NSInteger lastselected;
- (IBAction)deleteAlternate:(id)sender;

- (IBAction)doneButton:(id)sender;
@end