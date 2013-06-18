//
//  MessageCollection.h
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TrackingMessage;
@interface MessageCollection : NSObject
@property NSMutableSet *errorMessages;
@property NSMutableSet *warningMessages;
@property NSMutableSet *infoMessages;
@property NSMutableSet *debugMessages;

- (MessageCollection *) merge:(MessageCollection *) other;
- (void) addMessage:(TrackingMessage*)message;
- (void) addObject:(TrackingMessage*)message;

@end
