//
//  TMTNotificationCenter.m
//  TeXtended
//
//  Created by Tobias Mende on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTNotificationCenter.h"
#import "Compilable.h"
#import "TMTLog.h"

static NSMutableDictionary *mainCompilableCenters;

@interface TMTNotificationCenter ()
+ (NSString*)keyForCompilable:(Compilable*)compilable;

@end

@implementation TMTNotificationCenter

+ (void)initialize {
    if (self == [TMTNotificationCenter class]) {
        mainCompilableCenters = [NSMutableDictionary new];
    }
}

+ (NSNotificationCenter*)centerForCompilable:(Compilable *)compilable {
    NSString *key = [self keyForCompilable:compilable];
    NSNotificationCenter *center = [mainCompilableCenters objectForKey:key];
    if (!center) {
        center = [NSNotificationCenter new];
        [mainCompilableCenters setObject:center forKey:key];
        DDLogWarn(@"Creating new center for %@", key);
    }
    return center;
}

+ (void)removeCenterForCompilable:(Compilable *)compilable {
    [mainCompilableCenters removeObjectForKey:[self keyForCompilable:compilable]];
}

+ (NSString *)keyForCompilable:(Compilable *)compilable {
    return [compilable.mainCompilable dictionaryKey];
}



@end
