#include "LAListener.h"
#include "substrate.h"

@interface UISystemNavigationAction
- (id)destinations;
- (int)UIActionType;
- (id)titleForDestination:(unsigned int)arg1;
- (id)bundleIdForDestination:(unsigned int)arg1;
- (id)URLForDestination:(unsigned int)arg1;
@end

@interface UISystemNavigationActionDestinationContext
- (id)debugDescription;
@end

@interface SBMainDisplaySceneManager
@property(retain, nonatomic) UISystemNavigationAction *currentBreadcrumbNavigationAction;
- (void)_presentSpotlightFromEdge:(unsigned long long)arg1 fromBreadcrumb:(_Bool)arg2;
@end

@interface SBWorkspaceApplication
@property(retain, nonatomic) id application; // @synthesize application=_application;
@end


static SBMainDisplaySceneManager *currentSceneManager = nil;
static NSArray *whitelist = @[@"com.apple.mobilesms.compose", @"com.apple.MailCompositionService"];

%hook SBMainDisplaySceneManager
- (_Bool)_shouldBreadcrumbApplication:(SBWorkspaceApplication *)arg1 withTransitionContext:(id)arg2 { 
	// returns false for a mail/sms composer view controller 
	// so need to still save the breadcrumb anyways
	// if someone can show me when this "app" is launched and it
	// is not for a view controller, please let me know
	if(currentSceneManager) {
		if([whitelist containsObject:[arg1.application bundleIdentifier]]) { 
			HBLogDebug(@"Still gonna save, cause just presenting the mail composer");
			currentSceneManager = self;
		} else {
			currentSceneManager = nil;
		}
	}
	
	// So this is the importatnt piece. 
	// However, the destination for the scene manager does not change
 	// even when there is no breadcrumb
 	// there is also always a destination, even when there is no breadcrumb
 	// I reset the variable, just in case it gets released somehow, but
 	// this scenemanager is pretty consistant
	currentSceneManager = %orig ? self : currentSceneManager;
	return %orig;
}
- (_Bool)_isActivatingPinnedBreadcrumbApp:(id)arg1 withTransitionContext:(id)arg2 {
	%log;
	return %orig;
}
- (id)_breadcrumbNavigationActionForApplication:(id)arg1 withTransitionContext:(id)arg2{
	%log;
	return %orig;
}
- (void)_activateAppLink:(id)arg1 withAppLinkState:(id)arg2 transitionContext:(id)arg3 wasFromSpotlight:(_Bool)arg4 previousBreadcrumb:(id)arg5 {
	%log;
	%orig;
}
- (void)_activateBreadcrumbApplication:(id)arg1 {
	%log;
	%orig;
}
- (id)_breadcrumbBundleIdForApplication:(id)arg1 withTransitionContext:(id)arg2 {
	%log;
	return %orig;
}
- (void)_presentSpotlightFromEdge:(unsigned long long)arg1 fromBreadcrumb:(_Bool)arg2 {
	%log;
	%orig;
}
- (void)_deviceOrientationChanged:(id)arg1 {
	%log;
	%orig;
}
- (void)_application:(id)arg1 initiatedChangefromInterfaceOrientation:(long long)arg2 toInterfaceOrientation:(long long)arg3 scene:(id)arg4 sceneSettings:(id)arg5 transitionContext:(id)arg6 {
	%log;
	%orig;
}
- (id)_rotationAnimationSettingsForRotationFromInterfaceOrientation:(long long)arg1 toInterfaceOrientation:(long long)arg2 medusaSettings:(id)arg3 {
	%log;
	return %orig;
}
- (_Bool)_handleAction:(id)arg1 forScene:(id)arg2 {
	%log;
	return %orig;
}
- (id)_applicationForAppLink:(id)arg1 {
	%log;
	return %orig;
}

%end

@interface SBUIController
- (void)activateApplication:(id)arg1;
@end

@interface SBIconController
- (_Bool)presentSpotlightFromEdge:(unsigned long long)arg1 fromBreadcrumb:(_Bool)arg2 animated:(_Bool)arg3;
- (_Bool)_presentTopEdgeSpotlight:(_Bool)arg1;
@end

%hook UIStatusBarBreadcrumbItemView
- (void)userDidActivateButton:(id)arg1 {
	%log;
	%orig;
}
%end

