//
//  openhabDetailViewController.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 24/11/11.
//  Copyright (c) 2011 spaphone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "openhabWidget.h"
#import "openhabItem.h"
#import "openhabMasterViewControlleriPad.h"
#import "openhab.h"
#import "UIOpenHABTableViewCell.h"


@interface openhabDetailViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate, splitMultiple,openhabItemprotocol,openhabProtocol,UIOpenHABCellProtocol,MBProgressHUDDelegate>
{
        MBProgressHUD *HUD;
}

@property (retain, nonatomic) IBOutlet UIBarButtonItem *botonRefresco;
@property (assign, nonatomic) NSMutableArray* sitemap;
@property (strong, nonatomic) NSTimer *aTimer;
@property (assign, nonatomic) openhab *oh;
- (openhabWidget*)dameWidgetenSeccion:(NSUInteger)seccion;
-(IBAction)refreshMap:(id)sender;

@end
