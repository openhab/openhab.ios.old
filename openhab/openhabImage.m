//
//  openhabImage.m
//  openhab
//
//  Created by Pablo Romeu Guallart on 24/12/11.
//	Eclipse Public License - v 1.0
//
//  THE ACCOMPANYING PROGRAM IS PROVIDED UNDER THE TERMS OF THIS
//	ECLIPSE PUBLIC LICENSE ("AGREEMENT"). ANY USE, REPRODUCTION OR
//	DISTRIBUTION OF THE PROGRAM CONSTITUTES RECIPIENT'S ACCEPTANCE
//	OF THIS AGREEMENT.
//
//	See license.txt for more info

//

#import "openhabImage.h"

@implementation openhabImage
@synthesize image,name;

-(openhabImage*)initWithName:(NSString*)theName
{
	image=nil;
	name=theName;
	return self;
}
-(openhabImage*)initWithData:(NSData*)theData andName:(NSString*)theName
{
	image=[UIImage imageWithData:theData];
	name=theName;
	return self;
}

-(openhabImage*)initWithImage:(UIImage*)theImage andName:(NSString*)theName{
	image=theImage;
	name=theName;
	return self;
}

-(NSString*)description
{
	return self.name;
}
@end
