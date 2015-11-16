#include "LAListener.h"

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
@end

static SBMainDisplaySceneManager *currentSceneManager = nil;

%hook SBMainDisplaySceneManager
- (_Bool)_shouldBreadcrumbApplication:(id)arg1 withTransitionContext:(id)arg2 { 
	// So this is the importatnt piece. 
	// However, the destination for the scene manager does not change
 	// even when there is no breadcrumb
 	// there is also always a destination, even when there is no breadcrumb
 	// I reset the variable, just in case it gets released somehow, but
 	// this scenemanager is pretty consistant
	currentSceneManager = %orig ? self : nil;
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

%hook SBUIController
- (void)activateApplication:(id)arg1 {
	%log;
	%orig;
}
%end

@implementation SlideBackActivator
- (void)activator:(id)activator receiveEvent:(id)event {
	if(currentSceneManager) {

		HBLogDebug(@"SBMainStatusBarStateProvider = %@", [%c(SBMainStatusBarStateProvider) sharedInstance]);
		// The breadcrumb view is not in UIStatusBar view because it is actually in a UIStatusBarForegroundView
		// and then inside a UIStatusBarBreadcrumbItemView
		// can't see this while hooking SpringBoard and I don't want to hook UIKit. Am I doing this wrong?
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
	    			currentSceneManager = nil;
	    			[[%c(SpringBoard) sharedApplication] launchApplicationWithIdentifier:displayID suspended:NO];
	    			[event setHandled:YES];
	    			return;
	    		} else if ([currentSceneManager.currentBreadcrumbNavigationAction URLForDestination:0]) {
	    			HBLogDebug(@"it is a url");
	    			currentSceneManager = nil;
	    			[[%c(SpringBoard) sharedApplication] openURL:[currentSceneManager.currentBreadcrumbNavigationAction URLForDestination:0]];
	    			[event setHandled:YES];
	    			return;
	    		}
	    	}
		}
	}
	[event setHandled: NO];
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

    id la = [%c(LAActivator) sharedInstance];
    if ([la respondsToSelector:@selector(hasSeenListenerWithName:)] && [la respondsToSelector:@selector(assignEvent:toListenerWithName:)]) {
        if (![la hasSeenListenerWithName:@"org.thebigboss.homemadebread"]) {
            [la assignEvent:[%c(LAEvent) eventWithName:@"libactivator.menu.press.single"] toListenerWithName:@"org.thebigboss.homemadebread"];
        }
    }

    // register our listener. do this after the above so it still hasn't "seen" us if this is first launch
    [(LAActivator*)[%c(LAActivator) sharedInstance] registerListener:listener forName:@"org.thebigboss.homemadebread"]; // can also be done in +load https://github.com/nickfrey/NowNow/blob/master/Tweak.xm#L31
}