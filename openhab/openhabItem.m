//
//  openhabItem.m
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

#import "openhabItem.h"

@implementation openhabItem

@synthesize type;
@synthesize name;
@synthesize link;
@synthesize state;
@synthesize groups;

#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
		groups=[[NSMutableSet alloc]initWithCapacity:0];
    }
    
    return self;
}

- (id)copy
{
	openhabItem*theCopy=[openhabItem alloc];
	theCopy.type=[self.type copy];
	theCopy.name=[self.name copy];
	theCopy.link=[self.link copy];
	theCopy.state=[self.state copy];
	theCopy.groups=[self.groups copy];
	return theCopy;
}

-(openhabItem*)initWithDictionary:(NSDictionary*)dictionary
{
    [self setLink:[dictionary valueForKey:@"link"]];
    [self setType:[dictionary valueForKey:@"type"]];
    [self setName:[dictionary valueForKey:@"name"]];
    [self setState:[dictionary valueForKey:@"state"]];
	groups=[[NSMutableSet alloc]initWithCapacity:0];
    //[self setGroups:[dictionary valueForKey:@"groups"]];
    return self;
}

#pragma mark - Descriptions

- (NSString*)membersName
{
	NSMutableString*temp=[[NSMutableString alloc]initWithCapacity:0];
	for (openhabItem*n in self.groups) {
		temp=(NSMutableString*)[temp stringByAppendingFormat:@"%@ ",n.name];
	}
	return temp;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@, %@, %@, %@, Groups:%@",name,type,state,link, [self membersName]];
}


@end
