//
//  openhabMasterViewController.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 24/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "openhab.h"
#import "configuracion.h"
#import "MBProgressHUD.h"

@class openhabDetailViewController;
@class configurationViewController;
@protocol splitMultiple;

@interface openhabMasterViewControlleriPad : UITableViewController <openhabProtocol,UISplitViewControllerDelegate,MBProgressHUDDelegate>
{
    UIBarButtonItem* elBoton;
    UIPopoverController* elPopover;
    IBOutlet UIBarButtonItem *botonRefresco;
    MBProgressHUD *HUD;
}

@property (strong,nonatomic) UIBarButtonItem*elBoton;
@property (strong,nonatomic) UIPopoverController*elPopover;
@property (strong,nonatomic)  IBOutlet UIBarButtonItem *botonRefresco;
@property (strong, nonatomic) UIViewController *detailViewController;
@property (nonatomic,assign) IBOutlet UITableViewCell*celdaOpenHAB;
@property (strong, nonatomic) openhab *oh;
@property (assign) BOOL trabajando;
@property (strong, nonatomic) configuracion* conf;

-(IBAction)refrescaOpenHAB:(id)sender;
-(void)refrescaEstadoOpenHAB;
@end

@protocol splitMultiple

-(void)muestraBoton:(UIBarButtonItem*)boton pop:(UIPopoverController*)popover;
-(void)ocultaBoton:(UIBarButtonItem*)boton;

@end