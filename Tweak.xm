#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SparkAppList.h>
#import "./prefs/libcolorpicker.h"
//ScreenShot Remap
/*#import <IOKit/hid/IOHIDEventSystem.h>
#import <IOKit/hid/IOHIDEventSystemClient.h>

//ScreenShot Remap
@interface UIApplication (HomeGesture)
+(id)sharedApplication;
-(void)takeScreenshot;
@end*/

@interface NSUserDefaults (HomeGesture)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end
//Enable iPX Status Bar
@interface _UIStatusBar
+ (void)setDefaultVisualProviderClass:(Class)classOb;
+ (void)setForceSplit:(BOOL)arg1;
@end
@interface _UIStatusBarVisualProvider_iOS : NSObject
+ (CGSize)intrinsicContentSizeForOrientation:(NSInteger)orientation;
@end
//ScreenShot Remap
/*OBJC_EXTERN IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);

//ScreenShot Remap
#define kIOHIDEventUsageHome 64
#define kIOHIDEventUsagePower 48

void ioEventHandler(void *target, void *refcon, IOHIDEventQueueRef queue, IOHIDEventRef event) {
    static BOOL homePressed = NO;
    static BOOL powerPressed = NO;

    if (IOHIDEventGetType(event) == kIOHIDEventTypeKeyboard) {
        int keyDown = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardDown);
        int button = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsage);
        switch (button) {
            case kIOHIDEventUsageHome:
               homePressed = keyDown;
                break;
            case kIOHIDEventUsagePower:
                powerPressed = keyDown;
                break;
            default:
                break;
        }
        if (homePressed && powerPressed) {
                [[UIApplication sharedApplication] takeScreenshot];
        }
    }
}

static IOHIDEventSystemClientRef ioHIDClient;
static CFRunLoopRef ioHIDRunLoopScedule;*/


static NSString *nsDomainString = @"/var/mobile/Library/Preferences/com.midnight.homegesture.plist";
static NSString *nsNotificationString = @"com.midnight.homegesture.plist/post";


static BOOL hideCarrier;
static BOOL enableBar;
static BOOL enableBarCover;
static BOOL unlockHint;
static BOOL notificationHint;
static BOOL allowBread;
static BOOL hideTorch;
static BOOL hideCamera;
static BOOL stopKeyboard;
static BOOL disableGestures;
static BOOL hideDots;
static BOOL enableBlacklist;
static BOOL enablePillColor;
static BOOL enableKill;
//Prefs
static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber *noCarrier = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"hidecarrier" inDomain:nsDomainString];
	NSNumber *noBar = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"hideBar" inDomain:nsDomainString];
	NSNumber *noBarCover = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"hideBarCover" inDomain:nsDomainString];
	NSNumber *uHint = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"unlockHint" inDomain:nsDomainString];
	NSNumber *nHint = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"notificationHint" inDomain:nsDomainString];
	NSNumber *bread = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enableBread" inDomain:nsDomainString];
	NSNumber *hTorch = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"hideTorch" inDomain:nsDomainString];
	NSNumber *hCamera = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"hideCamera" inDomain:nsDomainString];
	NSNumber *stKeyboard = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"stopKeyboard" inDomain:nsDomainString];
	NSNumber *noGest = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"disableGestures" inDomain:nsDomainString];
	NSNumber *hDots = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"hideDots" inDomain:nsDomainString];
	NSNumber *eBlacklist = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enableBlacklist" inDomain:nsDomainString];
	NSNumber *pColor = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enablePillColor" inDomain:nsDomainString];
	NSNumber *eKill = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enableKill" inDomain:nsDomainString];

	hideCarrier = (noCarrier)? [noCarrier boolValue]:NO;
	enableBar = (noBar)? [noBar boolValue]:NO;
	enableBarCover = (noBarCover)? [noBarCover boolValue]:NO;
	unlockHint = (uHint)? [uHint boolValue]:NO;
	notificationHint = (nHint)? [nHint boolValue]:NO;
	allowBread = (bread)? [bread boolValue]:NO;
	hideTorch = (hTorch)? [hTorch boolValue]:NO;
	hideCamera = (hCamera)? [hCamera boolValue]:NO;
	stopKeyboard = (stKeyboard)? [stKeyboard boolValue]:NO;
	disableGestures = (noGest)? [noGest boolValue]:NO;
	hideDots = (hDots)? [hDots boolValue]:NO;
	enableBlacklist = (eBlacklist)? [eBlacklist boolValue]:NO;
	enablePillColor = (pColor)? [pColor boolValue]:NO;
	enableKill = (eKill)? [eKill boolValue]:YES;

}
/*static NSDictionary *prefs;
static NSString *selectedApp1; //Applist stuff
static NSMutableArray *test;
static void loadPrefs() {
NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.midnight.homegestureapplist.plist"];
selectedApp1 = [prefs objectForKey:@"selected"]; //Setting up variables
test = [prefs objectForKey:@"selected"];

}*/


