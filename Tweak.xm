//
//  Stepper
//  Tweak.xm
//
//  Created by Timm Kandziora on 24.08.14.
//  Copyright (c) 2014 Timm Kandziora (shinvou). All rights reserved.
//

#import "Stepper-Header.h"

static UILabel *label = nil;
static SBLockScreenView *lv =  nil;

static BOOL launched = NO;
static BOOL showLabel = YES;
static BOOL showSlider = YES;
static BOOL showStatusBar = YES;
static BOOL isPlaying = NO;

static int mode = 0;

static int xcoordinate = 5;
static int ycoordinate = 110;
static int bubbleradius = 55;
static int textColor = 3;
static int bubbleColor = 0;
static int textSize = 17;

static NSString *stepCount = @"";
static NSString *refreshInterval = @"300.0";
static NSString *originalDateFormat = @"";
static NSString *statusbarSeperator = @"|";

static void HideIcon()
{
	void* libHandle = dlopen("/usr/lib/hide.dylib", RTLD_LAZY);

	if (libHandle != NULL) {
		BOOL (*HideIcon)(NSString *) = (BOOL (*)(NSString *))dlsym(libHandle, "HideIconViaDisplayId");

		if (HideIcon != NULL) {
			HideIcon(@"com.shinvou.stepperapp");
		}

		dlclose(libHandle);
	}

	notify_post("com.libhide.hiddeniconschanged");
}

static void SetStatusBarText()
{
	if (showStatusBar) {
		SBStatusBarStateAggregator *statusBarStateAggregator = [%c(SBStatusBarStateAggregator) sharedInstance];
		NSDateFormatter *dateFormatter = MSHookIvar<NSDateFormatter *>(statusBarStateAggregator, "_timeItemDateFormatter");

		if (!launched) {
			originalDateFormat = [dateFormatter dateFormat];
			launched = YES;
		}

		[dateFormatter setDateFormat:[NSString stringWithFormat:@"%@ %@ %@", originalDateFormat, statusbarSeperator, stepCount]];

		[statusBarStateAggregator _updateTimeItems];
	}
}

static void UpdateStepCountOnStatusBar()
{
	[[%c(SBStatusBarStateAggregator) sharedInstance] _resetTimeItemFormatter];
}

// fuck switch statements :P
static UIColor* getColorForNumber(int number)
{
	if (number == 0) {
		return [UIColor blackColor];
	} else if (number == 1) {
		return [UIColor darkGrayColor];
	} else if (number == 2) {
		return [UIColor lightGrayColor];
	} else if (number == 3) {
		return [UIColor whiteColor];
	} else if (number == 4) {
		return [UIColor grayColor];
	} else if (number == 5) {
		return [UIColor redColor];
	} else if (number == 6) {
		return [UIColor greenColor];
	} else if (number == 7) {
		return [UIColor blueColor];
	} else if (number == 8) {
		return [UIColor cyanColor];
	} else if (number == 9) {
		return [UIColor yellowColor];
	} else if (number == 10) {
		return [UIColor magentaColor];
	} else if (number == 11) {
		return [UIColor orangeColor];
	} else if (number == 12) {
		return [UIColor purpleColor];
	} else {
		return [UIColor brownColor];
	}
}

