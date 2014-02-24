//
//  openhabMapping.m
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

#import "openhabMapping.h"

@implementation openhabMapping
@synthesize command,label;
-(openhabMapping*)initWithDictionary:(NSDictionary*)theDictionary
{
	self.command=[theDictionary valueForKey:@"command"];
	self.label=[theDictionary valueForKey:@"label"];
	return self;
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"command: %@, label: %@",self.command,self.label];
}

-(openhabMapping*)initwithStrings:(NSString*)theCommand label:(NSString*)theLabel
{
	return [self initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:theLabel,@"label",theCommand, @"command", nil]];
}
@end
