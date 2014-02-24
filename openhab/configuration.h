//
//  configuracion.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 25/11/11.
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

@interface configuration : NSObject

+ (NSObject*)readPlist:(NSString*)dato;
+ (void)writeToPlist:(NSString*)dato valor:(NSObject*)value;
@end
