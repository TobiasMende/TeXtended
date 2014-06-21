//
//  Parser.h
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Abstract class describing an interface for parser objects which use some custom techniques for getting additional information for a given latex document.
 
 **Author:** Tobias Mende
 
 */
@interface Parser : NSObject
    {
        void (^completionHandler)(NSArray *messages);
    }

    @property NSArray *messages;

/**
 * Parses the file for a given document and returns a set of TrackingMessages
 *
 * @param path the document to check
 * @param completionHandler a block to execute with the found messages after completing the parsing process.
 */
    - (void)parseDocument:(NSString *)path callbackBlock:(void (^)(NSArray *messages))completionHandler;

/**
 * Parses the given document content for the document specified by path
 *
 * @param content the content to extract messages from
 * @param path the path from which to get the base dir.
 */
    - (NSArray *)parseContent:(NSString *)content forDocument:(NSString *)path;

/**
 * Method for parsing the output of any internal syntac checker or log file parser
 *
 * @param output the checkers output
 * @param base the base dir from where the checker was executed (needed to extend relative paths in the output)
 * @return a message collection, containing all found messages lower or equal to the current log level.
 */
    - (NSArray *)parseOutput:(NSString *)output withBaseDir:(NSString *)base;

/**
 * Method for checking whether the given info string is a valid message and should be added to a trackin message or not.
 *
 * @warning This method is only used by subclasses for checking whether a message should be added to the message collection or not.
 *
 * @param info the info message
 * @return `YES` if the message should be added, `NO`otherwise.
 * @see TrackingMessage
 */
    - (BOOL)infoValid:(NSString *)info;

/**
 * Generate the absolut path for a path and a baseDir.
 *
 * @param path of the document
 * @param base the basedir of the document
 *
 * @return the absolut path to the document
 */
    - (NSString *)absolutPath:(NSString *)path withBaseDir:(NSString *)base;

    - (void)terminate;
@end
