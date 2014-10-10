#include <substrate.h>

#import <notify.h>
#import <libobjcipc/objcipc.h>
#import <QuartzCore/QuartzCore.h>

@interface SBStatusBarStateAggregator {
    NSString *_timeItemTimeString;
}
- (void)_updateTimeItems;
- (void)_resetTimeItemFormatter;
@end

@interface SpringBoard
- (void)updateStepCount;
-(void)relaunchSpringBoard;
@end

@interface SBLockScreenView
- (void)setCustomSlideToUnlockText:(id)unlockText;
- (void)shakeSlideToUnlockTextWithCustomText:(id)customText;
@end

@interface AADeviceInfo
+ (id)udid;
@end
