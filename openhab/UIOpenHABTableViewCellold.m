//
//  UIOpenHABTableViewCell.m
//  SML CES System
//
//  Created by Pablo Romeu Guallart on 20/09/11.
//  Copyright (c) 2011 spaphone. All rights reserved.
//

#import "UIOpenHABTableViewCell.h"

@implementation UIOpenHABTableViewCell
@synthesize tipo,label,icon,value,item,widgets,interruptor,elstepper,delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)changeValue:(id)sender
{
    if ([self.tipo isEqualToString:@"Switch"] )
    {
        // Cambiar valor del switch. modificaEstado lo cambiará en el item
        NSLog(@"El switch esta %i",[self.interruptor isOn]);
        if (![self.item.estado isEqualToString:@"ON"])
        {
            [self.item modificaEstado:@"ON"];
        }
        else
        {
            [self.item modificaEstado:@"OFF"];
        }
    }
    if ([self.tipo isEqualToString:@"Slider"] )
    {
        // Cambiar valor del switch
        NSString* i=[NSString stringWithFormat:@"%d",(int)self.elstepper.value];
        self.value.text = i;
        NSLog(@"Stepper %@",i);
        [self.item modificaEstado:i];
    }
    // Hay que esperar porque sino openhab no le da tiempo a refrescar
	[NSTimer scheduledTimerWithTimeInterval:1 target:self.delegate selector:@selector(actualizaTabla) userInfo:nil repeats:NO];
}

-(void)rellenaCelda:(openhabWidget*)widget
{
    self.label.text=widget.label;
    self.tipo=widget.tipo;
    
    // comprobamos si tiene item
    if (widget.item!=nil)
    {
		self.item=widget.item;
        
        // Poner el estado si no es indefinido
        
        NSRange loc=[widget.item.estado rangeOfString:@"Undefined"];
        if (loc.location==NSNotFound)
        {
            if (widget.data)
                self.value.text=widget.data;
            else
                self.value.text=nil;
            
        }
        else
        {
            self.value.text=nil;
        }
        
        // ponemos el valor al switch
        if ([self.tipo isEqualToString:@"Switch"])
        {
            if ([widget.item.estado rangeOfString:@"ON"].location!=NSNotFound)
            {
                [self.interruptor setOn:YES];
            }
            else
            {
                [self.interruptor setOn:NO];
            }
        }
                 
    }
    
  
	if (widget.widgets!=nil)
	{
		self.widgets=widget.widgets;
	}
	else
    {
		self.widgets=nil;
    }
    
    if (widget.icon == nil)
    {

        self.icon.image=[UIImage imageNamed:@"switch.png"];
    }
    else
    {
        self.icon.image=[UIImage imageNamed:[widget.icon stringByAppendingString:@".png"]];
    }
}


@end
