//
//  BibTexParser.h
//  DBLP Tool
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The TMTBibTexParser can be used to parse the content of a bib file for cite entries.
 
 @warning **Note:** The parsing works scanner based so all internal methods have to be called in a sensefull order. The content is parsed sequential.
 
 */
@interface TMTBibTexParser : NSObject {
    /** The scanner used to parse the content */
    NSScanner *scanner;
    
    NSMutableDictionary *strings;
    NSUInteger lastScanLocation;
}

/**
 Initiates the parsing process for the given content and returns an array of TMTBibTexEntry objects.
 @param content the content of a bib file
 @return an array containing all entries found in the given content.
 
 @see TMTBibTexEntry
 */
- (NSMutableArray *)parseBibTexIn:(NSString *)content;

@end
