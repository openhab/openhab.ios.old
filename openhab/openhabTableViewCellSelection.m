//
//  openhabTableViewCellSelection.m
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

#import "openhabTableViewCellSelection.h"

@implementation openhabTableViewCellSelection
@synthesize detailLabel;

-(void)loadWidget:(openhabWidget *)theWidget
{
    [super loadWidget:theWidget];
    if ([theWidget.item.state rangeOfString:@"Undefined"].location==NSNotFound)
    {
		openhabMapping*mapping=(openhabMapping*)[theWidget.mappings objectForKey:theWidget.item.state];
        [detailLabel setText:[mapping label]];
    }
    else
    {
        [detailLabel setText:@""];
    }
	[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	[self setSelectionStyle:UITableViewCellSelectionStyleBlue];
}
@end
