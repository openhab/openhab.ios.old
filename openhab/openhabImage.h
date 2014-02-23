//
//  openhabImage.h
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



@interface openhabImage : NSObject
{
	NSString*name;
	UIImage*image;
}
@property (nonatomic,strong) NSString*name;
@property (nonatomic,strong) UIImage*image;

-(openhabImage*)initWithName:(NSString*)theName;
-(openhabImage*)initWithData:(NSData*)theData andName:(NSString*)theName;
-(openhabImage*)initWithImage:(UIImage*)theImage andName:(NSString*)theName;
@end