static void ReloadSettings()
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.shinvou.stepper.plist"];

	if (settings) {
		if ([settings objectForKey:@"showLabel"]) {
			showLabel = [[settings objectForKey:@"showLabel"] boolValue];
		}

		if ([settings objectForKey:@"showSlider"]) {
			showSlider = [[settings objectForKey:@"showSlider"] boolValue];
		}

		if ([settings objectForKey:@"showStatusBar"]) {
			BOOL tempCheck = [[settings objectForKey:@"showStatusBar"] boolValue];

			if (!tempCheck && showStatusBar) {
				showStatusBar = NO;

				SBStatusBarStateAggregator *sbagg = [%c(SBStatusBarStateAggregator) sharedInstance];
				NSDateFormatter *dateFormatter = MSHookIvar<NSDateFormatter *>(sbagg, "_timeItemDateFormatter");

				[dateFormatter setDateFormat:[NSString stringWithFormat:@"%@", originalDateFormat]];

				[sbagg _updateTimeItems];
			} else if (tempCheck && !showStatusBar) {
				showStatusBar = YES;
				SetStatusBarText();
			}
		}

		if ([settings objectForKey:@"refreshInterval"]) {
			if (![refreshInterval isEqualToString:[settings objectForKey:@"refreshInterval"]]) {
				refreshInterval = [settings objectForKey:@"refreshInterval"];
				SpringBoard *springboard = (SpringBoard *)[%c(SpringBoard) sharedApplication];
				[springboard relaunchSpringBoard];
			}
		}

		if ([settings objectForKey:@"timeInterval"]) {
			mode = [[settings objectForKey:@"timeInterval"] intValue];
		}

		if ([settings objectForKey:@"statusbarSeperator"]) {
			statusbarSeperator = [settings objectForKey:@"statusbarSeperator"];
			[[%c(SBStatusBarStateAggregator) sharedInstance] _resetTimeItemFormatter];
		}

		if ([settings objectForKey:@"x"]) {
			xcoordinate = [[settings objectForKey:@"x"] intValue];
			label = nil;
		}

		if ([settings objectForKey:@"y"]) {
			ycoordinate = [[settings objectForKey:@"y"] intValue];
			label = nil;
		}

		if ([settings objectForKey:@"bubbleRadius"]) {
			bubbleradius = [[settings objectForKey:@"bubbleRadius"] intValue];
			label = nil;
		}

		if ([settings objectForKey:@"textColor"]) {
			textColor = [[settings objectForKey:@"textColor"] intValue];
			label = nil;
		}

		if ([settings objectForKey:@"bubbleColor"]) {
			bubbleColor = [[settings objectForKey:@"bubbleColor"] intValue];
			label = nil;
		}

		if ([settings objectForKey:@"textSize"]) {
			textSize = [[settings objectForKey:@"textSize"] intValue];
			label = nil;
		}
	}
}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application
{
	%orig;

	[OBJCIPC registerIncomingMessageHandlerForAppWithIdentifier:@"com.shinvou.stepperapp" andMessageName:@"YouGetNewSteps" handler:^NSDictionary *(NSDictionary *reply) {
		if ([reply[@"success"] boolValue]) {
			stepCount = reply[@"steps"];
			label.text = [NSString stringWithFormat:@"%@", stepCount];
			UpdateStepCountOnStatusBar();
			if (showSlider) {
				[lv setCustomSlideToUnlockText:[NSString stringWithFormat:@"%@ steps", stepCount]];
			}
		}

		return nil;
	}];

	[self updateStepCount];
	[NSTimer scheduledTimerWithTimeInterval:[refreshInterval floatValue] target:self selector:@selector(updateStepCount) userInfo:nil repeats:YES];
}

%new - (void)updateStepCount
{
	NSDictionary *dictionary = @{
		@"mode" : [NSNumber numberWithInt:mode]
	};


	TKNote(@"[StepperTweak] I'm updating the step count, so I'm sending a message to the app.");
	[OBJCIPC sendMessageToAppWithIdentifier:@"com.shinvou.stepperapp" messageName:@"WeWantNewSteps" dictionary:dictionary replyHandler:nil];
}

%end

%hook SBLockScreenView

- (void)setCustomSlideToUnlockText:(id)unlockText
{
	lv = self;

	if (showSlider) {
		unlockText = [NSString stringWithFormat:@"%@ steps", stepCount];
		%orig(unlockText);
	} else {
		%orig(unlockText);
	}
}

- (void)shakeSlideToUnlockTextWithCustomText:(id)customText
{
	if (showSlider) {
		customText = [NSString stringWithFormat:@"%@ steps", stepCount];
		%orig(customText);
	} else {
		%orig(customText);
	}
}

- (void)layoutSubviews
{
	if (!isPlaying) {
		if (showLabel) {
			UIView *view = MSHookIvar<UIView *>(self,"_notificationView");

			if (!label) {
				label = [[UILabel alloc] initWithFrame:CGRectMake(xcoordinate, ycoordinate, bubbleradius, bubbleradius)];
				label.numberOfLines = 1;
				label.textAlignment = NSTextAlignmentCenter;
				label.textColor = getColorForNumber(textColor);
				label.backgroundColor = getColorForNumber(bubbleColor);
				label.clipsToBounds = YES;
				label.layer.cornerRadius = bubbleradius / 2.0;
				label.tag = 1337;
			}

			if (![label superview] || [label superview] != view) {
				[view addSubview:label];
			}

			label.text = [NSString stringWithFormat:@"%@", stepCount];
			label.font = [UIFont systemFontOfSize:textSize];
		}
	}

	%orig;
}

%end

%hook SBStatusBarStateAggregator

- (void)_resetTimeItemFormatter
{
	%orig;

	if (showStatusBar) {
		SetStatusBarText();
	}
}

%end

%hook SBApplication

- (void)setNowPlayingWithAudio:(BOOL)audio
{
	%orig;

	if (audio) {
		isPlaying = YES;

		UIView *notificationView = MSHookIvar<UIView *>(lv,"_notificationView");

		UILabel *lockscreenLabel = (UILabel *)[notificationView viewWithTag:1337];
		[lockscreenLabel removeFromSuperview];
	} else {
		isPlaying = NO;
	}
}

%end

%ctor {
	@autoreleasepool {
			HideIcon();

			ReloadSettings();

			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReloadSettings, CFSTR("com.shinvou.stepper/reloadSettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
}
