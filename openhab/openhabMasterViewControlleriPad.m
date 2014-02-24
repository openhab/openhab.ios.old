//
//  openhabMasterViewController.m
//  openhab
//
//  Created by Pablo Romeu Guallart on 24/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "openhabMasterViewControlleriPad.h"
#import "openhabDetailViewController.h"
#import "configurationViewController.h"

@implementation openhabMasterViewControlleriPad

@synthesize detailViewController = _detailViewController;
@synthesize oh,trabajando,conf,elBoton,elPopover,botonRefresco, celdaOpenHAB;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
	self.conf = [configuracion new];
    [super awakeFromNib];
}

- (void)dealloc
{
    [_detailViewController release];
    [oh release];
	[conf release];
    [botonRefresco release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - delegado hud

- (void) muestraHUD
{
    // Should be initialized with the windows frame so the HUD disables all user input by covering the entire screen
	HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
	// Add HUD to screen
	[self.view.window addSubview:HUD];
	// Register for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	HUD.labelText = @"Loading";
    [HUD show:YES];
    
	// Show the HUD while the provided method executes in a new thread
    // NO LO HAGO
	//[HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}

- (void)hudWasHidden {
	// Remove HUD from screen when the HUD was hidden
	[HUD removeFromSuperview];
	[HUD release];
}

#pragma mark - crea o actualiza un mapa de openHAB

- (void)habilitaOpenHAB
{
    [HUD hide:YES];
    trabajando=NO;
    [self.botonRefresco setEnabled:YES];
    [self.celdaOpenHAB setUserInteractionEnabled:YES];
    [self.tableView reloadData];
    
}

- (void)deshabilitaOpenHAB
{
    [self muestraHUD];
    trabajando=YES;
    [self.botonRefresco setEnabled:NO];
    [self.celdaOpenHAB setUserInteractionEnabled:NO];
    [self.tableView reloadData];
    
}

-(IBAction)refrescaOpenHAB:(id)sender
{

    
	if (self.oh == nil)
	{
		self.oh=[openhab new];
		self.oh.delegate=self;
		[self deshabilitaOpenHAB];
		[self.oh parseaItems];
	}
	else 
		if (!trabajando)
		{
			[self.oh release];
			self.oh=[openhab new];
			self.oh.delegate=self;
			[self deshabilitaOpenHAB];
			[self.oh parseaItems];
		}
		else
			NSLog(@"Estamos trabajando");
}

#pragma mark - Actualiza widgets y estados

-(void)refrescaEstadoOpenHAB
{
    [self deshabilitaOpenHAB];
    [self.oh actualizaWidgets];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
    self.detailViewController = [[self.splitViewController.viewControllers lastObject] topViewController];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }

}

- (void)viewDidUnload
{
    [botonRefresco release];
    botonRefresco = nil;
    celdaOpenHAB=nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // CARGAMOS OPENHAB en la carga
	[self refrescaOpenHAB:self];	
		
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]])
    {
        self.detailViewController=[[segue destinationViewController] topViewController];
    }
    else
    {
        self.detailViewController=[segue destinationViewController];
    }
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"openhabSegue"])
    {
		// refrescamos
		// COMPROBAMOS SI ES UN NV
        // Get reference to the destination view controller
        openhabDetailViewController *vc=(openhabDetailViewController*)self.detailViewController;
        
        // Pass any objects to the view controller here, like...
        //NSLog(@"%@",[self.oh muestraSite]);
		[vc setSitemap:[self.oh sitemap]];
        [vc setOh:self.oh];
		
    }
    // Dismiss the popover if it's present.
    if (self.elPopover != nil) {
        [elPopover dismissPopoverAnimated:YES];
    }
    
    // Configure the new view controller's popover button (after the view has been displayed and its toolbar/navigation bar has been created).
    if (self.elBoton != nil) {
        if ([self.detailViewController isKindOfClass:[openhabDetailViewController class]])
        {
            openhabDetailViewController*temp=(openhabDetailViewController*)self.detailViewController;
            [temp muestraBoton:elBoton pop:elPopover];
        }
        else
        {
            configurationViewController*temp=(configurationViewController*)self.detailViewController;
            [temp muestraBoton:elBoton pop:elPopover];
        }
    
    }


}

#pragma mark - Protocolo openhab

// Avisaremos del fin de cada request
- (void)requestFinalizadaConExito:(openhab*)casa
{
	
}
// Avisaremos del fin del proceso de carga
- (void)cargaFinalizadaConExito:(openhab*)casa
{
    if (casa.sitemap == nil)
	{
		NSString* mapa=(NSString*)[conf readPlist:@"map"];
        [self.oh parseaWidgets:mapa];
	}
	else
    {
		[self habilitaOpenHAB];
    }

}
// Avisaremos de un error de carga
- (void)cargaErronea:(openhab*)casa
{
    UIAlertView* alerta=[[UIAlertView alloc]initWithTitle:@"Carga Errónea" message:@"Hubo un error en la comunicación con el servidor openHAB" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alerta autorelease];
	[alerta show];
	[self habilitaOpenHAB];
	
}
// Avisamos de fin de refresco
- (void)finRefresco:(openhab*)casa
{
    [self habilitaOpenHAB];
}

#pragma mark - Eventos de splitView

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    // Hay que mostrar el boton
    
    UIViewController <splitMultiple> * vista=nil;
    if ([self.detailViewController.navigationController.topViewController isKindOfClass:[openhabDetailViewController class]])
        vista = (openhabDetailViewController*)self.detailViewController.navigationController.topViewController;
    else
        vista = (configurationViewController*)self.detailViewController;

    self.elBoton=barButtonItem;
    self.elPopover=popoverController;
    
    [vista muestraBoton:barButtonItem pop:popoverController];
    
 
    /*barButtonItem.title = NSLocalizedString(@"Menu", @"Menu");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;*/
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    UIViewController <splitMultiple> * vista=nil;
    if ([self.detailViewController.navigationController.topViewController isKindOfClass:[openhabDetailViewController class]])
        vista = (openhabDetailViewController*)self.detailViewController.navigationController.topViewController;
    else
        vista = (configurationViewController*)self.detailViewController;
    
    [vista ocultaBoton:barButtonItem];
    
    self.elBoton=nil;
    self.elPopover=nil;
    /*
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;*/
}

@end
