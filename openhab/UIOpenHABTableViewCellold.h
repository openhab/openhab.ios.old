//
//  UIOpenHABTableViewCell.h
//  SML CES System
//
//  Created by Pablo Romeu Guallart on 20/09/11.
//  Copyright (c) 2011 spaphone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "openhabWidget.h"
#import "openhabItem.h"


@protocol UIOpenHABCellProtocol;
@interface UIOpenHABTableViewCell : UITableViewCell
{
    NSString* tipo;
	openhabItem* item;
	NSMutableArray* widgets;
    __weak IBOutlet UILabel* label;
    __weak IBOutlet UIImageView* icon;
    __weak IBOutlet UILabel* value;
    __weak IBOutlet UISwitch* interruptor;
    __weak IBOutlet UIStepper* elstepper;
	__weak IBOutlet id <UIOpenHABCellProtocol> delegate;

}

@property (nonatomic,strong) NSString* tipo;
@property (nonatomic,strong) openhabItem*item;
@property (nonatomic,strong) NSMutableArray*widgets;
@property (nonatomic,weak) id <UIOpenHABCellProtocol> delegate;
@property (nonatomic,weak) UILabel*label;
@property (nonatomic,weak) UILabel*value;
@property (nonatomic,weak) UIImageView* icon;
@property (nonatomic,weak) UISwitch* interruptor;
@property (nonatomic,weak) UIStepper* elstepper;

-(IBAction)changeValue:(id)sender;
-(void)rellenaCelda:(openhabWidget*)widget;

@end

@protocol UIOpenHABCellProtocol

-(void)actualizaTabla;

@end