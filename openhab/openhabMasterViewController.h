//
//  openhabMasterViewController.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 16/12/11.
//	Eclipse Public License - v 1.0
//
//  THE ACCOMPANYING PROGRAM IS PROVIDED UNDER THE TERMS OF THIS
//	ECLIPSE PUBLIC LICENSE ("AGREEMENT"). ANY USE, REPRODUCTION OR
//	DISTRIBUTION OF THE PROGRAM CONSTITUTES RECIPIENT'S ACCEPTANCE
//	OF THIS AGREEMENT.
//
//	See license.txt for more info

//

#import <UIKit/UIKit.h>
#import "openhab.h"

@protocol splitMultipleDetailViews;

@interface openhabMasterViewController : UITableViewController <UISplitViewControllerDelegate>

{
	UIPopoverController *thePopover;
	UIBarButtonItem*theButton;

}
// Everything for the splitMultipleDetailViews
@property (strong, nonatomic) UIViewController <splitMultipleDetailViews> *detailViewController;
@property (strong,nonatomic) UIPopoverController *thePopover;
@property (strong,nonatomic) UIBarButtonItem*theButton;

@end


@protocol splitMultipleDetailViews

-(void)showButton:(UIBarButtonItem*)button pop:(UIPopoverController*)popover;
-(void)hideButton:(UIBarButtonItem*)button;

@end