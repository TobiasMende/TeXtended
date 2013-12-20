//
//  TMTNotificationCenter.m
//  TeXtended
//
//  Created by Tobias Mende on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTNotificationCenter.h"
#import "Compilable.h"
#import <TMTHelperCollection/TMTLog.h>

static NSMutableDictionary *mainCompilableCenters;
static NSMutableArray *prohibitedKeys;
static NSUInteger pkIdx;
static const NSUInteger MAX_QUEUE_SIZE = 50;
@interface TMTNotificationCenter ()
+ (NSString*)keyForCompilable:(Compilable*)compilable;

@end

@implementation TMTNotificationCenter

+ (void)initialize {
    if (self == [TMTNotificationCenter class]) {
        mainCompilableCenters = [NSMutableDictionary new];
        prohibitedKeys = [[NSMutableArray alloc] initWithCapacity:MAX_QUEUE_SIZE];
        pkIdx = 0;
    }
}

+ (NSNotificationCenter*)centerForCompilable:(Compilable *)compilable {
    NSString *key = [self keyForCompilable:compilable];
    NSNotificationCenter *center = mainCompilableCenters[key];
    if (!center && ![prohibitedKeys containsObject:key]) {
        center = [NSNotificationCenter new];
        mainCompilableCenters[key] = center;
        DDLogVerbose(@"Creating new center for %@", key);
    }
    return center;
}

+ (void)removeCenterForCompilable:(Compilable *)compilable {
    [mainCompilableCenters removeObjectForKey:compilable.identifier];
    [prohibitedKeys setObject:compilable.identifier atIndexedSubscript:pkIdx];
    pkIdx = (pkIdx + 1) % MAX_QUEUE_SIZE;
    DDLogVerbose(@"Deleting center for %@", compilable.identifier);
}

+ (NSString *)keyForCompilable:(Compilable *)compilable {
    return [compilable.mainCompilable identifier];
}



@end
