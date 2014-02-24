//
//  openhabMasterViewController.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 24/11/11.
//  Copyright (c) 2011 spaphone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "openhab.h"
#import "configuracion.h"
@class openhabDetailViewController;

@interface openhabMasterViewController : UITableViewController <openhabProtocol>

@property (retain, nonatomic) IBOutlet UIBarButtonItem *botonRefresco;
@property (strong, nonatomic) openhabDetailViewController *detailViewController;
@property (strong, nonatomic) openhab *oh;
@property (assign) BOOL trabajando;
@property (nonatomic,assign) IBOutlet UITableViewCell*celdaOpenHAB;
@property (strong, nonatomic) configuracion* conf;

-(void)refrescaEstadoOpenHAB;
-(IBAction)refrescaOpenHAB:(id)sender;
@end
