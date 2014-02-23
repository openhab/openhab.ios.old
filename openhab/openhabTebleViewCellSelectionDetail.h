//
//  openhabTebleViewCellSelectionDetail.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 23/12/11.
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

@interface openhabTebleViewCellSelectionDetail : UITableViewController
{
	__weak openhabWidget*widget;
	__weak UITableView*lastTableView;
}
@property (nonatomic,weak) openhabWidget*widget;
@property (nonatomic,weak) UITableView*lastTableView;
@property (nonatomic) NSInteger lastselected;
@end
