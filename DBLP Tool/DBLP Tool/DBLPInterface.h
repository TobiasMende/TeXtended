//
//  DBLPHandler.h
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBLPCallbackHandler.h"

/**
 This class provides an interface to a DBLP database and handles search requests for authors and bib entries.
 
 **Author:** Tobias Mende
 
 */
@interface DBLPInterface : NSObject<NSURLConnectionDataDelegate, NSXMLParserDelegate> {
    NSString *dblpUrl;
    NSString *authorSearchAppendix;
    NSString *keySearchAppendix;
    NSString *bibtexSearchAppendix;
    NSMutableData *receivedAuthorData;
    NSMutableData *receivedKeyData;
    NSURLConnection *authorConnection;
    NSURLConnection *dblpKeyConnection;
}
- (id) initWithHandler:(id<DBLPCallbackHandler>)handler;
- (void) searchAuthor:(NSString*) query;
- (void) publicationsForAuthor:(NSString*) urlpt;

@property id<DBLPCallbackHandler> handler;

@end