%hook UIStatusBarSystemNavigationItemView
- (void)userDidActivateButton:(id)arg1 {
	%log;
	%orig;
}
- (void)setButton:(id)arg1 {
	%log;
	%orig;
}
%end

%hook UIStatusBarServer
+ (void)addStatusBarItem:(int)arg1 {
	%log;
	%orig;
}
+ (void)removeStatusBarItem:(int)arg1 {
	%log;
	%orig;
}
%end
@interface UIApplication (extras)
- (id)_systemNavigationAction;
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
- (BOOL)openURL:(id)arg1;
- (id)statusBar;
@end

@interface SBApplication
- (void)activate;
@end

@interface SBApplicationController
+ (SBApplicationController *)sharedInstance;
- (id)applicationWithBundleIdentifier:(id)arg1;
@end

@interface SlideBackActivator : NSObject <LAListener>
@end

@interface UIView (extras)
-(id)recursiveDescription;
@end

@interface SBSearchGesture
-(void)revealAnimated:(BOOL)arg1;
@end

%hook SBUIController
- (void)activateApplication:(id)arg1 {
	%log;
	%orig;
}
%end



// struct  customStruct { 
//         BOOL itemIsEnabled[27]; 
//         BOOL timeString[64]; 
//         int gsmSignalStrengthRaw; 
//         int gsmSignalStrengthBars; 
//         BOOL serviceString[100]; 
//         BOOL serviceCrossfadeString[100]; 
//         BOOL serviceImages[2][100]; 
//         BOOL operatorDirectory[1024]; 
//         unsigned int serviceContentType; 
//         int wifiSignalStrengthRaw; 
//         int wifiSignalStrengthBars; 
//         unsigned int dataNetworkType; 
//         int batteryCapacity; 
//         unsigned int batteryState; 
//         BOOL batteryDetailString[150]; 
//         int bluetoothBatteryCapacity; 
//         int thermalColor; 
//         unsigned int thermalSunlightMode : 1; 
//         unsigned int slowActivity : 1; 
//         unsigned int syncActivity : 1; 
//         BOOL activityDisplayId[256]; 
//         unsigned int bluetoothConnected : 1; 
//         unsigned int displayRawGSMSignal : 1; 
//         unsigned int displayRawWifiSignal : 1; 
//         unsigned int locationIconType : 1; 
//         unsigned int quietModeInactive : 1; 
//         unsigned int tetheringConnectionCount; 
//         unsigned int batterySaverModeActive : 1; 
//         BOOL breadcrumbTitle[256];  // I would assume this would be an NSString * but I don't understand why it would be 256
//         BOOL breadcrumbSecondaryTitle[256]; 
//     };

