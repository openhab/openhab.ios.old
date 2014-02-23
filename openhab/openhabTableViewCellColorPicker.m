//
//  openhabTableViewCellColorPicker.m
//  openhab
//
//  Created by Pablo Mª Romeu Guallart on 02/04/13.
//
//

#import "openhabTableViewCellColorPicker.h"


@interface openhabTableViewCellColorPicker ()
@property (strong,nonatomic) NSTimer*updateTimer;
@end

@implementation openhabTableViewCellColorPicker
@synthesize lastTableView,widget,updateTimer;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//	_colorPicker = [[RSColorPickerView alloc] initWithFrame:CGRectMake(10.0, 20.0, 300.0, 300.0)];
//    [_colorPicker setCropToCircle:YES]; // Defaults to YES (and you can set BG color)
	[_colorPicker setDelegate:self];
	[_colorPicker setSelectionColor:[self HueToColor:self.widget.item.state]];
	//[self.view addSubview:_colorPicker];
	
    // View that controls brightness
//	_brightnessSlider = [[RSBrightnessSlider alloc] initWithFrame:CGRectMake(10, 340.0, 300 , 30.0)];
	[_brightnessSlider setColorPicker:_colorPicker];
	//[self.view addSubview:_brightnessSlider];
	

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.widget=nil;
	self.lastTableView=nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	[updateTimer invalidate];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}
#pragma mark transform
-(NSString*)colorToOpenhabHUE:(UIColor*)theColor
{
	//- (BOOL)getHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha
	CGFloat hue,saturation,brightness,alpha;
	[theColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
	hue=360*hue;
	saturation*=100;
	brightness*=100;
	NSString *result=[NSString stringWithFormat:@"%ld,%ld,%ld",lround(hue),lround(saturation),lround(brightness)];
	return result;
}

-(UIColor*)HueToColor:(NSString*)theColor
{
	CGFloat hue,saturation,brightness;
	NSArray*comp=[theColor componentsSeparatedByString:@","];
	hue=[[comp objectAtIndex:0] intValue];
	saturation=[[comp objectAtIndex:1] intValue];
	brightness=[[comp objectAtIndex:2] intValue];
	hue=hue/360;
	saturation=saturation/100;
	brightness=brightness/100;
	UIColor *result=[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
	return result;
}

#pragma mark changed color
-(void)colorPickerDidChangeSelection:(RSColorPickerView *)cp
{
	//self.colorPatch.backgroundColor = [cp selectionColor];
	//self.view.backgroundColor=[cp selectionColor];
    self.brightnessSlider.value = [cp brightness];
//	NSString*res=[self colorToOpenhabHUE:[cp selectionColor]];
	//NSLog(@"Color changed to %@",res);
	if (!updateTimer)
	{
		updateTimer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sendUpdate) userInfo:nil repeats:NO];
	}
}

-(void)sendUpdate
{
	NSLog(@"Sent update");
	NSString*res=[self colorToOpenhabHUE:[_colorPicker selectionColor]];
	[[openhab sharedOpenHAB] changeValueofItem:self.widget.item toValue:res];
	updateTimer=nil;
}
@end
