//
//  Parser.h
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageCollection;
@interface Parser : NSObject {
    
}

/**
 Parses the file for a given document and returns a set of TrackingMessages
 
 @param the document to check
 
 @return a set of messages
 */
- (MessageCollection *)parseDocument:(NSString *)path;

- (MessageCollection *)parseOutput:(NSString*) output withBaseDir:(NSString*)base;
- (BOOL) infoValid:(NSString*)info;
- (NSString*)absolutPath:(NSString*)path withBaseDir:(NSString*)base;
@end
