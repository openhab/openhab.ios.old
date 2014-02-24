//
//  configurationMapViewController.h
//  openhab
//
//  Created by Pablo Mª Romeu Guallart on 31/08/12.
//
//

#import <UIKit/UIKit.h>
#import "openhab.h"

@interface configurationMapViewController : UITableViewController <openHABprotocol>
@property (weak, nonatomic) UITableViewController*lastViewController;
@property (strong,nonatomic) NSString*theField;
@property (strong,nonatomic) NSString*theServer;
@property (strong,nonatomic) NSMutableArray *arrayDetected;
@property (nonatomic) int lastselected;
@end