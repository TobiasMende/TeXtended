//
//  LacheckParser.h
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DocumentModel;

@interface LacheckParser : NSObject

/**
 Parses the file for a given document and returns a set of TrackingMessages
 
 @param the document to check
 
 @return a set of messages
 */
- (NSSet *)parseDocument:(NSString*)path;

@end
