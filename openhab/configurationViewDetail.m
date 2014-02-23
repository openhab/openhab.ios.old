//
//  configurationViewDetail.m
//  openhab
//
//  Created by Pablo Romeu Guallart on 21/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "configurationViewDetail.h"
#import "configuration.h"

@implementation configurationViewDetail
@synthesize theTextField,theField;

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

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.theTextField.text=(NSString*)[configuration readPlist:theField];
	self.theTextField.delegate=self;
}


- (void)viewDidUnload
{
	[self setTheTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
 - (IBAction)saveUrl:(UITextField*)sender {
 [configuration writeToPlist:@"BASE_URL" valor:sender.text];
 }
 
 - (IBAction)saveSitemap:(UITextField*)sender {
 [configuration writeToPlist:@"map" valor:sender.text];
 - (BOOL)textFieldShouldReturn:(UITextField *)textField
 {
 [textField resignFirstResponder];
 return NO;
 }
 
 -(void)textFieldDidEndEditing:(UITextField *)textField
 {
 [textField resignFirstResponder];
 }*/


- (IBAction)doneButton:(id)sender {
	[configuration writeToPlist:theField valor:theTextField.text];
	[self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
	[textField resignFirstResponder];
	[self doneButton:textField];
}
@end
