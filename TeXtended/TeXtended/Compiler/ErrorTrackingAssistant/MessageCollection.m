//
//  MessageCollection.m
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MessageCollection.h"
#import "TrackingMessage.h"

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

- (MessageCollection *)merge:(MessageCollection *)other {
    MessageCollection *col = [self copy];
    [col.errorMessages unionSet:other.errorMessages];
    [col.warningMessages unionSet:other.warningMessages];
    [col.infoMessages unionSet:other.infoMessages];
    [col.debugMessages unionSet:other.debugMessages];
    return col;
}

                                     
- (MessageCollection *)copy {
    MessageCollection *col = [MessageCollection new];
    col.debugMessages = self.debugMessages;
    col.infoMessages = self.infoMessages;
    col.warningMessages = self.warningMessages;
    col.errorMessages = self.errorMessages;
    return col;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithFormat:@"errors(%li) = %@\n",self.errorMessages.count, self.errorMessages];
    [string appendFormat:@"warnings(%li) = %@\n", self.warningMessages.count, self.warningMessages];
    [string appendFormat:@"infos(%li) = %@\n", self.infoMessages.count, self.infoMessages];
    [string appendFormat:@"debugs(%li) = %@", self.debugMessages.count, self.debugMessages];
    return string;
}

@end
