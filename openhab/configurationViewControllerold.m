//
//  configurationViewController.m
//  openhab
//
//  Created by Pablo Romeu Guallart on 26/11/11.
//  Copyright (c) 2011 spaphone. All rights reserved.
//

#import "configurationViewController.h"
#import "configuracion.h"


@interface configurationViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation configurationViewController

@synthesize masterPopoverController = _masterPopoverController;
@synthesize refresco,mapa,direccion, fichero,elstepper;

-(IBAction)cambiaRefresco:(id)sender
{
	if ([elstepper value] >=0)
		self.refresco.text=[NSString stringWithFormat:@"%i", (NSInteger)[elstepper value]];
}
-(IBAction)botonOk:(id)sender
{
	[self.fichero writeToPlist:@"BASE_URL" valor:self.direccion.text];
	[self.fichero writeToPlist:@"map" valor:self.mapa.text];
	
	// Pasar a NSNUMBER
	
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber * myNumber = [f numberFromString:self.refresco.text];
	[f release];
	
	[self.fichero writeToPlist:@"refresh" valor:myNumber];

	// Finalizar las ediciones
	[self.direccion endEditing:YES];
	[self.mapa endEditing:YES];

	if ([(UIBarButtonItem*)sender tag] == 0)
		[self.navigationController popViewControllerAnimated:YES]; 
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Split view

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
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

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/
- (void)dealloc
{
    [self.fichero release];
	self.fichero=nil;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.fichero=[configuracion new];
	self.direccion.text = (NSString*)[self.fichero readPlist:@"BASE_URL"];
	self.mapa.text = (NSString*)[self.fichero readPlist:@"map"];
	self.refresco.text = [NSString stringWithFormat:@"%@",[self.fichero readPlist:@"refresh"]];
	NSNumber*n=(NSNumber*)[self.fichero readPlist:@"refresh"];
	self.elstepper.value=[n doubleValue];
    [self configureView];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
	[textField resignFirstResponder];
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

@end
