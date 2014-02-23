//
//  configurationViewController.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 26/11/11.
//  Copyright (c) 2011 spaphone. All rights reserved.
//

#import "configuracion.h"
#import "openhabMasterViewControlleriPad.h"


@interface configurationViewController : UIViewController <UITextFieldDelegate,UISplitViewControllerDelegate,splitMultiple>
{
	__weak IBOutlet UITextField*direccion;
	__weak IBOutlet UITextField*mapa;
	__weak IBOutlet UILabel*refresco;
	__weak IBOutlet UIStepper*elstepper;
	__strong configuracion* fichero;
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) UITextField* direccion;
@property (weak, nonatomic) UITextField* mapa;
@property (weak, nonatomic) UILabel* refresco;
@property (weak, nonatomic) UIStepper* elstepper;
@property (strong, nonatomic) configuracion* fichero;

-(IBAction)cambiaRefresco:(id)sender;
-(IBAction)botonOk:(id)sender;

@end
