//
//  MessageCollection.m
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MessageCollection.h"
#import "TrackingMessage.h"
#import "Constants.h"


@implementation MessageCollection
- (id)init {
    self = [super init];
    if (self) {
        _errorMessages = [NSMutableSet new];
        _warningMessages = [NSMutableSet new];
        _infoMessages = [NSMutableSet new];
        _debugMessages = [NSMutableSet new];
    }
    return self;
}

- (void)addMessage:(TrackingMessage *)message {
    switch (message.type) {
        case TMTErrorMessage:
            [self.errorMessages addObject:message];
            break;
        case TMTWarningMessage:
            [self.warningMessages addObject:message];
            break;
        case TMTInfoMessage:
            [self.infoMessages addObject:message];
            break;
        case TMTDebugMessage:
            [self.debugMessages addObject:message];
            break;
        default:
            break;
    }
}

- (void)addObject:(TrackingMessage *)message {
    [self addMessage:message];
}

- (MessageCollection *)merged:(MessageCollection *)other {
    MessageCollection *col = [self copy];
    [col.errorMessages unionSet:other.errorMessages];
    [col.warningMessages unionSet:other.warningMessages];
    [col.infoMessages unionSet:other.infoMessages];
    [col.debugMessages unionSet:other.debugMessages];
    return col;
}

- (void)merge:(MessageCollection *)other {
    [self willChangeValueForKey:@"errorMessages"];
    [self.errorMessages unionSet:other.errorMessages];
    [self didChangeValueForKey:@"errorMessages"];
    [self willChangeValueForKey:@"warningMessages"];
    [self.warningMessages unionSet:other.warningMessages];
    [self didChangeValueForKey:@"warningMessages"];
    [self willChangeValueForKey:@"infoMessages"];
    [self.infoMessages unionSet:other.infoMessages];
    [self didChangeValueForKey:@"infoMessages"];
    [self willChangeValueForKey:@"debugMessages"];
    [self.debugMessages unionSet:other.debugMessages];
    [self didChangeValueForKey:@"debugMessages"];
}
                                     
- (MessageCollection *)copy {
    MessageCollection *col = [MessageCollection new];
    col.debugMessages = [self.debugMessages mutableCopy];
    col.infoMessages = [self.infoMessages mutableCopy];
    col.warningMessages = [self.warningMessages mutableCopy];
    col.errorMessages = [self.errorMessages mutableCopy];
    return col;
}

- (MessageCollection *)messagesForDocument:(NSString *)path {
    MessageCollection *subset = [MessageCollection new];
    
    for (TrackingMessage *message in self.set) {
        if ([message.document isEqualToString:path]) {
            [subset addMessage:message];
        }
    }
    return subset;
}

- (NSSet *)set {
    NSMutableSet *set = [NSMutableSet setWithSet:self.errorMessages];
    [set unionSet:self.warningMessages];
    [set unionSet:self.infoMessages];
    [set unionSet:self.debugMessages];
    return set;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithFormat:@"errors(%li) = %@\n",self.errorMessages.count, self.errorMessages];
    [string appendFormat:@"warnings(%li) = %@\n", self.warningMessages.count, self.warningMessages];
    [string appendFormat:@"infos(%li) = %@\n", self.infoMessages.count, self.infoMessages];
    [string appendFormat:@"debugs(%li) = %@", self.debugMessages.count, self.debugMessages];
    return string;
}

- (NSUInteger)count {
    return self.errorMessages.count + self.warningMessages.count + self.debugMessages.count + self.infoMessages.count;
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"set"] || [key isEqualToString:@"count"]) {
        keys = [keys setByAddingObjectsFromArray:@[@"errorMessages", @"warningMessages", @"infoMessages", @"debugMessages"]];
    }
    return keys;
}


- (void)adaptToLevel:(TMTLatexLogLevel)level {
    if (level < ALL) {
        self.debugMessages = [NSMutableSet new];
    }
    if (level < INFO) {
        self.infoMessages = [NSMutableSet new];
    }
    if (level < WARNING) {
        self.warningMessages = [NSMutableSet new];
    }
    if (level < ERROR) {
        self.errorMessages = [NSMutableSet new];
    }
}

@end
