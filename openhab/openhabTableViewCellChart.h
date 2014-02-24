//
//  openhabTableViewCellChart.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 06/09/12.
//
//

#import "openhabTableViewCell.h"
#import "openhab.h"

@interface openhabTableViewCellChart : openhabTableViewCell
{
	__weak IBOutlet UIImageView*bigImage;
}
@property (nonatomic,weak) IBOutlet UIImageView*bigImage;
@property (nonatomic,weak)NSTimer*theTimer;
@end
