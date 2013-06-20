//
//  Parser.h
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageCollection;

/**
 Abstract class describing an interface for parser objects which use some custom techniques for getting additional information for a given latex document.
 
 **Author:** Tobias Mende
 
 */
@interface Parser : NSObject {
    
}

/**
 Parses the file for a given document and returns a set of TrackingMessages
 
 @param path the document to check
 
 @return a set of messages
 */
- (MessageCollection *)parseDocument:(NSString *)path;

/**
 Parses the given document content for the document specified by path
 
 @param content the content to extract messages from
 @param path the path from which to get the base dir.
 
 @return a set of messages
 */
- (MessageCollection *)parseContent:(NSString *)content forDocument:(NSString *)path;

/**
 Method for parsing the output of any internal syntac checker or log file parser
 
 @param output the checkers output
 @param base the base dir from where the checker was executed (needed to extend relative paths in the output)
 
 @return a message collection, containing all found messages lower or equal to the current log level.
 */
- (MessageCollection *)parseOutput:(NSString*) output withBaseDir:(NSString*)base;

/**
 Method for checking whether the given info string is a valid message and should be added to a trackin message or not. 
 
 @warning This method is only used by subclasses for checking whether a message should be added to the message collection or not.
 
 @param info the info message
 @return `YES` if the message should be added, `NO`otherwise.
 @see MessageCollection
 @see TrackingMessage
 */
- (BOOL) infoValid:(NSString*)info;
- (NSString*)absolutPath:(NSString*)path withBaseDir:(NSString*)base;
@end
