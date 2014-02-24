//
//  loginViewController.h
//  openhab
//
//  Created by Pablo Mª Romeu Guallart on 22/08/12.
//
//

#import <UIKit/UIKit.h>
// v1.2 NEW! login
@interface loginViewController : UIViewController <UITextFieldDelegate>
- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextView *warningAuthText;
@property (strong, nonatomic) NSString *server;

@end
