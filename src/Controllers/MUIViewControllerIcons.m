//
//  MUIViewControllerIcons.m
//  wordPuzzle
//
//  Created by Michael Thomason on 6/5/12.
//  Copyright (c) 2014 Michael Thomason. All rights reserved.
//

#import "MUIViewControllerIcons.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Wordflick.h"

@interface MUIViewControllerIcons ()

@end

@implementation MUIViewControllerIcons
@synthesize icon512;
@synthesize icon57;
@synthesize icon114;
@synthesize icon72;
@synthesize icon144;
@synthesize icon29;
@synthesize icon58;
@synthesize icon50;
@synthesize icon100;
@synthesize icon16;
@synthesize icon64;
@synthesize icon96;
@synthesize icon128;
@synthesize scrollViewIcons;
@synthesize logoInGame;
@synthesize icon1024;

@synthesize icon40, icon80;
@synthesize icon60, icon120;
@synthesize icon76, icon152;


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[[self scrollViewIcons] setContentSize:CGSizeMake(3000.0000f, 3000.0000f)];

	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	UIColor *c = [[UIColor purpleColor] retain];
	[[self view] setBackgroundColor:[UIColor blackColor]];
	[[[self labelClassroom] layer] setCornerRadius:5.0000f];
	//UIColor *borderColor = [UIColor darkGrayColor];
	//CGFloat frameSizeFactor = 0.0666f;
	/*
	[[self icon57] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon57] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon57] layer] setBorderWidth:[[self icon57] frame].size.width * frameSizeFactor];
	
	[[self icon114] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon114] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon114] layer] setBorderWidth:[[self icon114] frame].size.width * frameSizeFactor];

	[[self icon72] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon72] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon72] layer] setBorderWidth:[[self icon72] frame].size.width * frameSizeFactor];

	[[self icon144] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon144] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon144] layer] setBorderWidth:[[self icon144] frame].size.width * frameSizeFactor];

	[[self icon512] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon512] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon512] layer] setBorderWidth:[[self icon512] frame].size.width * frameSizeFactor];

	[[self icon1024] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon1024] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon1024] layer] setBorderWidth:[[self icon1024] frame].size.width * frameSizeFactor];

	[[self icon29] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon29] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon29] layer] setBorderWidth:[[self icon29] frame].size.width * frameSizeFactor];

	[[self icon58] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon58] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon58] layer] setBorderWidth:[[self icon58] frame].size.width * frameSizeFactor];
	
	[[self icon50] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon50] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon50] layer] setBorderWidth:[[self icon50] frame].size.width * frameSizeFactor];

	[[self icon100] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon100] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon100] layer] setBorderWidth:[[self icon100] frame].size.width * frameSizeFactor];

	[[self icon16] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon16] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon16] layer] setBorderWidth:[[self icon16] frame].size.width * frameSizeFactor];

	[[self icon64] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon64] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon64] layer] setBorderWidth:[[self icon64] frame].size.width * frameSizeFactor];
	
	[[self icon96] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon96] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon96] layer] setBorderWidth:[[self icon96] frame].size.width * frameSizeFactor];

	[[self icon128] setBackgroundColor:[UIColor everydayBlue]];
	//[[[self icon128] layer] setBorderColor:[borderColor CGColor]];
	//[[[self icon128] layer] setBorderWidth:[[self icon72] frame].size.width * frameSizeFactor];
*/
	[c release];

	//NSString *testPath = [@"/Desktop/WordflickIcons/Icon-72.png" stringByExpandingTildeInPath];
	UIImage *imIcon57 = [MUIViewControllerIcons imageWithView:[self icon57]];
	NSData *imageData57 = UIImagePNGRepresentation(imIcon57);
	[imageData57 writeToFile:[@"/tmp/Icon.png" stringByExpandingTildeInPath] atomically:YES];
	
	UIImage *imIcon114 = [MUIViewControllerIcons imageWithView:[self icon114]];
	NSData *imageData114 = UIImagePNGRepresentation(imIcon114);
	[imageData114 writeToFile:[@"/tmp/Icon@2x.png" stringByExpandingTildeInPath] atomically:YES];
	
	UIImage *imIcon72 = [MUIViewControllerIcons imageWithView:[self icon72]];
	NSData *imageData72 = UIImagePNGRepresentation(imIcon72);
	[imageData72 writeToFile:[@"/tmp/Icon-72.png" stringByExpandingTildeInPath] atomically:YES];

	UIImage *imIcon144 = [MUIViewControllerIcons imageWithView:[self icon144]];
	NSData *imageData144 = UIImagePNGRepresentation(imIcon144);
	[imageData144 writeToFile:[@"/tmp/Icon-72@2x.png" stringByExpandingTildeInPath] atomically:YES];

	UIImage *imIcon512 = [MUIViewControllerIcons imageWithView:[self icon512]];
	NSData *imageData512 = UIImagePNGRepresentation(imIcon512);
	[imageData512 writeToFile:[@"/tmp/Icon-AppStore.png" stringByExpandingTildeInPath] atomically:YES];
	
	UIImage *imIcon1024 = [MUIViewControllerIcons imageWithView:[self icon1024]];
	NSData *imageData1024 = UIImagePNGRepresentation(imIcon1024);
	NSString *s = [@"/tmp/Icon-AppStore@2x.png" stringByExpandingTildeInPath];
	[imageData1024 writeToFile:s atomically:YES];

	UIImage *imIcon29 = [MUIViewControllerIcons imageWithView:[self icon29]];
	NSData *imageData29 = UIImagePNGRepresentation(imIcon29);
	[imageData29 writeToFile:[@"/tmp/Icon-Small.png" stringByExpandingTildeInPath] atomically:YES];
	
	UIImage *imIcon58 = [MUIViewControllerIcons imageWithView:[self icon58]];
	NSData *imageData58 = UIImagePNGRepresentation(imIcon58);
	[imageData58 writeToFile:[@"/tmp/Icon-Small@2x.png" stringByExpandingTildeInPath] atomically:YES];
	
	UIImage *imIcon50 = [MUIViewControllerIcons imageWithView:[self icon50]];
	NSData *imageData50 = UIImagePNGRepresentation(imIcon50);
	[imageData50 writeToFile:[@"/tmp/Icon-Small-50.png" stringByExpandingTildeInPath] atomically:YES];
	
	UIImage *imIcon100 = [MUIViewControllerIcons imageWithView:[self icon100]];
	NSData *imageData100 = UIImagePNGRepresentation(imIcon100);
	[imageData100 writeToFile:[@"/tmp/Icon-Small-50@2x.png" stringByExpandingTildeInPath] atomically:YES];


	UIImage *imIcon76 = [MUIViewControllerIcons imageWithView:[self icon76]];
	NSData *imageData76 = UIImagePNGRepresentation(imIcon76);
	[imageData76 writeToFile:[@"/tmp/Icon-76.png" stringByExpandingTildeInPath] atomically:YES];
	
	UIImage *imIcon152 = [MUIViewControllerIcons imageWithView:[self icon152]];
	NSData *imageData152 = UIImagePNGRepresentation(imIcon152);
	[imageData152 writeToFile:[@"/tmp/Icon-76@2x.png" stringByExpandingTildeInPath] atomically:YES];

	UIImage *imIcon60 = [MUIViewControllerIcons imageWithView:[self icon60]];
	NSData *imageData60 = UIImagePNGRepresentation(imIcon60);
	[imageData60 writeToFile:[@"/tmp/Icon-60.png" stringByExpandingTildeInPath] atomically:YES];
	
	UIImage *imIcon120 = [MUIViewControllerIcons imageWithView:[self icon120]];
	NSData *imageData120 = UIImagePNGRepresentation(imIcon120);
	[imageData120 writeToFile:[@"/tmp/Icon-60@2x.png" stringByExpandingTildeInPath] atomically:YES];
	
	UIImage *imIcon40 = [MUIViewControllerIcons imageWithView:[self icon40]];
	NSData *imageData40 = UIImagePNGRepresentation(imIcon40);
	[imageData40 writeToFile:[@"/tmp/Icon-40.png" stringByExpandingTildeInPath] atomically:YES];

	UIImage *imIcon80 = [MUIViewControllerIcons imageWithView:[self icon80]];
	NSData *imageData80 = UIImagePNGRepresentation(imIcon80);
	[imageData80 writeToFile:[@"/tmp/Icon-40@2x.png" stringByExpandingTildeInPath] atomically:YES];
	
	UIImage *imIcon16 = [MUIViewControllerIcons imageWithView:[self icon16]];
	NSData *imageData16 = UIImagePNGRepresentation(imIcon16);
	[imageData16 writeToFile:[@"/tmp/Icon-16.png" stringByExpandingTildeInPath] atomically:YES];
	
	UIImage *imIcon64 = [MUIViewControllerIcons imageWithView:[self icon64]];
	NSData *imageData64 = UIImagePNGRepresentation(imIcon64);
	[imageData64 writeToFile:[@"/tmp/Icon-64.png" stringByExpandingTildeInPath] atomically:YES];
	
	UIImage *imIcon96 = [MUIViewControllerIcons imageWithView:[self icon96]];
	NSData *imageData96 = UIImagePNGRepresentation(imIcon96);
	[imageData96 writeToFile:[@"/tmp/Icon-96.png" stringByExpandingTildeInPath] atomically:YES];

	UIImage *imIcon128 = [MUIViewControllerIcons imageWithView:[self icon128]];
	NSData *imageData128 = UIImagePNGRepresentation(imIcon128);
	[imageData128 writeToFile:[@"/tmp/Icon-128.png" stringByExpandingTildeInPath] atomically:YES];

	UIImage *imLogoInGame = [MUIViewControllerIcons imageWithView:[self logoInGame]];
	NSData *imageLogoInGame = UIImagePNGRepresentation(imLogoInGame);
	[imageLogoInGame writeToFile:[@"/tmp/Icon-ingamelogo.png" stringByExpandingTildeInPath] atomically:YES];

}

+ (UIImage *)imageWithView:(UIView *)view {
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (void)dealloc {
	[icon512 release];
	[icon57 release];
	[icon114 release];
	[icon72 release];
	[icon144 release];
	[icon29 release];
	[icon58 release];
	[icon50 release];
	[icon100 release];
	[icon1024 release];
	[scrollViewIcons release];
	[icon16 release];
	[icon64 release];
	[icon96 release];
	[icon128 release];
	[logoInGame release];
	[_labelClassroom release];
	[super dealloc];
}
@end
