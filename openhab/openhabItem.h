//
//  openhabItem.h
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


#import <Foundation/Foundation.h>

/*
 Los items may be groups or:
 
 'Switch' | 'Rollershutter' | 'Number' | 'String' | 'Dimmer' | 'Contact' | 'DateTime' | ID | ColorItem
 
 */

@interface openhabItem : NSObject
{
    NSString *type;
    NSString *name;
    NSString *state;
    NSString *link;
    NSMutableSet *groups;
}

@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *state;
@property (nonatomic,strong) NSString *link;
@property (nonatomic,strong) NSMutableSet *groups;

// Initialize with a dictionary
-(openhabItem*)initWithDictionary:(NSDictionary*)dictionary;
@end