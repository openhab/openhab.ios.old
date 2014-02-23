//
//  openhabDetailViewController.m
//  openhab
//
//  Created by Pablo Romeu Guallart on 24/11/11.
//  Copyright (c) 2011 spaphone. All rights reserved.
//

#import "openhabDetailViewController.h"
#import "UIOpenHABTableViewCell.h"
#import "configuracion.h"

@interface openhabDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation openhabDetailViewController
@synthesize botonRefresco;

@synthesize masterPopoverController = _masterPopoverController;
@synthesize sitemap,aTimer,oh;

- (void)dealloc
{
    [_masterPopoverController release];
 //   [sitemap release];
   // [oh release];
    [aTimer release];
    [botonRefresco release];
    [super dealloc];
	self.oh.delegate=nil;
	self.oh=nil;
	self.sitemap=nil;
}

#pragma mark - Managing the detail item

- (void)configureView
{
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setBotonRefresco:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.oh=nil;
    self.sitemap=nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureView];
    configuracion*c=[configuracion new];
    double interval=[(NSString*)[c readPlist:@"refresh"] doubleValue];
    if (interval > 0.0)
        self.aTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(refreshMap:) userInfo:nil repeats:YES];
    [c release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.aTimer invalidate];
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

#pragma mark - Split view

-(void)muestraBoton:(UIBarButtonItem*)boton pop:(UIPopoverController*)popover
{
    boton.title = NSLocalizedString(@"Menu", @"Menu");
    [self.navigationItem setLeftBarButtonItem:boton animated:YES];
    self.masterPopoverController = popover;
}

- (void)ocultaBoton:(UIBarButtonItem *)boton
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Métodos de control de la tabla

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Contar el numero de frames
    NSUInteger i = 0;
    for (openhabWidget*w in self.sitemap) {
        if ([w.tipo rangeOfString:@"Frame"].location!=NSNotFound)
            i++;
    }
    // por si acaso no se definen frames, darle mas uno
    if (i==0)
        i=1;
    return i;
}

- (openhabWidget*)dameWidgetenSeccion:(NSUInteger)seccion
{
    NSUInteger i = 0;
    openhabWidget * wtemp=nil;
    for (openhabWidget*w in self.sitemap) {
        if ([w.tipo rangeOfString:@"Frame"].location!=NSNotFound)
        {
            if (i==seccion)
                wtemp=w;
            i++;
        }
    }
    if (i==0)
	{
		openhabWidget*w=[[openhabWidget new]autorelease];
		w.widgets=self.sitemap;
		return w;
	}
    return wtemp;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self dameWidgetenSeccion:section].widgets count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Contar el numero de frames
    NSUInteger i = 0;
    NSString*val=@"";
    for (openhabWidget*w in self.sitemap) {
        if ([w.tipo rangeOfString:@"Frame"].location!=NSNotFound)
            if (i==section)
                val=w.label;
            i++;
    }

    return val;
}

-(UIOpenHABTableViewCell*)reutilizarCelda:(NSString*)tipo
{
    UIOpenHABTableViewCell *cell= [self.tableView dequeueReusableCellWithIdentifier:tipo];
    if (cell == nil) {
        cell = [[[UIOpenHABTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tipo] autorelease];
    }
    return cell;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIOpenHABTableViewCell *cell;
    openhabWidget*widget=[[self dameWidgetenSeccion:indexPath.section].widgets objectAtIndex:indexPath.row];
    if ([widget.tipo rangeOfString:@"Switch"].location!=NSNotFound)
    {
        cell=[self reutilizarCelda:@"CeldaSwitch"];
        [cell rellenaCelda:widget];
    }
    else if ([widget.tipo rangeOfString:@"Text"].location!=NSNotFound)
    {
            cell=[self reutilizarCelda:@"CeldaInfo"];
            [cell rellenaCelda:widget];
    }
    else if ([widget.tipo rangeOfString:@"Group"].location!=NSNotFound)
    {
        cell=[self reutilizarCelda:@"CeldaGrupo"];
        [cell rellenaCelda:widget];
    }
    
    else
    {
        cell=[self reutilizarCelda:@"CeldaStepper"];
        [cell rellenaCelda:widget];
    }

    
    return cell;
}


#pragma mark - preparar la segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"segueMasDetalle"])
    {
        // Get reference to the destination view controller
        openhabDetailViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
		UIOpenHABTableViewCell*celda=(UIOpenHABTableViewCell*)sender;

        [vc setSitemap:celda.widgets];
        [vc setOh:self.oh];
    }
}
#pragma mark - HUD

- (void)muestraHUD
{
    // Should be initialized with the windows frame so the HUD disables all user input by covering the entire screen
	HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
	// Add HUD to screen
	[self.view.window addSubview:HUD];
	// Register for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	HUD.labelText = @"Loading";
    [HUD show:YES];

}

- (void)hudWasHidden {
	// Remove HUD from screen when the HUD was hidden
    [self.botonRefresco setEnabled:YES];
	[HUD removeFromSuperview];
	[HUD release];
    HUD=nil;
}

#pragma mark - refresca estado

-(IBAction)refreshMap:(id)sender
{
    // Si no nos ha llamado el usuario
    if (sender==botonRefresco) {
        [self muestraHUD];   
    }
    self.oh.delegate=self;
    [self.botonRefresco setEnabled:NO];
    [self.oh actualizaWidgets];
    [self.oh refrescaEstado];
}

#pragma mark - protocolo openhabcell

-(void)actualizaTabla
{
	[self refreshMap:nil];
}

#pragma mark - delegado de item

-(void)estadoModificado:(openhabItem*)item
{
    [self.tableView reloadData];
}
-(void)estadoActualizado:(openhabItem*)item
{
    [self.tableView reloadData];
}

#pragma mark - delegado de openhab
// Avisaremos del fin de cada request
- (void)requestFinalizadaConExito:(openhab*)casa
{
    
}
// Avisaremos del fin del proceso de carga
- (void)cargaFinalizadaConExito:(openhab*)casa
{
    
}
// Avisaremos de un error de carga
- (void)cargaErronea:(openhab*)casa
{
    if (HUD!=nil) {
     [HUD hide:YES];   
    }
    
    [self.botonRefresco setEnabled:YES];
    UIAlertView* alerta=[[UIAlertView alloc]initWithTitle:@"Carga Errónea" message:@"Hubo un error en la comunicación con el servidor openHAB" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alerta autorelease];
	[alerta show];
}
// Avisamos de fin de refresco
- (void)finRefresco:(openhab*)casa
{
    //NSLog(@"Resfresca la tabla!");
    if (HUD!=nil) {
        [HUD hide:YES];   
    }
    [self.botonRefresco setEnabled:YES];
    [self.tableView reloadData];
}

@end
