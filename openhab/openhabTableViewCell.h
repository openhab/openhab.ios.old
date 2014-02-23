//
//  openhabTableViewCell.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 18/12/11.
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
#import "openhabWidget.h"
#import "openhab.h"


@interface openhabTableViewCell : UITableViewCell
{
	openhabWidget*widget;

	__weak IBOutlet UILabel * label;
	__weak IBOutlet UIImageView * theImage;
    __weak IBOutlet UIActivityIndicatorView * theSpinner;
    BOOL refreshIcon;
}

@property (nonatomic,weak)IBOutlet UILabel * label;
@property (nonatomic,weak)IBOutlet UIImageView*theImage;
@property (nonatomic,strong) openhabWidget*widget;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView * theSpinner;
@property (nonatomic)   BOOL refreshIcon;

-(void)loadWidget:(openhabWidget*)theWidget;
-(BOOL)mayBeModified;
-(IBAction)changeValue:(id)sender;  
@end