long _dismissalSlidingMode = 0;
bool originalButton;
long _homeButtonType = 1;

//static NSInteger switcherKillStyle = 1;
// Enable home gestures
%hook BSPlatform
- (NSInteger)homeButtonType {
	_homeButtonType = %orig;
	if (originalButton) {
		originalButton = NO;
		return %orig;
	} else {
		return 2;
	}
}
%end

// Remove carrier text
%hook UIStatusBarServiceItemView
//PreferencesValue(@"hidecarrier", NO);
- (id)_serviceContentsImage {
	if (hideCarrier){
		return nil;
		}else{
			return %orig;
		}
	}
- (CGFloat)extraRightPadding {
	if (hideCarrier){
		return 0.0f;
		}else{
			return %orig;
		}
	}
- (CGFloat)standardPadding {
	if (hideCarrier){
		return 2.0f;
		}else{
			return %orig;
	}
}
%end

@interface MTLumaDodgePillView : UIView
@end
// Hide home bar
static BOOL homeEnable = YES;
static BOOL rotateDisable = YES;
%hook MTLumaDodgePillView
- (id)initWithFrame:(struct CGRect)arg1 {
	if (enableBar){
		return %orig;
		}else{
			return NULL;
		}
}
/*-(void)setBackgroundColor:(UIColor*)arg1
{

     %orig([UIColor redColor]);
}*/
%end




// Workaround for TouchID respring bug
%hook SBCoverSheetSlidingViewController
- (void)_finishTransitionToPresented:(_Bool)arg1 animated:(_Bool)arg2 withCompletion:(id)arg3 {
	if ((_dismissalSlidingMode != 1) && (arg1 == 0)) {
		return;
	} else {
		%orig;
	}
}
- (long long)dismissalSlidingMode {
	_dismissalSlidingMode = %orig;
	return %orig;
}
%end

// Workaround for status bar transition bug
%hook CCUIOverlayStatusBarPresentationProvider
- (void)_addHeaderContentTransformAnimationToBatch:(id)arg1 transitionState:(id)arg2 {
	return;
}
%end
// Prevent status bar from flashing when invoking control center
%hook CCUIModularControlCenterOverlayViewController
- (void)setOverlayStatusBarHidden:(bool)arg1 {
	return;
}
%end
// Prevent status bar from displaying in fullscreen when invoking control center
%hook CCUIStatusBarStyleSnapshot
- (bool)isHidden {
	return NO;
}
%end
//Hide Control Center NavBar
%hook CCUIHeaderPocketView
- (BOOL)isHIdden {
    return YES;
}


%end

// Hide home bar in cover sheet
@interface SBDashboardHomeAffordanceView : UIView
@end
%hook SBDashboardHomeAffordanceView
- (void)_createStaticHomeAffordance {
	if (enableBarCover){
		return %orig;
		}else{
			return;
		}
}
%end

// Restore footer indicators
%hook SBDashBoardViewController
- (void)viewDidLoad {
	originalButton = YES;
	%orig;
}
%end

// Restore button to invoke Siri
%hook SBLockHardwareButtonActions
- (id)initWithHomeButtonType:(long long)arg1 proximitySensorManager:(id)arg2 {
	return %orig(_homeButtonType, arg2);
}
%end
%hook SBHomeHardwareButtonActions
- (id)initWitHomeButtonType:(long long)arg1 {
	return %orig(_homeButtonType);
}
%end

// Hide notification hints
%hook NCNotificationListSectionRevealHintView
- (void)_updateHintTitle {
	if(notificationHint){
		%orig;
	}else{
		return;
	}
}
%end

// Hide unlock hints
%hook SBDashBoardTeachableMomentsContainerViewController
- (void)_updateTextLabel {
	if(unlockHint){
		%orig;
	}else{
		return;
	}
}
%end

// Disable breadcrumb
%hook SBWorkspaceDefaults
- (bool)isBreadcrumbDisabled {
	if (allowBread){
		return NO;
	}else{
		return YES;
	}
}
%end
//AppSwitcher
%hook SBAppSwitcherSettings
- (NSInteger)effectiveKillAffordanceStyle {
	if(enableKill){
		return 2;
	}else{
		return %orig;
	}

}
- (NSInteger)killAffordanceStyle {
	if(enableKill){
		return 2;
	}else{
		return %orig;
	}
}
- (void)setKillAffordanceStyle:(NSInteger)style {
	if(enableKill){
		%orig(2);
	}else{
		%orig;
	}
}
%end

// Hide Control Center indicator
%hook SBDashBoardTeachableMomentsContainerView
-(void)_addControlCenterGrabber {}
%end

//Hide Camera and Torch



%hook SBDashBoardQuickActionsViewController
-(BOOL)hasFlashlight{
	if(hideTorch){
		return NO;
		}else{
			return %orig;
		}
}
-(BOOL)hasCamera{
	if(hideCamera){
		return NO;
	}else{
		return %orig;
	}
}
%end



