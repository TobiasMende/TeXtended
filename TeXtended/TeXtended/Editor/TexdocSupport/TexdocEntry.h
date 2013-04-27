//
//  TexdocEntry.h
//  TeXtended
//
//  Created by Tobias Mende on 23.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Container for a single line provided by the texdoc command
 
 
 **Author:** Tobias Mende
 
 */
@interface TexdocEntry : NSObject
/** The description of the entry of the file name if description is empty */
@property (strong) NSString *description;
/** The rank score of this entry (float) */
@property (strong) NSNumber *score;

/** The path to the file */
@property (strong) NSString *path;

/**
 Initializes a new TexdocEntry by transforming an array of string into correct datatypes.
 
 @param texdoc an array of strings containing a single texdoc entry
 
 @return self
 */
- (id) initWithArray:(NSArray *) texdoc;

/**
 Method for getting the file name (depends on [TexdocEntry path])
 
 @return the file name
 */
- (NSString *)fileName;

/**
 Returns the file icon (depends on [TexdocEntry path])
 
 @return a meaningfull file icon
 */
- (NSImage*) fileIcon;
@end
