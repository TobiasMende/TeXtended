//
//  Publication.h
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A DBLPPublication represents a single BibTex entry. It is initalized with a valid DBLP URL to the entry to represent.
 Instances of this object asynchronous load all information after initialization.
 
 The DBLPPublication stores different representations of an entry:
 * The original DBLP XML
 * An extended BibTex Version
 * direct access to
    * authors
    * title
    * mdate
    * publication type (type)
    * cite key (key)
 

 **Author:** Tobias Mende
 
 */
@interface TMTBibTexEntry : NSObject<NSURLConnectionDataDelegate> {
    /** The data received from the url provided on initialization */
    NSMutableData *receivedData;
}
/**
 Initializes the publication object by starting asynchronous fetching of bib informations from the DBLP server.
 Due to asynchronous fetching, all informations in the new object may be not available directly after initialization.
 
 @param url the url to the DBLP entry
 
 @return a new DBLPPublication
 */
- (id) initWithXMLUrl:(NSURL*)url;

/** The original DBLP XML */
@property NSXMLNode *xml;

/** The cite key */
@property NSString *key;

/** The modification date */
@property NSDate *mdate;

/** The publication type */
@property NSString *type;

@property NSString *author;
@property NSString *title;

/** The generated bibtex entry */
- (NSString*) bibtex;

- (NSComparisonResult)compare:(TMTBibTexEntry *)other;

/** The dictionary representation */
@property NSMutableDictionary *dictionary;
@end
