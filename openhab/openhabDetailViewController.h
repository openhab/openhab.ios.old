//
//  openhabDetailViewController.h
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

#import <UIKit/UIKit.h>
#import "openhabMasterViewController.h"
#import "openhab.h"
#import "configuration.h"
#import "openhabTableViewCell.h"
#import "openhabTableViewCellgroup.h"
#import "openhabTableViewCelltext.h"
#import "openhabTableViewCellgroup.h"
#import "openhabTableViewCellimage.h"
#import "openhabTableViewCellSwitch.h"
#import "openhabTableViewCellSelection.h"
#import "openhabTableViewCellSlider.h"
#import "openhabTableViewCellList.h"
#import "openhabTableViewCellimageNoChildren.h"
#import "openhabTableViewCelltextNoChildren.h"
#import "openhabTebleViewCellSelectionDetail.h"
#import "openhabTableViewCellSetpoint.h"
#import "openhabTableViewCellWebView.h"
#import "openhabTableViewCellVideo.h"
#import "openhabTableViewCellChart.h"
#import "openhabTableViewCellColor.h"
#import "openhabTableViewCellColorPicker.h"
#import "MBProgressHUD.h"


@interface openhabDetailViewController :  UITableViewController <splitMultipleDetailViews,openHABprotocol>
{
    __weak IBOutlet UIView *theLoadingView;
    __weak NSArray*myWidgets;
	NSString*myPageId;
    __weak IBOutlet UIActivityIndicatorView*loadingSpinner;
    __weak IBOutlet UILabel*loadingLabel;
    MBProgressHUD*HUD;
    UIAlertView*alert;
    // CHANGE v1.1 manualRefresh to NOT to show errors to user in auto refresh
    BOOL shouldNotifyUser;
}
@property (weak, nonatomic) IBOutlet UIView *theLoadingView;
@property (nonatomic,weak) NSArray*myWidgets;
@property (nonatomic,strong) NSString*myPageId;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView*loadingSpinner;
@property (nonatomic,weak) IBOutlet UILabel*loadingLabel;
@property (nonatomic,strong) NSTimer*refreshTimer;
@property (nonatomic,strong) NSTimer*progressTimer;
@property (nonatomic,strong)     MBProgressHUD*HUD;
@property (nonatomic,strong)      UIAlertView*alert;

-(IBAction)refreshTableandSitemap:(id)sender;
@end
