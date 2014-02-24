//
//  openhabTableViewCell.m
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

#import "openhabTableViewCell.h"

@implementation openhabTableViewCell
@synthesize widget,label,theImage,theSpinner,refreshIcon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)loadWidget:(openhabWidget*)theWidget
{
	// Set the widget, the label and the image
    // Ask for the image
    
    self.widget=theWidget;
    self.label.text=theWidget.label;
	
	// IF NOT AN IMAGE, check for icon
	if ([theWidget widgetType]!=7 && [theWidget widgetType]!=10)
	{
		if (theWidget.iconImage)
		{
			self.theImage.image=theWidget.iconImage;
			[self.theSpinner stopAnimating];
		}
		else
		{
			// lets look for the image and download it
			[[openhab sharedOpenHAB] getImage:theWidget.icon];
		}
	}
    if ([theWidget.widgets count]>0 || [theWidget widgetType]==17) // This is a colorpicker
    {
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [self setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    else
    {
        [self setAccessoryType:UITableViewCellAccessoryNone];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
}
-(BOOL)mayBeModified
{
	return NO;
}


-(IBAction)changeValue:(id)sender
{
	NSLog(@"ERROR: standard cell not switchable, %@",self);
}

@end
