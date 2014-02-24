//
//  openhabTableViewCellWebView.h
//  openhab
//
//  Created by Pablo Romeu Guallart on 30/08/12.
//
//

#import "openhabTableViewCell.h"

@interface openhabTableViewCellWebView : openhabTableViewCell <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *theWebView;
@property (nonatomic) BOOL loaded;

@end
