//
//  Stepper
//  StepperApp.mm
//
//  Created by Timm Kandziora on 24.08.14.
//  Copyright (c) 2014 Timm Kandziora (shinvou). All rights reserved.
//

#import <libobjcipc/objcipc.h>
#import <CoreMotion/CMStepCounter.h>

@interface StepperApp: UIApplication <UIApplicationDelegate> {
    int mode;
}
@end

@implementation StepperApp

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    TKNote(@"[StepperApp] I did finish launching.");
    
    [OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:@"WeWantNewSteps" handler:^NSDictionary *(NSDictionary *message) {
        mode = [[message objectForKey:@"mode"] intValue];
        [self getSteps];
        
        return nil;
    }];
}

- (void)getSteps
{
	if ([CMStepCounter isStepCountingAvailable]) {
		CMStepCounter *stepCounter = [[CMStepCounter alloc] init];

        [stepCounter queryStepCountStartingFrom:[self getNSDateForMode:mode] to:[NSDate date] toQueue:[NSOperationQueue mainQueue] withHandler:^(NSInteger numberOfSteps, NSError *error) {
			NSDictionary *dictionary = [[NSDictionary alloc] init];

			if (error == nil) {
				dictionary = @{
                               @"success" : [NSNumber numberWithBool:YES],
                               @"steps" : [NSNumber numberWithInt:numberOfSteps]
                };
                
				TKNote(@"[StepperApp] Successfully fetched motion data for mode %d: %ld steps.", mode, (long)numberOfSteps);
			} else {
				dictionary = @{
                               @"success" : [NSNumber numberWithBool:NO],
                               @"error" : error};
                
				TKNote(@"[StepperApp] Error while fetching motion data.");
			}

			[self replyWith:dictionary];
		}];
    } else {
		TKNote(@"[StepperApp] Unable to fetch motion data. Step counting is not available.");
	}
}

- (NSDate *)getNSDateForMode:(int)givenMode
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *dayStart = [calendar dateFromComponents:components];
    
    if (givenMode == 1) {
        NSDate *date = [dayStart dateByAddingTimeInterval:-1*24*60*60];
        return date;
    } else if (givenMode == 2) {
        NSDate *date = [dayStart dateByAddingTimeInterval:-2*24*60*60];
        return date;
    } else if (givenMode == 3) {
        NSDate *date = [dayStart dateByAddingTimeInterval:-3*24*60*60];
        return date;
    } else if (givenMode == 4) {
        NSDate *date = [dayStart dateByAddingTimeInterval:-4*24*60*60];
        return date;
    } else if (givenMode == 5) {
        NSDate *date = [dayStart dateByAddingTimeInterval:-5*24*60*60];
        return date;
    } else if (givenMode == 6) {
        NSDate *date = [dayStart dateByAddingTimeInterval:-6*24*60*60];
        return date;
    } else if (givenMode == 7) {
        NSDate *date = [dayStart dateByAddingTimeInterval:-7*24*60*60];
        return date;
    } else {
        return dayStart;
    }
}

- (void)replyWith:(NSDictionary *)dictionary
{
    [OBJCIPC sendMessageToSpringBoardWithMessageName:@"YouGetNewSteps" dictionary:dictionary replyHandler:^(NSDictionary *response) {
        TKNote(@"[StepperApp] Steps sent to SpringBoard.");
    }];
}

@end