static BOOL tryBreadcrumbLaunch() {
if(currentSceneManager) {

		HBLogDebug(@"SBMainStatusBarStateProvider = %@", [%c(SBMainStatusBarStateProvider) sharedInstance]);
		// The breadcrumb view is not in UIStatusBar view because it is actually in a UIStatusBarForegroundView
		// and then inside a UIStatusBarBreadcrumbItemView
		// can't see this while hooking SpringBoard and I don't want to hook UIKit. Am I doing this wrong?
		// UIStatusBar *statusBar = [[%c(SpringBoard) sharedApplication] statusBar];
		// struct customStruct raw = MSHookIvar<struct customStruct>(statusBar, "_currentRawData");
		// I'd love for someone to figure out this struct
		//HBLogDebug(@"raw Data = %@", (NSString *)raw.breadcrumbTitle);
		//HBLogDebug(@"statusbar = %@", [(UIView *)[[%c(SpringBoard) sharedApplication] statusBar] recursiveDescription]);
 
		HBLogDebug(@"current system navigation action = %@", [[%c(SpringBoard) sharedApplication] _systemNavigationAction]); // why is this always nil?
		//HBLogDebug(@"current scene manger = %@", currentSceneManager)
		HBLogDebug(@"UIActionType = %d", [currentSceneManager.currentBreadcrumbNavigationAction UIActionType]); // 18
		if(currentSceneManager.currentBreadcrumbNavigationAction) {
			HBLogDebug(@"currentBreadcrumbNavigationAction = %@", currentSceneManager.currentBreadcrumbNavigationAction);
			HBLogDebug(@"destinations = %@", currentSceneManager.currentBreadcrumbNavigationAction.destinations);
			for(id dest in currentSceneManager.currentBreadcrumbNavigationAction.destinations) {
				HBLogDebug(@"bundleID for %@: %@", dest, [currentSceneManager.currentBreadcrumbNavigationAction bundleIdForDestination:(int)(NSInteger)dest]);
				HBLogDebug(@"title for %@: %@", dest, [currentSceneManager.currentBreadcrumbNavigationAction titleForDestination:(int)(NSInteger)dest]);
				HBLogDebug(@"url for %@: %@", dest, [currentSceneManager.currentBreadcrumbNavigationAction URLForDestination:(int)(NSInteger)dest]);
			}
			if(currentSceneManager.currentBreadcrumbNavigationAction.destinations && [currentSceneManager.currentBreadcrumbNavigationAction.destinations count]) {
				if([currentSceneManager.currentBreadcrumbNavigationAction bundleIdForDestination:0]) {
					HBLogDebug(@"it is a id");
					NSString *displayID = [currentSceneManager.currentBreadcrumbNavigationAction bundleIdForDestination:0];

					//  SBApplicationController *appController = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
					//  SBApplication *app = [appController applicationWithBundleIdentifier:displayID];
					// // [app activate];
					//  [(SBUIController *)[%c(SBUIController) sharedInstance] activateApplication:app];

					if([displayID isEqualToString:@"com.apple.springboard.spotlight-placeholder"]) {
						// For some reason this doesn't want to display spotlight - even though
						// this is the right call, must be missing something
						[currentSceneManager _presentSpotlightFromEdge:1 fromBreadcrumb:1];
						//[(SBIconController *)[%c(SBIconController) sharedInstance] presentSpotlightFromEdge:1 fromBreadcrumb:1 animated:NO];
						//[(SBIconController *)[%c(SBIconController) sharedInstance] _presentTopEdgeSpotlight:NO];
						//[(SBSearchGesture *)[%c(SBSearchGesture) sharedInstance] revealAnimated:YES];
						currentSceneManager = nil;
						return YES;
					}

					currentSceneManager = nil;
					[[%c(SpringBoard) sharedApplication] launchApplicationWithIdentifier:displayID suspended:NO];
					return YES;
				} else if ([currentSceneManager.currentBreadcrumbNavigationAction URLForDestination:0]) {
					HBLogDebug(@"it is a url");
					currentSceneManager = nil;
					[[%c(SpringBoard) sharedApplication] openURL:[currentSceneManager.currentBreadcrumbNavigationAction URLForDestination:0]];
					return YES;
				}
			}
		}
	}
	return NO;
}

%hook SpringBoard
- (void)_handleMenuButtonEvent {
	%log;
	Class la = objc_getClass("LAActivator");
	if (!la) {
		HBLogDebug(@"Activator not installed so hooking menu button event");
		if(!tryBreadcrumbLaunch()) {
			%orig;
		}
	} else {
		%orig;
	}
}
%end

@implementation SlideBackActivator
- (void)activator:(id)activator receiveEvent:(id)event {
	HBLogDebug(@"launching with activator");
	[event setHandled:tryBreadcrumbLaunch()];
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return @"Homemade Bread";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return @"Breadcrumb-aware home button";
}

- (id)activator:(LAActivator *)activator requiresInfoDictionaryValueOfKey:(NSString *)key forListenerWithName:(NSString *)listenerName {
	if([key isEqualToString:@"receives-raw-events"]) {
		return [NSNumber numberWithBool:YES];
	}
	return [NSNumber numberWithBool:NO];
}

@end




%ctor {
	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);

	static SlideBackActivator *listener = [[SlideBackActivator alloc] init];


	// TODO: put this in the init function
	id la = [%c(LAActivator) sharedInstance];
	if ([la respondsToSelector:@selector(hasSeenListenerWithName:)] && [la respondsToSelector:@selector(assignEvent:toListenerWithName:)]) {
		if (![la hasSeenListenerWithName:@"org.thebigboss.homemadebread"]) {
			[la assignEvent:[%c(LAEvent) eventWithName:@"libactivator.menu.press.single"] toListenerWithName:@"org.thebigboss.homemadebread"];
		}
	}

	// register our listener. do this after the above so it still hasn't "seen" us if this is first launch
	[(LAActivator*)[%c(LAActivator) sharedInstance] registerListener:listener forName:@"org.thebigboss.homemadebread"]; // can also be done in +load https://github.com/nickfrey/NowNow/blob/master/Tweak.xm#L31
}