%hook SBHomeGestureSettings
-(BOOL)isHomeGestureEnabled{
	if(!disableGestures){
		if(homeEnable && rotateDisable){
			return YES;
		}else{
			return NO;
		}
	}else{
		return NO;
	}
}
%end

static NSString *test;


%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
	%orig;

	if(stopKeyboard){
		[[NSNotificationCenter defaultCenter] addObserver:self
                                         		selector:@selector(keyboardDidShow:)
                                             		name:UIKeyboardDidShowNotification
                                           		object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(keyboardDidHide:)
                                             name:UIKeyboardDidHideNotification
                                           object:nil];
			}
		//if(stopRotate)


		if (enableBlacklist){
			[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
			[[NSNotificationCenter defaultCenter]
   		addObserver:self selector:@selector(yourMethod:)
   		name:UIDeviceOrientationDidChangeNotification
   		object:[UIDevice currentDevice]];
		}
}
%new
-(void)keyboardDidShow:(NSNotification *)sender
{
    homeEnable = NO;

}

%new
-(void)keyboardDidHide:(NSNotification *)sender
{
    homeEnable = YES;
}

%new
-(void)yourMethod:(NSNotification *)sender {
    UIDevice *currentDevice = sender.object;
    if(currentDevice.orientation == UIDeviceOrientationPortrait) {
			rotateDisable = YES;
    }
		if(currentDevice.orientation == UIDeviceOrientationLandscapeLeft) {
			SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
			SBApplication *frontApp = (SBApplication *)[springBoard _accessibilityFrontMostApplication];
			test = [frontApp valueForKey:@"_bundleIdentifier"];
			if([SparkAppList doesIdentifier:@"com.midnight.homegesture.plist" andKey:@"excludedApps" containBundleIdentifier:test]){
			rotateDisable = NO;
			}
		}
		if(currentDevice.orientation == UIDeviceOrientationLandscapeRight) {
			SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
			SBApplication *frontApp = (SBApplication *)[springBoard _accessibilityFrontMostApplication];
			test = [frontApp valueForKey:@"_bundleIdentifier"];
			if([SparkAppList doesIdentifier:@"com.midnight.homegesture.plist" andKey:@"excludedApps" containBundleIdentifier:test]){
			rotateDisable = NO;
			}
		}
		if(currentDevice.orientation == UIDeviceOrientationPortraitUpsideDown) {
			rotateDisable = YES;
		}
}
%end

@interface SBDashBoardPageControl : UIView
@end

%hook SBDashBoardPageControl
-(id)_pageIndicatorColor{
	if (hideDots){
		return [UIColor clearColor];
	}else{
		return %orig;
	}
}
-(id)_currentPageIndicatorColor{
	if (hideDots){
		return [UIColor clearColor];
	}else{
		return %orig;
	}
}
%end



//Lock Screen HomeBar Color
@interface MTStaticColorPillView : UIView
@end

static NSMutableDictionary *coloursettings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.midnight.homegesture.plist"];

%hook MTStaticColorPillView
-(UIColor *)pillColor {
	if(enablePillColor){
		return LCPParseColorString([coloursettings objectForKey:@"customColour"], @"#FF0000");
	}else {
		return %orig;
	}
}

-(void)setPillColor:(UIColor *)pillColor {
	if(enablePillColor){
		pillColor = LCPParseColorString([coloursettings objectForKey:@"customColour"], @"#FF0000");
		%orig(pillColor);
	}else {
		%orig;
	}

}
%end
/*%hook MTLumaDodgePillSettings
-(void)setColorAddWhiteness:(double)arg1{
	arg1 = 15;
	%orig(arg1);
}
%end */


//Keep this, fixes scrolling in CC
/*%hook UIScrollView
- (UIEdgeInsets)adjustedContentInset {
	UIEdgeInsets orig = %orig;
	//orig.top = 88;
	orig.top = 0;
	return orig;
}
%end*/

%ctor{
  notificationCallback(NULL, NULL, NULL, NULL, NULL);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
    NULL,
    notificationCallback,
    (CFStringRef)nsNotificationString,
    NULL,
    CFNotificationSuspensionBehaviorCoalesce);


		/*ioHIDClient = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
		    ioHIDRunLoopScedule = CFRunLoopGetMain();
		    IOHIDEventSystemClientScheduleWithRunLoop(ioHIDClient, ioHIDRunLoopScedule, kCFRunLoopDefaultMode);
		    IOHIDEventSystemClientRegisterEventCallback(ioHIDClient, ioEventHandler, NULL, NULL);*/
	}

	/*%dtor {
    IOHIDEventSystemClientUnregisterEventCallback(ioHIDClient);
    IOHIDEventSystemClientUnscheduleWithRunLoop(ioHIDClient, ioHIDRunLoopScedule, kCFRunLoopDefaultMode);
}*/