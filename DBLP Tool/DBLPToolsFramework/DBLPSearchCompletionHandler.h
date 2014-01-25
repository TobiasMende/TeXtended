//
//  DBLPSearchCompletionHandler.h
//  DBLP Tool
//
//  Created by Tobias Mende on 19.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TMTBibTexEntry;

/**
 This protocol defines methods which can be used by handlers of the search view controller.
 
 
 @see DBLPSearchViewController
 **Author:** Tobias Mende
 */
@protocol DBLPSearchCompletionHandler <NSObject>

@optional

/**
 Tells the delegate to execute the given entry with respect to the given file path (e.g. the users wants to insert the entry into the file
 
 @param citation the entry to do something for
 @param path the file path of the bib file
 */
- (void)executeCitation:(TMTBibTexEntry *)citation forBibFile:(NSString *)path;

/**
 The search was aborted (e.g. by the user)
 */
- (void)dblpSearchAborted;
@end
