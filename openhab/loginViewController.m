//
//  loginViewController.m
//  openhab
//
//  Created by Pablo Mª Romeu Guallart on 22/08/12.
//
//
// v1.2 NEW! login

#import "loginViewController.h"
#import "PDKeychainBindings.h"

@interface loginViewController ()

@end

@implementation loginViewController
@synthesize userField;
@synthesize passwordField;
@synthesize warningAuthText;
@synthesize server;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	PDKeychainBindings *bindings=[PDKeychainBindings sharedKeychainBindings];
	// v1.2
	userField.text=[bindings stringForKey:[server stringByAppendingString:@"user"]];
	passwordField.text=[bindings stringForKey:[server stringByAppendingString:@"password"]];
	warningAuthText.text=NSLocalizedString(@"warningAuthTextLoc", @"warningAuthTextLoc");
	self.navigationItem.title=NSLocalizedString(@"loginLoc", @"loginLoc");
}

- (void)viewDidUnload
{
	[self setUserField:nil];
	[self setPasswordField:nil];
	[self setWarningAuthText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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

#pragma mark - Textfield

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (IBAction)done:(id)sender {
	PDKeychainBindings *bindings=[PDKeychainBindings sharedKeychainBindings];
	// Saving
	[bindings setObject:userField.text forKey:[server stringByAppendingString:@"user"]];
	[bindings setObject:passwordField.text forKey:[server stringByAppendingString:@"password"]];

	[self dismissModalViewControllerAnimated:YES];
}
@end
