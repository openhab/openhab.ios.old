//
//  openhabMasterViewController.m
//  openhab
//
//  Created by Pablo Romeu Guallart on 24/11/11.
//  Copyright (c) 2011 spaphone. All rights reserved.
//

#import "openhabMasterViewController.h"

#import "openhabDetailViewController.h"

@implementation openhabMasterViewController

@synthesize botonRefresco;
@synthesize detailViewController = _detailViewController;
@synthesize oh,trabajando, conf, celdaOpenHAB;


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

- (void)habilitaOpenHAB
{
    trabajando=NO;
    [self.botonRefresco setEnabled:YES];
    [self.celdaOpenHAB setUserInteractionEnabled:YES];
    [self.tableView reloadData];

}

- (void)deshabilitaOpenHAB
{
    trabajando=YES;
    [self.botonRefresco setEnabled:NO];
    [self.celdaOpenHAB setUserInteractionEnabled:NO];
    [self.tableView reloadData];

}

#pragma mark - crea o actualiza un mapa de openHAB

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

    self.detailViewController = (openhabDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewDidUnload
{
    [self setBotonRefresco:nil];
    [self setCeldaOpenHAB:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	// CARGAMOS OPENHAB CADA VEZ QUE VOLVEMOS
	
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
	
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"openhabSegue"])
    {
		// COMPROBAMOS SI ES UN NV
        // Get reference to the destination view controller
        openhabDetailViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        //NSLog(@"%@",[self.oh muestraSite]);
        [vc setSitemap:[self.oh sitemap]];
        [vc setOh:self.oh];
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
        [self.oh parseaWidgets:(NSString*)[conf readPlist:@"map"]];
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
@end
