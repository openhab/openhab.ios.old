//
//  openhabTableViewCellSwitch.m
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

#import "openhabTableViewCellSwitch.h"

@implementation openhabTableViewCellSwitch
@synthesize theSwitch;

-(void)loadWidget:(openhabWidget *)theWidget
{
    [super loadWidget:theWidget];
    if ([theWidget.item.state rangeOfString:@"ON"].location!=NSNotFound)
    {
        [self.theSwitch setOn:YES];
    }
    else
    {
        [self.theSwitch setOn:NO];
    }
}

-(BOOL)mayBeModified
{
	return YES;
}
-(IBAction)changeValue:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]])
    {
        NSLog(@"Value switched, %i",[self.theSwitch isOn]);
        if ([self.theSwitch isOn]) {
            [[openhab sharedOpenHAB] changeValueofItem:self.widget.item toValue:@"ON"];
            self.widget.item.state=@"ON";
        }
        else
        {
            [[openhab sharedOpenHAB] changeValueofItem:self.widget.item toValue:@"OFF"];
            self.widget.item.state=@"OFF";
        }
        
//        // Refresh sitemap and icon
        
        //[[openhab sharedOpenHAB] refreshSitemap];
    }
}
@end
