//
//  MessageCollection.h
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TrackingMessage;

/**
 A container for sets of tracking messages which seperates the messages by their message type.
 
 Instances of this class are used to easy pass a set of messages through the application.
 
 **Author:** Tobias Mende
 
 */
@interface MessageCollection : NSObject

/** The error messages */
@property NSMutableSet *errorMessages;

/** The warning messages */
@property NSMutableSet *warningMessages;

/** The info messages */
@property NSMutableSet *infoMessages;

/** The debug messages */
@property NSMutableSet *debugMessages;


/**
 Method for merging a given collection into the subsets of the left collection.
 
 @param other the message collection to merge in.
 
 @return self unioned with the others collections subsets.
 */
- (MessageCollection *) merge:(MessageCollection *) other;

/**
 Adds a message to the appropriate subset.
 
 @param message the message to add
 
 */
- (void) addMessage:(TrackingMessage*)message;

/**
 Just another method for adding a message to the appropriate subset. Just used to make this object feel like a real collection in cocoa
 
 @param message the message to add
 
 */
- (void) addObject:(TrackingMessage*)message;

@end
