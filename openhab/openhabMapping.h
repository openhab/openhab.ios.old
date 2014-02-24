//
//  openhabMapping.h
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



@interface openhabMapping : NSObject
{
	NSString*command;
	NSString*label;
}
@property (nonatomic,strong) NSString *command;
@property (nonatomic,strong) NSString *label;

-(openhabMapping*)initWithDictionary:(NSDictionary*)theDictionary;
-(openhabMapping*)initwithStrings:(NSString*)theCommand label:(NSString*)theLabel;
@end
