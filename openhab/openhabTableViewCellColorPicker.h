//
//  openhabTableViewCellColorPicker.h
//  openhab
//
//  Created by Pablo Mª Romeu Guallart on 02/04/13.
//
//

#import <UIKit/UIKit.h>
#import "openhab.h"
#import "RSColorPickerView.h"
#import "RSBrightnessSlider.h"
@interface openhabTableViewCellColorPicker : UIViewController <RSColorPickerViewDelegate>
{
	__weak openhabWidget*widget;
	__weak UITableView*lastTableView;
}
@property (nonatomic,weak) openhabWidget*widget;
@property (nonatomic,weak)  UITableView*lastTableView;
@property (nonatomic) IBOutlet RSColorPickerView *colorPicker;
@property (nonatomic) IBOutlet RSBrightnessSlider *brightnessSlider;
@end
