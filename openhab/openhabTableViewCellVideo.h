//
//  openhabTableViewCellVideo.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 05/09/12.
//
//

#import "openhabTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>

@interface openhabTableViewCellVideo : openhabTableViewCell
@property (strong, nonatomic) MPMoviePlayerController *player;
@property (nonatomic) BOOL loaded;
@end
