//
//  configurationViewDetail.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 21/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//



@interface configurationViewDetail : UIViewController <UITextFieldDelegate>

@property (strong,nonatomic) NSString*theField;
@property (weak, nonatomic) IBOutlet UITextField *theTextField;

- (IBAction)doneButton:(id)sender;
@end
