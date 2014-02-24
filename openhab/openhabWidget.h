//
//  openhabWidget.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 17/12/11.
//	Eclipse Public License - v 1.0
//
//  THE ACCOMPANYING PROGRAM IS PROVIDED UNDER THE TERMS OF THIS
//	ECLIPSE PUBLIC LICENSE ("AGREEMENT"). ANY USE, REPRODUCTION OR
//	DISTRIBUTION OF THE PROGRAM CONSTITUTES RECIPIENT'S ACCEPTANCE
//	OF THIS AGREEMENT.
//
//	See license.txt for more info

//

#import "openhabItem.h"
#import "openhabMapping.h"

/* Widgets are
 
 ((Switch | Selection | Slider | List | Setpoint |Webview | Video) or (Text | Group | Image | Frame | Colorpicker)
 
 v1.2 Setpoint
 */



@interface openhabWidget : NSObject
{
	NSString *type; // All widgets have type
    NSString *label; // All have labels
    NSString *icon; // Maybe icon
	NSString *linkedPage; // v1.2 Maybe linkedPage
	NSURL* theWidgetUrl; // v1.2 maybe WebView
    UIImage*iconImage; // Maybe an iconImage
	UIImage*Image; // Maybe an Image
	NSString*imageURL; //Maybe an image url
    openhabItem *item; // Maybe item
    NSMutableArray *widgets; //  (Text | Group | Image | Frame) may contain otro widget
	NSMutableDictionary *mappings; // We may have mappings. Mappings are objects with a couple (command, label) v1.2 this is changed to a dictionary
	NSString *data; // Maybe label has [localized data]
	NSInteger height; // Height for some values
	
	// v1.2 Chart needs
	NSString* service;
	NSInteger refresh;
	NSString* period;
}

@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *label;
@property (nonatomic,strong) NSString *icon;
@property (nonatomic,strong) NSString *linkedPage; // v1.2
@property (nonatomic,strong) UIImage *iconImage;
@property (nonatomic,strong) UIImage *Image;
@property (nonatomic,strong) NSString*imageURL;
@property (nonatomic,strong) openhabItem *item;
@property (nonatomic,strong) NSMutableArray *widgets;
@property (nonatomic,strong) NSMutableDictionary *mappings;
@property (nonatomic,strong) NSString *data;
@property (nonatomic,strong) NSURL* theWidgetUrl; // v1.2
@property (nonatomic) float sendFrequency,minValue,maxValue,step;	// v1.2 Sliders may have send frequency
																	// and setpoint values
@property (nonatomic) NSInteger height; // V1.2 Might have height value
@property (nonatomic,strong) NSString* service;
@property (nonatomic) NSInteger refresh;
@property (nonatomic,strong) NSString* period;

-(openhabWidget*)initWithDictionary:(NSDictionary*)dictionary;
-(openhabWidget*)copy;

// itemTypes: 1 Switch | 2 Selection | 3 Slider | 4 List
//groupWidgettypes itemTypes: 5 Text | 6 Group | 7 Image | 8 Frame | 11 Setpoint | 12 WebView | 14 Video | 16 Chart | 17 Colorpicker
// 0 for unknown type
-(NSInteger)widgetType;
-(NSString*)structure;
// v1.2 building charting url
-(void)buildChartingURLString:(NSString*)baseURL;
@end
