//
//  configuracion.m
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

#import "configuration.h"

@implementation configuration

+ (NSString*)inicializaPlist
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
	else
	{
		// Update non existing settings
		
		// Get the old one
		NSMutableDictionary *diccionarioAntiguo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
		
		// Get the new one
		
		NSURL *bundle = [[NSBundle mainBundle] URLForResource:@"data" withExtension:@"plist"];
		NSData *tmp = [NSData dataWithContentsOfURL:bundle options:NSDataReadingMappedIfSafe error:nil];
		NSDictionary *diccionarioNuevo = [NSPropertyListSerialization propertyListWithData:tmp options:NSPropertyListImmutable format:nil error:nil];
		
		NSMutableArray *newKeys=[[diccionarioNuevo allKeys] mutableCopy];
		[newKeys removeObjectsInArray:[diccionarioAntiguo allKeys]];
		
		for (NSString*key in newKeys) {
			[diccionarioAntiguo setObject:[diccionarioNuevo objectForKey:key] forKey:key];

		}
		[diccionarioAntiguo writeToFile:path atomically:YES];
	}
    return path;
}

+ (NSObject*)readPlist:(NSString*)dato
{
    
    NSMutableDictionary *diccionario = [[NSMutableDictionary alloc] initWithContentsOfFile: [configuration inicializaPlist]];
    
    NSObject* value = [[diccionario objectForKey:dato]copy];
    //NSLog(@"Leido %@",value);
    return value;
}

+ (void)writeToPlist:(NSString*)dato valor:(NSObject*)value
{
    NSString*path=[self inicializaPlist];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    //here add elements to data file and write data to file
    [data setObject:value forKey:dato];
    [data writeToFile: path atomically:YES];
}

#pragma mark - update things

+ (void)updateSettings
{
    // Update non existing settings
    // HACER: ACTUALIZAR RECURSIVAMENTE
    // Get the old one
    
    NSString*path=[configuration inicializaPlist];
    NSMutableDictionary *diccionarioAntiguo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    // Get the new one
    
    NSURL *bundle = [[NSBundle mainBundle] URLForResource:@"data" withExtension:@"plist"];
    NSData *tmp = [NSData dataWithContentsOfURL:bundle options:NSDataReadingMappedIfSafe error:nil];
    NSDictionary *diccionarioNuevo = [NSPropertyListSerialization propertyListWithData:tmp options:NSPropertyListImmutable format:nil error:nil];
    
    NSLog(@"Diccionario antiguo %@, Diccionario nuevo %@",diccionarioAntiguo,diccionarioNuevo);
    [diccionarioAntiguo setDictionary:diccionarioNuevo];
    [diccionarioAntiguo writeToFile:path atomically:YES];
}

+ (BOOL)shouldUpdate
{
    NSString*path=[configuration inicializaPlist];
    NSMutableDictionary *diccionarioAntiguo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSString*version=[diccionarioAntiguo objectForKey:@"dictVersion"];
    
    NSURL *bundle = [[NSBundle mainBundle] URLForResource:@"data" withExtension:@"plist"];
    NSData *tmp = [NSData dataWithContentsOfURL:bundle options:NSDataReadingMappedIfSafe error:nil];
    NSDictionary *diccionarioNuevo = [NSPropertyListSerialization propertyListWithData:tmp options:NSPropertyListImmutable format:nil error:nil];
    NSString*theNewversion=[diccionarioNuevo objectForKey:@"dictVersion"];
    return ![theNewversion isEqualToString:version];
}

@end
