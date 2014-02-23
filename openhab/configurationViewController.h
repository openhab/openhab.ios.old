//
//  configurationViewController.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 18/12/11.
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
#import "openhabMasterViewController.h"

@interface configurationViewController : UITableViewController <splitMultipleDetailViews>


@property (weak, nonatomic) IBOutlet UILabel *labelServer;
@property (weak, nonatomic) IBOutlet UILabel *labelAlternateServer;
@property (weak, nonatomic) IBOutlet UILabel *labelSitemap;
@property (weak, nonatomic) IBOutlet UILabel *labelRefresh;
@property (weak, nonatomic) IBOutlet UILabel *labelMaxConnections;

@property (weak, nonatomic) IBOutlet UILabel *theUrl;
@property (weak, nonatomic) IBOutlet UILabel *theAlternateUrl;
@property (weak, nonatomic) IBOutlet UILabel *theSitemap;
@property (weak, nonatomic) IBOutlet UILabel *refreshTime;
@property (weak, nonatomic) IBOutlet UILabel *maxConnections;
@property (weak, nonatomic) IBOutlet UILabel *theAuthenticationLabel;
@property (weak, nonatomic) IBOutlet UIStepper *refreshStepper;
@property (weak, nonatomic) IBOutlet UIStepper *maxStepper;

- (IBAction)changeRefreshValue:(id)sender;
- (IBAction)changeMaxConnectionsValue:(id)sender;

@end
